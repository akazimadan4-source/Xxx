--==================================================
-- UNDERGROUND TWEEN + MOVING PLATFORM (STABLE)
-- Target: Lamont Bell
-- LocalScript: StarterPlayer > StarterPlayerScripts
--==================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer

--==================================================
-- TARGET LAMONT BELL
--==================================================

local TARGET = Vector3.new(
    510.8173828125,
    4.581132888793945,
    601.048095703125
)

--==================================================
-- SETTINGS
--==================================================

local UNDERGROUND_DEPTH = 30
local PLATFORM_SIZE = Vector3.new(7, 0.6, 7)

local DOWN_TIME = 0.6
local TRAVEL_TIME = 3
local UP_TIME = 0.6

local busy = false
local moveConnection = nil

--==================================================
-- CHARACTER
--==================================================

local function getCharacter()
    local character = Player.Character or Player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    local root = character:WaitForChild("HumanoidRootPart")
    return character, humanoid, root
end

--==================================================
-- CREATE PLATFORM
--==================================================

local function createPlatform(root)
    local platform = Instance.new("Part")
    platform.Name = "UndergroundPlatform"
    platform.Size = PLATFORM_SIZE
    platform.Anchored = true
    platform.CanCollide = true
    platform.CanTouch = false
    platform.CanQuery = false
    platform.Transparency = 0
    platform.Material = Enum.Material.SmoothPlastic
    platform.BrickColor = BrickColor.new("Bright blue")
    platform.Parent = workspace
    
    platform.CFrame = CFrame.new(
        root.Position.X,
        root.Position.Y - 3.1,
        root.Position.Z
    )
    
    return platform
end

--==================================================
-- MOVE CHARACTER WITH TWEEN (STABLE)
--==================================================

local function tweenCharacter(root, targetPosition, duration, easingStyle)
    easingStyle = easingStyle or Enum.EasingStyle.Linear
    
    local tweenInfo = TweenInfo.new(
        duration,
        easingStyle,
        Enum.EasingDirection.InOut
    )
    
    local tween = TweenService:Create(
        root,
        tweenInfo,
        {
            CFrame = CFrame.new(targetPosition) * (root.CFrame - root.CFrame.Position)
        }
    )
    
    tween:Play()
    tween.Completed:Wait()
    return tween
end

--==================================================
-- MOVE PLATFORM + CHARACTER TOGETHER (STABLE)
--==================================================

local function moveTogether(platform, root, targetPos, duration, offset)
    offset = offset or (root.Position - platform.Position)
    
    -- Tween platform
    local platformTween = TweenService:Create(
        platform,
        TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut),
        { Position = targetPos }
    )
    
    -- Tween karakter bersama platform
    local charTargetPos = targetPos + offset
    local charTween = TweenService:Create(
        root,
        TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut),
        { 
            CFrame = CFrame.new(charTargetPos) * (root.CFrame - root.CFrame.Position)
        }
    )
    
    -- Jalankan bersamaan
    platformTween:Play()
    charTween:Play()
    
    platformTween.Completed:Wait()
    charTween.Completed:Wait()
end

--==================================================
-- UNDERGROUND TELEPORT (STABLE VERSION)
--==================================================

local function undergroundTeleport()
    if busy then return end
    busy = true
    
    local character, humanoid, root = getCharacter()
    
    if not character or not humanoid or humanoid.Health <= 0 then
        busy = false
        return
    end
    
    -- Simpan state awal
    local oldAutoRotate = humanoid.AutoRotate
    local oldPlatformStand = humanoid.PlatformStand
    
    humanoid.AutoRotate = false
    humanoid.PlatformStand = true
    
    -- Buat platform
    local platform = createPlatform(root)
    local offset = root.Position - platform.Position
    
    -- Hitung posisi-posisi
    local currentPos = platform.Position
    
    -- Posisi bawah tanah (di bawah posisi awal)
    local undergroundStart = Vector3.new(
        currentPos.X,
        currentPos.Y - UNDERGROUND_DEPTH,
        currentPos.Z
    )
    
    -- Posisi bawah tanah (di bawah target)
    local undergroundTarget = Vector3.new(
        TARGET.X,
        currentPos.Y - UNDERGROUND_DEPTH,
        TARGET.Z
    )
    
    -- Posisi akhir (di atas tanah, dekat target)
    local finalPosition = Vector3.new(
        TARGET.X,
        TARGET.Y - 3.1,
        TARGET.Z
    )
    
    --==========================================
    -- 1. TURUN BERSAMA
    --==========================================
    moveTogether(platform, root, undergroundStart, DOWN_TIME, offset)
    
    --==========================================
    -- 2. BERGERAK DI BAWAH TANAH
    --==========================================
    moveTogether(platform, root, undergroundTarget, TRAVEL_TIME, offset)
    
    --==========================================
    -- 3. NAIK KE PERMUKAAN
    --==========================================
    moveTogether(platform, root, finalPosition, UP_TIME, offset)
    
    --==========================================
    -- FINAL TOUCH - PASTIKAN POSISI TEPAT
    --==========================================
    local finalCharPos = finalPosition + offset
    root.CFrame = CFrame.new(finalCharPos) * (root.CFrame - root.CFrame.Position)
    
    -- Kembalikan physics
    task.wait(0.1)
    humanoid.PlatformStand = oldPlatformStand
    humanoid.AutoRotate = oldAutoRotate
    
    -- Hapus platform dengan aman
    if platform and platform.Parent then
        platform:Destroy()
    end
    
    -- Verifikasi posisi akhir
    task.wait(0.1)
    local finalCheck = root.Position
    local targetCharPos = finalPosition + offset
    
    -- Jika posisi melenceng, koreksi
    if (finalCheck - targetCharPos).Magnitude > 2 then
        root.CFrame = CFrame.new(targetCharPos) * (root.CFrame - root.CFrame.Position)
    end
    
    busy = false
end

--==================================================
-- UI
--==================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UndergroundTeleportUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = Player:WaitForChild("PlayerGui")

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 240, 0, 125)
Main.Position = UDim2.new(0.5, -120, 0.75, 0)
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Main.BorderSizePixel = 0
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundTransparency = 1
Title.Text = "LAMONT BELL"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 17
Title.Font = Enum.Font.GothamBold
Title.Parent = Main

local Button = Instance.new("TextButton")
Button.Name = "UndergroundButton"
Button.Size = UDim2.new(1, -20, 0, 45)
Button.Position = UDim2.new(0, 10, 0, 42)
Button.BackgroundColor3 = Color3.fromRGB(45, 120, 255)
Button.Text = "UNDERGROUND TP"
Button.TextColor3 = Color3.fromRGB(255, 255, 255)
Button.TextSize = 15
Button.Font = Enum.Font.GothamBold
Button.BorderSizePixel = 0
Button.Parent = Main

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 8)
ButtonCorner.Parent = Button

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, 0, 0, 20)
Status.Position = UDim2.new(0, 0, 1, -20)
Status.BackgroundTransparency = 1
Status.Text = "Ready"
Status.TextColor3 = Color3.fromRGB(180, 180, 180)
Status.TextSize = 11
Status.Font = Enum.Font.Gotham
Status.Parent = Main

--==================================================
-- BUTTON
--==================================================

Button.MouseButton1Click:Connect(function()
    if busy then return end
    
    Button.Text = "MOVING..."
    Button.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
    Status.Text = "↓ Going underground..."
    
    task.spawn(function()
        local success, err = pcall(function()
            undergroundTeleport()
        end)
        
        if not success then
            warn("Underground Teleport Error:", err)
            busy = false
        end
        
        Button.Text = "UNDERGROUND TP"
        Button.BackgroundColor3 = Color3.fromRGB(45, 120, 255)
        
        if success then
            Status.Text = "✅ Arrived at Lamont Bell"
            Status.TextColor3 = Color3.fromRGB(0, 255, 0)
        else
            Status.Text = "❌ Error occurred"
            Status.TextColor3 = Color3.fromRGB(255, 0, 0)
        end
        
        task.wait(2.5)
        Status.Text = "Ready"
        Status.TextColor3 = Color3.fromRGB(180, 180, 180)
    end)
end)