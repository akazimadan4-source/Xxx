-- ============================================
-- WANZZ PROJECT - BFG MULTIFARM (FIX BUG)
-- Perbaikan: Teleport halus, feeding akurat, motor tidak terpental
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
-- FALLBACK UNTUK BUFFER
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
        LastCoordIndex = 0,
        MaskOwned = false,
        CardScamInProgress = false,
    },
}

-- ============================================
-- DAFTAR KOORDINAT HOMELESS (12 TITIK)
-- ============================================
local HomelessCoords = {
    Vector3.new(-315.35, 3.72, -361.56),
    Vector3.new(-273.52, 3.85, -211.32),
    Vector3.new(1102.42, 3.36, 527.05),
    Vector3.new(52.89, 3.72, -425.36),
    Vector3.new(152.88, 3.73, -210.08),
    Vector3.new(-522.75, -7.86, -165.08),
    Vector3.new(65.12, 3.73, 68.10),
    Vector3.new(26.04, 3.73, 217.89),
    Vector3.new(520.08, 3.87, -295.52),
    Vector3.new(699.28, 3.72, -427.05),
    Vector3.new(900.03, 3.94, -283.12),
    Vector3.new(874.89, 3.73, -63.02)
}
local TotalCoords = #HomelessCoords

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

-- ============================================
-- FUNGSI REPAIR BIKE (jika terbalik/rusak)
-- ============================================
local function RepairBike()
    local BikeName = string.format("%s's Car", Player.Name)
    local Bike = Workspace:FindFirstChild(BikeName)
    if not Bike then return false end
    
    local primary = Bike.PrimaryPart
    if not primary then return false end
    
    -- Cek apakah motor miring (rotasi X atau Z tidak nol)
    local rot = primary.Rotation
    if math.abs(rot.X) > 10 or math.abs(rot.Z) > 10 then
        Configuration.State.Status = "[BIKE] Repairing bike..."
        -- Reset rotasi ke posisi tegak
        local newCF = CFrame.new(primary.Position) * CFrame.Angles(0, rot.Y, 0)
        pcall(function()
            Bike:PivotTo(newCF)
            for _, part in pairs(Bike:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Anchored = true
                end
            end
            task.wait(0.5)
            for _, part in pairs(Bike:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Anchored = false
                end
            end
        end)
        return true
    end
    return false
end

-- ============================================
-- STEALTH TELEPORT (DIPERBAIKI AGAR MOTOR TIDAK TERPENTAL)
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

    -- Perbaiki motor jika miring
    RepairBike()

    local startPos = Vehicle.PrimaryPart.Position
    local distance = (startPos - TargetPosition).Magnitude
    
    -- Perbaiki: tambahkan anchoring sebelum teleport
    pcall(function()
        for _, part in pairs(Vehicle:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Anchored = true
            end
        end
    end)

    if distance > 30 then
        local steps = math.min(math.floor(distance / 20), 8) -- lebih halus
        for i = 1, steps do
            local fraction = i / steps
            local midPos = startPos:Lerp(TargetPosition, fraction)
            pcall(function()
                Vehicle:PivotTo(CFrame.new(midPos))
            end)
            task.wait(0.08)
        end
    end
    
    pcall(function()
        Vehicle:PivotTo(CFrame.new(TargetPosition))
        -- Tunggu sebentar lalu lepas anchoring
        task.wait(0.3)
        for _, part in pairs(Vehicle:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Anchored = false
            end
        end
        -- Beri jeda agar posisi stabil
        task.wait(0.2)
        -- Kunci lagi sebentar agar tidak terpental
        for _, part in pairs(Vehicle:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Anchored = true
            end
        end
        task.wait(0.3)
        for _, part in pairs(Vehicle:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Anchored = false
            end
        end
    end)

    -- Cek apakah motor masih miring, perbaiki jika perlu
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
    return true
end

-- ============================================
-- LOKASI
-- ============================================
local Locations = {
    SafeZone      = Vector3.new(-478.840, 24.000,  389.200),
    HotChipsMan   = Vector3.new( -41.000,  3.000,  -25.000),
    BuyMarsh      = Vector3.new(510.817, 4.581, 601.048),
    BuyPotato     = Vector3.new(-759.197, 3.489, -194.846),
    Healing       = Vector3.new(-769.000,  6.000,  654.000),
    Clipboard     = Vector3.new(-477.803, 4.855, -435.559),
    PotatoCutter  = Vector3.new(-456.320,  3.870, -466.840),
    PlasticBagLab = Vector3.new(-456.280,  3.654, -472.670),
    FlourBowl     = Vector3.new(-494.640,  3.579, -518.580),
    SkiMask       = Vector3.new(-366.980, 0.528, -320.630),
    FakeID        = Vector3.new( 214.960,  1.857, -332.330),
    ApplyForCard  = Vector3.new( -49.210,  4.000, -310.810),
    CollectCard   = Vector3.new( -39.090,  5.392, -329.700),
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
        task.wait(0.05)
        RPC:FireServer(makeBuffer("\005"), Player.Character:WaitForChild("White Ski Mask"))
        task.wait(0.05)
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
        pcall(function()
            StoreRemote:FireServer("White Ski Mask")
        end)
        task.wait(0.5)
        attempts = attempts + 1
        backpack = Player:FindFirstChild("Backpack")
    until (backpack and backpack:FindFirstChild("White Ski Mask")) or attempts >= 10

    if backpack and backpack:FindFirstChild("White Ski Mask") then
        EquipTool(backpack:FindFirstChild("White Ski Mask"))
        task.wait(0.05)
        RPC:FireServer(makeBuffer("\005"), Player.Character:WaitForChild("White Ski Mask"))
        task.wait(0.05)
        UnequipTools()
        Configuration.State.MaskOwned = true
        Configuration.State.Status = "[MASK] Ski Mask obtained"
    else
        Configuration.State.Status = "[MASK] Failed to buy Ski Mask"
    end
end

-- ============================================
-- FUNGSI CARD SCAM
-- ============================================
local function PurchaseFakeID()
    WaitForReady()
    Configuration.State.Status = "[CARD] Buying fake ID"
    repeat WaitForReady() DirtBikeTeleport(Locations.FakeID) task.wait(0.05)
    until Workspace:FindFirstChild("Folders") and Workspace.Folders:FindFirstChild("NPCs") and Workspace.Folders.NPCs:FindFirstChild("FakeIDSeller")

    local FakeIDSeller = Workspace.Folders.NPCs:FindFirstChild("FakeIDSeller")
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
    until (Player:FindFirstChild("Backpack") and Player.Backpack:FindFirstChild("Fake ID")) or attempts >= 10
    return (Player:FindFirstChild("Backpack") and Player.Backpack:FindFirstChild("Fake ID")) ~= nil
end

local function ApplyForCard()
    WaitForReady()
    Configuration.State.Status = "[CARD] Applying for credit card"
    repeat DirtBikeTeleport(Locations.ApplyForCard) task.wait(0.05)
    until Workspace:FindFirstChild("Folders") and Workspace.Folders:FindFirstChild("NPCs") and Workspace.Folders.NPCs:FindFirstChild("Bank Teller")

    local BankTeller = Workspace.Folders.NPCs:FindFirstChild("Bank Teller")
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
    until not (Player:FindFirstChild("Backpack") and Player.Backpack:FindFirstChild("Fake ID")) or Safety >= 15

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

local function ClaimAndUseCard()
    WaitForReady()
    local function HasCard()
        local backpack = Player:FindFirstChild("Backpack")
        if backpack and backpack:FindFirstChild("Card") then return true end
        local char = Player.Character
        if char and char:FindFirstChild("Card") then return true end
        return false
    end

    if HasCard() then
        Configuration.State.Status = "[CARD] Card already owned"
    else
        Configuration.State.Status = "[CARD] Claiming card"
        local Card = Workspace:FindFirstChild("CardPickup")
        if not Card then return false end
        local CardPrompt = Card:FindFirstChild("Attachment") and Card.Attachment:FindFirstChild("ProximityPrompt")
        if not CardPrompt then return false end
        local Safety = 0
        repeat
            WaitForReady()
            DirtBikeTeleport(Card.Position)
            fireproximityprompt(CardPrompt)
            task.wait(0.5)
            Safety = Safety + 1
        until HasCard() or Safety >= 10
        if not HasCard() then
            local notif = PlayerGui:FindFirstChild("Main") and PlayerGui.Main:FindFirstChild("BasicNotification")
            if notif and notif.Text == "You are not on the wait list for a card." then
                return false
            end
        end
    end

    -- Cari ATM
    local atmAttempts = 0
    local AvailableATM = nil
    repeat
        for _, ATM in next, Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("ATMS") and Workspace.Map.ATMS:GetChildren() or {} do
            if ATM:FindFirstChild("ATMScreen") and ATM.ATMScreen.Transparency == 0 then
                AvailableATM = ATM
                break
            end
        end
        if not AvailableATM then task.wait(1) end
        atmAttempts = atmAttempts + 1
    until AvailableATM or atmAttempts >= 10
    if not AvailableATM then return false end

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

    if not PlayerGui:FindFirstChild("ATM") then return false end

    -- Equip card
    local card = Player:FindFirstChild("Backpack") and Player.Backpack:FindFirstChild("Card")
    if card then EquipTool(card) end
    task.wait(0.5)

    -- Klik swipe
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
    end
    return true
end

-- ============================================
-- MARSHMALLOW FUNCTIONS
-- ============================================
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

-- ============================================
-- MARSHMALLOW DENGAN TIMER
-- ============================================
local function PourWater()
    WaitForReady()
    local AptObj = Configuration.State.Apartment
    if not AptObj then return false end
    local Stove
    if tostring(AptObj):match("Home") then Stove = AptObj:FindFirstChild("Cooking Pot")
    else
        local Interior = AptObj:FindFirstChild("Interior")
        if Interior then Stove = Interior:FindFirstChild("Cooking Pot") end
    end
    if not Stove then return false end
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
    until not (Player:FindFirstChild("Backpack") and Player.Backpack:FindFirstChild("Water")) or Safety >= 10
    local notif = PlayerGui:FindFirstChild("Main")
    if notif then
        notif = notif:FindFirstChild("BasicNotification")
        if notif and notif.Text == "You do not have permission to cook in this apartment." then
            return false
        end
    end
    return true
end

local function AddSugarAndGelatin()
    WaitForReady()
    local AptObj = Configuration.State.Apartment
    if not AptObj then return false end
    local Stove
    if tostring(AptObj):match("Home") then Stove = AptObj:FindFirstChild("Cooking Pot")
    else
        local Interior = AptObj:FindFirstChild("Interior")
        if Interior then Stove = Interior:FindFirstChild("Cooking Pot") end
    end
    if not Stove then return false end
    local CookPrompt = Stove:FindFirstChild("Attachment")
    if CookPrompt then CookPrompt = CookPrompt:FindFirstChild("ProximityPrompt") end
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
    until not (Player:FindFirstChild("Backpack") and Player.Backpack:FindFirstChild("Sugar Block Bag")) or Safety >= 5
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
    until not (Player:FindFirstChild("Backpack") and Player.Backpack:FindFirstChild("Gelatin")) or Safety >= 5
end

local function BagMarshmallowAndSell()
    WaitForReady()
    local AptObj = Configuration.State.Apartment
    if not AptObj then return false end
    local Stove
    if tostring(AptObj):match("Home") then Stove = AptObj:FindFirstChild("Cooking Pot")
    else
        local Interior = AptObj:FindFirstChild("Interior")
        if Interior then Stove = Interior:FindFirstChild("Cooking Pot") end
    end
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
    repeat WaitForReady() DirtBikeTeleport(Locations.BuyMarsh) task.wait(0.05) lamontAttempts = lamontAttempts + 1 until Workspace:FindFirstChild("Folders") and Workspace.Folders:FindFirstChild("NPCs") and Workspace.Folders.NPCs:FindFirstChild("Lamont Bell") or lamontAttempts > 20
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
-- POTATO CHIPS FUNCTIONS
-- ============================================
local AvailablePot, PotPrompt, PotTimer
local Labatory = Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("Locations") and Workspace.Map.Locations:FindFirstChild("The Laboratory")

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
    return true
end

local function StartPotatoJob()
    WaitForReady()
    if not Labatory then return false end
    local Prompts = Labatory:FindFirstChild("Prompts")
    if not Prompts then return false end
    local Clipboard = Prompts:FindFirstChild("Clipboard")
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
    if not Labatory then return false end
    local CuttingBoards = Labatory:FindFirstChild("Cutting Boards")
    if not CuttingBoards then return false end
    local PotatoCutterModel = CuttingBoards:FindFirstChild("Potato Cutter")
    if not PotatoCutterModel then return false end
    local Model = PotatoCutterModel:FindFirstChild("Model")
    if not Model then return false end
    local Union = Model:FindFirstChild("Union")
    if not Union then return false end
    local CutterPrompt = Union:FindFirstChild("Attachment")
    if CutterPrompt then CutterPrompt = CutterPrompt:FindFirstChild("ProximityPrompt") end
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
    until not (Player:FindFirstChild("Backpack") and Player.Backpack:FindFirstChild("Potato"))
    return true
end

local function BagPotato()
    WaitForReady()
    if not Labatory then return false end
    local Prompts = Labatory:FindFirstChild("Prompts")
    if not Prompts then return false end
    local PlasticBag = Prompts:FindFirstChild("Plastic Bag")
    if not PlasticBag then return false end
    local BagPrompt = PlasticBag:FindFirstChild("Attachment")
    if BagPrompt then BagPrompt = BagPrompt:FindFirstChild("ProximityPrompt") end
    if BagPrompt then pcall(function() BagPrompt.MaxActivationDistance = 9e9 end) end
    Configuration.State.Status = "[POTATO] Bagging"
    if Player:FindFirstChild("Backpack") and Player.Backpack:FindFirstChild("Potato") then return true end
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
    if not Labatory then return false end
    local Bowls = Labatory:FindFirstChild("Bowls")
    if not Bowls then return false end
    local Bowl = Bowls:FindFirstChildOfClass("UnionOperation")
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
    until not (Player:FindFirstChild("Backpack") and Player.Backpack:FindFirstChild("Flour"))
    task.wait(3.5)
    return true
end

local function CookPotatoChips()
    WaitForReady()
    if not Labatory then return false end
    Configuration.State.Status = "[POTATO] Starting cook"
    AvailablePot = nil
    local Pots = Labatory:FindFirstChild("Pots")
    if not Pots then return false end
    for _, Object in next, Pots:GetChildren() do
        if AvailablePot then break end
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
            local Notif = PlayerGui:FindFirstChild("Main")
            if Notif then
                Notif = Notif:FindFirstChild("BasicNotification")
                if Notif then
                    Notif = Notif.Text
                    if Notif == "This pot is in use." then
                        repeat task.wait() until PlayerGui.Main.BasicNotification.TextTransparency == 1
                    elseif Notif == "You have 120 seconds to retrieve your product out of the pot when its done." then
                        AvailablePot = Object
                        local Timer = Object:FindFirstChild("Timer")
                        if Timer then PotTimer = Timer:FindFirstChild("TextLabel") end
                        PotPrompt = Object:FindFirstChild("ProximityPrompt")
                    end
                end
            end
        end
    end
    return AvailablePot ~= nil
end

-- ============================================
-- CLAIM & FEED HOMELESS (DIPERBAIKI)
-- ============================================
local function ClaimPotatoChipsAndSell()
    WaitForReady()
    Configuration.State.Status = "[POTATO] Waiting for cook"
    DirtBikeTeleport(Locations.SafeZone)
    local waitTime = 0
    repeat task.wait(1) waitTime = waitTime + 1 if waitTime > 130 then break end until PotTimer and PotTimer.Text == "0"

    -- Claim dari pot
    Configuration.State.Status = "[POTATO] Claiming from pot"
    local claimAttempts = 0
    repeat
        WaitForReady()
        DirtBikeTeleport(AvailablePot.Position)
        if PotPrompt then fireproximityprompt(PotPrompt) end
        task.wait(0.5)
        claimAttempts = claimAttempts + 1
        if claimAttempts > 20 then break end
    until Player:FindFirstChild("Backpack") and Player.Backpack:FindFirstChild("Potato Chips")

    -- Convert ke Hot Chips
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

    local PoorGuyPrompt = PoorGuy:FindFirstChild("UpperTorso")
    if PoorGuyPrompt then PoorGuyPrompt = PoorGuyPrompt:FindFirstChild("ProximityPrompt") end

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
    until Player:FindFirstChild("Backpack") and Player.Backpack:FindFirstChild("Hot Chips")

    task.wait(2)

    -- ============================================
    -- FEEDING HOMELESS (SAMA SEPERTI INTERAKSI LAMONT BELL)
    -- ============================================
    local fedCount = 0
    local maxFeedingAttempts = 50

    while Configuration.Main_Settings.Autofarming and fedCount < maxFeedingAttempts do
        local hotChips = Player:FindFirstChild("Backpack") and Player.Backpack:FindFirstChild("Hot Chips")
        if not hotChips then break end

        local lastIdx = Configuration.State.LastCoordIndex or 0
        local nextIdx = (lastIdx % TotalCoords) + 1
        local coord = HomelessCoords[nextIdx]

        Configuration.State.Status = "[POTATO] Feeding at coord " .. nextIdx .. "/" .. TotalCoords

        -- CARI NPC HOMELESS DENGAN METODE SAMA SEPERTI LAMONT BELL
        local targetNPC = nil
        local prompt = nil

        -- 1. Coba cari di Folder NPCs (kalau ada)
        local npcFolder = Workspace:FindFirstChild("Folders") and Workspace.Folders:FindFirstChild("NPCs")
        if npcFolder then
            for _, npc in pairs(npcFolder:GetChildren()) do
                if npc:IsA("Model") and npc:FindFirstChildOfClass("Humanoid") then
                    local upper = npc:FindFirstChild("UpperTorso")
                    if upper then
                        local dist = (upper.Position - coord).Magnitude
                        if dist < 30 then
                            targetNPC = npc
                            break
                        end
                    end
                end
            end
        end

        -- 2. Jika tidak ketemu, cari di seluruh Workspace (fallback)
        if not targetNPC then
            for _, npc in pairs(Workspace:GetDescendants()) do
                if npc:IsA("Model") and npc:FindFirstChildOfClass("Humanoid") then
                    local upper = npc:FindFirstChild("UpperTorso")
                    if upper then
                        local dist = (upper.Position - coord).Magnitude
                        if dist < 30 then
                            targetNPC = npc
                            break
                        end
                    end
                end
            end
        end

        if targetNPC then
            -- Ambil prompt dari UpperTorso (sama seperti Lamont Bell)
            local upper = targetNPC:FindFirstChild("UpperTorso")
            if upper then
                prompt = upper:FindFirstChild("ProximityPrompt")
                if not prompt then
                    -- Fallback: cari di Attachment
                    local att = upper:FindFirstChild("Attachment")
                    if att then prompt = att:FindFirstChild("ProximityPrompt") end
                end
            end
        end

        if prompt then
            pcall(function()
                prompt.MaxActivationDistance = 50
                prompt.HoldDuration = 0
            end)

            -- Teleport halus ke koordinat homeless
            DirtBikeTeleport(coord)
            task.wait(1.2) -- jeda agar prompt siap

            -- Equip Hot Chips (sama seperti equip bahan di marshmallow)
            local equipSuccess = false
            for retry = 1, 3 do
                hotChips = Player:FindFirstChild("Backpack") and Player.Backpack:FindFirstChild("Hot Chips")
                if hotChips then
                    EquipTool(hotChips)
                    task.wait(0.2)
                    if Player.Character and Player.Character:FindFirstChild("Hot Chips") then
                        equipSuccess = true
                        break
                    end
                end
                task.wait(0.3)
            end

            if equipSuccess then
                fireproximityprompt(prompt)
                task.wait(0.5)
                UnequipTools()
                fedCount = fedCount + 1
                Configuration.Statistics.ChipsFed = Configuration.Statistics.ChipsFed + 1
                Configuration.State.LastCoordIndex = nextIdx
                Configuration.State.Status = "[POTATO] Fed at coord " .. nextIdx .. " (" .. fedCount .. " given)"
            else
                Configuration.State.Status = "[POTATO] Failed to equip at coord " .. nextIdx
                task.wait(1)
            end
        else
            Configuration.State.LastCoordIndex = nextIdx
            Configuration.State.Status = "[POTATO] No NPC at coord " .. nextIdx .. ", skipping"
            task.wait(0.5)
        end
    end

    Configuration.State.Status = "[POTATO] Feeding done (" .. fedCount .. " chips given)"
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
-- MAIN AUTOFARM CONTROLLER (DENGAN TIMER)
-- ============================================
local AutofarmRunning = false

local function MainAutofarmController()
    if AutofarmRunning then return end
    AutofarmRunning = true

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

    while Configuration.Main_Settings.Autofarming do
        WaitForReady()

        -- ================================
        -- 1. Siapkan apartemen dan bahan marshmallow
        -- ================================
        local ApartmentOk = StartMarshmallowFarm()
        if not ApartmentOk then task.wait(5) continue end

        PurchaseMarshmallowIngredients()

        -- ================================
        -- 2. Tuang air (mulai timer 20 detik)
        -- ================================
        local WaterOk = PourWater()
        if not WaterOk then
            repeat StartMarshmallowFarm(); WaterOk = PourWater() until WaterOk
        end

        -- ================================
        -- 3. Sambil menunggu 20 detik, lakukan persiapan potato chips
        -- ================================
        local potatoPrepDone = false
        task.spawn(function()
            PurchasePotatoIngredients()
            StartPotatoJob()
            CutPotato()
            BagPotato()
            MixFlourAndPotato()
            CookPotatoChips()
            potatoPrepDone = true
        end)

        -- Countdown 20 detik untuk air
        for i = 20, 1, -1 do
            if not Configuration.Main_Settings.Autofarming then break end
            Configuration.State.Status = "[MARSH] Waiting water: " .. i .. "s"
            task.wait(1)
        end

        -- Pastikan persiapan potato selesai (jika belum)
        while not potatoPrepDone and Configuration.Main_Settings.Autofarming do
            task.wait(0.5)
        end

        -- ================================
        -- 4. Tambahkan sugar dan gelatin (mulai timer 40 detik)
        -- ================================
        AddSugarAndGelatin()

        -- ================================
        -- 5. Selama 40 detik, lakukan card scam (jika aktif)
        -- ================================
        if Configuration.Main_Settings.EnableCardScam then
            task.spawn(function()
                PurchaseFakeID()
                ApplyForCard()
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
                        end
                        break
                    end
                until os.clock() - startNotif > 40
            end)
        end

        -- Countdown 40 detik untuk marshmallow matang
        for i = 40, 1, -1 do
            if not Configuration.Main_Settings.Autofarming then break end
            Configuration.State.Status = "[MARSH] Cooking: " .. i .. "s"
            task.wait(1)
        end

        -- ================================
        -- 6. Sekarang marshmallow selesai, potato chips juga selesai (60 detik)
        -- ================================
        BagMarshmallowAndSell()
        ClaimPotatoChipsAndSell()

        -- Jika card scam sukses, ambil kartu dan swipe
        if Configuration.Main_Settings.EnableCardScam then
            ClaimAndUseCard()
        end

        -- Reset variabel untuk siklus berikutnya
        AvailablePot = nil; PotPrompt = nil; PotTimer = nil
        Configuration.Statistics.CyclesCompleted = Configuration.Statistics.CyclesCompleted + 1
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
-- UI MENGGUNAKAN LILUI
-- ============================================
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Eliuutho/lilui/main/lilui.lua"))()

local Window = UI:CreateWindow({
    Title = "WANZZ MULTIFARM",
    Author = "Stealth",
})

local MainTab = Window:Tab({ Title = "Main", Icon = "home" })

MainTab:Section({ Title = "Controls" })

local autofarmToggleState = false
MainTab:Toggle({
    Title = "Autofarming",
    Desc = "Start/Stop the farm",
    Value = false,
    Callback = function(v)
        autofarmToggleState = v
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

local antiDeathToggleState = true
MainTab:Toggle({
    Title = "Anti Death",
    Desc = "Teleport to safe zone when low HP",
    Value = true,
    Callback = function(v)
        antiDeathToggleState = v
        Configuration.Main_Settings.AutoAntiDeath = v
    end
})

local rejoinToggleState = true
MainTab:Toggle({
    Title = "Auto Rejoiner",
    Desc = "Rejoin when stuck or die",
    Value = true,
    Callback = function(v)
        rejoinToggleState = v
        Configuration.Main_Settings.AutoRejoiner = v
    end
})

local cardScamToggleState = true
MainTab:Toggle({
    Title = "Card Scam",
    Desc = "Fake ID -> Apply Card -> Swipe ATM",
    Value = true,
    Callback = function(v)
        cardScamToggleState = v
        Configuration.Main_Settings.EnableCardScam = v
    end
})

MainTab:Section({ Title = "Actions" })

MainTab:Button({
    Title = "Spawn DirtBike ($35K)",
    Desc = "Spawn a dirt bike",
    Callback = function()
        pcall(function()
            RPC:FireServer(makeBuffer("\001"), "Purchase", "DirtBike")
        end)
    end
})

MainTab:Button({
    Title = "Rejoin Game",
    Desc = "Teleport to lobby",
    Callback = function()
        DoRejoin()
    end
})

-- Status Tab
local StatusTab = Window:Tab({ Title = "Stats", Icon = "chart" })

StatusTab:Section({ Title = "Live Statistics" })

local statusLabel = StatusTab:Label({ Title = "📌 Status: Idle" })
local runtimeLabel = StatusTab:Label({ Title = "⏰ Runtime: 00:00:00" })
local cashLabel = StatusTab:Label({ Title = "💰 Cash: $0" })
local chipsLabel = StatusTab:Label({ Title = "🍟 Chips Fed: 0" })
local marshLabel = StatusTab:Label({ Title = "🧂 Marshmallows Sold: 0" })
local rejoinLabel = StatusTab:Label({ Title = "🔄 Times Rejoined: 0" })
local hotChipsLabel = StatusTab:Label({ Title = "🔥 Hot Chips Left: 0" })
local cyclesLabel = StatusTab:Label({ Title = "🔄 Cycles: 0" })
local cardsSwipedLabel = StatusTab:Label({ Title = "💳 Cards Swiped: 0" })

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
            chipsLabel:Set("🍟 Chips Fed: " .. Configuration.Statistics.ChipsFed)
            marshLabel:Set("🧂 Marshmallows Sold: " .. Configuration.Statistics.MarshmallowsSold)
            rejoinLabel:Set("🔄 Times Rejoined: " .. Configuration.Statistics.TimesRejoined)
            hotChipsLabel:Set("🔥 Hot Chips Left: " .. CountHotChips())
            cyclesLabel:Set("🔄 Cycles: " .. Configuration.Statistics.CyclesCompleted)
            cardsSwipedLabel:Set("💳 Cards Swiped: " .. Configuration.Statistics.CardsSwiped)
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