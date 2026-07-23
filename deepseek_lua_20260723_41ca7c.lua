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
-- LENGER HUB WITH RGB BORDER
-- ========================================

-- Background Particles
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

-- ========================================
-- MAIN GUI
-- ========================================

local Gui = Instance.new("ScreenGui")
Gui.Name = "LengerHub"
Gui.ResetOnSpawn = false
Gui.Parent = Player:WaitForChild("PlayerGui")

local Panel = Instance.new("Frame")
Panel.Size = UDim2.new(0, 340, 0, 330)
Panel.Position = UDim2.new(0.5, -170, 0.3, 0)
Panel.BackgroundColor3 = Color3.fromRGB(10, 5, 25)
Panel.BackgroundTransparency = 0.1
Panel.BorderSizePixel = 0
Panel.Active = true
Panel.Draggable = true
Panel.Parent = Gui
Instance.new("UICorner", Panel).CornerRadius = UDim.new(0, 14)

-- RGB BORDER (Berjalan)
local RGBBorder = Instance.new("Frame")
RGBBorder.Size = UDim2.new(1, 6, 1, 6)
RGBBorder.Position = UDim2.new(0, -3, 0, -3)
RGBBorder.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
RGBBorder.BackgroundTransparency = 0.5
RGBBorder.BorderSizePixel = 0
RGBBorder.ZIndex = 0
RGBBorder.Parent = Panel
Instance.new("UICorner", RGBBorder).CornerRadius = UDim.new(0, 16)

-- RGB Border Animation
local hue = 0
RS.RenderStepped:Connect(function()
    hue = (hue + 0.5) % 360
    local color = Color3.fromHSV(hue / 360, 1, 1)
    RGBBorder.BackgroundColor3 = color
    RGBBorder.BackgroundTransparency = 0.3 + math.sin(hue / 30) * 0.1
end)

-- Inner Border (Stroke)
local InnerStroke = Instance.new("UIStroke", Panel)
InnerStroke.Color = Color3.fromRGB(255, 255, 255)
InnerStroke.Transparency = 0.8
InnerStroke.Thickness = 1

local Header = Instance.new("Frame", Panel)
Header.Size = UDim2.new(1,0,0,40)
Header.BackgroundTransparency = 1

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(0.7,0,1,0)
Title.Position = UDim2.new(0.05,0,0,0)
Title.BackgroundTransparency = 1
Title.Text = "LENGER HUB"
Title.TextColor3 = Color3.fromRGB(150, 100, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16

local TitleGlow = Instance.new("TextLabel", Header)
TitleGlow.Size = UDim2.new(0.7,0,1,0)
TitleGlow.Position = UDim2.new(0.05,0,0,0)
TitleGlow.BackgroundTransparency = 1
TitleGlow.Text = "LENGER HUB"
TitleGlow.TextColor3 = Color3.fromRGB(150, 50, 255)
TitleGlow.TextTransparency = 0.7
TitleGlow.TextXAlignment = Enum.TextXAlignment.Left
TitleGlow.Font = Enum.Font.GothamBold
TitleGlow.TextSize = 16
TitleGlow.ZIndex = 0

local MinBtn = Instance.new("TextButton", Header)
MinBtn.Size = UDim2.new(0,28,0,28)
MinBtn.Position = UDim2.new(0.75,0,0.1,0)
MinBtn.BackgroundTransparency = 1
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.fromRGB(200,200,200)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 20

local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0,28,0,28)
CloseBtn.Position = UDim2.new(0.88,0,0.1,0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255,80,80)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14

local Content = Instance.new("Frame", Panel)
Content.Size = UDim2.new(1,0,1,-40)
Content.Position = UDim2.new(0,0,0,40)
Content.BackgroundTransparency = 1

local Status = Instance.new("TextLabel", Content)
Status.Size = UDim2.new(0.9,0,0,25)
Status.Position = UDim2.new(0.05,0,0.02,0)
Status.BackgroundTransparency = 1
Status.Text = "INACTIVE"
Status.TextColor3 = Color3.fromRGB(200,50,50)
Status.Font = Enum.Font.GothamBold
Status.TextSize = 13
Status.TextXAlignment = Enum.TextXAlignment.Left

local function Btn(text, x, y, color)
    local b = Instance.new("TextButton", Content)
    b.Size = UDim2.new(0.43,0,0,30)
    b.Position = UDim2.new(x,0,y,0)
    b.BackgroundColor3 = color
    b.BackgroundTransparency = 0.15
    b.Text = text
    b.TextColor3 = Color3.fromRGB(255,255,255)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 12
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
    Instance.new("UIStroke", b).Color = Color3.fromRGB(100, 50, 255)
    return b
end

local FOVBtn = Btn("FOV ON", 0.05, 0.16, Color3.fromRGB(0,150,100))
local AimBtn = Btn("AIM OFF", 0.52, 0.16, Color3.fromRGB(150,30,30))
local WallBtn = Btn("WALL OFF", 0.05, 0.37, Color3.fromRGB(30,30,60))
local ESPBtn = Btn("ESP OFF", 0.52, 0.37, Color3.fromRGB(30,30,60))
local StaminaBtn = Btn("STAMINA OFF", 0.05, 0.58, Color3.fromRGB(30,30,60))
StaminaBtn.TextColor3 = Color3.fromRGB(200,200,200)
local ModeBtn = Btn("MODE: PC", 0.52, 0.58, Color3.fromRGB(20,30,80))

FOVBtn.MouseButton1Click:Connect(function()
    FOV = not FOV
    FovCircle.Visible = FOV and SilentAim
    FOVBtn.Text = FOV and "FOV ON" or "FOV OFF"
    FOVBtn.BackgroundColor3 = FOV and Color3.fromRGB(0,200,100) or Color3.fromRGB(150,30,30)
end)

AimBtn.MouseButton1Click:Connect(function()
    SilentAim = not SilentAim
    FovCircle.Visible = SilentAim and FOV
    Status.Text = SilentAim and "ACTIVE" or "INACTIVE"
    Status.TextColor3 = SilentAim and Color3.fromRGB(50,200,50) or Color3.fromRGB(200,50,50)
    AimBtn.Text = SilentAim and "AIM ON" or "AIM OFF"
    AimBtn.BackgroundColor3 = SilentAim and Color3.fromRGB(0,200,100) or Color3.fromRGB(150,30,30)
end)

WallBtn.MouseButton1Click:Connect(function()
    Wallbang = not Wallbang
    WallBtn.Text = Wallbang and "WALL ON" or "WALL OFF"
    WallBtn.BackgroundColor3 = Wallbang and Color3.fromRGB(0,200,100) or Color3.fromRGB(30,30,60)
    WallBtn.TextColor3 = Wallbang and Color3.fromRGB(255,255,255) or Color3.fromRGB(200,200,200)
end)

ESPBtn.MouseButton1Click:Connect(function()
    ToggleESP(not ESP)
    ESPBtn.Text = ESP and "ESP ON" or "ESP OFF"
    ESPBtn.BackgroundColor3 = ESP and Color3.fromRGB(0,200,100) or Color3.fromRGB(30,30,60)
    ESPBtn.TextColor3 = ESP and Color3.fromRGB(255,255,255) or Color3.fromRGB(200,200,200)
end)

StaminaBtn.MouseButton1Click:Connect(function()
    ToggleStamina(not Stamina)
    StaminaBtn.Text = Stamina and "STAMINA ON" or "STAMINA OFF"
    StaminaBtn.BackgroundColor3 = Stamina and Color3.fromRGB(0,200,100) or Color3.fromRGB(30,30,60)
    StaminaBtn.TextColor3 = Color3.fromRGB(255,255,255)
end)

ModeBtn.MouseButton1Click:Connect(function()
    AimMode = AimMode == "PC" and "HP" or "PC"
    ModeBtn.Text = "MODE: " .. AimMode
    ModeBtn.BackgroundColor3 = AimMode == "PC" and Color3.fromRGB(20,30,80) or Color3.fromRGB(80,20,50)
end)

MinBtn.MouseButton1Click:Connect(function()
    isMin = not isMin
    Content.Visible = not isMin
    Panel.Size = isMin and UDim2.new(0,340,0,40) or UDim2.new(0,340,0,330)
    MinBtn.Text = isMin and "+" or "-"
end)

CloseBtn.MouseButton1Click:Connect(function()
    SilentAim, Wallbang = false, false
    FovCircle.Visible = false
    FovCircle:Remove()
    ToggleESP(false)
    ToggleStamina(false)
    for _, esp in pairs(espCache) do cleanEsp(esp) end
    espCache = {}
    ParticleContainer:Destroy()
    Gui:Destroy()
end)

local Notif = Instance.new("TextLabel", Gui)
Notif.Size = UDim2.new(0,340,0,40)
Notif.Position = UDim2.new(0.5,-170,0.9,0)
Notif.BackgroundColor3 = Color3.fromRGB(100,50,255)
Notif.BackgroundTransparency = 0.15
Notif.Text = "LENGER HUB LOADED"
Notif.TextColor3 = Color3.fromRGB(255,255,255)
Notif.Font = Enum.Font.GothamBold
Notif.TextSize = 14
Notif.ZIndex = 100
Instance.new("UICorner", Notif).CornerRadius = UDim.new(0,8)
Instance.new("UIStroke", Notif).Color = Color3.fromRGB(150,50,255)

TS:Create(Notif, TweenInfo.new(1), {Position = UDim2.new(0.5,-170,0.8,0)}):Play()
task.wait(4)
TS:Create(Notif, TweenInfo.new(0.5), {Position = UDim2.new(0.5,-170,0.95,0)}):Play()
task.wait(0.5)
Notif:Destroy()