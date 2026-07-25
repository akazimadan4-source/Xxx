-- SERVICES
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local TS = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

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

local function updateFovVisibility()
    FovCircle.Visible = SilentAim and FOV
end

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
-- WINDUI UI (replaces old GUI)
-- ========================================

-- Background Particles (optional, keep for aesthetics)
local ParticleContainer = Instance.new("Frame")
ParticleContainer.Size = UDim2.new(1, 0, 1, 0)
ParticleContainer.BackgroundTransparency = 1
ParticleContainer.Parent = Player:WaitForChild("PlayerGui")

local Particles = {}
local ParticleCount = 30

for i = 1, ParticleCount do
    local p = Instance.new("Frame")
    p.Size = UDim2.new(0, math.random(3, 6), 0, math.random(3, 6))
    p.Position = UDim2.new(math.random(), 0, math.random(), 0)
    p.BackgroundColor3 = Color3.fromRGB(
        math.random(100, 255),
        math.random(100, 255),
        255
    )
    p.BackgroundTransparency = 0.3
    p.BorderSizePixel = 0
    p.ZIndex = 0
    Instance.new("UICorner", p).CornerRadius = UDim.new(1, 0)
    p.Parent = ParticleContainer
    
    table.insert(Particles, {
        object = p,
        speedX = (math.random() - 0.5) * 0.005,
        speedY = (math.random() - 0.5) * 0.005,
        floatPhase = math.random() * math.pi * 2
    })
end

RS.RenderStepped:Connect(function()
    for _, data in ipairs(Particles) do
        data.floatPhase = data.floatPhase + 0.02
        local floatOffset = math.sin(data.floatPhase) * 0.01
        
        local pos = data.object.Position
        local newX = pos.X.Scale + data.speedX + floatOffset * 0.5
        local newY = pos.Y.Scale + data.speedY + floatOffset * 0.5
        
        if newX > 1 then newX = 0 end
        if newX < 0 then newX = 1 end
        if newY > 1 then newY = 0 end
        if newY < 0 then newY = 1 end
        
        data.object.Position = UDim2.new(newX, 0, newY, 0)
        data.object.BackgroundColor3 = Color3.fromRGB(
            128 + math.sin(data.floatPhase) * 127,
            128 + math.cos(data.floatPhase * 1.2) * 127,
            255
        )
    end
end)

-- Load WindUI
local WindUI
do
    local cloneref = (cloneref or clonereference or function(instance) return instance end)
    local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
    local RunService = cloneref(game:GetService("RunService"))

    local ok, result = pcall(function()
        return require("./src/Init")
    end)

    if ok then
        WindUI = result
    else
        if RunService:IsStudio() or not writefile then
            WindUI = require(ReplicatedStorage:WaitForChild("WindUI"):WaitForChild("Init"))
        else
            WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
        end
    end
end

-- Create Window
local Window = WindUI:CreateWindow({
    Title = "LENGER HUB",
    Author = "by Lenger",
    Icon = "solar:wind-bold",
    Theme = "Dark",
    ToggleKey = Enum.KeyCode.F,
})

-- Tabs
local MainTab = Window:Tab({
    Title = "Main",
    Icon = "warehouse",
})

local InfoTab = Window:Tab({
    Title = "Info",
    Icon = "badge-info",
})

-- Main Tab: Aimbot Section
local AimbotSection = MainTab:Section({
    Title = "Aimbot",
    Icon = "locate-fixed",
})

-- Silent Aim
local silentToggle = AimbotSection:Toggle({
    Title = "Silent Aim",
    Desc = "Enable silent aim",
    Icon = "crosshair",
    Value = false,
    Callback = function(state)
        SilentAim = state
        updateFovVisibility()
    end,
})

-- FOV Circle
local fovToggle = AimbotSection:Toggle({
    Title = "FOV Circle",
    Desc = "Show FOV circle",
    Icon = "circle",
    Value = false,
    Callback = function(state)
        FOV = state
        updateFovVisibility()
    end,
})

-- FOV Radius Slider
AimbotSection:Slider({
    Title = "FOV Radius",
    Desc = "Adjust FOV circle radius",
    Icon = "radius",
    Min = 50,
    Max = 500,
    Default = 250,
    Value = 250,
    Callback = function(value)
        FovCircle.Radius = value
    end,
})

-- Wallbang
AimbotSection:Toggle({
    Title = "Wallbang",
    Desc = "Allow hitting through walls",
    Icon = "wall",
    Value = false,
    Callback = function(state)
        Wallbang = state
    end,
})

-- Aim Mode (PC/HP) as Toggle with custom labels
local modeToggle = AimbotSection:Toggle({
    Title = "Aim Mode",
    Desc = "Switch between PC and HP (mobile)",
    Icon = "monitor",
    Value = (AimMode == "PC"),
    OnText = "PC",
    OffText = "HP",
    Callback = function(state)
        AimMode = state and "PC" or "HP"
    end,
})

-- ESP Section
local ESPSection = MainTab:Section({
    Title = "ESP",
    Icon = "eye",
})

ESPSection:Toggle({
    Title = "ESP",
    Desc = "Enable ESP for players",
    Icon = "eye",
    Value = false,
    Callback = function(state)
        ToggleESP(state)
    end,
})

-- Stamina Section
local StaminaSection = MainTab:Section({
    Title = "Stamina",
    Icon = "battery-full",
})

StaminaSection:Toggle({
    Title = "Infinite Stamina",
    Desc = "Keep stamina at max",
    Icon = "battery",
    Value = false,
    Callback = function(state)
        ToggleStamina(state)
    end,
})

-- Info Tab
InfoTab:Paragraph({
    Title = "LENGER HUB",
    Desc = "Aimbot & ESP for your game\nMade with WindUI",
})

InfoTab:Button({
    Title = "Close & Cleanup",
    Desc = "Disable all features and close UI",
    Icon = "x",
    Color = Color3.fromHex("#FF4444"),
    Callback = function()
        -- Disable everything
        SilentAim = false
        Wallbang = false
        FOV = false
        ToggleESP(false)
        ToggleStamina(false)
        FovCircle.Visible = false
        FovCircle:Remove()
        if ParticleContainer then ParticleContainer:Destroy() end
        Window:Destroy()
    end,
})

-- Optional: quick notification
local Notif = Instance.new("TextLabel")
Notif.Size = UDim2.new(0, 340, 0, 40)
Notif.Position = UDim2.new(0.5, -170, 0.9, 0)
Notif.BackgroundColor3 = Color3.fromRGB(100, 50, 255)
Notif.BackgroundTransparency = 0.15
Notif.Text = "LENGER HUB LOADED"
Notif.TextColor3 = Color3.fromRGB(255, 255, 255)
Notif.Font = Enum.Font.GothamBold
Notif.TextSize = 14
Notif.ZIndex = 100
Instance.new("UICorner", Notif).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", Notif).Color = Color3.fromRGB(150, 50, 255)
Notif.Parent = Player:WaitForChild("PlayerGui")

TS:Create(Notif, TweenInfo.new(1), {Position = UDim2.new(0.5, -170, 0.8, 0)}):Play()
task.wait(4)
TS:Create(Notif, TweenInfo.new(0.5), {Position = UDim2.new(0.5, -170, 0.95, 0)}):Play()
task.wait(0.5)
Notif:Destroy()