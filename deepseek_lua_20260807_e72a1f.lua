-- ============================================================
-- Silent Aim + Aimlock + FOV Circle
-- Digabung dari WAVEX HUB & sumber kedua
-- ============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local PathfindingService = game:GetService("PathfindingService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local CurrentCamera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- ==================== KONFIGURASI ====================
local Config = {
    Silent = {
        Enabled = false,
        WallCheck = false,
        TargetPart = {"Head"},   -- bisa multi, kita ambil yang pertama
        MaxDistance = 1000,
        HitChance = 100,
        WallBang = false,
        UseFieldOfView = false,
        Radius = 200,
        DrawFieldOfView = false,
        FieldOfViewColor = Color3.new(1,1,1),
        FieldOfViewTransparency = 0.75,
        Snapline = false,
        SnaplineColor = Color3.new(1,1,1),
        SnaplineThickness = 1,
        Aiming = false,
    },
    Aimlock = {
        Enabled = false,
        WallCheck = false,
        Type = "Mouse", -- "Camera" atau "Mouse"
        TargetPart = "Head",
        MaxDistance = 1000,
        Smoothness = 0.1,
        UseFieldOfView = false,
        Radius = 200,
        DrawFieldOfView = false,
        FieldOfViewColor = Color3.new(1,1,1),
        FieldOfViewTransparency = 0.75,
        Snapline = false,
        SnaplineColor = Color3.new(1,1,1),
        SnaplineThickness = 1,
        Aiming = false,
    }
}

-- ==================== LOAD LIBRARY OBSIDIAN ====================
local librarySource = game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/main/Library.lua")
local loadLibrary = loadstring(librarySource)
local Library = loadLibrary()

local themeManagerSource = game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/main/addons/ThemeManager.lua")
local loadThemeManager = loadstring(themeManagerSource)
local ThemeManager = loadThemeManager()

local saveManagerSource = game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/main/addons/SaveManager.lua")
local loadSaveManager = loadstring(saveManagerSource)
local SaveManager = loadSaveManager()

local Options = Library.Options
local Toggles = Library.Toggles
local CreateWindow = Library.CreateWindow

-- ==================== WINDOW UTAMA ====================
local Window = CreateWindow(Library, {
    NotifySide = "Right",
    ShowCustomCursor = true,
    Title = "StreetLife",
    Footer = "WAVEX HUB + Silent Aim"
})

-- Tabs
local MainTab = Window:AddTab("Main", "shield")
local PlayerTab = Window:AddTab("Player", "user")
local VisualTab = Window:AddTab("Visual", "eye")
local MiscTab = Window:AddTab("Mics", "wrench")
local TeleportTab = Window:AddTab("Teleport", "map-pin")
local CustomTab = Window:AddTab("Custom", "star")
local UISettingsTab = Window:AddTab("UiSetting", "settings")

-- ==================== FOV CIRCLE GUI ====================
local FOVScreenGui = Instance.new("ScreenGui")
FOVScreenGui.Parent = LocalPlayer.PlayerGui
FOVScreenGui.Enabled = false  -- default mati

local FOVFrame = Instance.new("Frame")
FOVFrame.Size = UDim2.fromOffset(200, 200)
FOVFrame.AnchorPoint = Vector2.new(0.5, 0.5)
FOVFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
FOVFrame.BackgroundTransparency = 0.75
FOVFrame.BorderSizePixel = 0
FOVFrame.Parent = FOVScreenGui

local FOVCorner = Instance.new("UICorner", FOVFrame)
FOVCorner.CornerRadius = UDim.new(1, 0)

local FOVStroke = Instance.new("UIStroke", FOVFrame)
FOVStroke.Color = Color3.fromRGB(255, 50, 50)
FOVStroke.Thickness = 1.5

-- Update posisi FOV ke mouse atau center
local FOVMode = "Mouse" -- "Mouse" atau "Center"
RunService.RenderStepped:Connect(function()
    if not FOVScreenGui.Enabled then return end
    local pos
    if FOVMode == "Mouse" then
        pos = UserInputService:GetMouseLocation()
    else
        pos = Vector2.new(CurrentCamera.ViewportSize.X/2, CurrentCamera.ViewportSize.Y/2)
    end
    FOVFrame.Position = UDim2.fromOffset(pos.X, pos.Y)
end)

-- ==================== FUNGSI UTILITY ====================
-- Mendapatkan target part berdasarkan nama
local function GetTargetPart(character, partName)
    if not character then return nil end
    if partName == "HumanoidRootPart" then
        return character:FindFirstChild("HumanoidRootPart")
    end
    -- Cari di seluruh child
    for _, child in ipairs(character:GetChildren()) do
        if child.Name == partName and child:IsA("BasePart") then
            return child
        end
    end
    return nil
end

-- Cek apakah karakter masih hidup dan valid
local function IsAlive(character)
    if not character or not character.Parent then return false end
    local humanoid = character:FindFirstChild("Humanoid")
    return humanoid and humanoid.Health > 0
end

-- Cek apakah target terlihat (wall check) - simple raycast
local function IsVisible(origin, targetPos)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = {LocalPlayer.Character, workspace.Terrain}
    local result = workspace:Raycast(origin, targetPos - origin, params)
    return not result or result.Instance:IsDescendantOf(LocalPlayer.Character) or result.Instance:IsDescendantOf(targetPos.Parent)
end

-- ==================== SILENT AIM / AIMLOCK CORE ====================
local function GetClosestPlayerInFOV(fovRadius, useFov, targetParts, maxDist, wallCheck)
    local closest = nil
    local closestAngle = math.huge
    local viewport = CurrentCamera.ViewportSize
    local center = Vector2.new(viewport.X/2, viewport.Y/2)

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if not player.Character or not IsAlive(player.Character) then continue end

        -- Ambil target part (ambil yang pertama dari daftar)
        local targetPartName = targetParts[1] or "Head"
        local targetPart = GetTargetPart(player.Character, targetPartName)
        if not targetPart then continue end

        -- Jarak
        local distance = (targetPart.Position - CurrentCamera.CFrame.Position).Magnitude
        if distance > maxDist then continue end

        -- Wall check
        if wallCheck and not IsVisible(CurrentCamera.CFrame.Position, targetPart.Position) then
            continue
        end

        -- Konversi ke posisi layar
        local screenPos, onScreen = CurrentCamera:WorldToViewportPoint(targetPart.Position)
        if not onScreen then continue end

        -- Hitung sudut dari center
        local vec = Vector2.new(screenPos.X, screenPos.Y) - center
        local angle = vec.Magnitude

        -- FOV check
        if useFov and angle > fovRadius then continue end

        if angle < closestAngle then
            closestAngle = angle
            closest = {
                Player = player,
                Part = targetPart,
                Position = targetPart.Position,
                ScreenPos = Vector2.new(screenPos.X, screenPos.Y),
                Distance = distance,
                Angle = angle
            }
        end
    end
    return closest
end

-- Fungsi untuk menggerakkan mouse/camera
local function AimAt(targetInfo, smoothness, aimType)
    if not targetInfo then return end
    local targetScreen = targetInfo.ScreenPos
    local viewport = CurrentCamera.ViewportSize
    local center = Vector2.new(viewport.X/2, viewport.Y/2)
    local delta = targetScreen - center

    if aimType == "Mouse" then
        -- Gerakkan mouse secara relatif
        local currentPos = UserInputService:GetMouseLocation()
        local newPos = currentPos + delta
        if smoothness > 0 then
            -- Interpolasi
            local tweenInfo = TweenInfo.new(smoothness/10, Enum.EasingStyle.Linear)
            -- Tidak ada tween untuk mouse, langsung set posisi atau pakai mousemoverel
            mousemoverel(delta.X * (1 - smoothness), delta.Y * (1 - smoothness)) -- sederhana
        else
            mousemoverel(delta.X, delta.Y)
        end
    else -- Camera
        -- Putar kamera ke arah target
        local lookAt = targetInfo.Position
        local currentCF = CurrentCamera.CFrame
        local targetCF = CFrame.new(currentCF.Position, lookAt)
        if smoothness > 0 then
            -- Interpolasi CFrame
            local newCF = currentCF:Lerp(targetCF, smoothness)
            CurrentCamera.CFrame = newCF
        else
            CurrentCamera.CFrame = targetCF
        end
    end
end

-- ==================== LOOP AIM ====================
RunService.RenderStepped:Connect(function()
    -- Silent Aim
    if Config.Silent.Enabled and Config.Silent.Aiming then
        local target = GetClosestPlayerInFOV(
            Config.Silent.Radius,
            Config.Silent.UseFieldOfView,
            Config.Silent.TargetPart,
            Config.Silent.MaxDistance,
            Config.Silent.WallCheck
        )
        if target then
            -- Silent aim: langsung set camera ke target (atau mouse)
            -- Kita gunakan Camera untuk silent aim
            CurrentCamera.CFrame = CFrame.new(CurrentCamera.CFrame.Position, target.Position)
        end
    end

    -- Aimlock (Aimbot)
    if Config.Aimlock.Enabled and Config.Aimlock.Aiming then
        local target = GetClosestPlayerInFOV(
            Config.Aimlock.Radius,
            Config.Aimlock.UseFieldOfView,
            {Config.Aimlock.TargetPart},
            Config.Aimlock.MaxDistance,
            Config.Aimlock.WallCheck
        )
        if target then
            AimAt(target, Config.Aimlock.Smoothness, Config.Aimlock.Type)
        end
    end
end)

-- ==================== UI: MAIN TAB ====================
local InfoGroup = MainTab:AddLeftGroupbox("Info", "info")
InfoGroup:AddLabel("StreetLife — by WAVEX HUB + Silent Aim")
InfoGroup:AddLabel("Version: 2.0")

-- FOV Circle Settings (dari tab Main)
local FOVGroup = MainTab:AddRightGroupbox("FOV Circle", "circle")
FOVGroup:AddToggle("FovVisible", {
    Text = "FOV Circle Visible",
    Default = false,
    Callback = function(visible)
        FOVScreenGui.Enabled = visible
    end
})

FOVGroup:AddSlider("FovSize", {
    Min = 50,
    Default = 200,
    Max = 500,
    Text = "FOV Size",
    Callback = function(size)
        FOVFrame.Size = UDim2.fromOffset(size, size)
        Config.Silent.Radius = size / 2  -- karena radius dihitung dari center
        Config.Aimlock.Radius = size / 2
    end,
    Rounding = 0
})

FOVGroup:AddDropdown("FovMode", {
    Text = "FOV Mode",
    Values = { "Mouse", "Center" },
    Default = "Mouse",
    Callback = function(mode)
        FOVMode = mode
    end
})

FOVGroup:AddColorPicker("FovColor", {
    Text = "FOV Color",
    Default = Color3.fromRGB(255, 50, 50),
    Callback = function(color)
        FOVStroke.Color = color
        Config.Silent.FieldOfViewColor = color
        Config.Aimlock.FieldOfViewColor = color
    end
})

FOVGroup:AddSlider("FovTransparency", {
    Min = 0,
    Default = 75,
    Max = 100,
    Text = "Transparency (%)",
    Callback = function(val)
        local trans = val / 100
        FOVFrame.BackgroundTransparency = trans
        Config.Silent.FieldOfViewTransparency = trans
        Config.Aimlock.FieldOfViewTransparency = trans
    end,
    Rounding = 0
})

-- ==================== UI: SILENT AIM TAB ====================
local SilentAimTab = Window:AddTab("Silent Aim", "crosshair")

local SilentGroup = SilentAimTab:AddLeftGroupbox("Silent Aim", "crosshair")
SilentGroup:AddToggle("SilentAimToggle", {
    Text = "Enabled",
    Default = false,
    Callback = function(state)
        Config.Silent.Enabled = state
    end
})
SilentGroup:AddKeybind("SilentAimBind", {
    Text = "Keybind (Hold)",
    Default = Enum.KeyCode.LeftAlt,
    Mode = "Hold",
    Callback = function(state)
        Config.Silent.Aiming = state
    end
})
SilentGroup:AddToggle("SilentAimFov", {
    Text = "Only in FOV",
    Default = true,
    Callback = function(state)
        Config.Silent.UseFieldOfView = state
    end
})
SilentGroup:AddToggle("SilentAimWallCheck", {
    Text = "Wall Check",
    Default = false,
    Callback = function(state)
        Config.Silent.WallCheck = state
    end
})
SilentGroup:AddDropdown("SilentAimTargetPart", {
    Text = "Target Part",
    Values = { "Head", "HumanoidRootPart", "Torso", "UpperTorso" },
    Default = "Head",
    Multi = false,
    Callback = function(value)
        Config.Silent.TargetPart = {value}
    end
})
SilentGroup:AddSlider("SilentAimMaxDist", {
    Min = 0,
    Default = 1000,
    Max = 5000,
    Text = "Max Distance",
    Callback = function(val)
        Config.Silent.MaxDistance = val
    end,
    Rounding = 0
})

-- ==================== UI: AIMBOT TAB ====================
local AimbotTab = Window:AddTab("Aimbot", "target")

local AimbotGroup = AimbotTab:AddLeftGroupbox("Aimlock", "target")
AimbotGroup:AddToggle("AimbotToggle", {
    Text = "Enabled",
    Default = false,
    Callback = function(state)
        Config.Aimlock.Enabled = state
    end
})
AimbotGroup:AddKeybind("AimbotBind", {
    Text = "Keybind (Toggle)",
    Default = Enum.KeyCode.RightControl,
    Mode = "Toggle",
    Callback = function(state)
        Config.Aimlock.Aiming = state
    end
})
AimbotGroup:AddToggle("AimbotFovOnly", {
    Text = "FOV Only",
    Default = true,
    Callback = function(state)
        Config.Aimlock.UseFieldOfView = state
    end
})
AimbotGroup:AddToggle("AimbotWallCheck", {
    Text = "Wall Check",
    Default = false,
    Callback = function(state)
        Config.Aimlock.WallCheck = state
    end
})
AimbotGroup:AddDropdown("AimbotTargetPart", {
    Text = "Target Part",
    Values = { "Head", "HumanoidRootPart", "Torso", "UpperTorso" },
    Default = "Head",
    Callback = function(value)
        Config.Aimlock.TargetPart = value
    end
})
AimbotGroup:AddDropdown("AimbotType", {
    Text = "Aim Type",
    Values = { "Mouse", "Camera" },
    Default = "Mouse",
    Callback = function(value)
        Config.Aimlock.Type = value
    end
})
AimbotGroup:AddSlider("AimbotSmoothness", {
    Min = 1,
    Default = 10,
    Max = 100,
    Text = "Smoothness (%)",
    Callback = function(val)
        Config.Aimlock.Smoothness = val / 100
    end,
    Rounding = 0
})
AimbotGroup:AddSlider("AimbotMaxDist", {
    Min = 0,
    Default = 1000,
    Max = 5000,
    Text = "Max Distance",
    Callback = function(val)
        Config.Aimlock.MaxDistance = val
    end,
    Rounding = 0
})

-- ==================== OTHER TABS (Placeholder) ====================
-- ... (Anda bisa tambahkan tab lain seperti Visual, Player, dll)

-- ==================== SAVEMANAGER & THEMEMANAGER ====================
-- SaveManager:Setup({ ConfigFolder = "WAVEXHUBConfig", Ignore = {} })
-- ThemeManager:SetLibrary(Library)
-- ThemeManager:SetFolder("WAVEXHUBTheme")
-- ThemeManager:ApplyToTab(UISettingsTab)

print("WAVEX HUB + Silent Aim & Aimbot loaded successfully!")