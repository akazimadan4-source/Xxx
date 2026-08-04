-- ========================================
-- WAVEX HUB - FULL SCRIPT WITH ARCANE UI
-- ========================================

-- Load Arcan UI Library
local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/NIcoGabrielRealYtr/Arcane-Library-Modified/refs/heads/main/Source"))()
if not library then
    game:GetService("Players").LocalPlayer:Kick("Failed to load UI library")
    return
end

-- ========================================
-- CORE FUNCTIONS (SAME AS ORIGINAL)
-- ========================================

-- SERVICES
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local TS = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

-- VARIABLES
local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local SilentAim, Wallbang, ESP, FOV, Stamina = false, false, false, true, false
local AimMode = "PC"
local espCache = {}

-- FOV CIRCLE
local FovCircle = Drawing.new("Circle")
FovCircle.Radius = 250
FovCircle.NumSides = 64
FovCircle.Thickness = 1
FovCircle.Visible = false
FovCircle.Color = Color3.fromRGB(0, 255, 255)
FovCircle.Transparency = 0.3

RS.RenderStepped:Connect(function()
    FovCircle.Position = AimMode == "PC" and UIS:GetMouseLocation() or Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
end)

-- ESP SETTINGS
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

local function SearchGc(name)
    for _,v in pairs(getgc()) do
        if type(v) == "function" then
            local info = debug.getinfo(v)
            if info.name == name then return v end
        end
    end
end

function GetFovTarget()
    local target, lowest = nil, math.huge
    local fovCenter = AimMode == "PC" and UIS:GetMouseLocation() or Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    for _,v in pairs(Players:GetPlayers()) do
        local char = v.Character
        if v ~= Player and char then
            local root, hum = char:FindFirstChild("HumanoidRootPart"), char:FindFirstChild("Humanoid")
            if root and hum and hum.Health > 0 then
                local sp, on = Camera:WorldToViewportPoint(root.Position)
                local dist = (fovCenter - Vector2.new(sp.X, sp.Y)).Magnitude
                if dist < FovCircle.Radius and dist < lowest and on then
                    target, lowest = v, dist
                end
            end
        end
    end
    return target
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
        local args = {...}
        args[2] = target.Character.Head.Position - args[1]
        if Wallbang then
            args[3] = {target.Character}
            return CastWhitelist(unpack(args))
        end
        return OldCast(unpack(args))
    end
    return OldCast(...)
end)

-- ========================================
-- ARCANE UI - WAVEX HUB
-- ========================================

local Window = library:Window({
    Name = "WAVEX Hub",
    Logo = "rbxassetid://93450275909746", -- can be replaced
    Size = UDim2.fromOffset(568, 350)
})

-- Category: Combat
Window:Category("Combat")

local AimbotPage = Window:Page({Name = "Aimbot", Icon = "136879043989014"})
local WallbangPage = Window:Page({Name = "Wallbang", Icon = "136879043989014"})
local StaminaPage = Window:Page({Name = "Stamina", Icon = "136879043989014"})

-- Aimbot Page
local AimbotSection = AimbotPage:Section({Name = "Aimbot Settings", Icon = "136879043989014"})

AimbotSection:Toggle({
    Name = "Silent Aim",
    Flag = "SilentAim",
    Callback = function(Value)
        SilentAim = Value
        -- Update FOV circle visibility
        FovCircle.Visible = FOV and SilentAim
    end
})

AimbotSection:Toggle({
    Name = "Show FOV Circle",
    Flag = "FOV",
    Callback = function(Value)
        FOV = Value
        FovCircle.Visible = FOV and SilentAim
    end
})

AimbotSection:Slider({
    Name = "FOV Radius",
    Flag = "FOVRadius",
    Min = 50,
    Max = 500,
    Default = 250,
    Suffix = "px",
    Callback = function(Value)
        FovCircle.Radius = Value
    end
})

AimbotSection:Dropdown({
    Name = "Aim Mode",
    Flag = "AimMode",
    Items = {"PC", "HP"},
    Default = "PC",
    Multi = false,
    Callback = function(Value)
        AimMode = Value
    end
})

-- Wallbang Page
local WallbangSection = WallbangPage:Section({Name = "Wallbang", Icon = "136879043989014"})
WallbangSection:Toggle({
    Name = "Wallbang",
    Flag = "Wallbang",
    Callback = function(Value)
        Wallbang = Value
    end
})

-- Stamina Page
local StaminaSection = StaminaPage:Section({Name = "Stamina", Icon = "136879043989014"})
StaminaSection:Toggle({
    Name = "Infinite Stamina",
    Flag = "Stamina",
    Callback = function(Value)
        ToggleStamina(Value)
    end
})

-- Category: Visuals
Window:Category("Visuals")

local ESPPage = Window:Page({Name = "ESP", Icon = "136879043989014"})
local ESPSection = ESPPage:Section({Name = "ESP Settings", Icon = "136879043989014"})

ESPSection:Toggle({
    Name = "Enable ESP",
    Flag = "ESP",
    Callback = function(Value)
        ToggleESP(Value)
    end
})

ESPSection:Toggle({
    Name = "Show Names",
    Flag = "ShowNames",
    Default = true,
    Callback = function(Value)
        espSet.ShowName = Value
    end
})

ESPSection:Toggle({
    Name = "Show Skeletons",
    Flag = "ShowSkeletons",
    Default = true,
    Callback = function(Value)
        espSet.ShowSkeletons = Value
    end
})

ESPSection:Colorpicker({
    Name = "Name Color",
    Flag = "NameColor",
    Default = Color3.fromRGB(0, 255, 255),
    Callback = function(Value)
        espSet.NameColor = Value
        -- Update existing ESP names
        for _, esp in pairs(espCache) do
            if esp.name then esp.name.Color = Value end
        end
    end
})

ESPSection:Colorpicker({
    Name = "Skeleton Color",
    Flag = "SkeletonColor",
    Default = Color3.fromRGB(0, 255, 255),
    Callback = function(Value)
        espSet.SkeletonsColor = Value
        -- Update existing skeleton lines
        for _, esp in pairs(espCache) do
            if esp.skeletonLines then
                for _, line in ipairs(esp.skeletonLines) do
                    if line and line[1] then line[1].Color = Value end
                end
            end
        end
    end
})

-- Category: Settings
Window:Category("Settings")

local SettingsPage = Window:Page({Name = "General", Icon = "136879043989014"})
local SettingsSection = SettingsPage:Section({Name = "UI", Icon = "136879043989014"})

SettingsSection:Button({
    Name = "Unload WAVEX Hub",
    Callback = function()
        -- Clean up all features
        SilentAim = false
        Wallbang = false
        FOV = false
        FovCircle.Visible = false
        FovCircle:Remove()
        ToggleESP(false)
        ToggleStamina(false)
        for _, esp in pairs(espCache) do cleanEsp(esp) end
        espCache = {}
        -- Unload UI (library might have its own method, but we destroy the window)
        Window:Destroy()
        -- Also destroy any leftover UI (just in case)
        game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("WAVEXHub") and game:GetService("Players").LocalPlayer.PlayerGui.WAVEXHub:Destroy()
    end
})

SettingsSection:Label("WAVEX Hub v1.0")

-- Notification on load
library:Notification("WAVEX Hub loaded successfully!", 4, "93450275909746")