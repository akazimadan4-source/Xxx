-- =============================================
-- WAVEX HUB - Reborn (No Stamina, Refactored)
-- =============================================

-- Services
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

-- Locals
local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = Player:GetMouse()

-- Toggles
local aimEnabled = false
local wallEnabled = false
local espEnabled = false
local fovEnabled = true
local aimMode = "PC" -- PC or HP

-- FOV Circle
local fovCircle = Drawing.new("Circle")
fovCircle.Radius = 250
fovCircle.NumSides = 64
fovCircle.Thickness = 1.5
fovCircle.Visible = false
fovCircle.Color = Color3.fromRGB(0, 255, 255)
fovCircle.Transparency = 0.35

RunService.RenderStepped:Connect(function()
    local pos = (aimMode == "PC") and UIS:GetMouseLocation() or Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    fovCircle.Position = pos
end)

-- ESP System
local espData = {}
local espConfig = {
    enabled = false,
    showName = true,
    showSkeleton = true,
    nameColor = Color3.fromRGB(0, 255, 255),
    skeletonColor = Color3.fromRGB(0, 255, 255)
}

local bonePairs = {
    {"Head","UpperTorso"},{"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},
    {"RightLowerArm","RightHand"},{"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},
    {"LeftLowerArm","LeftHand"},{"UpperTorso","LowerTorso"},{"LowerTorso","LeftUpperLeg"},
    {"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},{"LowerTorso","RightUpperLeg"},
    {"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"}
}

local function createDrawObject(class, props)
    local obj = Drawing.new(class)
    for k, v in pairs(props) do
        obj[k] = v
    end
    return obj
end

local function clearEsp(entry)
    if not entry then return end
    if entry.nameLabel then pcall(entry.nameLabel.Remove, entry.nameLabel) end
    if entry.lines then
        for _, line in ipairs(entry.lines) do
            if line and line[1] then pcall(line[1].Remove, line[1]) end
        end
    end
end

local function addEspTarget(player)
    if espData[player] then return end
    espData[player] = {
        nameLabel = createDrawObject("Text", {
            Color = espConfig.nameColor,
            Outline = true,
            Center = true,
            Size = 13,
            Visible = false
        }),
        lines = {}
    }
end

local function removeEspTarget(player)
    local entry = espData[player]
    if entry then
        clearEsp(entry)
        espData[player] = nil
    end
end

local function hideAllEsp()
    for _, entry in pairs(espData) do
        if entry.nameLabel then entry.nameLabel.Visible = false end
        for _, line in ipairs(entry.lines) do
            if line and line[1] then line[1].Visible = false end
        end
    end
end

local function toggleEsp(state)
    espEnabled = state
    espConfig.enabled = state
    if not state then hideAllEsp() end
end

local function refreshEsp()
    for player, entry in pairs(espData) do
        if not player or not player.Parent then
            removeEspTarget(player)
            continue
        end

        local character = player.Character
        if not character or not espConfig.enabled then
            if entry.nameLabel then entry.nameLabel.Visible = false end
            for _, line in ipairs(entry.lines) do if line and line[1] then line[1].Visible = false end end
            continue
        end

        local rootPart = character:FindFirstChild("HumanoidRootPart")
        local humanoid = character:FindFirstChild("Humanoid")
        if not rootPart or not humanoid or humanoid.Health <= 0 then
            if entry.nameLabel then entry.nameLabel.Visible = false end
            for _, line in ipairs(entry.lines) do if line and line[1] then line[1].Visible = false end end
            continue
        end

        local screenPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
        if not onScreen then
            if entry.nameLabel then entry.nameLabel.Visible = false end
            for _, line in ipairs(entry.lines) do if line and line[1] then line[1].Visible = false end end
            continue
        end

        local hrp2D = Camera:WorldToViewportPoint(rootPart.Position)
        local boxHeight = (Camera:WorldToViewportPoint(rootPart.Position - Vector3.new(0,3,0)).Y - Camera:WorldToViewportPoint(rootPart.Position + Vector3.new(0,2.6,0)).Y) / 2
        local boxSize = Vector2.new(math.floor(boxHeight * 1.8), math.floor(boxHeight * 1.9))
        local boxPos = Vector2.new(math.floor(hrp2D.X - boxHeight * 1.8 / 2), math.floor(hrp2D.Y - boxHeight * 1.6 / 2))

        if espConfig.showName then
            entry.nameLabel.Text = player.Name
            entry.nameLabel.Position = Vector2.new(boxSize.X/2 + boxPos.X, boxPos.Y - 16)
            entry.nameLabel.Visible = true
        else
            entry.nameLabel.Visible = false
        end

        if espConfig.showSkeleton then
            if #entry.lines == 0 then
                for _, pair in ipairs(bonePairs) do
                    if character[pair[1]] and character[pair[2]] then
                        local line = createDrawObject("Line", {
                            Thickness = 1.5,
                            Color = espConfig.skeletonColor,
                            Transparency = 0.7,
                            Visible = false
                        })
                        table.insert(entry.lines, {line, pair[1], pair[2]})
                    end
                end
            end
            for _, lineData in ipairs(entry.lines) do
                local part1 = character[lineData[2]]
                local part2 = character[lineData[3]]
                if part1 and part2 then
                    local p1 = Camera:WorldToViewportPoint(part1.Position)
                    local p2 = Camera:WorldToViewportPoint(part2.Position)
                    lineData[1].From = Vector2.new(p1.X, p1.Y)
                    lineData[1].To = Vector2.new(p2.X, p2.Y)
                    lineData[1].Visible = true
                else
                    lineData[1].Visible = false
                end
            end
        else
            for _, lineData in ipairs(entry.lines) do
                if lineData[1] then lineData[1].Visible = false end
            end
        end
    end
end

-- Initialize ESP for existing players
for _, plr in ipairs(Players:GetPlayers()) do
    if plr ~= Player then addEspTarget(plr) end
end

Players.PlayerAdded:Connect(function(plr)
    if plr ~= Player then addEspTarget(plr) end
end)
Players.PlayerRemoving:Connect(removeEspTarget)
RunService.RenderStepped:Connect(refreshEsp)

-- Core: Silent Aim & Wallbang (same hook method)
local function findGC(name)
    for _, obj in pairs(getgc()) do
        if type(obj) == "function" then
            local info = debug.getinfo(obj)
            if info and info.name == name then
                return obj
            end
        end
    end
    return nil
end

local castBlacklist = findGC("CastBlacklist")
local castWhitelist = findGC("CastWhitelist")
if not castBlacklist or not castWhitelist then
    Player:Kick("Required functions not found")
    return
end

local function getBestTarget()
    local best, bestDist = nil, math.huge
    local fovCenter = (aimMode == "PC") and UIS:GetMouseLocation() or Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    for _, plr in pairs(Players:GetPlayers()) do
        if plr == Player then continue end
        local char = plr.Character
        if char then
            local root = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChild("Humanoid")
            if root and hum and hum.Health > 0 then
                local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
                if onScreen then
                    local dist = (fovCenter - Vector2.new(pos.X, pos.Y)).Magnitude
                    if dist < fovCircle.Radius and dist < bestDist then
                        best, bestDist = plr, dist
                    end
                end
            end
        end
    end
    return best
end

local originalCast = hookfunction(castBlacklist, function(...)
    local args = {...}
    local target = getBestTarget()
    if target and aimEnabled then
        local targetChar = target.Character
        if targetChar then
            local head = targetChar:FindFirstChild("Head")
            if head then
                args[2] = head.Position - args[1] -- direction to target
                if wallEnabled then
                    args[3] = {targetChar} -- allow hit through walls
                    return castWhitelist(unpack(args))
                end
                return originalCast(unpack(args))
            end
        end
    end
    return originalCast(unpack(args))
end)

-- UI (without stamina)
local function buildUI()
    local gui = Instance.new("ScreenGui")
    gui.Parent = Player:WaitForChild("PlayerGui")
    gui.Name = "WavexHubReborn"
    gui.ResetOnSpawn = false

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 280, 0, 320)
    mainFrame.Position = UDim2.new(0.5, -140, 0.3, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
    mainFrame.BackgroundTransparency = 0.15
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = gui
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)
    local stroke = Instance.new("UIStroke", mainFrame)
    stroke.Color = Color3.fromRGB(100, 50, 255)
    stroke.Thickness = 1.5
    stroke.Transparency = 0.5

    local title = Instance.new("TextLabel", mainFrame)
    title.Size = UDim2.new(1, 0, 0, 35)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "WAVEX REBORN"
    title.TextColor3 = Color3.fromRGB(180, 130, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.TextScaled = true

    local closeBtn = Instance.new("TextButton", mainFrame)
    closeBtn.Size = UDim2.new(0, 25, 0, 25)
    closeBtn.Position = UDim2.new(1, -30, 0, 5)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 14

    local divider = Instance.new("Frame", mainFrame)
    divider.Size = UDim2.new(0.9, 0, 0, 1)
    divider.Position = UDim2.new(0.05, 0, 0, 35)
    divider.BackgroundColor3 = Color3.fromRGB(100, 50, 255)
    divider.BackgroundTransparency = 0.4
    divider.BorderSizePixel = 0

    local statusLabel = Instance.new("TextLabel", mainFrame)
    statusLabel.Size = UDim2.new(0.9, 0, 0, 20)
    statusLabel.Position = UDim2.new(0.05, 0, 0, 42)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Status: INACTIVE"
    statusLabel.TextColor3 = Color3.fromRGB(200, 50, 50)
    statusLabel.Font = Enum.Font.GothamBold
    statusLabel.TextSize = 13
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left

    local function makeBtn(text, yPos, defaultColor, activeColor)
        local btn = Instance.new("TextButton", mainFrame)
        btn.Size = UDim2.new(0.85, 0, 0, 30)
        btn.Position = UDim2.new(0.075, 0, 0, yPos)
        btn.BackgroundColor3 = defaultColor
        btn.BackgroundTransparency = 0.2
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(255,255,255)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 12
        btn.BorderSizePixel = 0
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        local btnStroke = Instance.new("UIStroke", btn)
        btnStroke.Color = Color3.fromRGB(100, 50, 255)
        btnStroke.Thickness = 1
        btnStroke.Transparency = 0.6
        return btn
    end

    local aimBtn = makeBtn("[OFF] Silent Aim", 70, Color3.fromRGB(150,30,30), Color3.fromRGB(0,200,100))
    local fovBtn = makeBtn("[ON] FOV Circle", 110, Color3.fromRGB(0,150,100), Color3.fromRGB(0,200,100))
    local wallBtn = makeBtn("[OFF] Wallbang", 150, Color3.fromRGB(30,30,60), Color3.fromRGB(0,200,100))
    local espBtn = makeBtn("[OFF] ESP", 190, Color3.fromRGB(30,30,60), Color3.fromRGB(0,200,100))
    local modeBtn = makeBtn("Mode: PC", 230, Color3.fromRGB(20,30,80), Color3.fromRGB(80,20,50))

    aimBtn.MouseButton1Click:Connect(function()
        aimEnabled = not aimEnabled
        fovCircle.Visible = aimEnabled and fovEnabled
        statusLabel.Text = "Status: " .. (aimEnabled and "ACTIVE" or "INACTIVE")
        statusLabel.TextColor3 = aimEnabled and Color3.fromRGB(50,200,50) or Color3.fromRGB(200,50,50)
        aimBtn.Text = aimEnabled and "[ON] Silent Aim" or "[OFF] Silent Aim"
        aimBtn.BackgroundColor3 = aimEnabled and Color3.fromRGB(0,200,100) or Color3.fromRGB(150,30,30)
    end)

    fovBtn.MouseButton1Click:Connect(function()
        fovEnabled = not fovEnabled
        fovCircle.Visible = fovEnabled and aimEnabled
        fovBtn.Text = fovEnabled and "[ON] FOV Circle" or "[OFF] FOV Circle"
        fovBtn.BackgroundColor3 = fovEnabled and Color3.fromRGB(0,200,100) or Color3.fromRGB(150,30,30)
    end)

    wallBtn.MouseButton1Click:Connect(function()
        wallEnabled = not wallEnabled
        wallBtn.Text = wallEnabled and "[ON] Wallbang" or "[OFF] Wallbang"
        wallBtn.BackgroundColor3 = wallEnabled and Color3.fromRGB(0,200,100) or Color3.fromRGB(30,30,60)
    end)

    espBtn.MouseButton1Click:Connect(function()
        toggleEsp(not espEnabled)
        espBtn.Text = espEnabled and "[ON] ESP" or "[OFF] ESP"
        espBtn.BackgroundColor3 = espEnabled and Color3.fromRGB(0,200,100) or Color3.fromRGB(30,30,60)
    end)

    modeBtn.MouseButton1Click:Connect(function()
        aimMode = (aimMode == "PC") and "HP" or "PC"
        modeBtn.Text = "Mode: " .. aimMode
        modeBtn.BackgroundColor3 = (aimMode == "PC") and Color3.fromRGB(20,30,80) or Color3.fromRGB(80,20,50)
    end)

    closeBtn.MouseButton1Click:Connect(function()
        aimEnabled = false; wallEnabled = false; fovEnabled = false
        fovCircle.Visible = false; fovCircle:Remove()
        toggleEsp(false)
        for _, entry in pairs(espData) do clearEsp(entry) end
        espData = {}
        gui:Destroy()
    end)

    -- Notification
    local notif = Instance.new("TextLabel", gui)
    notif.Size = UDim2.new(0, 280, 0, 35)
    notif.Position = UDim2.new(0.5, -140, 0.9, 0)
    notif.BackgroundColor3 = Color3.fromRGB(100, 50, 255)
    notif.BackgroundTransparency = 0.15
    notif.Text = "WAVEX REBORN LOADED"
    notif.TextColor3 = Color3.fromRGB(255,255,255)
    notif.Font = Enum.Font.GothamBold
    notif.TextSize = 14
    Instance.new("UICorner", notif).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", notif).Color = Color3.fromRGB(150, 50, 255)

    TweenService:Create(notif, TweenInfo.new(1), {Position = UDim2.new(0.5, -140, 0.8, 0)}):Play()
    task.wait(4)
    TweenService:Create(notif, TweenInfo.new(0.5), {Position = UDim2.new(0.5, -140, 1.0, 0)}):Play()
    task.wait(0.5)
    notif:Destroy()
end

buildUI()