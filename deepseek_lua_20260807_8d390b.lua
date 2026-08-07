-- ============================================================
-- Deobfuscated & Cleaned by WAVEX HUB
-- Original: BaconCheatz | .gg/DwREVahzN
-- ============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local PathfindingService = game:GetService("PathfindingService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local CurrentCamera = workspace.CurrentCamera

-- Load Obsidian Library
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

-- Main Window
local Window = CreateWindow(Library, {
    NotifySide = "Right",
    ShowCustomCursor = true,
    Title = "StreetLife",
    Footer = "WAVEX HUB"
})

-- Tabs
local MainTab = Window:AddTab("Main", "shield")
local PlayerTab = Window:AddTab("Player", "user")
local VisualTab = Window:AddTab("Visual", "eye")
local MiscTab = Window:AddTab("Mics", "wrench")
local TeleportTab = Window:AddTab("Teleport", "map-pin")
local CustomTab = Window:AddTab("Custom", "star")
local UISettingsTab = Window:AddTab("UiSetting", "settings")

-- ==================== MAIN TAB ====================
local InfoGroup = MainTab:AddLeftGroupbox("Info", "info")
InfoGroup:AddLabel("StreetLife — by WAVEX HUB")
InfoGroup:AddLabel("Version: 1.0")

-- FOV Circle GUI (ScreenGui with moving frame)
local FOVScreenGui = Instance.new("ScreenGui")
FOVScreenGui.Parent = LocalPlayer.PlayerGui

local FOVFrame = Instance.new("Frame")
FOVFrame.Size = UDim2.fromOffset(400, 400)
FOVFrame.AnchorPoint = Vector2.new(0.5, 0.5)
FOVFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
FOVFrame.BackgroundTransparency = 0.8
FOVFrame.BorderSizePixel = 0

local FOVCorner = Instance.new("UICorner", FOVFrame)
FOVCorner.CornerRadius = UDim.new(1, 0)

local FOVStroke = Instance.new("UIStroke", FOVFrame)
FOVStroke.Color = Color3.fromRGB(255, 50, 50)
FOVStroke.Thickness = 1.5

-- Update FOV position to mouse
RunService.RenderStepped:Connect(function()
    local mousePos = UserInputService:GetMouseLocation()
    FOVFrame.Position = UDim2.fromOffset(mousePos.X, mousePos.Y)
end)

-- FOV Settings
local FOVGroup = MainTab:AddRightGroupbox("FOV Circle", "circle")
FOVGroup:AddToggle("FovVisible", {
    Text = "FOV Circle Visible",
    Default = true,
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
    end,
    Rounding = 0
})

FOVGroup:AddDropdown("FovMode", {
    Text = "FOV Mode",
    Values = { "Mouse", "Center" },
    Default = "Mouse",
    Callback = function(mode) end
})

-- Highlight (unused but kept)
local Highlight = Instance.new("Highlight")
Highlight.FillColor = Color3.fromRGB(255, 50, 50)
Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)

-- Drawing (unused)
local TracerLine = Drawing.new("Line")
TracerLine.Color = Color3.fromRGB(255, 50, 50)

-- FOV Logic (empty placeholder)
RunService.RenderStepped:Connect(function() end)

-- Silent Aim
local SilentAimGroup = MainTab:AddLeftGroupbox("Silent Aim", "crosshair")
SilentAimGroup:AddToggle("SilentAimToggle", {
    Text = "Silent Aim",
    Default = false,
    Callback = function() end
})
SilentAimGroup:AddToggle("SilentAimFov", {
    Text = "Only in FOV",
    Default = true,
    Callback = function() end
})
SilentAimGroup:AddToggle("SilentAimHighlight", {
    Text = "Target Highlight",
    Default = false,
    Callback = function() end
})
SilentAimGroup:AddToggle("SilentAimTracer", {
    Text = "FOV Tracer",
    Default = false,
    Callback = function() end
})

-- Aimbot
local AimbotGroup = MainTab:AddLeftGroupbox("Aimbot", "crosshair")
AimbotGroup:AddToggle("AimbotToggle", {
    Text = "Aimbot",
    Default = false,
    Callback = function() end
})
AimbotGroup:AddToggle("AimbotFovOnly", {
    Text = "FOV Only",
    Default = true,
    Callback = function() end
})
AimbotGroup:AddToggle("AimbotWallCheck", {
    Text = "Wall Check",
    Default = false,
    Callback = function() end
})
AimbotGroup:AddToggle("AimbotHoldOnly", {
    Text = "Hold RMB to Aim",
    Default = false,
    Callback = function() end
})

AimbotGroup:AddDropdown("AimbotTargetPart", {
    Text = "Target Part",
    Values = { "Head", "HumanoidRootPart", "Torso", "UpperTorso" },
    Default = "Head",
    Callback = function() end
})

AimbotGroup:AddSlider("AimbotSmoothing", {
    Min = 1,
    Default = 20,
    Max = 100,
    Text = "Smoothing",
    Callback = function(val)
        local smooth = val / 100
    end,
    Rounding = 0
})

AimbotGroup:AddSlider("AimbotPrediction", {
    Min = 0,
    Default = 0,
    Max = 20,
    Text = "Prediction",
    Callback = function(val)
        local pred = val / 100
    end,
    Rounding = 1
})

-- ==================== OTHER TABS ====================
-- Player, Visual, Mics, Teleport, Custom, UiSetting
-- Placeholder tabs (can be expanded later)

-- ============================================================
-- SaveManager & ThemeManager (optional)
-- ============================================================
-- SaveManager:Setup({
--     ConfigFolder = "WAVEXHUBConfig",
--     Ignore = { ... },
-- })
-- ThemeManager:SetLibrary(Library)
-- ThemeManager:SetFolder("WAVEXHUBTheme")
-- ThemeManager:ApplyToTab(UISettingsTab)

print("WAVEX HUB loaded successfully!")