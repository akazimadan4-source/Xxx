-- ============================================
-- SERVICES
-- ============================================
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local TS = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

-- ============================================
-- VARIABLES
-- ============================================
local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Fitur
local SilentAim = false
local Wallbang = false
local ESP = false
local ShowFOV = false
local Stamina = false
local AimMode = "PC"          -- "PC" atau "HP"

-- Pengaturan baru
local FOVRadius = 250          -- radius FOV circle
local AimTarget = "Head"       -- "Head", "Torso", "Foot"

-- Cache ESP
local espCache = {}

-- ============================================
-- FOV CIRCLE
-- ============================================
local FovCircle = Drawing.new("Circle")
FovCircle.Radius = FOVRadius
FovCircle.NumSides = 64
FovCircle.Thickness = 1
FovCircle.Visible = false
FovCircle.Color = Color3.fromRGB(0, 255, 255)
FovCircle.Transparency = 0.3

RS.RenderStepped:Connect(function()
    FovCircle.Position = AimMode == "PC" and UIS:GetMouseLocation() or Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
end)

-- ============================================
-- ESP SETTINGS
-- ============================================
local espSet = {
    Enabled = false,
    ShowName = true,
    ShowSkeletons = true,
    NameColor = Color3.fromRGB(0, 255, 255),
    SkeletonsColor = Color3.fromRGB(0, 255, 255)
}

local bones = {
    {"Head","UpperTorso"},{"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},
    {"RightLowerArm","RightHand"},{"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},
    {"LeftLowerArm","LeftHand"},{"UpperTorso","LowerTorso"},{"LowerTorso","LeftUpperLeg"},
    {"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},{"LowerTorso","RightUpperLeg"},
    {"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"}
}

local function newDraw(class, props)
    local d = Drawing.new(class)
    for k,v in pairs(props) do d[k] = v end
    return d
end

local function cleanEsp(esp)
    if not esp then return end
    for _, obj in pairs(esp) do
        if type(obj) ~= "table" and obj and obj.Remove then
            pcall(function() obj:Remove() end)
        elseif type(obj) == "table" then
            for _, line in ipairs(obj) do
                if line and line[1] and line[1].Remove then
                    pcall(function() line[1]:Remove() end)
                end
            end
        end
    end
end

local function createEsp(p)
    espCache[p] = {
        name = newDraw("Text", {Color = espSet.NameColor, Outline = true, Center = true, Size = 13, Visible = false}),
        skeletonLines = {}
    }
end

local function removeEsp(p)
    local esp = espCache[p]
    if esp then
        cleanEsp(esp)
        espCache[p] = nil
    end
end

local function hideAllEsp()
    for _, esp in pairs(espCache) do
        if esp.name then esp.name.Visible = false end
        if esp.skeletonLines then
            for _, line in ipairs(esp.skeletonLines) do
                if line and line[1] then line[1].Visible = false end
            end
        end
    end
end

local function ToggleESP(state)
    ESP = state
    espSet.Enabled = state
    if not state then hideAllEsp() end
end

local function updateEsp()
    for p, esp in pairs(espCache) do
        if not p or not p.Parent then
            removeEsp(p)
            continue
        end
        
        local char = p.Character
        if not char or not espSet.Enabled then
            if esp.name then esp.name.Visible = false end
            if esp.skeletonLines then
                for _, line in ipairs(esp.skeletonLines) do
                    if line and line[1] then line[1].Visible = false end
                end
            end
            continue
        end
        
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChild("Humanoid")
        
        if not root or not hum or hum.Health <= 0 then
            if esp.name then esp.name.Visible = false end
            if esp.skeletonLines then
                for _, line in ipairs(esp.skeletonLines) do
                    if line and line[1] then line[1].Visible = false end
                end
            end
            continue
        end
        
        local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
        if not onScreen then
            if esp.name then esp.name.Visible = false end
            if esp.skeletonLines then
                for _, line in ipairs(esp.skeletonLines) do
                    if line and line[1] then line[1].Visible = false end
                end
            end
            continue
        end
        
        local hrp2D = Camera:WorldToViewportPoint(root.Position)
        local cSize = (Camera:WorldToViewportPoint(root.Position - Vector3.new(0,3,0)).Y - Camera:WorldToViewportPoint(root.Position + Vector3.new(0,2.6,0)).Y) / 2
        local bSize = Vector2.new(math.floor(cSize * 1.8), math.floor(cSize * 1.9))
        local bPos = Vector2.new(math.floor(hrp2D.X - cSize * 1.8 / 2), math.floor(hrp2D.Y - cSize * 1.6 / 2))
        
        if espSet.ShowName then
            esp.name.Text = p.Name
            esp.name.Position = Vector2.new(bSize.X/2 + bPos.X, bPos.Y - 16)
            esp.name.Visible = true
        else
            esp.name.Visible = false
        end
        
        if espSet.ShowSkeletons then
            if #esp.skeletonLines == 0 then
                for _, bp in ipairs(bones) do
                    if char[bp[1]] and char[bp[2]] then
                        local l = newDraw("Line", {Thickness = 1.5, Color = espSet.SkeletonsColor, Transparency = 0.7, Visible = false})
                        table.insert(esp.skeletonLines, {l, bp[1], bp[2]})
                    end
                end
            end
            for _, ld in ipairs(esp.skeletonLines) do
                if char[ld[2]] and char[ld[3]] then
                    local p1 = Camera:WorldToViewportPoint(char[ld[2]].Position)
                    local p2 = Camera:WorldToViewportPoint(char[ld[3]].Position)
                    ld[1].From = Vector2.new(p1.X, p1.Y)
                    ld[1].To = Vector2.new(p2.X, p2.Y)
                    ld[1].Visible = true
                else
                    ld[1].Visible = false
                end
            end
        else
            for _, ld in ipairs(esp.skeletonLines) do
                if ld and ld[1] then ld[1].Visible = false end
            end
        end
    end
end

-- Inisialisasi ESP untuk pemain yang sudah ada
for _, p in ipairs(Players:GetPlayers()) do
    if p ~= Player then
        createEsp(p)
    end
end

Players.PlayerAdded:Connect(function(p)
    if p ~= Player then
        createEsp(p)
    end
end)

Players.PlayerRemoving:Connect(removeEsp)
RS.RenderStepped:Connect(updateEsp)

-- ============================================
-- STAMINA
-- ============================================
local function ToggleStamina(state)
    Stamina = state
    if state then
        RS:BindToRenderStep("Stamina", 0, function()
            if not Stamina then return end
            pcall(function()
                local ps = Player:FindFirstChild("PlayerScripts")
                if ps then
                    for _, child in pairs(ps:GetDescendants()) do
                        if child.Name == "MovementController" and child:IsA("ModuleScript") then
                            local req = require(child)
                            if req then req.Stamina = 100 end
                        end
                    end
                end
            end)
        end)
    else
        RS:UnbindFromRenderStep("Stamina")
    end
end

-- ============================================
-- SILENT AIM – Fungsi pencarian target & hook
-- ============================================
function GetFovTarget()
    local target, lowest = nil, math.huge
    local fovCenter = AimMode == "PC" and UIS:GetMouseLocation() or Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    for _, v in pairs(Players:GetPlayers()) do
        local char = v.Character
        if v ~= Player and char then
            local hum = char:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
                local part = nil
                if AimTarget == "Head" then
                    part = char:FindFirstChild("Head")
                elseif AimTarget == "Torso" then
                    part = char:FindFirstChild("HumanoidRootPart")
                elseif AimTarget == "Foot" then
                    part = char:FindFirstChild("LeftFoot") or char:FindFirstChild("RightFoot")
                end
                if not part then continue end

                local sp, on = Camera:WorldToViewportPoint(part.Position)
                local dist = (fovCenter - Vector2.new(sp.X, sp.Y)).Magnitude
                if dist < FOVRadius and dist < lowest and on then
                    target, lowest = v, dist
                end
            end
        end
    end
    return target
end

-- Cari fungsi CastBlacklist dan CastWhitelist
local function SearchGc(name)
    for _,v in pairs(getgc()) do
        if type(v) == "function" then
            local info = debug.getinfo(v)
            if info.name == name then return v end
        end
    end
end

local CastBlacklist = SearchGc("CastBlacklist")
local CastWhitelist = SearchGc("CastWhitelist")
if not CastBlacklist or not CastWhitelist then 
    Player:Kick("Missing Function") 
    return 
end

local OldCast = hookfunction(CastBlacklist, function(...)
    local target = GetFovTarget()
    if target and SilentAim then
        local char = target.Character
        local part = nil
        if AimTarget == "Head" then
            part = char:FindFirstChild("Head")
        elseif AimTarget == "Torso" then
            part = char:FindFirstChild("HumanoidRootPart")
        elseif AimTarget == "Foot" then
            part = char:FindFirstChild("LeftFoot") or char:FindFirstChild("RightFoot")
        end
        if part then
            local args = {...}
            args[2] = part.Position - args[1]
            if Wallbang then
                args[3] = {target.Character}
                return CastWhitelist(unpack(args))
            end
            return OldCast(unpack(args))
        end
    end
    return OldCast(...)
end)

-- ============================================
-- NEVERLOSE UI
-- ============================================
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/ImInsane-1337/neverlose-ui/refs/heads/main/source/library.lua"))()
local CheatName = "LengerHub"

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
    Name = "Lenger Hub",
    SubName = "by Lenger",
    Logo = "120959262762131"  -- ganti dengan ID asset jika punya
})

local KeybindList = Library:KeybindList("Keybinds")

-- Watermark
Library:Watermark({
    "Lenger Hub",
    "by Lenger",
    120959262762131
})

task.spawn(function()
    while true do
        local FPS = math.floor(1 / game:GetService("RunService").RenderStepped:Wait())
        Library:Watermark({  
            "Lenger Hub",  
            "by Lenger",  
            120959262762131,  
            "FPS: " .. FPS  
        })  
        task.wait(0.5)  
    end
end)

-- ============================================
-- TAB UTAMA
-- ============================================
Window:Category("Main")

local MainPage = Window:Page({Name = "Aimbot", Icon = "138827881557940"})
local AimSection = MainPage:Section({Name = "Aimbot Settings", Side = 1})

-- Toggle Silent Aim
AimSection:Toggle({
    Name = "Silent Aim",
    Flag = "SilentAim",
    Default = false,
    Callback = function(Value)
        SilentAim = Value
        FovCircle.Visible = ShowFOV and SilentAim
    end
})

-- Toggle Wallbang
AimSection:Toggle({
    Name = "Wallbang",
    Flag = "Wallbang",
    Default = false,
    Callback = function(Value)
        Wallbang = Value
    end
})

-- Dropdown Target (Head / Torso / Foot)
AimSection:Dropdown({
    Name = "Aim Target",
    Flag = "AimTarget",
    Default = {"Head"},
    Items = {"Head", "Torso", "Foot"},
    Multi = false,
    Callback = function(Value)
        AimTarget = Value[1]
    end
})

-- Slider FOV Radius
AimSection:Slider({
    Name = "FOV Radius",
    Flag = "FOVRadius",
    Min = 50,
    Max = 500,
    Default = 250,
    Suffix = " px",
    Callback = function(Value)
        FOVRadius = Value
        FovCircle.Radius = Value
    end
})

-- Toggle Show FOV Circle
AimSection:Toggle({
    Name = "Show FOV Circle",
    Flag = "ShowFOV",
    Default = false,
    Callback = function(Value)
        ShowFOV = Value
        FovCircle.Visible = Value and SilentAim
        if Value then
            FovCircle.Radius = FOVRadius
        end
    end
})

-- Mode PC / HP
AimSection:Dropdown({
    Name = "Aim Mode",
    Flag = "AimMode",
    Default = {"PC"},
    Items = {"PC", "HP"},
    Multi = false,
    Callback = function(Value)
        AimMode = Value[1]
    end
})

-- ============================================
-- TAB ESP
-- ============================================
local EspPage = Window:Page({Name = "ESP", Icon = "138827881557940"})
local EspSection = EspPage:Section({Name = "ESP Settings", Side = 1})

EspSection:Toggle({
    Name = "Enable ESP",
    Flag = "ESPEnabled",
    Default = false,
    Callback = function(Value)
        ToggleESP(Value)
    end
})

EspSection:Toggle({
    Name = "Show Names",
    Flag = "ESPNames",
    Default = true,
    Callback = function(Value)
        espSet.ShowName = Value
    end
})

EspSection:Toggle({
    Name = "Show Skeletons",
    Flag = "ESPSkeletons",
    Default = true,
    Callback = function(Value)
        espSet.ShowSkeletons = Value
    end
})

EspSection:Colorpicker({
    Name = "Name Color",
    Flag = "ESPNameColor",
    Default = Color3.fromRGB(0, 255, 255),
    Callback = function(Value)
        espSet.NameColor = Value
        for _, esp in pairs(espCache) do
            if esp.name then esp.name.Color = Value end
        end
    end
})

EspSection:Colorpicker({
    Name = "Skeleton Color",
    Flag = "ESPSkeletonColor",
    Default = Color3.fromRGB(0, 255, 255),
    Callback = function(Value)
        espSet.SkeletonsColor = Value
        for _, esp in pairs(espCache) do
            if esp.skeletonLines then
                for _, line in ipairs(esp.skeletonLines) do
                    if line and line[1] then line[1].Color = Value end
                end
            end
        end
    end
})

-- ============================================
-- TAB MISC
-- ============================================
local MiscPage = Window:Page({Name = "Misc", Icon = "138827881557940"})
local MiscSection = MiscPage:Section({Name = "Other Features", Side = 1})

MiscSection:Toggle({
    Name = "Infinite Stamina",
    Flag = "Stamina",
    Default = false,
    Callback = function(Value)
        ToggleStamina(Value)
    end
})

MiscSection:Button({
    Name = "Test Notification",
    Callback = function()
        Library:Notification({
            Title = "Lenger Hub",
            Description = "Script loaded successfully!",
            Duration = 3,
            Icon = "73789337996373"
        })
    end
})

MiscSection:Keybind({
    Name = "Toggle Silent Aim",
    Flag = "SilentAimKeybind",
    Default = Enum.KeyCode.Delete,
    Callback = function()
        SilentAim = not SilentAim
        FovCircle.Visible = ShowFOV and SilentAim
        Library:Notification({
            Title = "Silent Aim",
            Description = SilentAim and "Enabled" or "Disabled",
            Duration = 1
        })
    end
})

-- ============================================
-- TAB SETTINGS (Config)
-- ============================================
Window:Category("Settings")
local SettingsPage = Library:CreateSettingsPage(Window, KeybindList)
Window:Init()

-- ============================================
-- NOTIFIKASI AWAL
-- ============================================
task.wait(1)
Library:Notification({
    Title = "Lenger Hub",
    Description = "Welcome! All features ready.",
    Duration = 3,
    Icon = "73789337996373"
})