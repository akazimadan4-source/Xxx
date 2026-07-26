-- ============================================
-- AUTO FARM - MARSHMALLOW FARM + BUY MASK + GOAL SYSTEM
-- Siklus: Bike → Mask → Apartment → Water → Safe Zone (20s) → Sugar+Gelatin → Safe Zone (40s) → Bag & Sell
-- UI: Neverlose UI
-- ============================================

if getgenv().WANZZ_LOADED then return end
getgenv().WANZZ_LOADED = true

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LogService = game:GetService("LogService")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local RPC = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("RPC")

-- ============================================
-- ANTI DETEKSI
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
-- KONFIGURASI
-- ============================================
local Configuration = {
    Main_Settings = {
        Autofarming = false,
        AutoAntiDeath = true,
        AutoRejoiner = true,
    },
    Statistics = {
        TimesRejoined = 0,
        Runtime = 0,
        CashMade = 0,
        MarshmallowsSold = 0,
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
    Goal = {
        Enabled = false,
        Type = "Marshmallow", -- "Marshmallow" or "Cash"
        Target = 10,
    },
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

-- ============================================
-- FUNGSI REPAIR BIKE
-- ============================================
local function RepairBike()
    local BikeName = string.format("%s's Car", Player.Name)
    local Bike = Workspace:FindFirstChild(BikeName)
    if not Bike then return false end
    local primary = Bike.PrimaryPart
    if not primary then return false end
    local rot = primary.Rotation
    if math.abs(rot.X) > 10 or math.abs(rot.Z) > 10 then
        Configuration.State.Status = "[BIKE] Repairing bike..."
        local newCF = CFrame.new(primary.Position) * CFrame.Angles(0, rot.Y, 0)
        pcall(function()
            Bike:PivotTo(newCF)
            for _, part in pairs(Bike:GetDescendants()) do
                if part:IsA("BasePart") then part.Anchored = true end
            end
            task.wait(0.5)
            for _, part in pairs(Bike:GetDescendants()) do
                if part:IsA("BasePart") then part.Anchored = false end
            end
        end)
        return true
    end
    return false
end

-- ============================================
-- STEALTH TELEPORT
-- ============================================
local function DirtBikeTeleportStealth(TargetPosition)
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
    RepairBike()
    local startPos = Vehicle.PrimaryPart.Position
    local distance = (startPos - TargetPosition).Magnitude
    pcall(function()
        for _, part in pairs(Vehicle:GetDescendants()) do
            if part:IsA("BasePart") then part.Anchored = true end
        end
    end)
    if distance > 30 then
        local steps = math.min(math.floor(distance / 20), 8)
        for i = 1, steps do
            local fraction = i / steps
            local midPos = startPos:Lerp(TargetPosition, fraction)
            pcall(function() Vehicle:PivotTo(CFrame.new(midPos)) end)
            task.wait(0.15)
        end
    end
    pcall(function()
        Vehicle:PivotTo(CFrame.new(TargetPosition))
        task.wait(0.3)
        for _, part in pairs(Vehicle:GetDescendants()) do
            if part:IsA("BasePart") then part.Anchored = false end
        end
        task.wait(0.2)
        for _, part in pairs(Vehicle:GetDescendants()) do
            if part:IsA("BasePart") then part.Anchored = true end
        end
        task.wait(0.3)
        for _, part in pairs(Vehicle:GetDescendants()) do
            if part:IsA("BasePart") then part.Anchored = false end
        end
    end)
    RepairBike()
    return true
end
local DirtBikeTeleport = DirtBikeTeleportStealth

-- ============================================
-- SPAWN & SIT ON BIKE
-- ============================================
local function SpawnAndSitOnBike()
    local BikeName = string.format("%s's Car", Player.Name)
    local ExistingBike = Workspace:FindFirstChild(BikeName)
    if ExistingBike and ExistingBike:FindFirstChild("DriveSeat") and ExistingBike.DriveSeat.Occupant then
        Configuration.State.BikeSitting = true
        Configuration.State.BikeSpawned = true
        return true
    end
    Configuration.State.Status = "[BIKE] Spawning..."
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
        task.wait(0.15)
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
    return true
end

-- ============================================
-- LOKASI
-- ============================================
local Locations = {
    SafeZone      = Vector3.new(-478.840, 24.000,  389.200),
    BuyMarsh      = Vector3.new(510.817, 4.581, 601.048),
    Healing       = Vector3.new(-769.000,  6.000,  654.000),
    SkiMask       = Vector3.new(-366.980, 0.528, -320.630),
}

-- ============================================
-- FUNGSI BELI SKI MASK
-- ============================================
local function BuySkiMask()
    WaitForReady()
    local CurrentChar = Player.Character
    if not CurrentChar then return end
    if CurrentChar:FindFirstChild("White Ski Mask") then
        Configuration.State.MaskOwned = true
        return
    end
    local backpack = Player:FindFirstChild("Backpack")
    if backpack and backpack:FindFirstChild("White Ski Mask") then
        EquipTool(backpack:FindFirstChild("White Ski Mask"))
        task.wait(0.15)
        RPC:FireServer(makeBuffer("\005"), Player.Character:WaitForChild("White Ski Mask"))
        task.wait(0.15)
        UnequipTools()
        Configuration.State.MaskOwned = true
        return
    end
    Configuration.State.Status = "[MASK] Buying Ski Mask..."
    DirtBikeTeleport(Locations.SkiMask)
    task.wait(0.5)
    local StoreRemote = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("StorePurchase")
    local attempts = 0
    repeat
        pcall(function() StoreRemote:FireServer("White Ski Mask") end)
        task.wait(0.5)
        attempts = attempts + 1
        backpack = Player:FindFirstChild("Backpack")
    until (backpack and backpack:FindFirstChild("White Ski Mask")) or attempts >= 10
    if backpack and backpack:FindFirstChild("White Ski Mask") then
        EquipTool(backpack:FindFirstChild("White Ski Mask"))
        task.wait(0.15)
        RPC:FireServer(makeBuffer("\005"), Player.Character:WaitForChild("White Ski Mask"))
        task.wait(0.15)
        UnequipTools()
        Configuration.State.MaskOwned = true
        Configuration.State.Status = "[MASK] Ski Mask obtained"
    else
        Configuration.State.Status = "[MASK] Failed to buy Ski Mask"
    end
end

-- ============================================
-- MARSHMALLOW FUNCTIONS
-- ============================================
local function ScavengeInventory()
    UnequipTools()
    local Backpack = Player:FindFirstChild("Backpack")
    if not Backpack then return 0,0,0 end
    local Water, Gelatin, SugarBlockBag = 0,0,0
    for _, Object in next, Backpack:GetChildren() do
        if Object.Name == "Water" then Water = Water + 1 end
        if Object.Name == "Gelatin" then Gelatin = Gelatin + 1 end
        if Object.Name == "Sugar Block Bag" then SugarBlockBag = SugarBlockBag + 1 end
    end
    return Water, Gelatin, SugarBlockBag
end

local function PurchaseMarshmallowIngredients()
    WaitForReady()
    local Water, Gelatin, SugarBlockBag = ScavengeInventory()
    if Water >= 1 and Gelatin >= 1 and SugarBlockBag >= 1 then return true end
    local MarshRemote = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("StorePurchase")
    DirtBikeTeleport(Locations.BuyMarsh)
    Configuration.State.Status = "[MARSH] Buying ingredients"
    task.wait(0.5)
    if Water < 1 then pcall(function() MarshRemote:FireServer("Water") end) task.wait(0.5) end
    if Gelatin < 1 then pcall(function() MarshRemote:FireServer("Gelatin") end) task.wait(0.5) end
    if SugarBlockBag < 1 then pcall(function() MarshRemote:FireServer("Sugar Block Bag") end) task.wait(0.5) end
    return true
end

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

local function GetStoveFromApartment(AptObj)
    if not AptObj then return nil end
    if tostring(AptObj):match("Home") then
        return AptObj:FindFirstChild("Cooking Pot")
    else
        local Interior = AptObj:FindFirstChild("Interior")
        if Interior then return Interior:FindFirstChild("Cooking Pot") end
    end
    return nil
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
                    repeat fireproximityprompt(KnobPrompt) task.wait(1) CloseAttempts = CloseAttempts+1 until math.abs(LockPart.Rotation.Y) < 5 or CloseAttempts >= 10
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
                        repeat fireproximityprompt(LockPrompt) task.wait(0.5) LockAttempts = LockAttempts+1 until LockPart.Rotation.X == 90 or LockAttempts >= 10
                        if LockPart.Rotation.X ~= 90 then return StartMarshmallowFarm() end
                    end
                end
            end
        end
    end
    Configuration.State.Status = "[APT] Secured"
    return true
end

local function EnsureApartment()
    if Configuration.State.Apartment and GetStoveFromApartment(Configuration.State.Apartment) then
        return true
    end
    for i = 1, 5 do
        if StartMarshmallowFarm() and Configuration.State.Apartment then
            local stove = GetStoveFromApartment(Configuration.State.Apartment)
            if stove then return true end
        end
        task.wait(2)
    end
    return false
end

local function PourWater()
    WaitForReady()
    if not EnsureApartment() then
        Configuration.State.Status = "[MARSH] No valid apartment"
        return false
    end
    local Stove = GetStoveFromApartment(Configuration.State.Apartment)
    if not Stove then
        Configuration.State.Status = "[MARSH] Stove not found"
        return false
    end
    local CookPrompt = Stove:FindFirstChild("Attachment")
    if CookPrompt then CookPrompt = CookPrompt:FindFirstChild("ProximityPrompt") end
    DirtBikeTeleport(Stove.Position)
    Configuration.State.Status = "[MARSH] Pouring water..."
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
    until not (Player:FindFirstChild("Backpack") and Player.Backpack:FindFirstChild("Water")) or Safety >= 10

    local notif = PlayerGui:FindFirstChild("Main")
    if notif then
        notif = notif:FindFirstChild("BasicNotification")
        if notif and notif.Text == "You do not have permission to cook in this apartment." then
            Configuration.State.Status = "[MARSH] No permission, re-finding apartment..."
            StartMarshmallowFarm()
            return false
        end
    end
    return true
end

local function AddSugarAndGelatin()
    WaitForReady()
    if not EnsureApartment() then
        Configuration.State.Status = "[MARSH] No valid apartment"
        return false
    end
    local Stove = GetStoveFromApartment(Configuration.State.Apartment)
    if not Stove then
        Configuration.State.Status = "[MARSH] Stove not found"
        return false
    end
    local CookPrompt = Stove:FindFirstChild("Attachment")
    if CookPrompt then CookPrompt = CookPrompt:FindFirstChild("ProximityPrompt") end

    DirtBikeTeleport(Stove.Position)
    task.wait(0.5)

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
            Configuration.State.Status = "[MARSH] Sugar failed, retrying..."
            return false
        end
    until not (Player:FindFirstChild("Backpack") and Player.Backpack:FindFirstChild("Sugar Block Bag")) or Safety >= 10

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
            Configuration.State.Status = "[MARSH] Gelatin failed, retrying..."
            return false
        end
    until not (Player:FindFirstChild("Backpack") and Player.Backpack:FindFirstChild("Gelatin")) or Safety >= 10

    return true
end

local function BagMarshmallowAndSell()
    WaitForReady()
    if not EnsureApartment() then return false end
    local Stove = GetStoveFromApartment(Configuration.State.Apartment)
    if not Stove then return false end
    local CookPrompt = Stove:FindFirstChild("Attachment")
    if CookPrompt then CookPrompt = CookPrompt:FindFirstChild("ProximityPrompt") end
    local StoveTimer
    local Timer = Stove:FindFirstChild("Timer")
    if Timer then StoveTimer = Timer:FindFirstChild("TextLabel") end

    Configuration.State.Status = "[MARSH] Waiting for cook"
    DirtBikeTeleport(Locations.SafeZone)
    local waitTime = 0
    repeat task.wait(1) waitTime = waitTime + 1 if waitTime > 130 then break end until StoveTimer and StoveTimer.Text == "0"

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
    until (Player:FindFirstChild("Backpack") and (Player.Backpack:FindFirstChild("Small Marshmallow Bag") or Player.Backpack:FindFirstChild("Medium Marshmallow Bag") or Player.Backpack:FindFirstChild("Large Marshmallow Bag")))

    local lamontAttempts = 0
    repeat WaitForReady() DirtBikeTeleport(Locations.BuyMarsh) task.wait(0.15) lamontAttempts = lamontAttempts + 1 until Workspace:FindFirstChild("Folders") and Workspace.Folders:FindFirstChild("NPCs") and Workspace.Folders.NPCs:FindFirstChild("Lamont Bell") or lamontAttempts > 20

    Configuration.State.Status = "[MARSH] Selling"
    local LamontBell = Workspace:FindFirstChild("Folders") and Workspace.Folders:FindFirstChild("NPCs") and Workspace.Folders.NPCs:FindFirstChild("Lamont Bell")
    if not LamontBell then return false end
    local LamontPrompt = LamontBell:FindFirstChild("UpperTorso")
    if LamontPrompt then LamontPrompt = LamontPrompt:FindFirstChild("ProximityPrompt") end

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
-- MAIN AUTOFARM CONTROLLER
-- ============================================
local AutofarmRunning = false
local GoalReached = false

local function CheckGoal()
    if not Configuration.Goal.Enabled then return false end
    if Configuration.Goal.Type == "Marshmallow" then
        return Configuration.Statistics.MarshmallowsSold >= Configuration.Goal.Target
    elseif Configuration.Goal.Type == "Cash" then
        return GetCurrentCashAmount() >= Configuration.Goal.Target
    end
    return false
end

local function MainAutofarmController()
    if AutofarmRunning then return end
    AutofarmRunning = true
    GoalReached = false

    if not Configuration.State.BikeSitting then
        repeat
            WaitForReady()
            SpawnAndSitOnBike()
            task.wait(1)
        until Configuration.State.BikeSitting or not Configuration.Main_Settings.Autofarming
    end

    if Configuration.Main_Settings.Autofarming and not Configuration.State.MaskOwned then
        BuySkiMask()
    end

    while Configuration.Main_Settings.Autofarming and not GoalReached do
        WaitForReady()

        -- Cek goal setiap siklus
        if CheckGoal() then
            GoalReached = true
            Configuration.State.Status = "[GOAL] ✅ Goal reached! Stopping farm."
            Library:Notification({
                Title = "🎯 Goal Reached!",
                Description = Configuration.Goal.Type == "Marshmallow" and 
                    "Marshmallows sold: " .. Configuration.Statistics.MarshmallowsSold .. "/" .. Configuration.Goal.Target or
                    "Cash: $" .. GetCommaValue(GetCurrentCashAmount()) .. "/$" .. GetCommaValue(Configuration.Goal.Target),
                Duration = 8,
                Icon = "120959262762131"
            })
            Configuration.Main_Settings.Autofarming = false
            autofarmToggleState = false
            break
        end

        -- 1. Siapkan apartemen
        if not EnsureApartment() then
            Configuration.State.Status = "[APT] Cannot find apartment, retrying..."
            task.wait(5)
            continue
        end

        PurchaseMarshmallowIngredients()

        -- 2. Tuang air
        local WaterOk = false
        for retry = 1, 5 do
            if PourWater() then
                WaterOk = true
                break
            else
                Configuration.State.Status = "[MARSH] Retry PourWater ("..retry.."/5)"
                task.wait(2)
            end
        end
        if not WaterOk then
            Configuration.State.Status = "[MARSH] Failed to pour water, restarting cycle"
            task.wait(5)
            continue
        end

        -- 3. Teleport ke safe zone dan tunggu 20 detik
        Configuration.State.Status = "[MARSH] Teleport to safe zone, waiting water 20s"
        DirtBikeTeleport(Locations.SafeZone)
        for i = 20, 1, -1 do
            if not Configuration.Main_Settings.Autofarming or GoalReached then break end
            Configuration.State.Status = "[MARSH] Water waiting: " .. i .. "s (Safe Zone)"
            task.wait(1)
        end

        -- 4. Pastikan apartemen valid sebelum sugar
        if not EnsureApartment() then
            Configuration.State.Status = "[MARSH] Apartment lost, restarting cycle"
            task.wait(3)
            continue
        end

        -- 5. Tambah sugar & gelatin
        local sugarAdded = false
        for retry = 1, 5 do
            if AddSugarAndGelatin() then
                sugarAdded = true
                break
            else
                Configuration.State.Status = "[MARSH] Retry AddSugarAndGelatin ("..retry.."/5)"
                task.wait(2)
            end
        end
        if not sugarAdded then
            Configuration.State.Status = "[MARSH] Failed to add sugar/gelatin, restarting cycle"
            task.wait(5)
            continue
        end

        -- 6. Teleport ke safe zone dan tunggu 40 detik (marshmallow masak)
        Configuration.State.Status = "[MARSH] Teleport to safe zone, cooking 40s"
        DirtBikeTeleport(Locations.SafeZone)
        for i = 40, 1, -1 do
            if not Configuration.Main_Settings.Autofarming or GoalReached then break end
            Configuration.State.Status = "[MARSH] Cooking: " .. i .. "s (Safe Zone)"
            task.wait(1)
        end

        -- 7. Selesaikan marshmallow (kembali ke apartemen)
        BagMarshmallowAndSell()
        Configuration.Statistics.CyclesCompleted = Configuration.Statistics.CyclesCompleted + 1

        -- Cek goal setelah selesai satu siklus
        if CheckGoal() then
            GoalReached = true
            Configuration.State.Status = "[GOAL] ✅ Goal reached! Stopping farm."
            Library:Notification({
                Title = "🎯 Goal Reached!",
                Description = Configuration.Goal.Type == "Marshmallow" and 
                    "Marshmallows sold: " .. Configuration.Statistics.MarshmallowsSold .. "/" .. Configuration.Goal.Target or
                    "Cash: $" .. GetCommaValue(GetCurrentCashAmount()) .. "/$" .. GetCommaValue(Configuration.Goal.Target),
                Duration = 8,
                Icon = "120959262762131"
            })
            Configuration.Main_Settings.Autofarming = false
            autofarmToggleState = false
            break
        end
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
-- UI NEVERLOSE
-- ============================================
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/ImInsane-1337/neverlose-ui/refs/heads/main/source/library.lua"))()
local CheatName = "AUTO FARM"

Library.Folders = {
    Directory = CheatName,
    Configs = CheatName .. "/Configs",
    Assets = CheatName .. "/Assets",
}

local Accent = Color3.fromRGB(255, 80, 80)
local Gradient = Color3.fromRGB(120, 20, 20)

Library.Theme.Accent = Accent
Library.Theme.AccentGradient = Gradient
Library:ChangeTheme("Accent", Accent)
Library:ChangeTheme("AccentGradient", Gradient)

local Window = Library:Window({
    Name = "AUTO FARM",
    SubName = "Marshmallow Farm v1.0",
    Logo = "120959262762131"
})

local KeybindList = Library:KeybindList("Keybinds")

Library:Watermark({
    "AUTO FARM",
    "by Stealth",
    120959262762131
})

task.spawn(function()
    while true do
        local FPS = math.floor(1 / game:GetService("RunService").RenderStepped:Wait())
        Library:Watermark({
            "AUTO FARM",
            "by Stealth",
            120959262762131,
            "FPS: " .. FPS,
            "Runtime: " .. FormatRuntime(Configuration.Statistics.Runtime)
        })
        task.wait(0.5)
    end
end)

Window:Category("Main")

-- ============================================
-- TAB: AUTOFARM
-- ============================================
local FarmPage = Window:Page({Name = "Autofarm", Icon = "138827881557940"})
local FarmSection = FarmPage:Section({Name = "Farm Settings", Side = 1})

local autofarmToggle = FarmSection:Toggle({
    Name = "Autofarming",
    Flag = "Autofarming",
    Default = false,
    Callback = function(Value)
        Configuration.Main_Settings.Autofarming = Value
        if Value then
            task.spawn(function()
                repeat task.wait(0.5) until SpawnAndSitOnBike() or not Configuration.Main_Settings.Autofarming
                if Configuration.Main_Settings.Autofarming then
                    MainAutofarmController()
                end
            end)
        end
    end
})

FarmSection:Toggle({
    Name = "Anti Death",
    Flag = "AntiDeath",
    Default = true,
    Callback = function(Value)
        Configuration.Main_Settings.AutoAntiDeath = Value
    end
})

FarmSection:Toggle({
    Name = "Auto Rejoiner",
    Flag = "AutoRejoiner",
    Default = true,
    Callback = function(Value)
        Configuration.Main_Settings.AutoRejoiner = Value
    end
})

FarmSection:Button({
    Name = "Spawn DirtBike ($35K)",
    Callback = function()
        pcall(function()
            RPC:FireServer(makeBuffer("\001"), "Purchase", "DirtBike")
        end)
    end
})

FarmSection:Button({
    Name = "Rejoin Game",
    Callback = function()
        DoRejoin()
    end
})

-- ============================================
-- TAB: GOAL
-- ============================================
local GoalPage = Window:Page({Name = "Goal", Icon = "138878854069288"})
local GoalSection = GoalPage:Section({Name = "Goal System", Side = 1})

local goalEnabled = GoalSection:Toggle({
    Name = "Enable Goal",
    Flag = "GoalEnabled",
    Default = false,
    Callback = function(Value)
        Configuration.Goal.Enabled = Value
    end
})

local goalType = GoalSection:Dropdown({
    Name = "Goal Type",
    Flag = "GoalType",
    Default = {"Marshmallow"},
    Items = {"Marshmallow", "Cash"},
    Multi = false,
    Callback = function(Value)
        Configuration.Goal.Type = Value[1]
    end
})

local goalTarget = GoalSection:Slider({
    Name = "Target Value",
    Flag = "GoalTarget",
    Min = 1,
    Max = 10000,
    Default = 10,
    Suffix = "",
    Callback = function(Value)
        Configuration.Goal.Target = Value
    end
})

GoalSection:Label("📊 Current Progress"):Label(""):Label(""):Label("")

local goalStatusLabel = GoalSection:Label("🎯 Goal: Disabled")
local goalProgressLabel = GoalSection:Label("📈 Progress: 0 / 0")

-- ============================================
-- TAB: STATS
-- ============================================
local StatsPage = Window:Page({Name = "Stats", Icon = "73789337996373"})
local StatsSection = StatsPage:Section({Name = "Live Statistics", Side = 1})

StatsSection:Label("📌 Status: "):Label("")
StatsSection:Label("⏰ Runtime: "):Label("")
StatsSection:Label("💰 Cash: "):Label("")
StatsSection:Label("🧂 Marshmallows Sold: "):Label("")
StatsSection:Label("🔄 Times Rejoined: "):Label("")
StatsSection:Label("🔄 Cycles: "):Label("")

local statusLabel = StatsSection:Label("📌 Status: Idle")
local runtimeLabel = StatsSection:Label("⏰ Runtime: 00:00:00")
local cashLabel = StatsSection:Label("💰 Cash: $0")
local marshLabel = StatsSection:Label("🧂 Marshmallows Sold: 0")
local rejoinLabel = StatsSection:Label("🔄 Times Rejoined: 0")
local cyclesLabel = StatsSection:Label("🔄 Cycles: 0")

-- ============================================
-- SETTINGS PAGE
-- ============================================
Window:Category("Settings")
local SettingsPage = Library:CreateSettingsPage(Window, KeybindList)

Window:Init()

-- ============================================
-- UPDATE STATISTICS
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
            statusLabel:Set("📌 Status: " .. (Configuration.State.Status or "Idle"))
            runtimeLabel:Set("⏰ Runtime: " .. FormatRuntime(Elapsed))
            cashLabel:Set("💰 Cash: $" .. GetCommaValue(currentCash))
            marshLabel:Set("🧂 Marshmallows Sold: " .. Configuration.Statistics.MarshmallowsSold)
            rejoinLabel:Set("🔄 Times Rejoined: " .. Configuration.Statistics.TimesRejoined)
            cyclesLabel:Set("🔄 Cycles: " .. Configuration.Statistics.CyclesCompleted)

            -- Update goal progress
            if Configuration.Goal.Enabled then
                local current = Configuration.Goal.Type == "Marshmallow" and Configuration.Statistics.MarshmallowsSold or currentCash
                goalStatusLabel:Set("🎯 Goal: " .. Configuration.Goal.Type .. " → " .. Configuration.Goal.Target)
                goalProgressLabel:Set("📈 Progress: " .. current .. " / " .. Configuration.Goal.Target)
            else
                goalStatusLabel:Set("🎯 Goal: Disabled")
                goalProgressLabel:Set("📈 Progress: 0 / 0")
            end
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