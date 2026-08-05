-- ========================================
-- WAVEX HUB - SIMPLE UI (NO EXTERNAL LIBRARY)
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
local SilentAim, Wallbang, ESP, FOV = false, false, false, true
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
-- SIMPLE UI (NO LIBRARY)
-- ========================================

local function CreateUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Parent = Player:WaitForChild("PlayerGui")
    ScreenGui.Name = "WAVEXHub"
    ScreenGui.ResetOnSpawn = false

    -- Main Frame
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 280, 0, 320) -- slightly reduced height
    Frame.Position = UDim2.new(0.5, -140, 0.3, 0)
    Frame.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
    Frame.BackgroundTransparency = 0.15
    Frame.BorderSizePixel = 0
    Frame.Active = true
    Frame.Draggable = true
    Frame.Parent = ScreenGui
    local Corner = Instance.new("UICorner", Frame)
    Corner.CornerRadius = UDim.new(0, 10)

    -- Inner Stroke
    local Stroke = Instance.new("UIStroke", Frame)
    Stroke.Color = Color3.fromRGB(100, 50, 255)
    Stroke.Thickness = 1.5
    Stroke.Transparency = 0.5

    -- Title
    local Title = Instance.new("TextLabel", Frame)
    Title.Size = UDim2.new(1, 0, 0, 35)
    Title.Position = UDim2.new(0, 0, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "WAVEX HUB"
    Title.TextColor3 = Color3.fromRGB(180, 130, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18
    Title.TextScaled = true

    -- Close Button
    local CloseBtn = Instance.new("TextButton", Frame)
    CloseBtn.Size = UDim2.new(0, 25, 0, 25)
    CloseBtn.Position = UDim2.new(1, -30, 0, 5)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 14
    CloseBtn.Parent = Frame

    -- Divider
    local Div = Instance.new("Frame", Frame)
    Div.Size = UDim2.new(0.9, 0, 0, 1)
    Div.Position = UDim2.new(0.05, 0, 0, 35)
    Div.BackgroundColor3 = Color3.fromRGB(100, 50, 255)
    Div.BackgroundTransparency = 0.4
    Div.BorderSizePixel = 0

    -- Status Label
    local Status = Instance.new("TextLabel", Frame)
    Status.Size = UDim2.new(0.9, 0, 0, 20)
    Status.Position = UDim2.new(0.05, 0, 0, 42)
    Status.BackgroundTransparency = 1
    Status.Text = "Status: INACTIVE"
    Status.TextColor3 = Color3.fromRGB(200, 50, 50)
    Status.Font = Enum.Font.GothamBold
    Status.TextSize = 13
    Status.TextXAlignment = Enum.TextXAlignment.Left

    -- Helper function to create toggle button
    local function ToggleBtn(text, yPos, defaultColor, onColor)
        local btn = Instance.new("TextButton", Frame)
        btn.Size = UDim2.new(0.85, 0, 0, 30)
        btn.Position = UDim2.new(0.075, 0, 0, yPos)
        btn.BackgroundColor3 = defaultColor
        btn.BackgroundTransparency = 0.2
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(255,255,255)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 12
        btn.BorderSizePixel = 0
        local btnCorner = Instance.new("UICorner", btn)
        btnCorner.CornerRadius = UDim.new(0, 6)
        local btnStroke = Instance.new("UIStroke", btn)
        btnStroke.Color = Color3.fromRGB(100, 50, 255)
        btnStroke.Thickness = 1
        btnStroke.Transparency = 0.6
        return btn
    end

    -- Create buttons (Stamina removed)
    local AimBtn = ToggleBtn("[OFF] Silent Aim", 70, Color3.fromRGB(150, 30, 30), Color3.fromRGB(0, 200, 100))
    local FOVBtn = ToggleBtn("[ON] FOV Circle", 110, Color3.fromRGB(0, 150, 100), Color3.fromRGB(0, 200, 100))
    local WallBtn = ToggleBtn("[OFF] Wallbang", 150, Color3.fromRGB(30, 30, 60), Color3.fromRGB(0, 200, 100))
    local ESPBtn = ToggleBtn("[OFF] ESP", 190, Color3.fromRGB(30, 30, 60), Color3.fromRGB(0, 200, 100))
    local ModeBtn = ToggleBtn("Mode: PC", 230, Color3.fromRGB(20, 30, 80), Color3.fromRGB(80, 20, 50))

    -- Modify some buttons to have different colors
    ModeBtn.BackgroundColor3 = Color3.fromRGB(20, 30, 80)

    -- Button Click Events
    AimBtn.MouseButton1Click:Connect(function()
        SilentAim = not SilentAim
        FovCircle.Visible = SilentAim and FOV
        Status.Text = "Status: " .. (SilentAim and "ACTIVE" or "INACTIVE")
        Status.TextColor3 = SilentAim and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
        AimBtn.Text = SilentAim and "[ON] Silent Aim" or "[OFF] Silent Aim"
        AimBtn.BackgroundColor3 = SilentAim and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(150, 30, 30)
    end)

    FOVBtn.MouseButton1Click:Connect(function()
        FOV = not FOV
        FovCircle.Visible = FOV and SilentAim
        FOVBtn.Text = FOV and "[ON] FOV Circle" or "[OFF] FOV Circle"
        FOVBtn.BackgroundColor3 = FOV and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(150, 30, 30)
    end)

    WallBtn.MouseButton1Click:Connect(function()
        Wallbang = not Wallbang
        WallBtn.Text = Wallbang and "[ON] Wallbang" or "[OFF] Wallbang"
        WallBtn.BackgroundColor3 = Wallbang and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(30, 30, 60)
    end)

    ESPBtn.MouseButton1Click:Connect(function()
        ToggleESP(not ESP)
        ESPBtn.Text = ESP and "[ON] ESP" or "[OFF] ESP"
        ESPBtn.BackgroundColor3 = ESP and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(30, 30, 60)
    end)

    ModeBtn.MouseButton1Click:Connect(function()
        AimMode = AimMode == "PC" and "HP" or "PC"
        ModeBtn.Text = "Mode: " .. AimMode
        ModeBtn.BackgroundColor3 = AimMode == "PC" and Color3.fromRGB(20, 30, 80) or Color3.fromRGB(80, 20, 50)
    end)

    -- Close button
    CloseBtn.MouseButton1Click:Connect(function()
        -- Cleanup (Stamina removed)
        SilentAim = false; Wallbang = false; FOV = false
        FovCircle.Visible = false; FovCircle:Remove()
        ToggleESP(false)
        for _, esp in pairs(espCache) do cleanEsp(esp) end
        espCache = {}
        ScreenGui:Destroy()
    end)

    -- Notification
    local Notif = Instance.new("TextLabel", ScreenGui)
    Notif.Size = UDim2.new(0, 280, 0, 35)
    Notif.Position = UDim2.new(0.5, -140, 0.9, 0)
    Notif.BackgroundColor3 = Color3.fromRGB(100, 50, 255)
    Notif.BackgroundTransparency = 0.15
    Notif.Text = "WAVEX HUB LOADED"
    Notif.TextColor3 = Color3.fromRGB(255,255,255)
    Notif.Font = Enum.Font.GothamBold
    Notif.TextSize = 14
    Notif.ZIndex = 100
    Instance.new("UICorner", Notif).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", Notif).Color = Color3.fromRGB(150, 50, 255)

    TS:Create(Notif, TweenInfo.new(1), {Position = UDim2.new(0.5, -140, 0.8, 0)}):Play()
    task.wait(4)
    TS:Create(Notif, TweenInfo.new(0.5), {Position = UDim2.new(0.5, -140, 1.0, 0)}):Play()
    task.wait(0.5)
    Notif:Destroy()
end

-- Create the UI
CreateUI()