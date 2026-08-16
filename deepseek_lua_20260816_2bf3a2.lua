-- Deobfuscated and cleaned version
-- Script: Quickz Movement GUI
-- Token: "Quickz-1920"

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
if not player then
    player = Players.PlayerAdded:Wait()
end

-- GUI Colors
local colors = {
    MainBG = Color3.fromRGB(30, 30, 30),
    BarBG = Color3.fromRGB(37, 37, 38),
    Text = Color3.fromRGB(240, 240, 240),
    SubText = Color3.fromRGB(160, 160, 160),
    Border = Color3.fromRGB(65, 65, 65),
    Accent = Color3.fromRGB(50, 50, 52)
}

-- Config variables
local speed = 14              -- r30
local heightOffset = -11      -- r31
local surfaceOffset = 3       -- _G.QM_SurfaceOffset
local dropPadding = 3         -- _G.QM_DropPadding
local slowdownDist = 20       -- _G.QM_SlowdownDist
local slowdownMin = 0.15      -- _G.QM_SlowdownMin
local arriveDelay = 2         -- _G.QM_ArriveDelay
local cancelIfBusy = false    -- _G.QM_CancelIfBusy

-- State
local isMoving = false
local slowNearDest = false
local platform = nil          -- the moving platform part
local platformY = nil         -- current platform height
local heartbeatConn = nil

-- Platform creation
local function createPlatform(yPos)
    if platform and platform.Parent then
        return platform
    end
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local part = Instance.new("Part")
    part.Name = "Quickz_MovPlatform"
    part.Shape = Enum.PartType.Cylinder
    part.Size = Vector3.new(1, 30, 30)
    part.Anchored = true
    part.CanCollide = true
    part.Transparency = 1
    part.CFrame = CFrame.new(hrp.Position.X, yPos, hrp.Position.Z) * CFrame.Angles(0, 0, math.rad(90))
    part.Parent = workspace

    platformY = yPos
    platform = part

    heartbeatConn = RunService.Heartbeat:Connect(function()
        if not platform or not platform.Parent then
            if heartbeatConn then heartbeatConn:Disconnect() end
            return
        end
        local char = player.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                platform.CFrame = CFrame.new(hrp.Position.X, platformY, hrp.Position.Z) * CFrame.Angles(0, 0, math.rad(90))
            end
        end
    end)

    return platform
end

-- Destroy platform
local function destroyPlatform()
    if platform and platform.Parent then
        platform.Transparency = 1
    end
    if heartbeatConn then
        heartbeatConn:Disconnect()
        heartbeatConn = nil
    end
end

-- Go underground
local function goUnderground()
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp or not platformY then return end
    pcall(function()
        hrp.CFrame = CFrame.new(hrp.Position.X, platformY + 0.5 + 3, hrp.Position.Z)
    end)
    task.wait(0.05)
end

-- Surface
local function surface()
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp or not platformY then return end
    pcall(function()
        hrp.CFrame = CFrame.new(hrp.Position.X, platformY + 11 + 3, hrp.Position.Z)
    end)
    task.wait(0.3)
    destroyPlatform()
end

-- Smooth teleport function
local function teleportTo(targetPos, yBase, onProgress)
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not humanoid then return end

    local origSpeed = humanoid.WalkSpeed
    local origJump = humanoid.JumpPower
    humanoid.WalkSpeed = 0
    humanoid.JumpPower = 0

    local targetY = yBase + 0.5 + surfaceOffset
    pcall(function()
        hrp.CFrame = CFrame.new(hrp.Position.X, targetY, hrp.Position.Z)
    end)
    task.wait(0.05)

    local startVec = Vector2.new(targetPos.X, targetPos.Z)
    local currentVec = Vector2.new(hrp.Position.X, hrp.Position.Z)
    local totalDist = (startVec - currentVec).Magnitude
    if totalDist < 0.5 then
        humanoid.WalkSpeed = origSpeed
        humanoid.JumpPower = origJump
        return
    end

    isMoving = true
    local finished = false

    local moveConn = RunService.Heartbeat:Connect(function(dt)
        if not isMoving then
            finished = true
            if moveConn then moveConn:Disconnect() end
            return
        end
        local charNow = player.Character
        if not charNow then
            finished = true
            if moveConn then moveConn:Disconnect() end
            return
        end
        local hrpNow = charNow:FindFirstChild("HumanoidRootPart")
        if not hrpNow then
            finished = true
            if moveConn then moveConn:Disconnect() end
            return
        end

        local currentPos = Vector2.new(hrpNow.Position.X, hrpNow.Position.Z)
        local delta = startVec - currentPos
        local distRemaining = delta.Magnitude

        if distRemaining < 0.3 then
            pcall(function()
                hrpNow.CFrame = CFrame.new(targetPos.X, targetY, targetPos.Z)
            end)
            finished = true
            if moveConn then moveConn:Disconnect() end
            return
        end

        local moveSpeed = speed
        if slowNearDest then
            moveSpeed = speed * math.clamp(distRemaining / slowdownDist, slowdownMin, 1)
        end

        local step = delta.Unit * math.min(moveSpeed * dt, distRemaining)
        local newPos = currentPos + step
        pcall(function()
            hrpNow.CFrame = CFrame.new(newPos.X, targetY, newPos.Y)
        end)

        if onProgress then
            local progress = math.floor((totalDist - distRemaining) / totalDist * 100)
            onProgress(progress)
        end
    end)

    while not finished do
        task.wait(0.05)
    end

    isMoving = false
    humanoid.WalkSpeed = origSpeed
    humanoid.JumpPower = origJump
end

-- Teleport sequence
local function performTeleport(target)
    if isMoving then
        if cancelIfBusy then
            -- Cancel current movement? In original code it just shows "busy".
            return
        end
        statusText.Text = "[tp] busy — wait..."
        return
    end

    isMoving = true
    task.spawn(function()
        statusText.Text = "[tp] going underground..."
        createPlatform(platformY or heightOffset + 0) -- initialize if needed
        goUnderground()

        statusText.Text = string.format("[tp] traveling to %s...", target.name)
        teleportTo(Vector3.new(target.x, 0, target.z), platformY or heightOffset + 0, function(pct)
            statusText.Text = string.format("[tp] %s — %d%%", target.name, pct)
        end)

        statusText.Text = "[tp] surfacing..."
        surface()

        statusText.Text = "[tp] arrived at " .. target.name
        task.wait(arriveDelay)
        statusText.Text = "ready"
        isMoving = false
    end)
end

-- UI Creation
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "QuickzMovement"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = player:WaitForChild("PlayerGui", 15)

-- Helper: draggable frame
local function makeDraggable(frame, dragHandle)
    local dragging = false
    local dragStart = nil
    local startPos = nil

    local function updatePosition()
        local pos = frame.AbsolutePosition
        frame.Position = UDim2.new(0, pos.X, 0, pos.Y)
    end

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            updatePosition()
            dragging = true
            dragStart = Vector2.new(input.Position.X, input.Position.Y)
            startPos = Vector2.new(frame.Position.X.Offset, frame.Position.Y.Offset)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
        local delta = Vector2.new(input.Position.X, input.Position.Y) - dragStart
        local viewport = workspace.CurrentCamera.ViewportSize
        local size = frame.AbsoluteSize
        frame.Position = UDim2.new(
            0,
            math.clamp(startPos.X + delta.X, 0, viewport.X - size.X),
            0,
            math.clamp(startPos.Y + delta.Y, 0, viewport.Y - size.Y)
        )
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- Loading screen
local loadingFrame = Instance.new("Frame")
loadingFrame.Name = "LoadingFrame"
loadingFrame.Size = UDim2.new(0, 300, 0, 200)
loadingFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
loadingFrame.BackgroundColor3 = colors.MainBG
loadingFrame.BorderSizePixel = 0
loadingFrame.Parent = screenGui
Instance.new("UICorner", loadingFrame).CornerRadius = UDim.new(0, 4)
Instance.new("UIStroke", loadingFrame).Color = colors.Border

local avatarImage = Instance.new("ImageLabel")
avatarImage.Size = UDim2.new(0, 56, 0, 56)
avatarImage.Position = UDim2.new(0.5, -28, 0, 22)
avatarImage.BackgroundColor3 = colors.Accent
avatarImage.BorderSizePixel = 0
avatarImage.Image = "rbxthumb://type=AvatarHeadShot&id=" .. player.UserId .. "&w=150&h=150"
avatarImage.Parent = loadingFrame
Instance.new("UICorner", avatarImage).CornerRadius = UDim.new(1, 0)

local helloLabel = Instance.new("TextLabel")
helloLabel.Size = UDim2.new(1, 0, 0, 22)
helloLabel.Position = UDim2.new(0, 0, 0, 90)
helloLabel.BackgroundTransparency = 1
helloLabel.Font = Enum.Font.RobotoMono
helloLabel.Text = "Hello, " .. player.DisplayName .. "."
helloLabel.TextColor3 = colors.Text
helloLabel.TextSize = 13
helloLabel.Parent = loadingFrame

local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(1, -20, 0, 28)
infoLabel.Position = UDim2.new(0, 10, 0, 120)
infoLabel.BackgroundTransparency = 1
infoLabel.Font = Enum.Font.RobotoMono
infoLabel.Text = "[info] loading modules..."
infoLabel.TextColor3 = colors.SubText
infoLabel.TextSize = 11
infoLabel.TextWrapped = true
infoLabel.Parent = loadingFrame

local progressBarBg = Instance.new("Frame")
progressBarBg.Size = UDim2.new(1, -40, 0, 5)
progressBarBg.Position = UDim2.new(0, 20, 0, 162)
progressBarBg.BackgroundColor3 = colors.Accent
progressBarBg.BorderSizePixel = 0
progressBarBg.Parent = loadingFrame
Instance.new("UICorner", progressBarBg).CornerRadius = UDim.new(1, 0)

local progressBar = Instance.new("Frame")
progressBar.Size = UDim2.new(0, 0, 1, 0)
progressBar.BackgroundColor3 = colors.Text
progressBar.BorderSizePixel = 0
progressBar.Parent = progressBarBg
Instance.new("UICorner", progressBar).CornerRadius = UDim.new(1, 0)

local progressText = Instance.new("TextLabel")
progressText.Size = UDim2.new(1, 0, 0, 13)
progressText.Position = UDim2.new(0, 0, 0, 172)
progressText.BackgroundTransparency = 1
progressText.Font = Enum.Font.RobotoMono
progressText.Text = "0%"
progressText.TextColor3 = colors.SubText
progressText.TextSize = 9
progressText.TextXAlignment = Enum.TextXAlignment.Center
progressText.Parent = loadingFrame

local function setProgress(pct)
    pct = math.clamp(pct, 0, 1)
    local tween = TweenService:Create(progressBar, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
        Size = UDim2.new(pct, 0, 1, 0)
    })
    tween:Play()
    progressText.Text = string.format("%d%%", math.floor(pct * 100 + 0.5))
end

-- Key frame (authentication)
local keyFrame = Instance.new("Frame")
keyFrame.Name = "KeyFrame"
keyFrame.Size = UDim2.new(0, 340, 0, 195)
keyFrame.Position = UDim2.new(0.5, -170, 0.5, -97)
keyFrame.BackgroundColor3 = colors.MainBG
keyFrame.BorderSizePixel = 0
keyFrame.Visible = false
keyFrame.Parent = screenGui
Instance.new("UICorner", keyFrame).CornerRadius = UDim.new(0, 4)
Instance.new("UIStroke", keyFrame).Color = colors.Border

local keyTitleBar = Instance.new("Frame")
keyTitleBar.Size = UDim2.new(1, 0, 0, 32)
keyTitleBar.BackgroundColor3 = colors.BarBG
keyTitleBar.BorderSizePixel = 0
keyTitleBar.Parent = keyFrame
Instance.new("UICorner", keyTitleBar).CornerRadius = UDim.new(0, 4)
makeDraggable(keyFrame, keyTitleBar)

local keyTitle = Instance.new("TextLabel")
keyTitle.Size = UDim2.new(1, -15, 1, 0)
keyTitle.Position = UDim2.new(0, 12, 0, 0)
keyTitle.BackgroundTransparency = 1
keyTitle.Font = Enum.Font.RobotoMono
keyTitle.Text = "Quickz Movement — Key System"
keyTitle.TextColor3 = colors.Text
keyTitle.TextSize = 12
keyTitle.TextXAlignment = Enum.TextXAlignment.Left
keyTitle.Parent = keyTitleBar

local tokenBox = Instance.new("TextBox")
tokenBox.Size = UDim2.new(1, -40, 0, 30)
tokenBox.Position = UDim2.new(0, 20, 0, 50)
tokenBox.BackgroundColor3 = colors.BarBG
tokenBox.BorderSizePixel = 1
tokenBox.BorderColor3 = colors.Border
tokenBox.Font = Enum.Font.RobotoMono
tokenBox.PlaceholderText = "Type authentication token..."
tokenBox.PlaceholderColor3 = colors.SubText
tokenBox.Text = ""
tokenBox.TextColor3 = colors.Text
tokenBox.TextSize = 12
tokenBox.Parent = keyFrame
Instance.new("UICorner", tokenBox).CornerRadius = UDim.new(0, 3)

local verifyBtn = Instance.new("TextButton")
verifyBtn.Size = UDim2.new(0, 140, 0, 30)
verifyBtn.Position = UDim2.new(0, 20, 0, 100)
verifyBtn.BackgroundColor3 = colors.Text
verifyBtn.BorderSizePixel = 0
verifyBtn.Font = Enum.Font.RobotoMono
verifyBtn.Text = "Verify Token"
verifyBtn.TextColor3 = colors.MainBG
verifyBtn.TextSize = 12
verifyBtn.Parent = keyFrame
Instance.new("UICorner", verifyBtn).CornerRadius = UDim.new(0, 3)

local discordBtn = Instance.new("TextButton")
discordBtn.Size = UDim2.new(0, 140, 0, 30)
discordBtn.Position = UDim2.new(1, -160, 0, 100)
discordBtn.BackgroundColor3 = colors.Accent
discordBtn.BorderSizePixel = 0
discordBtn.Font = Enum.Font.RobotoMono
discordBtn.Text = "Get Token (Discord)"
discordBtn.TextColor3 = colors.Text
discordBtn.TextSize = 11
discordBtn.Parent = keyFrame
Instance.new("UICorner", discordBtn).CornerRadius = UDim.new(0, 3)

local keyStatus = Instance.new("TextLabel")
keyStatus.Size = UDim2.new(1, -40, 0, 22)
keyStatus.Position = UDim2.new(0, 20, 0, 150)
keyStatus.BackgroundTransparency = 1
keyStatus.Font = Enum.Font.RobotoMono
keyStatus.Text = ""
keyStatus.TextColor3 = colors.SubText
keyStatus.TextSize = 10
keyStatus.TextXAlignment = Enum.TextXAlignment.Left
keyStatus.Parent = keyFrame

verifyBtn.MouseButton1Click:Connect(function()
    if tokenBox.Text == "Quickz-1920" then
        keyStatus.Text = "[status] token verified. access granted."
        task.wait(0.5)
        keyFrame.Visible = false
        mainFrame.Visible = true
    else
        keyStatus.Text = "[error] invalid authentication token."
        tokenBox.Text = ""
    end
end)

discordBtn.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard("https://discord.gg/WdTbHzcqpU")
    end
end)

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 460, 0, 300)
mainFrame.Position = UDim2.new(0.5, -230, 0.5, -150)
mainFrame.BackgroundColor3 = colors.MainBG
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 4)
Instance.new("UIStroke", mainFrame).Color = colors.Border

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 35)
titleBar.BackgroundColor3 = colors.BarBG
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 4)
makeDraggable(mainFrame, titleBar)

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(0, 180, 1, 0)
titleLabel.Position = UDim2.new(0.5, -90, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Font = Enum.Font.RobotoMono
titleLabel.Text = "Quickz Movement"
titleLabel.TextColor3 = colors.Text
titleLabel.TextSize = 13
titleLabel.TextXAlignment = Enum.TextXAlignment.Center
titleLabel.Parent = titleBar

local userFrame = Instance.new("Frame")
userFrame.Size = UDim2.new(0, 160, 1, 0)
userFrame.Position = UDim2.new(0, 10, 0, 0)
userFrame.BackgroundTransparency = 1
userFrame.Parent = titleBar

local avatarSmall = Instance.new("ImageLabel")
avatarSmall.Size = UDim2.new(0, 24, 0, 24)
avatarSmall.Position = UDim2.new(0, 0, 0.5, -12)
avatarSmall.BackgroundColor3 = colors.Accent
avatarSmall.BorderSizePixel = 0
avatarSmall.Image = "rbxthumb://type=AvatarHeadShot&id=" .. player.UserId .. "&w=150&h=150"
avatarSmall.Parent = userFrame
Instance.new("UICorner", avatarSmall).CornerRadius = UDim.new(0, 3)

local displayNameLabel = Instance.new("TextLabel")
displayNameLabel.Size = UDim2.new(1, -32, 0, 16)
displayNameLabel.Position = UDim2.new(0, 32, 0, 3)
displayNameLabel.BackgroundTransparency = 1
displayNameLabel.Font = Enum.Font.RobotoMono
displayNameLabel.Text = player.DisplayName
displayNameLabel.TextColor3 = colors.Text
displayNameLabel.TextSize = 11
displayNameLabel.TextXAlignment = Enum.TextXAlignment.Left
displayNameLabel.Parent = userFrame

local usernameLabel = Instance.new("TextLabel")
usernameLabel.Size = UDim2.new(1, -32, 0, 14)
usernameLabel.Position = UDim2.new(0, 32, 0, 17)
usernameLabel.BackgroundTransparency = 1
usernameLabel.Font = Enum.Font.RobotoMono
usernameLabel.Text = "@" .. player.Name
usernameLabel.TextColor3 = colors.SubText
usernameLabel.TextSize = 10
usernameLabel.TextXAlignment = Enum.TextXAlignment.Left
usernameLabel.Parent = userFrame

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 35, 1, 0)
closeBtn.Position = UDim2.new(1, -35, 0, 0)
closeBtn.BackgroundColor3 = colors.BarBG
closeBtn.BorderSizePixel = 0
closeBtn.Font = Enum.Font.RobotoMono
closeBtn.Text = "×"
closeBtn.TextColor3 = colors.Text
closeBtn.TextSize = 16
closeBtn.Parent = titleBar

local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 35, 1, 0)
minimizeBtn.Position = UDim2.new(1, -70, 0, 0)
minimizeBtn.BackgroundColor3 = colors.BarBG
minimizeBtn.BorderSizePixel = 0
minimizeBtn.Font = Enum.Font.RobotoMono
minimizeBtn.Text = "─"
minimizeBtn.TextColor3 = colors.Text
minimizeBtn.TextSize = 12
minimizeBtn.Parent = titleBar

-- Minimize panel (floating small frame)
local minimizePanel = Instance.new("Frame")
minimizePanel.Size = UDim2.new(0, 130, 0, 30)
minimizePanel.Position = UDim2.new(0.5, -65, 0, -40)  -- will be moved up
minimizePanel.BackgroundColor3 = colors.MainBG
minimizePanel.BorderSizePixel = 1
minimizePanel.BorderColor3 = colors.Border
minimizePanel.Visible = false
minimizePanel.Parent = screenGui
Instance.new("UICorner", minimizePanel).CornerRadius = UDim.new(0, 4)

local minTitle = Instance.new("TextLabel")
minTitle.Size = UDim2.new(1, 0, 1, 0)
minTitle.BackgroundTransparency = 1
minTitle.Font = Enum.Font.RobotoMono
minTitle.Text = "Quickz Movement"
minTitle.TextColor3 = colors.Text
minTitle.TextSize = 11
minTitle.Parent = minimizePanel
makeDraggable(minimizePanel, minimizePanel)

closeBtn.MouseButton1Click:Connect(function()
    isMoving = false
    destroyPlatform()
    screenGui:Destroy()
end)

minimizeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    minimizePanel.Visible = true
    minimizePanel:TweenPosition(UDim2.new(0.5, -65, 0, 45), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.3, true)
end)

minimizePanel.MouseButton1Click:Connect(function()
    minimizePanel:TweenPosition(UDim2.new(0.5, -65, 0, -40), Enum.EasingDirection.In, Enum.EasingStyle.Quart, 0.2, true, function()
        minimizePanel.Visible = false
        mainFrame.Visible = true
    end)
end)

-- Sidebar tabs
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 110, 1, -35)
sidebar.Position = UDim2.new(0, 0, 0, 35)
sidebar.BackgroundColor3 = colors.BarBG
sidebar.BorderSizePixel = 0
sidebar.Parent = mainFrame

local tabList = Instance.new("UIListLayout")
tabList.SortOrder = Enum.SortOrder.LayoutOrder
tabList.Padding = UDim.new(0, 4)
tabList.Parent = sidebar

local tabPadding = Instance.new("UIPadding")
tabPadding.PaddingTop = UDim.new(0, 8)
tabPadding.PaddingLeft = UDim.new(0, 6)
tabPadding.PaddingRight = UDim.new(0, 6)
tabPadding.Parent = sidebar

local contentArea = Instance.new("Frame")
contentArea.Size = UDim2.new(1, -120, 1, -45)
contentArea.Position = UDim2.new(0, 115, 0, 40)
contentArea.BackgroundTransparency = 1
contentArea.Parent = mainFrame

-- Tab management
local tabButtons = {}
local tabContents = {}
local tabData = {}

local function createTab(label, icon, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 28)
    btn.LayoutOrder = order
    btn.BackgroundColor3 = colors.BarBG
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.Parent = sidebar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 3)

    local inner = Instance.new("Frame")
    inner.Size = UDim2.new(1, 0, 1, 0)
    inner.BackgroundTransparency = 1
    inner.Parent = btn

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 5)
    layout.Parent = inner

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 6)
    pad.PaddingRight = UDim.new(0, 4)
    pad.Parent = inner

    local iconLabel = Instance.new("ImageLabel")
    iconLabel.Size = UDim2.new(0, 13, 0, 13)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Image = icon
    iconLabel.ImageColor3 = colors.SubText
    iconLabel.ScaleType = Enum.ScaleType.Fit
    iconLabel.LayoutOrder = 1
    iconLabel.Parent = inner

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, -22, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Font = Enum.Font.RobotoMono
    textLabel.Text = label
    textLabel.TextColor3 = colors.SubText
    textLabel.TextSize = 10
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.LayoutOrder = 2
    textLabel.Parent = inner

    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, 0, 1, 0)
    content.BackgroundTransparency = 1
    content.Visible = false
    content.Parent = contentArea

    table.insert(tabButtons, btn)
    table.insert(tabContents, content)
    table.insert(tabData, {icon = iconLabel, lbl = textLabel, btn = btn})

    btn.MouseButton1Click:Connect(function()
        for i, v in ipairs(tabButtons) do
            v.BackgroundColor3 = colors.BarBG
            tabData[i].lbl.TextColor3 = colors.SubText
            tabData[i].icon.ImageColor3 = colors.SubText
            tabContents[i].Visible = false
        end
        btn.BackgroundColor3 = colors.Accent
        textLabel.TextColor3 = colors.Text
        iconLabel.ImageColor3 = colors.Text
        content.Visible = true
    end)

    return btn, content, iconLabel, textLabel
end

-- Create tabs
local teleportTabBtn, teleportContent = createTab("Teleports", "rbxassetid://82314355192648", 1)
-- make first active
teleportTabBtn.BackgroundColor3 = colors.Accent
tabData[1].lbl.TextColor3 = colors.Text
tabData[1].icon.ImageColor3 = colors.Text
teleportContent.Visible = true

-- Teleports tab content
local teleportScroll = Instance.new("ScrollingFrame")
teleportScroll.Size = UDim2.new(1, 0, 1, 0)
teleportScroll.BackgroundTransparency = 1
teleportScroll.BorderSizePixel = 0
teleportScroll.ScrollBarThickness = 3
teleportScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
teleportScroll.Parent = teleportContent

local teleportList = Instance.new("UIListLayout")
teleportList.SortOrder = Enum.SortOrder.LayoutOrder
teleportList.Padding = UDim.new(0, 5)
teleportList.Parent = teleportScroll

local teleportPad = Instance.new("UIPadding")
teleportPad.PaddingTop = UDim.new(0, 8)
teleportPad.PaddingLeft = UDim.new(0, 6)
teleportPad.PaddingRight = UDim.new(0, 6)
teleportPad.PaddingBottom = UDim.new(0, 10)
teleportPad.Parent = teleportScroll

teleportList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    teleportScroll.CanvasSize = UDim2.new(0, 0, 0, teleportList.AbsoluteContentSize.Y + 20)
end)

-- Slowdown toggle
local slowFrame = Instance.new("Frame")
slowFrame.Size = UDim2.new(1, 0, 0, 24)
slowFrame.BackgroundTransparency = 1
slowFrame.LayoutOrder = 0
slowFrame.Parent = teleportScroll

local slowLabel = Instance.new("TextLabel")
slowLabel.Size = UDim2.new(1, -70, 1, 0)
slowLabel.BackgroundTransparency = 1
slowLabel.Font = Enum.Font.RobotoMono
slowLabel.Text = "Slow down near destination"
slowLabel.TextColor3 = colors.Text
slowLabel.TextSize = 9
slowLabel.TextXAlignment = Enum.TextXAlignment.Left
slowLabel.Parent = slowFrame

local slowToggle = Instance.new("TextButton")
slowToggle.Size = UDim2.new(0, 30, 0, 16)
slowToggle.Position = UDim2.new(1, -32, 0.5, -8)
slowToggle.BackgroundColor3 = colors.Border
slowToggle.BorderSizePixel = 0
slowToggle.Text = ""
slowToggle.Parent = slowFrame
Instance.new("UICorner", slowToggle).CornerRadius = UDim.new(1, 0)

local slowDot = Instance.new("Frame")
slowDot.Size = UDim2.new(0, 12, 0, 12)
slowDot.Position = UDim2.new(0, 2, 0.5, -6)
slowDot.BackgroundColor3 = colors.SubText
slowDot.BorderSizePixel = 0
slowDot.Parent = slowToggle
Instance.new("UICorner", slowDot).CornerRadius = UDim.new(1, 0)

slowToggle.MouseButton1Click:Connect(function()
    slowNearDest = not slowNearDest
    if slowNearDest then
        TweenService:Create(slowToggle, TweenInfo.new(0.15), {BackgroundColor3 = colors.Text}):Play()
        TweenService:Create(slowDot, TweenInfo.new(0.15), {
            Position = UDim2.new(0, 16, 0.5, -6),
            BackgroundColor3 = colors.MainBG
        }):Play()
    else
        TweenService:Create(slowToggle, TweenInfo.new(0.15), {BackgroundColor3 = colors.Border}):Play()
        TweenService:Create(slowDot, TweenInfo.new(0.15), {
            Position = UDim2.new(0, 2, 0.5, -6),
            BackgroundColor3 = colors.SubText
        }):Play()
    end
end)

-- Separator
local sep1 = Instance.new("Frame")
sep1.Size = UDim2.new(1, 0, 0, 1)
sep1.BackgroundColor3 = colors.Border
sep1.BorderSizePixel = 0
sep1.LayoutOrder = 1
sep1.Parent = teleportScroll

local teleportHeader = Instance.new("TextLabel")
teleportHeader.Size = UDim2.new(1, 0, 0, 16)
teleportHeader.BackgroundTransparency = 1
teleportHeader.Font = Enum.Font.RobotoMono
teleportHeader.Text = "── Teleports ──"
teleportHeader.TextColor3 = colors.SubText
teleportHeader.TextSize = 9
teleportHeader.TextXAlignment = Enum.TextXAlignment.Left
teleportHeader.LayoutOrder = 2
teleportHeader.Parent = teleportScroll

local statusText = Instance.new("TextLabel")
statusText.Size = UDim2.new(1, 0, 0, 13)
statusText.BackgroundTransparency = 1
statusText.Font = Enum.Font.RobotoMono
statusText.Text = "ready"
statusText.TextColor3 = colors.SubText
statusText.TextSize = 9
statusText.TextXAlignment = Enum.TextXAlignment.Left
statusText.LayoutOrder = 3
statusText.Parent = teleportScroll

-- Teleport locations
local locations = {
    {name = "[casino]", x = 1176.07, z = -20.96},
    {name = "[tier]", x = 1131.24, z = 169.35},
    {name = "[hospital]", x = 1065.49, z = 529.2},
    {name = "[car dealership]", x = 730.46, z = 446.1},
    {name = "[marshmallow]", x = 509.78, z = 599.79},
    {name = "[ilegal guns]", x = 753.72, z = 41.51},
    {name = "[binary]", x = -279.52, z = 253.22},
    {name = "[gun shop 2]", x = -466.83, z = 350.52},
    {name = "[gun shop 1]", x = -177.49, z = 436.44}, -- from earlier
    {name = "[kos]", x = 511.52, z = -82.68},
    {name = "[bank]", x = -52, z = -333.68},
    {name = "[potato]", x = -492.41, z = -451.7},
    {name = "[buy potato]", x = -797.78, z = -170.59},
    {name = "[???]", x = -534.31, z = -84.77} -- original had obfuscated name
}

for i, loc in ipairs(locations) do
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 26)
    row.BackgroundTransparency = 1
    row.LayoutOrder = 3 + i
    row.Parent = teleportScroll

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundColor3 = colors.BarBG
    btn.BorderSizePixel = 1
    btn.BorderColor3 = colors.Border
    btn.Font = Enum.Font.RobotoMono
    btn.Text = "⤍  " .. loc.name
    btn.TextColor3 = colors.Text
    btn.TextSize = 10
    btn.Parent = row
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 3)

    btn.MouseButton1Click:Connect(function()
        performTeleport(loc)
    end)
end

-- Config tab (second tab)
local configTabBtn, configContent = createTab("Config", "rbxassetid://122422795821505", 2)

local configScroll = Instance.new("ScrollingFrame")
configScroll.Size = UDim2.new(1, 0, 1, 0)
configScroll.BackgroundTransparency = 1
configScroll.BorderSizePixel = 0
configScroll.ScrollBarThickness = 3
configScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
configScroll.Parent = configContent

local configList = Instance.new("UIListLayout")
configList.SortOrder = Enum.SortOrder.LayoutOrder
configList.Padding = UDim.new(0, 6)
configList.Parent = configScroll

local configPad = Instance.new("UIPadding")
configPad.PaddingTop = UDim.new(0, 8)
configPad.PaddingLeft = UDim.new(0, 6)
configPad.PaddingRight = UDim.new(0, 6)
configPad.PaddingBottom = UDim.new(0, 10)
configPad.Parent = configScroll

configList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    configScroll.CanvasSize = UDim2.new(0, 0, 0, configList.AbsoluteContentSize.Y + 20)
end)

local warnLabel = Instance.new("TextLabel")
warnLabel.Size = UDim2.new(1, 0, 0, 26)
warnLabel.BackgroundTransparency = 1
warnLabel.Font = Enum.Font.RobotoMono
warnLabel.Text = "⚠  if u dont know, dont use this tab"
warnLabel.TextColor3 = colors.SubText
warnLabel.TextSize = 9
warnLabel.TextWrapped = true
warnLabel.TextXAlignment = Enum.TextXAlignment.Left
warnLabel.LayoutOrder = 0
warnLabel.Parent = configScroll

-- Helper: number input row
local function createNumberInput(label, placeholder, defaultValue, order, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 24)
    row.BackgroundTransparency = 1
    row.LayoutOrder = order
    row.Parent = configScroll

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.52, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.RobotoMono
    lbl.Text = label
    lbl.TextColor3 = colors.Text
    lbl.TextSize = 9
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0.46, 0, 1, -2)
    box.Position = UDim2.new(0.54, 0, 0, 1)
    box.BackgroundColor3 = colors.BarBG
    box.BorderSizePixel = 1
    box.BorderColor3 = colors.Border
    box.Font = Enum.Font.RobotoMono
    box.PlaceholderText = placeholder
    box.PlaceholderColor3 = colors.SubText
    box.Text = tostring(defaultValue)
    box.TextColor3 = colors.Text
    box.TextSize = 9
    box.ClearTextOnFocus = false
    box.Parent = row
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 3)

    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 8, 0, 8)
    indicator.Position = UDim2.new(1, -10, 0.5, -4)
    indicator.BackgroundColor3 = colors.Border
    indicator.BorderSizePixel = 0
    indicator.Text = ""
    indicator.ZIndex = 5
    indicator.Parent = box
    Instance.new("UICorner", indicator).CornerRadius = UDim.new(1, 0)

    box.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local val = tonumber(box.Text)
            if val then
                callback(val)
                box.Text = tostring(val)
                indicator.BackgroundColor3 = Color3.fromRGB(80, 200, 80)
                task.delay(1, function()
                    TweenService:Create(indicator, TweenInfo.new(0.4), {BackgroundColor3 = colors.Border}):Play()
                end)
            else
                indicator.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
                task.delay(0.8, function()
                    box.Text = tostring(defaultValue)
                    TweenService:Create(indicator, TweenInfo.new(0.4), {BackgroundColor3 = colors.Border}):Play()
                end)
            end
        end
    end)

    return box
end

-- Helper: separator line
local function addSeparator(order)
    local sep = Instance.new("Frame")
    sep.Size = UDim2.new(1, 0, 0, 1)
    sep.BackgroundColor3 = colors.Border
    sep.BorderSizePixel = 0
    sep.LayoutOrder = order
    sep.Parent = configScroll
end

-- Helper: category header
local function addHeader(text, order)
    local hdr = Instance.new("TextLabel")
    hdr.Size = UDim2.new(1, 0, 0, 14)
    hdr.BackgroundTransparency = 1
    hdr.Font = Enum.Font.RobotoMono
    hdr.Text = text
    hdr.TextColor3 = colors.SubText
    hdr.TextSize = 9
    hdr.TextXAlignment = Enum.TextXAlignment.Left
    hdr.LayoutOrder = order
    hdr.Parent = configScroll
end

-- Helper: toggle row
local function createToggle(label, defaultValue, order, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 24)
    row.BackgroundTransparency = 1
    row.LayoutOrder = order
    row.Parent = configScroll

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -40, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.RobotoMono
    lbl.Text = label
    lbl.TextColor3 = colors.Text
    lbl.TextSize = 9
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 30, 0, 16)
    btn.Position = UDim2.new(1, -32, 0.5, -8)
    btn.BackgroundColor3 = defaultValue and colors.Text or colors.Border
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.Parent = row
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)

    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 12, 0, 12)
    dot.Position = defaultValue and UDim2.new(0, 16, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
    dot.BackgroundColor3 = defaultValue and colors.MainBG or colors.SubText
    dot.BorderSizePixel = 0
    dot.Parent = btn
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

    btn.MouseButton1Click:Connect(function()
        local newVal = not defaultValue
        defaultValue = newVal
        if newVal then
            TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = colors.Text}):Play()
            TweenService:Create(dot, TweenInfo.new(0.15), {
                Position = UDim2.new(0, 16, 0.5, -6),
                BackgroundColor3 = colors.MainBG
            }):Play()
        else
            TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = colors.Border}):Play()
            TweenService:Create(dot, TweenInfo.new(0.15), {
                Position = UDim2.new(0, 2, 0.5, -6),
                BackgroundColor3 = colors.SubText
            }):Play()
        end
        callback(newVal)
    end)
end

-- Config items
addSeparator(1)
addHeader("Movement", 2)

createNumberInput("Speed", "speed", speed, 3, function(val)
    speed = math.clamp(val, 1, 500)
end)

createNumberInput("Height Offset", "height offset", heightOffset, 4, function(val)
    heightOffset = val
end)

createNumberInput("Surface Offset", "surface offset", surfaceOffset, 5, function(val)
    surfaceOffset = val
end)

createNumberInput("Drop Padding", "drop padding", dropPadding, 6, function(val)
    dropPadding = val
end)

addSeparator(10)
addHeader("Slowdown", 11)

createToggle("Show platform while moving", true, 12, function(val)
    if platform and platform.Parent then
        platform.Transparency = val and 0.4 or 1
    end
end)

createNumberInput("Platform Width", "width", 1, 13, function(val)
    if platform and platform.Parent then
        platform.Size = Vector3.new(val, platform.Size.Y, platform.Size.Z)
    end
end)

createNumberInput("Platform Size (Y&Z)", "size", 30, 14, function(val)
    if platform and platform.Parent then
        platform.Size = Vector3.new(platform.Size.X, val, val)
    end
end)

createToggle("Platform Collision", true, 15, function(val)
    if platform and platform.Parent then
        platform.CanCollide = val
    end
end)

addSeparator(20)
addHeader("Advanced", 21)

createNumberInput("Slowdown Distance", "slowdown dist", slowdownDist, 22, function(val)
    slowdownDist = math.max(1, val)
end)

createNumberInput("Slowdown Minimum Speed", "slowdown min", slowdownMin, 23, function(val)
    slowdownMin = math.clamp(val, 0.01, 1)
end)

addSeparator(30)
addHeader("Misc", 31)

createNumberInput("Arrival Delay (s)", "arrive delay", arriveDelay, 32, function(val)
    arriveDelay = math.max(0, val)
end)

createToggle("Cancel if busy", true, 33, function(val)
    cancelIfBusy = val
end)

-- Loading sequence
task.spawn(function()
    setProgress(0.1)
    task.wait(0.8)
    infoLabel.Text = "[info] loading movement modules..."
    setProgress(0.5)
    task.wait(0.6)
    infoLabel.Text = "[info] establishing bypass..."
    setProgress(0.85)
    task.wait(0.4)
    infoLabel.Text = "[success] environment loaded."
    setProgress(1)
    task.wait(0.2)

    -- Hide loading screen with tweens
    TweenService:Create(loadingFrame, TweenInfo.new(0.25), {BackgroundTransparency = 1}):Play()
    TweenService:Create(helloLabel, TweenInfo.new(0.15), {TextTransparency = 1}):Play()
    TweenService:Create(infoLabel, TweenInfo.new(0.15), {TextTransparency = 1}):Play()
    TweenService:Create(avatarImage, TweenInfo.new(0.15), {ImageTransparency = 1}):Play()
    TweenService:Create(progressBarBg, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
    TweenService:Create(progressBar, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
    TweenService:Create(progressText, TweenInfo.new(0.15), {TextTransparency = 1}):Play()
    task.wait(0.25)
    loadingFrame.Visible = false
    keyFrame.Visible = true
end)

-- Initialize platformY with a default
platformY = heightOffset + 0