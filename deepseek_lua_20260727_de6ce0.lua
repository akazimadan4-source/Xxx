-- ============================================
-- LENGER MULTI FARM (STABLE SEQUENTIAL)
-- Hanya logika autofarm yang diubah, UI tetap sama.
-- ============================================

if getgenv().WANZZ_LOADED then return end
getgenv().WANZZ_LOADED = true

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LogService = game:GetService("LogService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local RPC = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("RPC")

-- ============================================
-- ANTI DETEKSI (tetap)
-- ============================================
pcall(function()
    if LogService then LogService:SetLoggingEnabled(false) end
    if LogService then LogService:Clear() end
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("Script") or obj:IsA("LocalScript") then
            local name = obj.Name:lower()
            if name:find("scan") or name:find("anticheat") or name:find("antiban") or name:find("detect") then
                obj.Disabled = true
            end
        end
    end
end)

-- ============================================
-- FALLBACK BUFFER
-- ============================================
local function makeBuffer(data)
    local success, result = pcall(function() return buffer.fromstring(data) end)
    return success and result or data
end

-- ============================================
-- KONFIGURASI (tetap)
-- ============================================
local Configuration = {
    Main_Settings = {
        Autofarming = false,
        AutoAntiDeath = true,
        AutoRejoiner = true,
        EnableCardScam = true,
    },
    Statistics = {
        TimesRejoined = 0,
        Runtime = 0,
        CashMade = 0,
        ChipsFed = 0,
        MarshmallowsSold = 0,
        CardsSwiped = 0,
        CyclesCompleted = 0,
    },
    State = {
        Status = "Idle",
        BikeSitting = false,
        BikeSpawned = false,
        RespawnPending = false,
        Apartment = nil,
        MaskOwned = false,
    },
}

-- ============================================
-- LOKASI (dari Multi Farm)
-- ============================================
local Locations = {
    SafeZone      = Vector3.new(-478.840, 24.000,  389.200),
    HotChipsMan   = Vector3.new( -41.000,  3.000,  -25.000),
    FakeID        = Vector3.new( 214.960,  1.857, -332.330),
    BuyMarsh      = Vector3.new( 512.820,  4.000,  595.580),
    BuyPotato     = Vector3.new(-759.920, -0.025, -195.870),
    ApplyForCard  = Vector3.new( -49.210,  4.000, -310.810),
    CollectCard   = Vector3.new( -39.090,  5.392, -329.700),
    SkiMask       = Vector3.new(-366.980,  0.528, -320.630),
    Healing       = Vector3.new(-769.000,  6.000,  654.000),
    Clipboard     = Vector3.new(-479.230,  5.342, -433.270),
    PotatoCutter  = Vector3.new(-456.320,  1.870, -466.840),
    PlasticBagLab = Vector3.new(-456.280,  1.654, -472.670),
    FlourBowl     = Vector3.new(-494.640,  1.579, -518.580),
}

-- ============================================
-- HELPER FUNCTIONS
-- ============================================
local function GetHumanoid()
    local c = Player.Character
    return c and c:FindFirstChildOfClass("Humanoid")
end

local function EquipTool(tool)
    local h = GetHumanoid()
    if h and tool then pcall(function() h:EquipTool(tool) end) end
end

local function UnequipTools()
    local h = GetHumanoid()
    if h then pcall(function() h:UnequipTools() end) end
end

local Random = Random.new()

local function GetCurrentCashAmount()
    local ok, n = pcall(function()
        local main = PlayerGui:FindFirstChild("Main")
        if main then
            local money = main:FindFirstChild("Money")
            if money then
                local amount = money:FindFirstChild("Amount")
                if amount then
                    return tonumber((amount.Text:gsub("%D+", ""))) or 0
                end
            end
        end
        return 0
    end)
    return (ok and n) or 0
end

local function GetCommaValue(n)
    local s = tostring(math.floor(n))
    while true do
        local result, count = s:gsub("^(-?%d+)(%d%d%d)", "%1,%2")
        s = result
        if count == 0 then break end
    end
    return s
end

local function FormatRuntime(seconds)
    return string.format("%02d:%02d:%02d",
        math.floor(seconds / 3600),
        math.floor((seconds % 3600) / 60),
        seconds % 60
    )
end

local function WaitForReady()
    repeat task.wait() until Configuration.Main_Settings.Autofarming
end

local function CountHotChips()
    local backpack = Player:FindFirstChild("Backpack")
    if not backpack then return 0 end
    local count = 0
    for _, obj in pairs(backpack:GetChildren()) do
        if obj.Name == "Hot Chips" then count = count + 1 end
    end
    return count
end

local function ScavengeInventory()
    UnequipTools()
    local Backpack = Player:FindFirstChild("Backpack")
    if not Backpack then return 0,0,0,0,0 end
    local Potato, Flour, Water, Gelatin, SugarBlockBag = 0,0,0,0,0
    for _, Object in next, Backpack:GetChildren() do
        if Object.Name == "Potato" then Potato = Potato + 1 end
        if Object.Name == "Flour" then Flour = Flour + 1 end
        if Object.Name == "Water" then Water = Water + 1 end
        if Object.Name == "Gelatin" then Gelatin = Gelatin + 1 end
        if Object.Name == "Sugar Block Bag" then SugarBlockBag = SugarBlockBag + 1 end
    end
    return Potato, Flour, Water, Gelatin, SugarBlockBag
end

local function HasItem(name)
    local backpack = Player:FindFirstChild("Backpack")
    if backpack and backpack:FindFirstChild(name) then return true end
    local char = Player.Character
    if char and char:FindFirstChild(name) then return true end
    return false
end

-- ============================================
-- 1. SPAWN & SIT BIKE (sequential)
-- ============================================
local function SpawnAndSitOnBike()
    Configuration.State.Status = "[BIKE] Spawning..."
    local BikeName = string.format("%s's Car", Player.Name)
    local ExistingBike = Workspace:FindFirstChild(BikeName)

    if ExistingBike and ExistingBike:FindFirstChild("DriveSeat") and ExistingBike.DriveSeat.Occupant then
        Configuration.State.BikeSitting = true
        Configuration.State.BikeSpawned = true
        Configuration.State.Status = "[BIKE] Already seated"
        return true
    end

    local Bike = Workspace:FindFirstChild(BikeName)
    if not Bike then
        RPC:FireServer(makeBuffer("\001"), "Spawn", "DirtBike")
        local SpawnStart = os.clock()
        repeat task.wait(0.1) until Workspace:FindFirstChild(BikeName) or (os.clock() - SpawnStart) > 4
        Bike = Workspace:FindFirstChild(BikeName)
    end
    if not Bike then
        Configuration.State.Status = "[BIKE] Failed to spawn"
        return false
    end

    local DriveSeat = Bike:WaitForChild("DriveSeat")
    UnequipTools()
    Configuration.State.RespawnPending = true

    local HumanoidRootPart = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if HumanoidRootPart then
        HumanoidRootPart.CFrame = CFrame.new(67^2, 10^10, 67^2)
    end

    Player.CharacterAdded:Wait()
    local Character = Player.Character
    HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

    local TargetCFrame = DriveSeat.CFrame * CFrame.new(3, 1, 0)
    task.wait(2)
    for _ = 1, 5 do
        if HumanoidRootPart then
            HumanoidRootPart.CFrame = TargetCFrame
        end
        task.wait(0.05)
    end
    task.wait(2.5)

    local Prompt = DriveSeat:FindFirstChildWhichIsA("ProximityPrompt", true)
    if not Prompt then
        local Attachment = DriveSeat:FindFirstChild("Attachment")
        if Attachment then Prompt = Attachment:FindFirstChild("ProximityPrompt") end
    end

    if Prompt then
        pcall(function()
            Prompt.HoldDuration = 0
            Prompt.RequiresLineOfSight = false
            Prompt.MaxActivationDistance = 9e9
        end)
        fireproximityprompt(Prompt)
    end

    task.wait(1)
    Configuration.State.RespawnPending = false
    Configuration.State.BikeSitting = true
    Configuration.State.BikeSpawned = true
    Configuration.State.Status = "[BIKE] Seated"
    return true
end

-- ============================================
-- 2. DIRTBIKE TELEPORT (Multi Farm style)
-- ============================================
local function DirtBikeTeleport(TargetPosition)
    local c = Player.Character
    if not c then return false end
    local h = c:FindFirstChild("Humanoid")
    if not h then return false end

    if not h.SeatPart then
        Configuration.State.Status = "[BIKE] Re-sitting..."
        if not SpawnAndSitOnBike() then return false end
        task.wait(0.3)
    end

    local DriveSeat = h.SeatPart
    if not DriveSeat or DriveSeat.Name ~= "DriveSeat" then return false end

    local Vehicle = DriveSeat.Parent
    if not Vehicle then return false end

    Vehicle:PivotTo(CFrame.new(TargetPosition))
    for _, Object in pairs(Vehicle:GetDescendants()) do
        if Object:IsA("BasePart") then Object.Anchored = false end
    end
    task.wait(0.51)
    for _, Object in pairs(Vehicle:GetDescendants()) do
        if Object:IsA("BasePart") then Object.Anchored = true end
    end
    return true
end

-- ============================================
-- 3. APARTMENT (FIND / BUY / LOCK)
-- ============================================
local function FindAvailableApartments()
    local Available, Owned = {}, {}
    local Apartments = { "WH1", "BH3", "BH2", "BH4", "BH1", "LT1" }
    local CasinoApartments = { "Home 1", "Home 2", "Home 3", "Home 4" }
    local map = Workspace:FindFirstChild("Map")
    if not map then return Available, "Not Owned" end
    local apts = map:FindFirstChild("APTS")
    if not apts then return Available, "Not Owned" end
    for _, Object in next, apts:GetChildren() do
        if Object:IsA("Model") and (table.find(Apartments, tostring(Object)) or table.find(CasinoApartments, tostring(Object))) then
            local Board = Object:FindFirstChild("Board", true)
            if Board then
                local nameLabel = Board:FindFirstChild("name")
                if nameLabel then
                    local surfaceGui = nameLabel:FindFirstChild("SurfaceGui")
                    if surfaceGui then
                        local textLabel = surfaceGui:FindFirstChild("TextLabel")
                        if textLabel then
                            local Text = textLabel.Text
                            if Text == "VACANT" then table.insert(Available, Object)
                            elseif Text == Player.Name then table.insert(Owned, Object) end
                        end
                    end
                end
            end
        end
    end
    if #Owned >= 1 then return Owned, "Owned" end
    return Available, "Not Owned"
end

local function StartMarshmallowFarm()
    WaitForReady()
    Configuration.State.Status = "[APT] Finding apartment"
    local Apartments, Ownership = FindAvailableApartments()
    if #Apartments == 0 then
        Configuration.State.Status = "[APT] None available"
        return false
    end
    local Apartment = Ownership == "Owned" and Apartments[1] or Apartments[Random:NextInteger(1, #Apartments)]
    local IsHome = tostring(Apartment):match("Home")
    local map = Workspace:FindFirstChild("Map")
    if not map then return false end
    local locations = map:FindFirstChild("Locations")
    if IsHome then
        if locations then
            local apartments = locations:FindFirstChild("Apartments")
            if apartments then
                Configuration.State.Apartment = apartments:FindFirstChild(tostring(Apartment))
            end
        end
    else
        local houses = map:FindFirstChild("Houses")
        if houses then
            Configuration.State.Apartment = houses:FindFirstChild(tostring(Apartment))
        end
    end
    if Ownership == "Not Owned" then
        local Board = Apartment:FindFirstChild("Board", true)
        if Board then
            local backboard = Board:FindFirstChild("backboard")
            if backboard then
                local Prompt = backboard:FindFirstChild("ProximityPrompt")
                if Prompt then
                    pcall(function() Prompt.MaxActivationDistance = 9e9 end)
                    WaitForReady()
                    DirtBikeTeleport(backboard.Position)
                    Configuration.State.Status = "[APT] Purchasing"
                    fireproximityprompt(Prompt)
                    task.wait(2)
                    local nameLabel = Board:FindFirstChild("name")
                    if nameLabel then
                        local surfaceGui = nameLabel:FindFirstChild("SurfaceGui")
                        if surfaceGui then
                            local textLabel = surfaceGui:FindFirstChild("TextLabel")
                            if textLabel and textLabel.Text ~= tostring(Player) then
                                return StartMarshmallowFarm()
                            end
                        end
                    end
                end
            end
        end
    end
    local Door = Apartment:FindFirstChild("Door")
    if Door then
        local DoorLock = Door:FindFirstChild("DoorLock")
        local Interact = Door:FindFirstChild("Interact")
        if DoorLock and Interact then
            local LockPart = DoorLock:FindFirstChild("Part")
            local KnobPrompt = Interact:FindFirstChild("Attachment")
            if KnobPrompt then KnobPrompt = KnobPrompt:FindFirstChild("ProximityPrompt") end
            if LockPart and KnobPrompt then
                if math.abs(LockPart.Rotation.Y) > 5 and math.abs(LockPart.Rotation.Y - 90) > 5 then
                    WaitForReady()
                    pcall(function() KnobPrompt.MaxActivationDistance = 9e9 end)
                    DirtBikeTeleport(LockPart.Position)
                    Configuration.State.Status = "[APT] Closing door"
                    task.wait(0.5)
                    local CloseAttempts = 0
                    repeat
                        fireproximityprompt(KnobPrompt)
                        task.wait(1)
                        CloseAttempts = CloseAttempts + 1
                    until math.abs(LockPart.Rotation.Y) < 5 or CloseAttempts >= 10
                    task.wait(0.5)
                end
                if LockPart.Rotation.X ~= 90 then
                    WaitForReady()
                    local LockPrompt = LockPart:FindFirstChild("ProximityPrompt")
                    if LockPrompt then
                        pcall(function() LockPrompt.MaxActivationDistance = 9e9 end)
                        DirtBikeTeleport(LockPart.Position)
                        Configuration.State.Status = "[APT] Locking door"
                        task.wait(0.5)
                        local LockAttempts = 0
                        repeat
                            fireproximityprompt(LockPrompt)
                            task.wait(0.5)
                            LockAttempts = LockAttempts + 1
                        until LockPart.Rotation.X == 90 or LockAttempts >= 10
                        if LockPart.Rotation.X ~= 90 then
                            return StartMarshmallowFarm()
                        end
                    end
                end
            end
        end
    end
    Configuration.State.Status = "[APT] Secured"
    return true
end

local function EnsureApartment()
    if Configuration.State.Apartment and (Configuration.State.Apartment:FindFirstChild("Cooking Pot") or (Configuration.State.Apartment:FindFirstChild("Interior") and Configuration.State.Apartment.Interior:FindFirstChild("Cooking Pot"))) then
        return true
    end
    for i = 1, 5 do
        if StartMarshmallowFarm() and Configuration.State.Apartment then
            local stove = Configuration.State.Apartment:FindFirstChild("Cooking Pot") or (Configuration.State.Apartment:FindFirstChild("Interior") and Configuration.State.Apartment.Interior:FindFirstChild("Cooking Pot"))
            if stove then return true end
        end
        task.wait(2)
    end
    return false
end

-- ============================================
-- 4. MARSHMALLOW WORKFLOW (sequential)
-- ============================================
local function PurchaseMarshmallowIngredients()
    WaitForReady()
    local _, _, Water, Gelatin, SugarBlockBag = ScavengeInventory()
    if Water >= 1 and Gelatin >= 1 and SugarBlockBag >= 1 then return true end
    local MarshRemote = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("StorePurchase")
    DirtBikeTeleport(Locations.BuyMarsh)
    Configuration.State.Status = "[MARSH] Buying ingredients"
    task.wait(0.5)
    if Water < 1 then pcall(function() MarshRemote:FireServer("Water") end) task.wait(0.5) end
    if Gelatin < 1 then pcall(function() MarshRemote:FireServer("Gelatin") end) task.wait(0.5) end
    if SugarBlockBag < 1 then pcall(function() MarshRemote:FireServer("Sugar Block Bag") end) task.wait(0.5) end
    -- verify
    local _, _, Water2, Gelatin2, SugarBlockBag2 = ScavengeInventory()
    return (Water2 >= 1 and Gelatin2 >= 1 and SugarBlockBag2 >= 1)
end

local function PourWater()
    WaitForReady()
    if not EnsureApartment() then
        Configuration.State.Status = "[MARSH] No valid apartment"
        return false
    end

    local AptObj = Configuration.State.Apartment
    local Stove
    if tostring(AptObj):match("Home") then
        Stove = AptObj:FindFirstChild("Cooking Pot")
    else
        Stove = AptObj:FindFirstChild("Interior") and AptObj.Interior:FindFirstChild("Cooking Pot")
    end
    if not Stove then
        Configuration.State.Status = "[MARSH] Stove not found"
        return false
    end
    local CookPrompt = Stove:FindFirstChild("Attachment") and Stove.Attachment:FindFirstChild("ProximityPrompt")
    if not CookPrompt then
        Configuration.State.Status = "[MARSH] Cook prompt not found"
        return false
    end

    DirtBikeTeleport(Stove.Position)
    Configuration.State.Status = "[MARSH] Pouring water"
    local Safety = 0
    repeat
        WaitForReady()
        local water = Player:FindFirstChild("Backpack") and Player.Backpack:FindFirstChild("Water")
        if water then EquipTool(water) end
        DirtBikeTeleport(Stove.Position)
        if CookPrompt then
            pcall(function()
                CookPrompt.MaxActivationDistance = 50
                CookPrompt.HoldDuration = 0
            end)
            fireproximityprompt(CookPrompt)
        end
        task.wait(1)
        UnequipTools()
        Safety = Safety + 1
        if Safety >= 10 then
            Configuration.State.Status = "[MARSH] Water failed, retrying..."
            return false
        end
    until not HasItem("Water") or Safety >= 10

    -- check permission
    local notif = PlayerGui:FindFirstChild("Main") and PlayerGui.Main:FindFirstChild("BasicNotification")
    if notif and notif.Text == "You do not have permission to cook in this apartment." then
        Configuration.State.Status = "[MARSH] No permission, re-finding apartment..."
        StartMarshmallowFarm()
        return false
    end
    return true
end

local function AddSugarAndGelatin()
    WaitForReady()
    -- Re-fetch stove
    local AptObj = Configuration.State.Apartment
    if not AptObj then
        if not EnsureApartment() then return false end
        AptObj = Configuration.State.Apartment
    end
    local Stove
    if tostring(AptObj):match("Home") then
        Stove = AptObj:FindFirstChild("Cooking Pot")
    else
        Stove = AptObj:FindFirstChild("Interior") and AptObj.Interior:FindFirstChild("Cooking Pot")
    end
    if not Stove then
        Configuration.State.Status = "[MARSH] Stove lost"
        return false
    end
    local CookPrompt = Stove:FindFirstChild("Attachment") and Stove.Attachment:FindFirstChild("ProximityPrompt")
    if not CookPrompt then return false end

    Configuration.State.Status = "[MARSH] Adding sugar"
    local Safety = 0
    repeat
        WaitForReady()
        local sugar = Player:FindFirstChild("Backpack") and Player.Backpack:FindFirstChild("Sugar Block Bag")
        if sugar then EquipTool(sugar) end
        DirtBikeTeleport(Stove.Position)
        if CookPrompt then fireproximityprompt(CookPrompt) end
        task.wait(1)
        UnequipTools()
        Safety = Safety + 1
        if Safety >= 10 then
            Configuration.State.Status = "[MARSH] Sugar failed"
            return false
        end
    until not HasItem("Sugar Block Bag") or Safety >= 10

    Configuration.State.Status = "[MARSH] Adding gelatin"
    Safety = 0
    repeat
        WaitForReady()
        local gelatin = Player:FindFirstChild("Backpack") and Player.Backpack:FindFirstChild("Gelatin")
        if gelatin then EquipTool(gelatin) end
        DirtBikeTeleport(Stove.Position)
        if CookPrompt then fireproximityprompt(CookPrompt) end
        task.wait(1)
        UnequipTools()
        Safety = Safety + 1
        if Safety >= 10 then
            Configuration.State.Status = "[MARSH] Gelatin failed"
            return false
        end
    until not HasItem("Gelatin") or Safety >= 10
    return true
end

local function BagMarshmallowAndSell()
    WaitForReady()
    -- Wait for cooking to finish (timer)
    local AptObj = Configuration.State.Apartment
    if not AptObj then
        if not EnsureApartment() then return false end
        AptObj = Configuration.State.Apartment
    end
    local Stove
    if tostring(AptObj):match("Home") then
        Stove = AptObj:FindFirstChild("Cooking Pot")
    else
        Stove = AptObj:FindFirstChild("Interior") and AptObj.Interior:FindFirstChild("Cooking Pot")
    end
    if not Stove then return false end
    local StoveTimer = Stove:FindFirstChild("Timer") and Stove.Timer:FindFirstChild("TextLabel")
    local CookPrompt = Stove:FindFirstChild("Attachment") and Stove.Attachment:FindFirstChild("ProximityPrompt")

    Configuration.State.Status = "[MARSH] Waiting for cook"
    DirtBikeTeleport(Locations.SafeZone)
    if StoveTimer then
        repeat task.wait(1) until StoveTimer.Text == "0" or not Configuration.Main_Settings.Autofarming
    else
        task.wait(45) -- fallback
    end

    DirtBikeTeleport(Stove.Position)
    Configuration.State.Status = "[MARSH] Bagging"
    local bagAttempts = 0
    repeat
        WaitForReady()
        local emptyBag = Player:FindFirstChild("Backpack") and Player.Backpack:FindFirstChild("Empty Bag")
        if emptyBag then EquipTool(emptyBag) end
        task.wait(0.5)
        if CookPrompt then fireproximityprompt(CookPrompt) end
        task.wait(0.5)
        UnequipTools()
        task.wait(0.25)
        bagAttempts = bagAttempts + 1
        if bagAttempts > 20 then break end
    until HasItem("Small Marshmallow Bag") or HasItem("Medium Marshmallow Bag") or HasItem("Large Marshmallow Bag") or bagAttempts >= 20

    -- Sell to Lamont Bell
    local lamontAttempts = 0
    repeat
        WaitForReady()
        DirtBikeTeleport(Locations.BuyMarsh)
        task.wait(0.05)
        lamontAttempts = lamontAttempts + 1
    until Workspace:FindFirstChild("Folders") and Workspace.Folders:FindFirstChild("NPCs") and Workspace.Folders.NPCs:FindFirstChild("Lamont Bell") or lamontAttempts > 20

    local LamontBell = Workspace:FindFirstChild("Folders") and Workspace.Folders:FindFirstChild("NPCs") and Workspace.Folders.NPCs:FindFirstChild("Lamont Bell")
    if not LamontBell then return false end
    local LamontPrompt = LamontBell:FindFirstChild("UpperTorso") and LamontBell.UpperTorso:FindFirstChild("ProximityPrompt")
    UnequipTools()
    local backpack = Player:FindFirstChild("Backpack")
    if not backpack then return false end
    for _, Object in next, backpack:GetChildren() do
        if tostring(Object):find("Marshmallow") then
            WaitForReady()
            DirtBikeTeleport(Locations.BuyMarsh)
            EquipTool(Object)
            task.wait(0.5)
            if LamontPrompt then fireproximityprompt(LamontPrompt) end
            task.wait(0.5)
        end
    end
    Configuration.Statistics.MarshmallowsSold = Configuration.Statistics.MarshmallowsSold + 1
    return true
end

-- ============================================
-- 5. POTATO CHIPS WORKFLOW (sequential)
-- ============================================
local function PurchasePotatoIngredients()
    WaitForReady()
    local Potato, Flour = ScavengeInventory()
    if Potato >= 1 and Flour >= 1 then return true end
    local PotatoRemote = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("StorePurchase")
    Configuration.State.Status = "[POTATO] Buying ingredients"
    DirtBikeTeleport(Locations.BuyPotato)
    task.wait(0.5)
    if Flour < 1 then pcall(function() PotatoRemote:FireServer("Flour") end) task.wait(0.5) end
    if Potato < 1 then pcall(function() PotatoRemote:FireServer("Potato") end) task.wait(0.5) end
    local Potato2, Flour2 = ScavengeInventory()
    return (Potato2 >= 1 and Flour2 >= 1)
end

local function StartPotatoJob()
    WaitForReady()
    local Labatory = Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("Locations") and Workspace.Map.Locations:FindFirstChild("The Laboratory")
    if not Labatory then return false end
    local Clipboard = Labatory:FindFirstChild("Prompts") and Labatory.Prompts:FindFirstChild("Clipboard")
    if not Clipboard then return false end
    local ClipboardPrompt = Clipboard:FindFirstChild("ProximityPrompt")
    if ClipboardPrompt then pcall(function() ClipboardPrompt.MaxActivationDistance = 9e9 end) end
    DirtBikeTeleport(Locations.Clipboard)
    Configuration.State.Status = "[POTATO] Claiming task"
    task.wait(0.5)
    local Attempts = 0
    repeat
        WaitForReady()
        DirtBikeTeleport(Locations.Clipboard)
        task.wait(0.25)
        if ClipboardPrompt then fireproximityprompt(ClipboardPrompt) end
        task.wait(0.5)
        Attempts = Attempts + 1
        if Attempts > 20 then break end
    until PlayerGui:FindFirstChild("Main") and PlayerGui.Main:FindFirstChild("TaskUpdate") and PlayerGui.Main.TaskUpdate:FindFirstChild("TextLabel") and PlayerGui.Main.TaskUpdate.TextLabel.Text:match("Task:")
    return true
end

local function CutPotato()
    WaitForReady()
    local Labatory = Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("Locations") and Workspace.Map.Locations:FindFirstChild("The Laboratory")
    if not Labatory then return false end
    local PotatoCutter = Labatory:FindFirstChild("Cutting Boards") and Labatory.CuttingBoards:FindFirstChild("Potato Cutter")
    if not PotatoCutter then return false end
    local Union = PotatoCutter:FindFirstChild("Model") and PotatoCutter.Model:FindFirstChild("Union")
    if not Union then return false end
    local CutterPrompt = Union:FindFirstChild("Attachment") and Union.Attachment:FindFirstChild("ProximityPrompt")
    if CutterPrompt then pcall(function() CutterPrompt.MaxActivationDistance = 9e9 end) end
    Configuration.State.Status = "[POTATO] Cutting"
    local Safety = 0
    repeat
        WaitForReady()
        DirtBikeTeleport(Locations.PotatoCutter)
        local potato = Player:FindFirstChild("Backpack") and Player.Backpack:FindFirstChild("Potato")
        if potato then EquipTool(potato) end
        task.wait(0.25)
        if CutterPrompt then fireproximityprompt(CutterPrompt) end
        task.wait(0.5)
        UnequipTools()
        task.wait(0.25)
        Safety = Safety + 1
        if Safety > 25 then break end
    until not HasItem("Potato") or Safety >= 25
    return true
end

local function BagPotato()
    WaitForReady()
    local Labatory = Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("Locations") and Workspace.Map.Locations:FindFirstChild("The Laboratory")
    if not Labatory then return false end
    local PlasticBag = Labatory:FindFirstChild("Prompts") and Labatory.Prompts:FindFirstChild("Plastic Bag")
    if not PlasticBag then return false end
    local BagPrompt = PlasticBag:FindFirstChild("Attachment") and PlasticBag.Attachment:FindFirstChild("ProximityPrompt")
    if BagPrompt then pcall(function() BagPrompt.MaxActivationDistance = 9e9 end) end
    Configuration.State.Status = "[POTATO] Bagging"
    if HasItem("Potato") then return true end
    local Safety = 0
    repeat
        WaitForReady()
        DirtBikeTeleport(Locations.PlasticBagLab)
        task.wait(0.25)
        if BagPrompt then fireproximityprompt(BagPrompt) end
        task.wait(0.5)
        Safety = Safety + 1
        if Safety >= 20 then break end
    until PlayerGui:FindFirstChild("Main") and PlayerGui.Main:FindFirstChild("TaskUpdate") and PlayerGui.Main.TaskUpdate:FindFirstChild("TextLabel") and PlayerGui.Main.TaskUpdate.TextLabel.Text:match("Head")
    return true
end

local function MixFlourAndPotato()
    WaitForReady()
    local Labatory = Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("Locations") and Workspace.Map.Locations:FindFirstChild("The Laboratory")
    if not Labatory then return false end
    local Bowl = Labatory:FindFirstChild("Bowls") and Labatory.Bowls:FindFirstChildOfClass("UnionOperation")
    if not Bowl then return false end
    local BowlPrompt = Bowl:FindFirstChild("ProximityPrompt")
    if BowlPrompt then pcall(function() BowlPrompt.MaxActivationDistance = 9e9 end) end
    Configuration.State.Status = "[POTATO] Mixing"
    local Safety = 0
    repeat
        WaitForReady()
        DirtBikeTeleport(Locations.FlourBowl)
        task.wait(0.25)
        local flour = Player:FindFirstChild("Backpack") and Player.Backpack:FindFirstChild("Flour")
        if flour then EquipTool(flour) end
        task.wait(0.25)
        if BowlPrompt then fireproximityprompt(BowlPrompt) end
        task.wait(0.5)
        UnequipTools()
        Safety = Safety + 1
        if Safety >= 20 then break end
    until not HasItem("Flour") or Safety >= 20
    task.wait(3.5)
    return true
end

local function CookPotatoChips()
    WaitForReady()
    local Labatory = Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("Locations") and Workspace.Map.Locations:FindFirstChild("The Laboratory")
    if not Labatory then
        Configuration.State.Status = "[POTATO] Lab not found"
        return false
    end
    Configuration.State.Status = "[POTATO] Starting cook"
    local Pots = Labatory:FindFirstChild("Pots")
    if not Pots then return false end

    for _, Object in next, Pots:GetChildren() do
        if Object:IsA("UnionOperation") then
            local Safety = 0
            repeat
                WaitForReady()
                DirtBikeTeleport(Object.Position)
                local prompt = Object:FindFirstChild("ProximityPrompt")
                if prompt then fireproximityprompt(prompt) end
                task.wait(0.05)
                Safety = Safety + 1
                if Safety > 130 then break end
            until PlayerGui:FindFirstChild("Main") and PlayerGui.Main:FindFirstChild("BasicNotification") and PlayerGui.Main.BasicNotification.TextTransparency == 0

            local Notif = PlayerGui:FindFirstChild("Main") and PlayerGui.Main:FindFirstChild("BasicNotification")
            if Notif then
                local notifText = Notif.Text
                if notifText == "This pot is in use." then
                    repeat task.wait() until PlayerGui.Main.BasicNotification.TextTransparency == 1
                elseif notifText == "You have 120 seconds to retrieve your product out of the pot when its done." then
                    -- pot found
                    return true
                end
            end
        end
    end
    Configuration.State.Status = "[POTATO] No available pot"
    return false
end

local function ClaimPotatoChipsAndSell()
    WaitForReady()
    Configuration.State.Status = "[POTATO] Waiting for cook"
    DirtBikeTeleport(Locations.SafeZone)
    -- Wait for pot timer (we need to detect the pot we used)
    local Labatory = Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("Locations") and Workspace.Map.Locations:FindFirstChild("The Laboratory")
    if not Labatory then return false end
    local Pots = Labatory:FindFirstChild("Pots")
    if not Pots then return false end

    local foundPot = nil
    local potTimer = nil
    for _, Object in next, Pots:GetChildren() do
        if Object:IsA("UnionOperation") then
            local Timer = Object:FindFirstChild("Timer")
            if Timer then
                local textLabel = Timer:FindFirstChild("TextLabel")
                if textLabel and textLabel.Text ~= "" and textLabel.Text ~= "0" then
                    foundPot = Object
                    potTimer = textLabel
                    break
                end
            end
        end
    end

    if potTimer then
        repeat task.wait(1) until potTimer.Text == "0" or not Configuration.Main_Settings.Autofarming
    else
        task.wait(120) -- fallback
    end

    if not foundPot then
        -- try to find any pot with empty timer
        for _, Object in next, Pots:GetChildren() do
            if Object:IsA("UnionOperation") then
                local Timer = Object:FindFirstChild("Timer")
                if Timer then
                    local textLabel = Timer:FindFirstChild("TextLabel")
                    if textLabel and textLabel.Text == "0" then
                        foundPot = Object
                        break
                    end
                end
            end
        end
    end
    if not foundPot then
        Configuration.State.Status = "[POTATO] No pot to claim"
        return false
    end

    local PotPrompt = foundPot:FindFirstChild("ProximityPrompt")
    Configuration.State.Status = "[POTATO] Claiming from pot"
    local claimAttempts = 0
    repeat
        WaitForReady()
        DirtBikeTeleport(foundPot.Position)
        if PotPrompt then fireproximityprompt(PotPrompt) end
        task.wait(0.5)
        claimAttempts = claimAttempts + 1
        if claimAttempts > 20 then break end
    until HasItem("Potato Chips") or claimAttempts >= 20

    Configuration.State.Status = "[POTATO] Converting to hot chips"
    local convertAttempts = 0
    repeat
        WaitForReady()
        DirtBikeTeleport(Locations.HotChipsMan)
        task.wait(0.05)
        convertAttempts = convertAttempts + 1
        if convertAttempts > 20 then break end
    until Workspace:FindFirstChild("Folders") and Workspace.Folders:FindFirstChild("NPCs") and Workspace.Folders.NPCs:FindFirstChild("Poor Guy")

    local PoorGuy = Workspace:FindFirstChild("Folders") and Workspace.Folders:FindFirstChild("NPCs") and Workspace.Folders.NPCs:FindFirstChild("Poor Guy")
    if not PoorGuy then return false end
    local PoorGuyPrompt = PoorGuy:FindFirstChild("UpperTorso") and PoorGuy.UpperTorso:FindFirstChild("ProximityPrompt")

    local hotChipsAttempts = 0
    repeat
        WaitForReady()
        DirtBikeTeleport(Locations.HotChipsMan)
        if PoorGuyPrompt then
            pcall(function() PoorGuyPrompt.MaxActivationDistance = 50; PoorGuyPrompt.HoldDuration = 0 end)
            fireproximityprompt(PoorGuyPrompt)
        end
        UnequipTools()
        task.wait(0.05)
        hotChipsAttempts = hotChipsAttempts + 1
        if hotChipsAttempts > 20 then break end
    until HasItem("Hot Chips") or hotChipsAttempts >= 20

    task.wait(2)

    -- Feed Homeless (sequential)
    Configuration.State.Status = "[FEED] Feeding homeless"
    local homelessFolder = Workspace:FindFirstChild("Folders") and Workspace.Folders:FindFirstChild("HomelessPeople")
    if not homelessFolder then return false end

    local fedCount = 0
    while HasItem("Hot Chips") and Configuration.Main_Settings.Autofarming do
        -- Find available homeless (standing)
        local availableHomeless = {}
        for _, Object in next, homelessFolder:GetChildren() do
            if Object:IsA("Model") then
                local Leg = Object:FindFirstChild("RightLowerLeg")
                if Leg and math.floor(Leg.Rotation.X) == 90 then
                    table.insert(availableHomeless, Object)
                end
            end
        end
        if #availableHomeless == 0 then
            Configuration.State.Status = "[FEED] No homeless available"
            break
        end

        for _, HomelessRef in next, availableHomeless do
            if not HasItem("Hot Chips") then break end
            local HomelessName = tostring(HomelessRef)
            repeat
                WaitForReady()
                local upper = HomelessRef:FindFirstChild("UpperTorso")
                if upper then
                    DirtBikeTeleport(upper.Position)
                else
                    DirtBikeTeleport(HomelessRef.PrimaryPart.Position)
                end
                task.wait(0.05)
            until Workspace:FindFirstChild("Folders") and Workspace.Folders:FindFirstChild("HomelessPeople") and Workspace.Folders.HomelessPeople:FindFirstChild(HomelessName)
            local Homeless = Workspace:FindFirstChild("Folders") and Workspace.Folders:FindFirstChild("HomelessPeople") and Workspace.Folders.HomelessPeople:FindFirstChild(HomelessName)
            if not Homeless then continue end
            local UpperTorso = Homeless:FindFirstChild("UpperTorso")
            if not UpperTorso then continue end
            local Prompt = UpperTorso:FindFirstChild("ProximityPrompt")
            if not Prompt then continue end

            EquipTool(Player.Backpack:FindFirstChild("Hot Chips"))
            task.wait(0.25)
            fireproximityprompt(Prompt)
            task.wait(0.5)
            UnequipTools()
            fedCount = fedCount + 1
            Configuration.Statistics.ChipsFed = Configuration.Statistics.ChipsFed + 1
        end
        task.wait(0.5)
    end

    Configuration.State.Status = "[FEED] Done (" .. fedCount .. " chips fed)"
    return true
end

-- ============================================
-- 6. FAKE ID & CARD SCAM (sequential)
-- ============================================
local function PurchaseFakeID()
    WaitForReady()
    if HasItem("Fake ID") then return true end
    Configuration.State.Status = "[CARD] Buying fake ID"
    repeat WaitForReady() DirtBikeTeleport(Locations.FakeID) task.wait(0.05)
    until Workspace:FindFirstChild("Folders") and Workspace.Folders:FindFirstChild("NPCs") and Workspace.Folders.NPCs:FindFirstChild("FakeIDSeller")

    local FakeIDSeller = Workspace:FindFirstChild("Folders") and Workspace.Folders:FindFirstChild("NPCs") and Workspace.Folders.NPCs:FindFirstChild("FakeIDSeller")
    if not FakeIDSeller then return false end
    local BuyIDPrompt = FakeIDSeller:FindFirstChild("UpperTorso") and FakeIDSeller.UpperTorso:FindFirstChild("Attachment") and FakeIDSeller.UpperTorso.Attachment:FindFirstChild("ProximityPrompt")
    if not BuyIDPrompt then return false end

    local attempts = 0
    repeat
        WaitForReady()
        DirtBikeTeleport(Locations.FakeID)
        local SkiMask = Player.Character and Player.Character:FindFirstChild("White Ski Mask") or (Player:FindFirstChild("Backpack") and Player.Backpack:FindFirstChild("White Ski Mask"))
        if SkiMask then EquipTool(SkiMask) end
        task.wait(0.25)
        fireproximityprompt(BuyIDPrompt)
        UnequipTools()
        task.wait(4)
        attempts = attempts + 1
    until HasItem("Fake ID") or attempts >= 10
    return HasItem("Fake ID")
end

local function ApplyForCard()
    WaitForReady()
    if HasItem("Card") then return true end
    Configuration.State.Status = "[CARD] Applying for credit card"
    repeat DirtBikeTeleport(Locations.ApplyForCard) task.wait(0.05)
    until Workspace:FindFirstChild("Folders") and Workspace.Folders:FindFirstChild("NPCs") and Workspace.Folders.NPCs:FindFirstChild("Bank Teller")

    local BankTeller = Workspace:FindFirstChild("Folders") and Workspace.Folders:FindFirstChild("NPCs") and Workspace.Folders.NPCs:FindFirstChild("Bank Teller")
    if not BankTeller then return false end
    local BankPrompt = BankTeller:FindFirstChild("UpperTorso") and BankTeller.UpperTorso:FindFirstChild("Attachment") and BankTeller.UpperTorso.Attachment:FindFirstChild("ProximityPrompt")
    if not BankPrompt then return false end

    local Safety = 0
    repeat
        WaitForReady()
        DirtBikeTeleport(Locations.ApplyForCard)
        local fakeID = Player:FindFirstChild("Backpack") and Player.Backpack:FindFirstChild("Fake ID")
        if fakeID then EquipTool(fakeID) end
        task.wait(0.5)
        fireproximityprompt(BankPrompt)
        task.wait(0.5)
        UnequipTools()
        Safety = Safety + 1
    until not HasItem("Fake ID") or Safety >= 15

    if Safety >= 15 then
        WaitForReady()
        Configuration.State.Status = "[CARD] Claiming card early"
        local Card = Workspace:FindFirstChild("CardPickup")
        if Card then
            local CardPrompt = Card:FindFirstChild("Attachment") and Card.Attachment:FindFirstChild("ProximityPrompt")
            if CardPrompt then
                for _ = 1, 10 do
                    DirtBikeTeleport(Card.Position)
                    fireproximityprompt(CardPrompt)
                    task.wait(0.05)
                    UnequipTools()
                end
            end
        end
    end
    return true
end

local function FindAvailableATMs()
    local map = Workspace:FindFirstChild("Map")
    if not map then return nil end
    local atms = map:FindFirstChild("ATMS")
    if not atms then return nil end
    for _, ATM in next, atms:GetChildren() do
        if ATM:FindFirstChild("ATMScreen") and ATM.ATMScreen.Transparency == 0 then
            return ATM
        end
    end
    return nil
end

local function ClaimAndUseCard()
    WaitForReady()
    if not HasItem("Card") then
        Configuration.State.Status = "[CARD] Card not found, skipping"
        return false
    end

    local atmAttempts = 0
    local AvailableATM = nil
    repeat
        AvailableATM = FindAvailableATMs()
        if not AvailableATM then task.wait(1) end
        atmAttempts = atmAttempts + 1
    until AvailableATM or atmAttempts >= 10
    if not AvailableATM then
        Configuration.State.Status = "[CARD] No ATM available"
        return false
    end

    local ATMPrompt = AvailableATM:FindFirstChild("Attachment") and AvailableATM.Attachment:FindFirstChild("ProximityPrompt")
    if not ATMPrompt then return false end

    WaitForReady()
    Configuration.State.Status = "[CARD] Using ATM"
    local OldATM = PlayerGui:FindFirstChild("ATM")
    if OldATM then OldATM:Destroy() end
    local atmOpenAttempts = 0
    repeat
        WaitForReady()
        DirtBikeTeleport(AvailableATM.Position)
        fireproximityprompt(ATMPrompt)
        task.wait(0.05)
        atmOpenAttempts = atmOpenAttempts + 1
    until PlayerGui:FindFirstChild("ATM") or atmOpenAttempts >= 10

    if not PlayerGui:FindFirstChild("ATM") then
        Configuration.State.Status = "[CARD] Failed to open ATM"
        return false
    end

    local card = Player:FindFirstChild("Backpack") and Player.Backpack:FindFirstChild("Card")
    if card then EquipTool(card) end
    task.wait(0.5)

    local swipeBtn = PlayerGui.ATM:FindFirstChild("Frame") and PlayerGui.ATM.Frame:FindFirstChild("Swipe")
    if swipeBtn then
        if replicatesignal then
            replicatesignal(swipeBtn.MouseButton1Click)
        else
            local pos = swipeBtn.AbsolutePosition
            local size = swipeBtn.AbsoluteSize
            if pos and size then
                VirtualInputManager:SendMouseButtonEvent(pos.X + size.X/2, pos.Y + size.Y/2, 0, true, game, 0)
                task.wait(0.05)
                VirtualInputManager:SendMouseButtonEvent(pos.X + size.X/2, pos.Y + size.Y/2, 0, false, game, 0)
            end
        end
        Configuration.State.Status = "[CARD] Swiping card"
        task.wait(0.5)
        UnequipTools()
        Configuration.Statistics.CardsSwiped = Configuration.Statistics.CardsSwiped + 1
        return true
    else
        Configuration.State.Status = "[CARD] Swipe button not found"
        return false
    end
end

-- ============================================
-- 7. BUY SKI MASK (for Fake ID)
-- ============================================
local function BuySkiMask()
    WaitForReady()
    if HasItem("White Ski Mask") then
        Configuration.State.MaskOwned = true
        return true
    end
    Configuration.State.Status = "[MASK] Buying Ski Mask..."
    DirtBikeTeleport(Locations.SkiMask)
    task.wait(0.5)

    local StoreRemote = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("StorePurchase")
    local attempts = 0
    repeat
        pcall(function()
            StoreRemote:FireServer("White Ski Mask")
        end)
        task.wait(0.5)
        attempts = attempts + 1
    until HasItem("White Ski Mask") or attempts >= 10

    if HasItem("White Ski Mask") then
        EquipTool(Player.Backpack:FindFirstChild("White Ski Mask"))
        task.wait(0.05)
        RPC:FireServer(makeBuffer("\005"), Player.Character:WaitForChild("White Ski Mask"))
        task.wait(0.05)
        UnequipTools()
        Configuration.State.MaskOwned = true
        Configuration.State.Status = "[MASK] Ski Mask obtained"
        return true
    else
        Configuration.State.Status = "[MASK] Failed to buy Ski Mask"
        return false
    end
end

-- ============================================
-- ANTI DEATH
-- ============================================
local function cekDarah(char)
    local hum = char:FindFirstChild("Humanoid")
    if not hum then return end
    hum.HealthChanged:Connect(function(hp)
        if not Configuration.Main_Settings.AutoAntiDeath then return end
        if Configuration.State.RespawnPending then return end
        if hp > 0 and hp < 95 then
            Configuration.State.Status = "[HEAL] Teleporting"
            DirtBikeTeleport(Locations.Healing)
        end
    end)
end

if Player.Character then cekDarah(Player.Character) end
Player.CharacterAdded:Connect(cekDarah)

-- ============================================
-- MAIN AUTOFARM CONTROLLER (SEQUENTIAL)
-- ============================================
local AutofarmRunning = false

local function MainAutofarmController()
    if AutofarmRunning then return end
    AutofarmRunning = true

    while Configuration.Main_Settings.Autofarming do
        WaitForReady()

        -- 1. Bike
        if not Configuration.State.BikeSitting then
            Configuration.State.Status = "[MAIN] Spawning bike"
            if not SpawnAndSitOnBike() then
                task.wait(3)
                continue
            end
        end

        -- 2. Ski Mask
        if not Configuration.State.MaskOwned then
            Configuration.State.Status = "[MAIN] Buying ski mask"
            BuySkiMask()
        end

        -- 3. Apartment
        Configuration.State.Status = "[MAIN] Setting up apartment"
        if not EnsureApartment() then
            task.wait(5)
            continue
        end

        -- 4. Marshmallow ingredients
        Configuration.State.Status = "[MAIN] Buying marshmallow ingredients"
        if not PurchaseMarshmallowIngredients() then
            task.wait(3)
            continue
        end

        -- 5. Pour water
        Configuration.State.Status = "[MAIN] Pouring water"
        if not PourWater() then
            task.wait(3)
            continue
        end

        -- 6. Potato preparation (sequential)
        Configuration.State.Status = "[MAIN] Starting potato job"
        if not PurchasePotatoIngredients() then
            task.wait(3)
            continue
        end
        if not StartPotatoJob() then
            task.wait(3)
            continue
        end
        if not CutPotato() then
            task.wait(3)
            continue
        end
        if not BagPotato() then
            task.wait(3)
            continue
        end
        if not MixFlourAndPotato() then
            task.wait(3)
            continue
        end
        if not CookPotatoChips() then
            task.wait(3)
            continue
        end

        -- 7. Sugar & Gelatin (after potato is cooking)
        Configuration.State.Status = "[MAIN] Adding sugar and gelatin"
        if not AddSugarAndGelatin() then
            task.wait(3)
            continue
        end

        -- 8. Wait for marshmallow to cook
        Configuration.State.Status = "[MAIN] Waiting for marshmallow"
        -- We already have timer from bag function, but we can just wait 45s
        for i = 45, 1, -1 do
            if not Configuration.Main_Settings.Autofarming then break end
            Configuration.State.Status = "[MARSH] Cooking: " .. i .. "s"
            task.wait(1)
        end

        -- 9. Bag and sell marshmallow
        Configuration.State.Status = "[MAIN] Bagging and selling marshmallow"
        if not BagMarshmallowAndSell() then
            task.wait(3)
            continue
        end

        -- 10. Claim potato chips and feed homeless
        Configuration.State.Status = "[MAIN] Claiming potato chips"
        if not ClaimPotatoChipsAndSell() then
            task.wait(3)
            continue
        end

        -- 11. Card scam (optional)
        if Configuration.Main_Settings.EnableCardScam then
            Configuration.State.Status = "[MAIN] Starting card scam"
            if not PurchaseFakeID() then
                task.wait(3)
            end
            if not ApplyForCard() then
                task.wait(3)
            end
            -- Wait for card approval (check notification)
            local startNotif = os.clock()
            repeat
                task.wait(0.5)
                local notif = PlayerGui:FindFirstChild("Main") and PlayerGui.Main:FindFirstChild("BasicNotification")
                if notif and notif.TextTransparency == 0 then
                    if notif.Text:match("successful") then
                        for i = 35, 1, -1 do
                            if not Configuration.Main_Settings.Autofarming then break end
                            Configuration.State.Status = "[CARD] Approved, waiting " .. i .. "s"
                            task.wait(1)
                        end
                        break
                    end
                end
            until os.clock() - startNotif > 40
            Configuration.State.Status = "[MAIN] Claiming and using card"
            ClaimAndUseCard()
        end

        -- 12. Cycle complete
        Configuration.Statistics.CyclesCompleted = Configuration.Statistics.CyclesCompleted + 1
        Configuration.State.Status = "[MAIN] Cycle complete"
        task.wait(2)
    end

    AutofarmRunning = false
end

-- ============================================
-- REJOIN
-- ============================================
local function DoRejoin()
    if not Configuration.Main_Settings.AutoRejoiner then return end
    Configuration.Main_Settings.Autofarming = false
    Configuration.Statistics.TimesRejoined = Configuration.Statistics.TimesRejoined + 1
    TeleportService:Teleport(10179538382)
end

-- ============================================
-- UI (TETAP SAMA PERSIS DENGAN DEEPSEEK)
-- ============================================
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/NIcoGabrielRealYtr/Aether.lua-Library/refs/heads/main/Source"))()

local MainWindow = Library:CreateWindow({
    Title = "LENGER MULTI FARM",
    SubText = "Stealth",
    Image = "rbxassetid://95259225424429",
    IsMobile = true
})

local MainTab = MainWindow:AddTab({
    Text = "Main",
    Icon = "rbxassetid://108020878442937"
})

local ControlsSection = MainTab:AddSection({
    Title = "Controls",
    Side = "Left"
})

ControlsSection:AddToggle({
    Text = "Autofarming",
    Desc = "Start/Stop the farm",
    Flag = "autofarm",
    Default = false,
    Callback = function(v)
        Configuration.Main_Settings.Autofarming = v
        if v then
            task.spawn(function()
                repeat task.wait(0.5) until SpawnAndSitOnBike() or not Configuration.Main_Settings.Autofarming
                if Configuration.Main_Settings.Autofarming then
                    MainAutofarmController()
                end
            end)
        end
    end
})

ControlsSection:AddToggle({
    Text = "Anti Death",
    Desc = "Teleport to safe zone when low HP",
    Flag = "antideath",
    Default = true,
    Callback = function(v)
        Configuration.Main_Settings.AutoAntiDeath = v
    end
})

ControlsSection:AddToggle({
    Text = "Auto Rejoiner",
    Desc = "Rejoin when stuck or die",
    Flag = "rejoin",
    Default = true,
    Callback = function(v)
        Configuration.Main_Settings.AutoRejoiner = v
    end
})

ControlsSection:AddToggle({
    Text = "Card Scam",
    Desc = "Fake ID -> Apply Card -> Swipe ATM",
    Flag = "cardscam",
    Default = true,
    Callback = function(v)
        Configuration.Main_Settings.EnableCardScam = v
    end
})

local ActionsSection = MainTab:AddSection({
    Title = "Actions",
    Side = "Right"
})

ActionsSection:AddButton({
    Text = "Spawn DirtBike ($35K)",
    Desc = "Spawn a dirt bike",
    Callback = function()
        pcall(function()
            RPC:FireServer(makeBuffer("\001"), "Purchase", "DirtBike")
        end)
    end
})

ActionsSection:AddButton({
    Text = "Rejoin Game",
    Desc = "Teleport to lobby",
    Callback = function()
        DoRejoin()
    end
})

local StatsTab = MainWindow:AddTab({
    Text = "Stats",
    Icon = "rbxassetid://108020878442937"
})

local StatsSection = StatsTab:AddSection({
    Title = "Live Statistics",
    Side = "Left"
})

local function CreateLabel(section, initialText)
    local label
    if section.AddLabel then
        label = section:AddLabel({ Text = initialText })
    else
        label = section:AddTextBox({
            Text = initialText,
            ReadOnly = true,
            Flag = "label_" .. tostring(#StatsSection:GetChildren() + 1)
        })
    end

    local labelObject = {
        _label = label,
        Update = function(self, newText)
            if not self._label then return end
            local lbl = self._label
            if lbl.Set then
                pcall(lbl.Set, lbl, newText)
            elseif lbl.SetText then
                pcall(lbl.SetText, lbl, newText)
            elseif lbl.Text ~= nil then
                pcall(function() lbl.Text = newText end)
            elseif lbl.Value ~= nil then
                pcall(function() lbl.Value = newText end)
            else
                pcall(function() rawset(lbl, "Text", newText) end)
                pcall(function() rawset(lbl, "Value", newText) end)
            end
        end
    }
    return labelObject
end

local statusLabel = CreateLabel(StatsSection, "📌 Status: Idle")
local runtimeLabel = CreateLabel(StatsSection, "⏰ Runtime: 00:00:00")
local cashLabel = CreateLabel(StatsSection, "💰 Cash: $0")
local chipsLabel = CreateLabel(StatsSection, "🍟 Chips Fed: 0")
local marshLabel = CreateLabel(StatsSection, "🧂 Marshmallows Sold: 0")
local rejoinLabel = CreateLabel(StatsSection, "🔄 Times Rejoined: 0")
local hotChipsLabel = CreateLabel(StatsSection, "🔥 Hot Chips Left: 0")
local cyclesLabel = CreateLabel(StatsSection, "🔄 Cycles: 0")
local cardsSwipedLabel = CreateLabel(StatsSection, "💳 Cards Swiped: 0")

-- ============================================
-- UPDATE STATISTICS (LIVE)
-- ============================================
task.spawn(function()
    local StartTime = os.clock()
    task.wait(2)
    local StartCash = GetCurrentCashAmount()

    local function UpdateStats()
        local Elapsed = math.floor(os.clock() - StartTime)
        Configuration.Statistics.Runtime = Elapsed
        local currentCash = GetCurrentCashAmount()
        Configuration.Statistics.CashMade = currentCash - StartCash

        pcall(function()
            statusLabel:Update("📌 Status: " .. (Configuration.State.Status or "Idle"))
            runtimeLabel:Update("⏰ Runtime: " .. FormatRuntime(Elapsed))
            cashLabel:Update("💰 Cash: $" .. GetCommaValue(currentCash))
            chipsLabel:Update("🍟 Chips Fed: " .. Configuration.Statistics.ChipsFed)
            marshLabel:Update("🧂 Marshmallows Sold: " .. Configuration.Statistics.MarshmallowsSold)
            rejoinLabel:Update("🔄 Times Rejoined: " .. Configuration.Statistics.TimesRejoined)
            hotChipsLabel:Update("🔥 Hot Chips Left: " .. CountHotChips())
            cyclesLabel:Update("🔄 Cycles: " .. Configuration.Statistics.CyclesCompleted)
            cardsSwipedLabel:Update("💳 Cards Swiped: " .. Configuration.Statistics.CardsSwiped)
        end)
    end

    while true do
        local success, err = pcall(UpdateStats)
        if not success then
            task.wait(5)
        else
            task.wait(1)
        end
    end
end)

-- ============================================
-- AUTO REJOINER SETUP
-- ============================================
if getgenv().AutoRejoinerEnabled then
    getgenv().AutoRejoinerEnabled = nil
    Configuration.Statistics.TimesRejoined = Configuration.Statistics.TimesRejoined + 1
    Configuration.Main_Settings.Autofarming = true
    task.spawn(function()
        repeat task.wait(0.5) until not PlayerGui:FindFirstChild("IntroUI")
        task.wait(2)
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Z, false, game)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Z, false, game)
        repeat task.wait(0.5) until SpawnAndSitOnBike() or not Configuration.Main_Settings.Autofarming
        if Configuration.Main_Settings.Autofarming then
            MainAutofarmController()
        end
    end)
end

-- ============================================
-- STUCK DETECTION
-- ============================================
task.spawn(function()
    local LastCash = 0
    local LastCashTime = os.clock()
    local LastStatus = ""
    local LastStatusTime = os.clock()
    task.wait(60)
    LastCash = GetCurrentCashAmount()
    LastStatus = Configuration.State.Status
    while task.wait(30) do
        if not Configuration.Main_Settings.Autofarming then
            LastCashTime = os.clock()
            LastStatusTime = os.clock()
            LastCash = GetCurrentCashAmount()
            LastStatus = Configuration.State.Status
            continue
        end
        local now = os.clock()
        local currentCash = GetCurrentCashAmount()
        local currentStatus = Configuration.State.Status
        if currentCash ~= LastCash then LastCash = currentCash; LastCashTime = now end
        if currentStatus ~= LastStatus then LastStatus = currentStatus; LastStatusTime = now end
        if (now - LastCashTime) >= 300 or (now - LastStatusTime) >= 300 then
            DoRejoin()
            return
        end
    end
end)

-- ============================================
-- DEATH HANDLER
-- ============================================
local function ConnectDeathHandler(char)
    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid then return end
    humanoid.Died:Connect(function()
        if Configuration.State.RespawnPending then return end
        if Configuration.Main_Settings.Autofarming and Configuration.Main_Settings.AutoRejoiner then
            task.wait(3)
            DoRejoin()
        end
    end)
end
ConnectDeathHandler(Player.Character)
Player.CharacterAdded:Connect(ConnectDeathHandler)

-- ============================================
-- ANTI-AFK
-- ============================================
Player.Idled:Connect(function()
    if Configuration.Main_Settings.Autofarming then
        local VirtualUser = game:GetService("VirtualUser")
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

Library:Notify({
    Title = "LENGER MULTI FARM",
    Lifetime = 3,
    Text = "Script loaded successfully!"
})