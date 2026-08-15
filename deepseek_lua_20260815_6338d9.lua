-- ============================================
-- WANZZ MARSHMALLOW - TWEEN TELEPORT SYSTEM
-- Tanpa Motor, Tanpa Mask, Tanpa Safe Zone
-- Apartment Biasa (WH1, BH3, BH2, BH4, BH1, LT1)
-- UNDERGROUND SAAT BELI BAHAN
-- ============================================

if getgenv().WANZZ_LOADED then return end
getgenv().WANZZ_LOADED = true

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LogService = game:GetService("LogService")
local ProximityPromptService = game:GetService("ProximityPromptService")

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
-- KONFIGURASI
-- ============================================
local Configuration = {
    Main_Settings = {
        Autofarming = false,
    },
    State = {
        Status = "Idle",
        Apartment = nil,
        ApartmentOwned = false,
    },
}

-- ============================================
-- LOKASI KOORDINAT
-- ============================================
local Locations = {
    BuyMarsh      = Vector3.new(510.817, 4.581, 601.048),
    Underground   = Vector3.new(0, -500, 0),
}

-- ============================================
-- LIST APARTEMEN (BIASA SAJA)
-- ============================================
local ApartmentList = {
    {name = "WH1", pos = Vector3.new(-438.000, 10.000, -370.000)},
    {name = "BH3", pos = Vector3.new(-290.000, 15.000, -450.000)},
    {name = "BH2", pos = Vector3.new(-260.000, 15.000, -480.000)},
    {name = "BH4", pos = Vector3.new(-320.000, 15.000, -420.000)},
    {name = "BH1", pos = Vector3.new(-230.000, 15.000, -510.000)},
    {name = "LT1", pos = Vector3.new(190.000, 15.000, -530.000)},
}

-- ============================================
-- TWEEN TELEPORT (TANPA MOTOR)
-- ============================================
local function TweenTeleport(TargetPosition)
    local character = Player.Character
    if not character then
        Player.CharacterAdded:Wait()
        character = Player.Character
        task.wait(0.3)
    end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return false end
    
    pcall(function()
        humanoidRootPart.CFrame = CFrame.new(Locations.Underground)
    end)
    task.wait(0.05)
    
    local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
    local tween = TweenService:Create(humanoidRootPart, tweenInfo, {
        CFrame = CFrame.new(TargetPosition)
    })
    tween:Play()
    tween.Completed:Wait()
    
    return true
end

-- ============================================
-- AUTO RESPAWN
-- ============================================
local function AutoRespawn()
    Configuration.State.Status = "🔄 Auto Respawn..."
    local character = Player.Character
    if not character then
        Player.CharacterAdded:Wait()
        return true
    end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.Health = 0
        Player.CharacterAdded:Wait()
        task.wait(0.8)
        return true
    end
    return false
end

-- ============================================
-- BUAT PROXIMITY PROMPT INSTAN
-- ============================================
local function MakePromptInstant()
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("ProximityPrompt") then
            pcall(function()
                v.HoldDuration = 0
                v.MaxActivationDistance = 50
                v.RequiresLineOfSight = false
            end)
        end
    end
    
    ProximityPromptService.PromptButtonHoldBegan:Connect(function(v)
        pcall(function() v.HoldDuration = 0 end)
    end)
end
MakePromptInstant()

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

-- ============================================
-- SCAN INVENTORY
-- ============================================
local function ScavengeInventory()
    UnequipTools()
    local Backpack = Player:FindFirstChild("Backpack")
    if not Backpack then return 0,0,0,0 end
    local Water, Gelatin, SugarBlockBag, EmptyBag = 0,0,0,0
    for _, Object in next, Backpack:GetChildren() do
        if Object.Name == "Water" then Water = Water + 1 end
        if Object.Name == "Gelatin" then Gelatin = Gelatin + 1 end
        if Object.Name == "Sugar Block Bag" then SugarBlockBag = SugarBlockBag + 1 end
        if Object.Name == "Empty Bag" then EmptyBag = EmptyBag + 1 end
    end
    return Water, Gelatin, SugarBlockBag, EmptyBag
end

-- ============================================
-- CARI APARTEMEN
-- ============================================
local function FindAvailableApartment()
    Configuration.State.Status = "🔍 Cari Apartemen..."
    local map = Workspace:FindFirstChild("Map")
    if not map then return nil end
    
    local apts = map:FindFirstChild("APTS")
    if not apts then return nil end
    
    -- Cek apartemen milik sendiri dulu
    for _, aptData in pairs(ApartmentList) do
        local apt = apts:FindFirstChild(aptData.name)
        if apt then
            local Board = apt:FindFirstChild("Board", true)
            if Board then
                local nameLabel = Board:FindFirstChild("name")
                if nameLabel then
                    local surfaceGui = nameLabel:FindFirstChild("SurfaceGui")
                    if surfaceGui then
                        local textLabel = surfaceGui:FindFirstChild("TextLabel")
                        if textLabel and textLabel.Text == Player.Name then
                            Configuration.State.ApartmentOwned = true
                            return aptData
                        end
                    end
                end
            end
        end
    end
    
    -- Cari apartemen kosong
    for _, aptData in pairs(ApartmentList) do
        local apt = apts:FindFirstChild(aptData.name)
        if apt then
            local Board = apt:FindFirstChild("Board", true)
            if Board then
                local nameLabel = Board:FindFirstChild("name")
                if nameLabel then
                    local surfaceGui = nameLabel:FindFirstChild("SurfaceGui")
                    if surfaceGui then
                        local textLabel = surfaceGui:FindFirstChild("TextLabel")
                        if textLabel and textLabel.Text == "VACANT" then
                            Configuration.State.ApartmentOwned = false
                            return aptData
                        end
                    end
                end
            end
        end
    end
    
    return nil
end

-- ============================================
-- BELI & KUNCI APARTEMEN
-- ============================================
local function BuyAndSecureApartment(aptData)
    if not aptData then return false end
    
    Configuration.State.Status = "🏠 Beli & Kunci Apartemen..."
    local map = Workspace:FindFirstChild("Map")
    if not map then return false end
    
    local apts = map:FindFirstChild("APTS")
    if not apts then return false end
    
    local apt = apts:FindFirstChild(aptData.name)
    if not apt then return false end
    
    -- Beli apartemen jika belum punya
    if not Configuration.State.ApartmentOwned then
        local Board = apt:FindFirstChild("Board", true)
        if Board then
            local backboard = Board:FindFirstChild("backboard")
            if backboard then
                local Prompt = backboard:FindFirstChild("ProximityPrompt")
                if Prompt then
                    pcall(function() Prompt.MaxActivationDistance = 9e9 end)
                    TweenTeleport(backboard.Position)
                    fireproximityprompt(Prompt)
                    task.wait(2)
                    
                    local nameLabel = Board:FindFirstChild("name")
                    if nameLabel then
                        local surfaceGui = nameLabel:FindFirstChild("SurfaceGui")
                        if surfaceGui then
                            local textLabel = surfaceGui:FindFirstChild("TextLabel")
                            if textLabel and textLabel.Text == Player.Name then
                                Configuration.State.ApartmentOwned = true
                            end
                        end
                    end
                end
            end
        end
    end
    
    -- Kunci pintu
    local Door = apt:FindFirstChild("Door")
    if Door then
        local DoorLock = Door:FindFirstChild("DoorLock")
        local Interact = Door:FindFirstChild("Interact")
        if DoorLock and Interact then
            local LockPart = DoorLock:FindFirstChild("Part")
            local KnobPrompt = Interact:FindFirstChild("Attachment")
            if KnobPrompt then KnobPrompt = KnobPrompt:FindFirstChild("ProximityPrompt") end
            if LockPart and KnobPrompt then
                -- Tutup pintu
                if math.abs(LockPart.Rotation.Y) > 5 and math.abs(LockPart.Rotation.Y - 90) > 5 then
                    pcall(function() KnobPrompt.MaxActivationDistance = 9e9 end)
                    TweenTeleport(LockPart.Position)
                    task.wait(0.3)
                    local CloseAttempts = 0
                    repeat 
                        fireproximityprompt(KnobPrompt) 
                        task.wait(0.5) 
                        CloseAttempts = CloseAttempts+1 
                    until math.abs(LockPart.Rotation.Y) < 5 or CloseAttempts >= 10
                    task.wait(0.3)
                end
                -- Kunci pintu
                if LockPart.Rotation.X ~= 90 then
                    local LockPrompt = LockPart:FindFirstChild("ProximityPrompt")
                    if LockPrompt then
                        pcall(function() LockPrompt.MaxActivationDistance = 9e9 end)
                        TweenTeleport(LockPart.Position)
                        task.wait(0.3)
                        local LockAttempts = 0
                        repeat 
                            fireproximityprompt(LockPrompt) 
                            task.wait(0.5) 
                            LockAttempts = LockAttempts+1 
                        until LockPart.Rotation.X == 90 or LockAttempts >= 10
                    end
                end
            end
        end
    end
    
    Configuration.State.Apartment = apt
    return true
end

-- ============================================
-- GET STOVE DARI APARTEMEN
-- ============================================
local function GetStove()
    local apt = Configuration.State.Apartment
    if not apt then return nil end
    
    local interior = apt:FindFirstChild("Interior")
    if interior then
        return interior:FindFirstChild("Cooking Pot")
    end
    return nil
end

-- ============================================
-- BELI BAHAN (DENGAN UNDERGROUND TELEPORT)
-- ============================================
local function PurchaseMarshmallowIngredients()
    Configuration.State.Status = "📦 Beli Bahan..."
    local Water, Gelatin, SugarBlockBag, EmptyBag = ScavengeInventory()
    if Water >= 1 and Gelatin >= 1 and SugarBlockBag >= 1 and EmptyBag >= 1 then 
        Configuration.State.Status = "✅ Bahan cukup, lanjut..."
        return true 
    end
    
    -- Teleport ke penjual
    TweenTeleport(Locations.BuyMarsh)
    task.wait(0.3)
    
    local MarshRemote = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("StorePurchase")
    
    -- Beli bahan
    if Water < 1 then 
        pcall(function() MarshRemote:FireServer("Water") end) 
        task.wait(0.3) 
    end
    if Gelatin < 1 then 
        pcall(function() MarshRemote:FireServer("Gelatin") end) 
        task.wait(0.3) 
    end
    if SugarBlockBag < 1 then 
        pcall(function() MarshRemote:FireServer("Sugar Block Bag") end) 
        task.wait(0.3) 
    end
    if EmptyBag < 1 then 
        pcall(function() MarshRemote:FireServer("Empty Bag") end) 
        task.wait(0.3) 
    end
    
    -- === UNDERGROUND TELEPORT SETELAH BELI ===
    Configuration.State.Status = "⬇️ Underground setelah beli..."
    TweenTeleport(Locations.Underground)
    task.wait(0.3)
    
    return true
end

-- ============================================
-- TUANG AIR
-- ============================================
local function PourWater()
    local stove = GetStove()
    if not stove then return false end
    
    local CookPrompt = stove:FindFirstChild("Attachment")
    if CookPrompt then CookPrompt = CookPrompt:FindFirstChild("ProximityPrompt") end
    
    Configuration.State.Status = "💧 Tuang Water..."
    TweenTeleport(stove.Position)
    task.wait(0.3)
    
    local Safety = 0
    repeat
        local water = Player:FindFirstChild("Backpack") and Player.Backpack:FindFirstChild("Water")
        if water then EquipTool(water) end
        TweenTeleport(stove.Position)
        if CookPrompt then
            pcall(function()
                CookPrompt.MaxActivationDistance = 50
                CookPrompt.HoldDuration = 0
            end)
            fireproximityprompt(CookPrompt)
        end
        task.wait(0.5)
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
    
    Configuration.State.Status = "⏳ Tunggu air mendidih (10s)..."
    task.wait(10)
    return true
end

-- ============================================
-- TAMBAH GULA & GELATIN
-- ============================================
local function AddSugarAndGelatin()
    local stove = GetStove()
    if not stove then return false end
    
    local CookPrompt = stove:FindFirstChild("Attachment")
    if CookPrompt then CookPrompt = CookPrompt:FindFirstChild("ProximityPrompt") end
    
    Configuration.State.Status = "🍬 Tambah Sugar..."
    TweenTeleport(stove.Position)
    task.wait(0.3)
    
    local Safety = 0
    repeat
        local sugar = Player:FindFirstChild("Backpack") and Player.Backpack:FindFirstChild("Sugar Block Bag")
        if sugar then EquipTool(sugar) end
        TweenTeleport(stove.Position)
        if CookPrompt then fireproximityprompt(CookPrompt) end
        task.wait(0.5)
        UnequipTools()
        Safety = Safety + 1
    until not (Player:FindFirstChild("Backpack") and Player.Backpack:FindFirstChild("Sugar Block Bag")) or Safety >= 5
    
    Configuration.State.Status = "🧪 Tambah Gelatin..."
    Safety = 0
    repeat
        local gelatin = Player:FindFirstChild("Backpack") and Player.Backpack:FindFirstChild("Gelatin")
        if gelatin then EquipTool(gelatin) end
        TweenTeleport(stove.Position)
        if CookPrompt then fireproximityprompt(CookPrompt) end
        task.wait(0.5)
        UnequipTools()
        Safety = Safety + 1
    until not (Player:FindFirstChild("Backpack") and Player.Backpack:FindFirstChild("Gelatin")) or Safety >= 5
    
    return true
end

-- ============================================
-- TUNGGU MASAK
-- ============================================
local function WaitForCook()
    Configuration.State.Status = "⏳ Tunggu Masak (max 130s)..."
    local stove = GetStove()
    if not stove then return false end
    
    local StoveTimer
    local Timer = stove:FindFirstChild("Timer")
    if Timer then StoveTimer = Timer:FindFirstChild("TextLabel") end
    
    local waitTime = 0
    repeat 
        task.wait(1) 
        waitTime = waitTime + 1 
        if waitTime > 130 then 
            Configuration.State.Status = "❌ Timeout!"
            return false 
        end 
    until StoveTimer and StoveTimer.Text == "0"
    
    return true
end

-- ============================================
-- KEMAS MARSHMALLOW
-- ============================================
local function BagMarshmallow()
    Configuration.State.Status = "📦 Kemas Marshmallow..."
    local stove = GetStove()
    if not stove then return false end
    
    local CookPrompt = stove:FindFirstChild("Attachment")
    if CookPrompt then CookPrompt = CookPrompt:FindFirstChild("ProximityPrompt") end
    
    TweenTeleport(stove.Position)
    task.wait(0.3)
    
    local bagAttempts = 0
    repeat
        local emptyBag = Player:FindFirstChild("Backpack") and Player.Backpack:FindFirstChild("Empty Bag")
        if emptyBag then EquipTool(emptyBag) end
        task.wait(0.3)
        if CookPrompt then fireproximityprompt(CookPrompt) end
        task.wait(0.3)
        UnequipTools()
        task.wait(0.25)
        bagAttempts = bagAttempts + 1
        if bagAttempts > 20 then break end
    until (Player:FindFirstChild("Backpack") and (Player.Backpack:FindFirstChild("Small Marshmallow Bag") or Player.Backpack:FindFirstChild("Medium Marshmallow Bag") or Player.Backpack:FindFirstChild("Large Marshmallow Bag")))
    
    return true
end

-- ============================================
-- JUAL MARSHMALLOW
-- ============================================
local function SellMarshmallow()
    Configuration.State.Status = "🚀 Ke Penjual..."
    TweenTeleport(Locations.Underground)
    task.wait(0.3)
    TweenTeleport(Locations.BuyMarsh)
    task.wait(0.3)
    
    Configuration.State.Status = "💰 Jual Semua..."
    local LamontBell = Workspace:FindFirstChild("Folders") and Workspace.Folders:FindFirstChild("NPCs") and Workspace.Folders.NPCs:FindFirstChild("Lamont Bell")
    if not LamontBell then return false end
    
    local LamontPrompt = LamontBell:FindFirstChild("UpperTorso")
    if LamontPrompt then LamontPrompt = LamontPrompt:FindFirstChild("ProximityPrompt") end
    if LamontPrompt then
        pcall(function()
            LamontPrompt.MaxActivationDistance = 50
            LamontPrompt.HoldDuration = 0
        end)
    end
    
    UnequipTools()
    local backpack = Player:FindFirstChild("Backpack")
    if not backpack then return false end
    
    for _, Object in next, backpack:GetChildren() do
        if tostring(Object):find("Marshmallow") then
            TweenTeleport(Locations.BuyMarsh)
            EquipTool(Object)
            task.wait(0.3)
            if LamontPrompt then fireproximityprompt(LamontPrompt) end
            task.wait(0.3)
        end
    end
    
    return true
end

-- ============================================
-- MAIN AUTOFARM CONTROLLER
-- ============================================
local AutofarmRunning = false

local function MainAutofarmController()
    if AutofarmRunning then return end
    AutofarmRunning = true

    while Configuration.Main_Settings.Autofarming do
        
        -- STEP 1: AUTO RESPAWN
        AutoRespawn()
        task.wait(0.5)
        
        -- STEP 2: CARI APARTEMEN
        local aptData = FindAvailableApartment()
        if not aptData then
            Configuration.State.Status = "❌ Ga ada apartemen, coba lagi..."
            task.wait(3)
            continue
        end
        
        -- STEP 3: BELI & KUNCI APARTEMEN
        local secured = BuyAndSecureApartment(aptData)
        if not secured then
            Configuration.State.Status = "❌ Gagal kunci, coba lagi..."
            task.wait(3)
            continue
        end
        
        -- STEP 4: AUTO RESPAWN
        AutoRespawn()
        task.wait(0.5)
        
        -- STEP 5: KE PENJUAL & BELI BAHAN (DENGAN UNDERGROUND)
        Configuration.State.Status = "🚀 Ke Penjual..."
        TweenTeleport(Locations.BuyMarsh)
        task.wait(0.3)
        PurchaseMarshmallowIngredients() -- Di sini ada underground setelah beli
        
        -- STEP 6: KE APARTEMEN
        Configuration.State.Status = "🏠 Ke Apartemen..."
        local stove = GetStove()
        if stove then
            TweenTeleport(stove.Position)
        else
            TweenTeleport(aptData.pos)
        end
        task.wait(0.3)
        
        -- STEP 7: MASAK
        local cookSuccess = PourWater()
        if not cookSuccess then
            Configuration.State.Status = "❌ Gagal masak, ulang..."
            AutoRespawn()
            task.wait(2)
            continue
        end
        AddSugarAndGelatin()
        
        -- STEP 8: TUNGGU MASAK
        local waitSuccess = WaitForCook()
        if not waitSuccess then
            Configuration.State.Status = "❌ Timeout, ulang..."
            AutoRespawn()
            task.wait(2)
            continue
        end
        
        -- STEP 9: KEMAS
        BagMarshmallow()
        
        -- STEP 10: JUAL
        SellMarshmallow()
        
        Configuration.State.Status = "✅ Selesai 1 cycle! Ulang..."
        task.wait(1)
    end
    AutofarmRunning = false
end

-- ============================================
-- UI SIMPEL
-- ============================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -160, 0.3, 0)
MainFrame.Size = UDim2.new(0, 320, 0, 220)
MainFrame.ClipsDescendants = true

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 12)
Corner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Position = UDim2.new(0, 0, 0, 5)
Title.Text = "🍬 Marshmallow Farm"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Parent = MainFrame
StatusLabel.BackgroundTransparency = 1
StatusLabel.Size = UDim2.new(1, -20, 0, 30)
StatusLabel.Position = UDim2.new(0, 10, 0, 48)
StatusLabel.Text = "📌 Status: Idle"
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.TextSize = 16
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left

local ToggleButton = Instance.new("TextButton")
ToggleButton.Parent = MainFrame
ToggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
ToggleButton.BorderSizePixel = 0
ToggleButton.Position = UDim2.new(0.1, 0, 0.75, 0)
ToggleButton.Size = UDim2.new(0.8, 0, 0, 40)
ToggleButton.Text = "▶️ START FARM"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextScaled = true
ToggleButton.Font = Enum.Font.GothamBold

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 8)
ButtonCorner.Parent = ToggleButton

local isFarming = false

ToggleButton.MouseButton1Click:Connect(function()
    isFarming = not isFarming
    Configuration.Main_Settings.Autofarming = isFarming
    
    if isFarming then
        ToggleButton.Text = "⏹️ STOP FARM"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        task.spawn(function()
            MainAutofarmController()
        end)
    else
        ToggleButton.Text = "▶️ START FARM"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        Configuration.State.Status = "⏹️ Stopped"
    end
end)

-- Update status
task.spawn(function()
    while true do
        pcall(function()
            StatusLabel.Text = "📌 Status: " .. (Configuration.State.Status or "Idle")
        end)
        task.wait(0.5)
    end
end)

-- ============================================
-- CONNECT DEATH HANDLER
-- ============================================
local function ConnectDeathHandler(char)
    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid then return end
    humanoid.Died:Connect(function()
        Configuration.State.Status = "💀 Respawn..."
        task.wait(0.5)
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

print("✅ WANZZ Marshmallow SB Loaded!")
print("📌 Klik START FARM untuk mulai")