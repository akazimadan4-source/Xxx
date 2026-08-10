-- Deobfuscated & Cleaned
-- Script: Lenger Store Autofarm
-- Token: lenger123

local Env = getfenv()
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

-- ===== KONFIGURASI =====
local CONFIG = {
    Token = "lenger123",  -- Token baru
    GuiName = "LengerStore",
    ConfigFile = "LengerStore_Settings.json",
    Theme = {
        IsLight = false,
        TransparentMode = false
    },
    Keybinds = {}
}

-- ===== GUI =====
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui", 15)

-- Theme colors
local function getThemeColors(isLight)
    if isLight then
        return {
            MainBG = Color3.fromRGB(240, 240, 240),
            BarBG = Color3.fromRGB(220, 220, 224),
            Text = Color3.fromRGB(30, 30, 30),
            SubText = Color3.fromRGB(100, 100, 100),
            Border = Color3.fromRGB(190, 190, 190),
            Accent = Color3.fromRGB(205, 205, 205)
        }
    else
        return {
            MainBG = Color3.fromRGB(30, 30, 30),
            BarBG = Color3.fromRGB(37, 37, 38),
            Text = Color3.fromRGB(240, 240, 240),
            SubText = Color3.fromRGB(160, 160, 160),
            Border = Color3.fromRGB(65, 65, 65),
            Accent = Color3.fromRGB(50, 50, 52)
        }
    end
end

local colors = getThemeColors(CONFIG.Theme.IsLight)

-- ===== MAIN GUI =====
local screenGui = Instance.new("ScreenGui")
screenGui.Name = CONFIG.GuiName
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

-- ===== FUNGSI =====
-- 1. Load/Save Config
local function saveConfig()
    if writefile then
        pcall(function()
            local data = {
                IsLight = CONFIG.Theme.IsLight,
                TransparentMode = CONFIG.Theme.TransparentMode
            }
            writefile(CONFIG.ConfigFile, HttpService:JSONEncode(data))
        end)
    end
end

local function loadConfig()
    if readfile and isfile and isfile(CONFIG.ConfigFile) then
        pcall(function()
            local data = HttpService:JSONDecode(readfile(CONFIG.ConfigFile))
            if data then
                CONFIG.Theme.IsLight = data.IsLight or false
                CONFIG.Theme.TransparentMode = data.TransparentMode or false
            end
        end)
    end
end
loadConfig()

-- 2. Drag function
local function makeDraggable(frame, dragHandle, offset)
    offset = offset or 0
    local dragging = false
    local dragStart, startPos

    local function updatePosition()
        local pos = frame.AbsolutePosition
        frame.Position = UDim2.new(0, pos.X, 0, pos.Y)
    end

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            updatePosition()
            dragging = true
            dragStart = Vector2.new(input.Position.X, input.Position.Y)
            startPos = Vector2.new(frame.Position.X.Offset, frame.Position.Y.Offset)

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement and 
           input.UserInputType ~= Enum.UserInputType.Touch then return end

        local delta = Vector2.new(input.Position.X, input.Position.Y) - dragStart
        local viewport = workspace.CurrentCamera.ViewportSize
        local size = frame.AbsoluteSize

        frame.Position = UDim2.new(
            0, math.clamp(startPos.X + delta.X, 0, viewport.X - size.X),
            0, math.clamp(startPos.Y + delta.Y, offset, viewport.Y - size.Y)
        )
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- 3. Key binding system
local currentBinding = nil
local bindingOverlay = nil

local function createKeyBinder(parent, id, callback, order)
    CONFIG.Keybinds[id] = { key = nil, callback = callback, keyLabel = nil }

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 38, 0, 18)
    btn.BackgroundColor3 = colors.Accent
    btn.BorderSizePixel = 1
    btn.BorderColor3 = colors.Border
    btn.Font = Enum.Font.RobotoMono
    btn.Text = "[-]"
    btn.TextColor3 = colors.SubText
    btn.TextSize = 9
    btn.LayoutOrder = order or 0
    btn.ZIndex = 5
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 3)

    CONFIG.Keybinds[id].keyLabel = btn

    btn.MouseButton1Click:Connect(function()
        if currentBinding then return end
        currentBinding = id
        btn.Text = "[...]"
        btn.TextColor3 = colors.Text

        local overlay = Instance.new("Frame")
        overlay.Size = UDim2.new(1, 0, 0, 18)
        overlay.Position = UDim2.new(0, 0, 0, 0)
        overlay.BackgroundColor3 = colors.Accent
        overlay.BackgroundTransparency = 0.3
        overlay.BorderSizePixel = 0
        overlay.ZIndex = 20
        overlay.Parent = screenGui

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.RobotoMono
        label.Text = "press a key to bind  •  ESC to clear"
        label.TextColor3 = colors.Text
        label.TextSize = 10
        label.TextXAlignment = Enum.TextXAlignment.Center
        label.ZIndex = 21
        label.Parent = overlay

        bindingOverlay = overlay

        task.delay(5, function()
            if currentBinding == id then
                local key = CONFIG.Keybinds[id].key
                btn.Text = key and "[" .. tostring(key):gsub("Enum.KeyCode.", "") .. "]" or "[-]"
                btn.TextColor3 = colors.SubText
                if overlay and overlay.Parent then overlay:Destroy() end
                if bindingOverlay == overlay then bindingOverlay = nil end
            end
        end)
    end)

    return btn
end

-- Key listener
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if currentBinding then
        local id = currentBinding
        if input.KeyCode == Enum.KeyCode.Escape then
            CONFIG.Keybinds[id].key = nil
            if CONFIG.Keybinds[id].keyLabel then
                CONFIG.Keybinds[id].keyLabel.Text = "[-]"
            end
        else
            for k, v in pairs(CONFIG.Keybinds) do
                if k ~= id and v.key == input.KeyCode then
                    v.key = nil
                    if v.keyLabel then
                        v.keyLabel.Text = "[-]"
                        v.keyLabel.TextColor3 = colors.SubText
                    end
                end
            end

            CONFIG.Keybinds[id].key = input.KeyCode
            if CONFIG.Keybinds[id].keyLabel then
                CONFIG.Keybinds[id].keyLabel.Text = "[" .. tostring(input.KeyCode):gsub("Enum.KeyCode.", "") .. "]"
            end

            if bindingOverlay and bindingOverlay.Parent then
                bindingOverlay:Destroy()
            end
            bindingOverlay = nil
        end
        currentBinding = nil
        return
    end

    for id, data in pairs(CONFIG.Keybinds) do
        if data.key and input.KeyCode == data.key then
            pcall(data.callback)
        end
    end
end)

-- ===== BUILD GUI =====
-- Loading Screen
local loadingFrame = Instance.new("Frame")
loadingFrame.Name = "LoadingFrame"
loadingFrame.Size = UDim2.new(0, 320, 0, 220)
loadingFrame.Position = UDim2.new(0.5, -160, 0.5, -110)
loadingFrame.BackgroundColor3 = colors.MainBG
loadingFrame.BorderSizePixel = 0
loadingFrame.Parent = screenGui
Instance.new("UICorner", loadingFrame).CornerRadius = UDim.new(0, 4)

local stroke = Instance.new("UIStroke")
stroke.Color = colors.Border
stroke.Thickness = 1
stroke.Parent = loadingFrame

-- Avatar
local avatar = Instance.new("ImageLabel")
avatar.Size = UDim2.new(0, 64, 0, 64)
avatar.Position = UDim2.new(0.5, -32, 0, 25)
avatar.BackgroundColor3 = colors.MainBG
avatar.BorderSizePixel = 0
avatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. player.UserId .. "&w=150&h=150"
avatar.Parent = loadingFrame
Instance.new("UICorner", avatar).CornerRadius = UDim.new(1, 0)

-- Hello text
local helloText = Instance.new("TextLabel")
helloText.Size = UDim2.new(1, 0, 0, 25)
helloText.Position = UDim2.new(0, 0, 0, 105)
helloText.BackgroundTransparency = 1
helloText.Font = Enum.Font.RobotoMono
helloText.Text = "Hello, " .. player.DisplayName .. "."
helloText.TextColor3 = colors.Text
helloText.TextSize = 15
helloText.Parent = loadingFrame

-- Status text
local statusText = Instance.new("TextLabel")
statusText.Size = UDim2.new(1, -20, 0, 30)
statusText.Position = UDim2.new(0, 10, 0, 140)
statusText.BackgroundTransparency = 1
statusText.Font = Enum.Font.RobotoMono
statusText.Text = "[info] loading modules..."
statusText.TextColor3 = colors.SubText
statusText.TextSize = 12
statusText.TextWrapped = true
statusText.Parent = loadingFrame

-- Progress bar
local progressBar = Instance.new("Frame")
progressBar.Size = UDim2.new(1, -40, 0, 6)
progressBar.Position = UDim2.new(0, 20, 0, 180)
progressBar.BackgroundColor3 = colors.Accent
progressBar.BorderSizePixel = 0
progressBar.Parent = loadingFrame
Instance.new("UICorner", progressBar).CornerRadius = UDim.new(1, 0)

local progressFill = Instance.new("Frame")
progressFill.Size = UDim2.new(0, 0, 1, 0)
progressFill.BackgroundColor3 = colors.Text
progressFill.BorderSizePixel = 0
progressFill.Parent = progressBar
Instance.new("UICorner", progressFill).CornerRadius = UDim.new(1, 0)

local progressText = Instance.new("TextLabel")
progressText.Size = UDim2.new(1, 0, 0, 14)
progressText.Position = UDim2.new(0, 0, 0, 190)
progressText.BackgroundTransparency = 1
progressText.Font = Enum.Font.RobotoMono
progressText.Text = "0%"
progressText.TextColor3 = colors.SubText
progressText.TextSize = 10
progressText.TextXAlignment = Enum.TextXAlignment.Center
progressText.Parent = loadingFrame

local function setProgress(val)
    local clamped = math.clamp(val, 0, 1)
    local tween = TweenService.Create(progressFill, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
        Size = UDim2.new(clamped, 0, 1, 0)
    })
    tween:Play()
    progressText.Text = string.format("%d%%", math.floor(clamped * 100 + 0.5))
end

-- ===== KEY FRAME (AUTH) =====
local keyFrame = Instance.new("Frame")
keyFrame.Name = "KeyFrame"
keyFrame.Size = UDim2.new(0, 360, 0, 200)
keyFrame.Position = UDim2.new(0.5, -180, 0.5, -100)
keyFrame.BackgroundColor3 = colors.MainBG
keyFrame.BorderSizePixel = 0
keyFrame.Visible = false
keyFrame.Parent = screenGui
Instance.new("UICorner", keyFrame).CornerRadius = UDim.new(0, 4)

local keyStroke = Instance.new("UIStroke")
keyStroke.Color = colors.Border
keyStroke.Thickness = 1
keyStroke.Parent = keyFrame

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
keyTitle.Text = "Lenger Store Key System"  -- Ganti jadi Lenger Store
keyTitle.TextColor3 = colors.Text
keyTitle.TextSize = 13
keyTitle.TextXAlignment = Enum.TextXAlignment.Left
keyTitle.Parent = keyTitleBar

local keyInput = Instance.new("TextBox")
keyInput.Size = UDim2.new(1, -40, 0, 30)
keyInput.Position = UDim2.new(0, 20, 0, 55)
keyInput.BackgroundColor3 = colors.BarBG
keyInput.BorderSizePixel = 1
keyInput.BorderColor3 = colors.Border
keyInput.Font = Enum.Font.RobotoMono
keyInput.PlaceholderText = "Type authentication token..."
keyInput.PlaceholderColor3 = colors.SubText
keyInput.Text = ""
keyInput.TextColor3 = colors.Text
keyInput.TextSize = 12
keyInput.Parent = keyFrame
Instance.new("UICorner", keyInput).CornerRadius = UDim.new(0, 3)

local verifyBtn = Instance.new("TextButton")
verifyBtn.Size = UDim2.new(0, 150, 0, 32)
verifyBtn.Position = UDim2.new(0, 20, 0, 105)
verifyBtn.BackgroundColor3 = colors.Text
verifyBtn.BorderSizePixel = 0
verifyBtn.Font = Enum.Font.RobotoMono
verifyBtn.Text = "Verify Token"
verifyBtn.TextColor3 = colors.MainBG
verifyBtn.TextSize = 12
verifyBtn.Parent = keyFrame
Instance.new("UICorner", verifyBtn).CornerRadius = UDim.new(0, 3)

local discordBtn = Instance.new("TextButton")
discordBtn.Size = UDim2.new(0, 150, 0, 32)
discordBtn.Position = UDim2.new(1, -170, 0, 105)
discordBtn.BackgroundColor3 = colors.Accent
discordBtn.BorderSizePixel = 0
discordBtn.Font = Enum.Font.RobotoMono
discordBtn.Text = "Get Token (Discord)"
discordBtn.TextColor3 = colors.Text
discordBtn.TextSize = 12
discordBtn.Parent = keyFrame
Instance.new("UICorner", discordBtn).CornerRadius = UDim.new(0, 3)

local keyStatus = Instance.new("TextLabel")
keyStatus.Size = UDim2.new(1, -40, 0, 25)
keyStatus.Position = UDim2.new(0, 20, 0, 155)
keyStatus.BackgroundTransparency = 1
keyStatus.Font = Enum.Font.RobotoMono
keyStatus.Text = ""
keyStatus.TextColor3 = colors.SubText
keyStatus.TextSize = 11
keyStatus.TextXAlignment = Enum.TextXAlignment.Left
keyStatus.Parent = keyFrame

-- ===== MAIN FRAME =====
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 200, 0, 0)
mainFrame.Position = UDim2.new(0.5, -100, 0.5, -80)
mainFrame.BackgroundColor3 = colors.MainBG
mainFrame.BackgroundTransparency = 0
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.AutomaticSize = Enum.AutomaticSize.Y
mainFrame.Parent = screenGui
mainFrame.ClipsDescendants = false
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 4)

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = colors.Border
mainStroke.Thickness = 1
mainStroke.Parent = mainFrame

local mainLayout = Instance.new("UIListLayout")
mainLayout.SortOrder = Enum.SortOrder.LayoutOrder
mainLayout.Padding = UDim.new(0, 0)
mainLayout.Parent = mainFrame

-- Title bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.BackgroundColor3 = colors.BarBG
titleBar.BorderSizePixel = 0
titleBar.LayoutOrder = 0
titleBar.Parent = mainFrame
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 4)

local titleBarDivider = Instance.new("Frame")
titleBarDivider.Size = UDim2.new(1, 0, 0.5, 0)
titleBarDivider.Position = UDim2.new(0, 0, 0.5, 0)
titleBarDivider.BackgroundColor3 = colors.BarBG
titleBarDivider.BorderSizePixel = 0
titleBarDivider.Parent = titleBar

makeDraggable(mainFrame, titleBar)

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -60, 1, 0)
titleLabel.Position = UDim2.new(0, 8, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Font = Enum.Font.RobotoMono
titleLabel.Text = "Lenger Store"  -- Ganti jadi Lenger Store
titleLabel.TextColor3 = colors.Text
titleLabel.TextSize = 10
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 22, 0, 22)
minimizeBtn.Position = UDim2.new(1, -48, 0.5, -11)
minimizeBtn.BackgroundColor3 = colors.Accent
minimizeBtn.BorderSizePixel = 0
minimizeBtn.Font = Enum.Font.RobotoMono
minimizeBtn.Text = "─"
minimizeBtn.TextColor3 = colors.SubText
minimizeBtn.TextSize = 10
minimizeBtn.Parent = titleBar
Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(0, 3)

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 22, 0, 22)
closeBtn.Position = UDim2.new(1, -24, 0.5, -11)
closeBtn.BackgroundColor3 = colors.Accent
closeBtn.BorderSizePixel = 0
closeBtn.Font = Enum.Font.RobotoMono
closeBtn.Text = "×"
closeBtn.TextColor3 = colors.SubText
closeBtn.TextSize = 13
closeBtn.Parent = titleBar
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 3)

-- Divider
local divider1 = Instance.new("Frame")
divider1.Size = UDim2.new(1, 0, 0, 1)
divider1.BackgroundColor3 = colors.Border
divider1.BorderSizePixel = 0
divider1.LayoutOrder = 1
divider1.Parent = mainFrame

-- Content
local content = Instance.new("Frame")
content.Size = UDim2.new(1, 0, 0, 0)
content.AutomaticSize = Enum.AutomaticSize.Y
content.BackgroundTransparency = 1
content.BorderSizePixel = 0
content.LayoutOrder = 2
content.Parent = mainFrame

local contentLayout = Instance.new("UIListLayout")
contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
contentLayout.Padding = UDim.new(0, 5)
contentLayout.Parent = content

local contentPadding = Instance.new("UIPadding")
contentPadding.PaddingLeft = UDim.new(0, 8)
contentPadding.PaddingRight = UDim.new(0, 8)
contentPadding.PaddingTop = UDim.new(0, 8)
contentPadding.PaddingBottom = UDim.new(0, 8)
contentPadding.Parent = content

-- Helper functions
local function addDivider(order, parent)
    local div = Instance.new("Frame")
    div.Size = UDim2.new(1, 0, 0, 1)
    div.BackgroundColor3 = colors.Border
    div.BorderSizePixel = 0
    div.LayoutOrder = order
    div.Parent = parent or content
    return div
end

local function addButton(text, order, parent, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 22)
    btn.BackgroundColor3 = colors.BarBG
    btn.BorderSizePixel = 1
    btn.BorderColor3 = colors.Border
    btn.Font = Enum.Font.RobotoMono
    btn.Text = text
    btn.TextColor3 = colors.Text
    btn.TextSize = 10
    btn.LayoutOrder = order
    btn.Parent = parent or content
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 3)
    if callback then
        btn.MouseButton1Click:Connect(callback)
    end
    return btn
end

local function addLabel(text, order, parent)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 12)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.RobotoMono
    lbl.Text = text
    lbl.TextColor3 = colors.SubText
    lbl.TextSize = 9
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.LayoutOrder = order
    lbl.Parent = parent or content
    return lbl
end

-- ===== DELETE MODE =====
local deleteModeActive = false
local highlightedObject = nil
local selectionBox = nil
local deletedObjects = {}
local deleteConnections = {}
local statusLabel = nil

local function getSelectionBox()
    if not selectionBox or not selectionBox.Parent then
        selectionBox = Instance.new("SelectionBox")
        selectionBox.Color3 = Color3.fromRGB(255, 255, 255)
        selectionBox.LineThickness = 0.03
        selectionBox.SurfaceTransparency = 0.5
        selectionBox.SurfaceColor3 = Color3.fromRGB(255, 255, 255)
        selectionBox.Parent = workspace
    end
    return selectionBox
end

local function clearHighlight()
    if selectionBox then
        selectionBox.Adornee = nil
    end
end

local function getTarget()
    local mouse = player:GetMouse()
    local camera = workspace.CurrentCamera
    local ray = camera:ScreenPointToRay(mouse.X, mouse.Y)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    local char = player.Character
    if char then
        params.FilterDescendantsInstances = {char}
    end
    local result = workspace:Raycast(ray.Origin, ray.Direction * 1000, params)
    if result then
        return result.Instance
    end
    return nil
end

local function enableDeleteMode()
    deleteModeActive = true
    if statusLabel then statusLabel.Text = "[delete mode ON]" end
    
    deleteConnections.render = RunService.RenderStepped:Connect(function()
        if not deleteModeActive then
            clearHighlight()
            return
        end
        local target = getTarget()
        if target then
            highlightedObject = target
            getSelectionBox().Adornee = target
        else
            highlightedObject = nil
            clearHighlight()
        end
    end)
    
    deleteConnections.click = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if not deleteModeActive then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            if highlightedObject then
                local obj = highlightedObject
                clearHighlight()
                table.insert(deletedObjects, {
                    part = obj,
                    originalParent = obj.Parent
                })
                obj.Parent = nil
            end
        end
    end)
end

local function disableDeleteMode()
    deleteModeActive = false
    if statusLabel then statusLabel.Text = "[idle]" end
    for _, conn in pairs(deleteConnections) do
        if conn and conn.Disconnect then conn:Disconnect() end
    end
    deleteConnections = {}
    clearHighlight()
    if selectionBox then
        selectionBox:Destroy()
        selectionBox = nil
    end
end

local function createToggle(label, order, parent, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 22)
    frame.BackgroundTransparency = 1
    frame.LayoutOrder = order
    frame.Parent = parent or content

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -34, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.RobotoMono
    lbl.Text = label
    lbl.TextColor3 = colors.Text
    lbl.TextSize = 10
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 28, 0, 14)
    btn.Position = UDim2.new(1, -30, 0.5, -7)
    btn.BackgroundColor3 = colors.Border
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.Parent = frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)

    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 10, 0, 10)
    dot.Position = UDim2.new(0, 2, 0.5, -5)
    dot.BackgroundColor3 = colors.SubText
    dot.BorderSizePixel = 0
    dot.Parent = btn
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

    local active = false
    
    local function setState(val)
        active = val
        if active then
            TweenService.Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = colors.Text}):Play()
            TweenService.Create(dot, TweenInfo.new(0.15), {
                Position = UDim2.new(0, 16, 0.5, -5),
                BackgroundColor3 = colors.MainBG
            }):Play()
        else
            TweenService.Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = colors.Border}):Play()
            TweenService.Create(dot, TweenInfo.new(0.15), {
                Position = UDim2.new(0, 2, 0.5, -5),
                BackgroundColor3 = colors.SubText
            }):Play()
        end
        callback(active)
    end

    btn.MouseButton1Click:Connect(function()
        setState(not active)
    end)

    return frame, btn, setState
end

local deleteToggle, delBtn, setDeleteMode = createToggle("Delete Mode", 1, content, function(state)
    if state then
        enableDeleteMode()
    else
        disableDeleteMode()
    end
end)

statusLabel = addLabel("[idle]", 0, content)

addDivider(2)

-- Undo/Redo buttons
local actionRow = Instance.new("Frame")
actionRow.Size = UDim2.new(1, 0, 0, 22)
actionRow.BackgroundTransparency = 1
actionRow.LayoutOrder = 3
actionRow.Parent = content

local actionLayout = Instance.new("UIListLayout")
actionLayout.FillDirection = Enum.FillDirection.Horizontal
actionLayout.SortOrder = Enum.SortOrder.LayoutOrder
actionLayout.Padding = UDim.new(0, 4)
actionLayout.Parent = actionRow

local undoBtn = Instance.new("TextButton")
undoBtn.Size = UDim2.new(0.5, -2, 1, 0)
undoBtn.BackgroundColor3 = colors.BarBG
undoBtn.BorderSizePixel = 1
undoBtn.BorderColor3 = colors.Border
undoBtn.Font = Enum.Font.RobotoMono
undoBtn.Text = "⟵ Undo"
undoBtn.TextColor3 = colors.Text
undoBtn.TextSize = 10
undoBtn.LayoutOrder = 1
undoBtn.Parent = actionRow
Instance.new("UICorner", undoBtn).CornerRadius = UDim.new(0, 3)

local redoBtn = Instance.new("TextButton")
redoBtn.Size = UDim2.new(0.5, -2, 1, 0)
redoBtn.BackgroundColor3 = colors.BarBG
redoBtn.BorderSizePixel = 1
redoBtn.BorderColor3 = colors.Border
redoBtn.Font = Enum.Font.RobotoMono
redoBtn.Text = "Redo All ⟶"
redoBtn.TextColor3 = colors.Text
redoBtn.TextSize = 10
redoBtn.LayoutOrder = 2
redoBtn.Parent = actionRow
Instance.new("UICorner", redoBtn).CornerRadius = UDim.new(0, 3)

undoBtn.MouseButton1Click:Connect(function()
    if #deletedObjects == 0 then return end
    local data = table.remove(deletedObjects)
    if data and data.part then
        pcall(function()
            data.part.Parent = data.originalParent
        end)
    end
end)

redoBtn.MouseButton1Click:Connect(function()
    for i = #deletedObjects, 1, -1 do
        local data = deletedObjects[i]
        if data and data.part then
            pcall(function()
                data.part.Parent = data.originalParent
            end)
        end
    end
    deletedObjects = {}
end)

addDivider(4)

-- Theme & BG options
local optionsRow = Instance.new("Frame")
optionsRow.Size = UDim2.new(1, 0, 0, 22)
optionsRow.BackgroundTransparency = 1
optionsRow.LayoutOrder = 5
optionsRow.Parent = content

local optionsLayout = Instance.new("UIListLayout")
optionsLayout.FillDirection = Enum.FillDirection.Horizontal
optionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
optionsLayout.Padding = UDim.new(0, 4)
optionsLayout.Parent = optionsRow

local themeBtn = Instance.new("TextButton")
themeBtn.Size = UDim2.new(0.5, -2, 1, 0)
themeBtn.BackgroundColor3 = colors.BarBG
themeBtn.BorderSizePixel = 1
themeBtn.BorderColor3 = colors.Border
themeBtn.Font = Enum.Font.RobotoMono
themeBtn.Text = CONFIG.Theme.IsLight and "Theme: Light" or "Theme: Dark"
themeBtn.TextColor3 = colors.Text
themeBtn.TextSize = 9
themeBtn.LayoutOrder = 1
themeBtn.Parent = optionsRow
Instance.new("UICorner", themeBtn).CornerRadius = UDim.new(0, 3)

local bgBtn = Instance.new("TextButton")
bgBtn.Size = UDim2.new(0.5, -2, 1, 0)
bgBtn.BackgroundColor3 = colors.BarBG
bgBtn.BorderSizePixel = 1
bgBtn.BorderColor3 = colors.Border
bgBtn.Font = Enum.Font.RobotoMono
bgBtn.Text = CONFIG.Theme.TransparentMode and "BG: 85%" or "BG: 100%"
bgBtn.TextColor3 = colors.Text
bgBtn.TextSize = 9
bgBtn.LayoutOrder = 2
bgBtn.Parent = optionsRow
Instance.new("UICorner", bgBtn).CornerRadius = UDim.new(0, 3)

themeBtn.MouseButton1Click:Connect(function()
    CONFIG.Theme.IsLight = not CONFIG.Theme.IsLight
    local isLight = CONFIG.Theme.IsLight
    themeBtn.Text = isLight and "Theme: Light" or "Theme: Dark"
    
    local newColors = getThemeColors(isLight)
    colors = newColors
    
    TweenService.Create(mainFrame, TweenInfo.new(0.2), {
        BackgroundColor3 = newColors.MainBG
    }):Play()
    TweenService.Create(titleBar, TweenInfo.new(0.2), {
        BackgroundColor3 = newColors.BarBG
    }):Play()
    TweenService.Create(titleBarDivider, TweenInfo.new(0.2), {
        BackgroundColor3 = newColors.BarBG
    }):Play()
    TweenService.Create(mainStroke, TweenInfo.new(0.2), {
        Color = newColors.Border
    }):Play()
    
    saveConfig()
end)

bgBtn.MouseButton1Click:Connect(function()
    CONFIG.Theme.TransparentMode = not CONFIG.Theme.TransparentMode
    bgBtn.Text = CONFIG.Theme.TransparentMode and "BG: 85%" or "BG: 100%"
    TweenService.Create(mainFrame, TweenInfo.new(0.2), {
        BackgroundTransparency = CONFIG.Theme.TransparentMode and 0.15 or 0
    }):Play()
    saveConfig()
end)

addDivider(6)

local shortcutLabel = addLabel("[E] toggle UI   [X] delete mode", 7, content)
shortcutLabel.TextXAlignment = Enum.TextXAlignment.Center
shortcutLabel.Size = UDim2.new(1, 0, 0, 12)

-- Minimized button
local minimizedBtn = Instance.new("TextButton")
minimizedBtn.Size = UDim2.new(0, 130, 0, 26)
minimizedBtn.Position = UDim2.new(0.5, -65, 0, -40)
minimizedBtn.BackgroundColor3 = colors.BarBG
minimizedBtn.BorderSizePixel = 1
minimizedBtn.BorderColor3 = colors.Border
minimizedBtn.Font = Enum.Font.RobotoMono
minimizedBtn.Text = "Lenger Store"  -- Ganti jadi Lenger Store
minimizedBtn.TextColor3 = colors.Text
minimizedBtn.TextSize = 10
minimizedBtn.Visible = false
minimizedBtn.Parent = screenGui
Instance.new("UICorner", minimizedBtn).CornerRadius = UDim.new(0, 3)
makeDraggable(minimizedBtn, minimizedBtn, 40)

-- Toggle visibility
local isVisible = true

local function showMain()
    isVisible = true
    mainFrame.Visible = true
    minimizedBtn.Visible = false
end

local function hideMain()
    isVisible = false
    mainFrame.Visible = false
    minimizedBtn.Visible = true
    minimizedBtn:TweenPosition(UDim2.new(0.5, -65, 0, 45), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.25, true)
end

local function toggleMain()
    if isVisible then
        hideMain()
    else
        showMain()
    end
end

-- Keyboard shortcuts
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.E then
        toggleMain()
    elseif input.KeyCode == Enum.KeyCode.X then
        if mainFrame.Visible then
            setDeleteMode(not deleteModeActive)
        end
    end
end)

minimizeBtn.MouseButton1Click:Connect(hideMain)

minimizedBtn.MouseButton1Click:Connect(function()
    minimizedBtn:TweenPosition(UDim2.new(0.5, -65, 0, -40), Enum.EasingDirection.In, Enum.EasingStyle.Quart, 0.2, true, function()
        showMain()
    end)
end)

closeBtn.MouseButton1Click:Connect(function()
    disableDeleteMode()
    screenGui:Destroy()
end)

-- Discord button
discordBtn.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard("https://discord.gg/WdTbHzcqpU")
    elseif toclipboard then
        toclipboard("https://discord.gg/WdTbHzcqpU")
    end
end)

-- ===== VERIFY BUTTON =====
verifyBtn.MouseButton1Click:Connect(function()
    if keyInput.Text == CONFIG.Token then
        keyStatus.Text = "[status] token verified. access granted."
        task.wait(0.5)
        keyFrame.Visible = false
        mainFrame.Visible = true
    else
        keyStatus.Text = "[error] invalid authentication token."
        keyInput.Text = ""
    end
end)

-- ===== LOADING SEQUENCE =====
task.spawn(function()
    setProgress(0.1)
    task.wait(0.9)
    statusText.Text = "[info] loading autofarm components..."
    setProgress(0.45)
    task.wait(0.6)
    statusText.Text = "[info] establishing client hooks..."
    setProgress(0.8)
    task.wait(0.4)
    statusText.Text = "[success] environment loaded."
    setProgress(1)
    task.wait(0.2)
    
    local tween = TweenService.Create(loadingFrame, TweenInfo.new(0.25), {
        BackgroundTransparency = 1
    })
    TweenService.Create(helloText, TweenInfo.new(0.15), {TextTransparency = 1}):Play()
    TweenService.Create(statusText, TweenInfo.new(0.15), {TextTransparency = 1}):Play()
    TweenService.Create(avatar, TweenInfo.new(0.15), {ImageTransparency = 1}):Play()
    TweenService.Create(progressBar, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
    TweenService.Create(progressFill, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
    TweenService.Create(progressText, TweenInfo.new(0.15), {TextTransparency = 1}):Play()
    tween:Play()
    
    tween.Completed:Connect(function()
        loadingFrame.Visible = false
        keyFrame.Visible = true
    end)
end)

return