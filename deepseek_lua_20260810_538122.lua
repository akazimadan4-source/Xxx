-- Quickz Delete Tool (Cleaned Version)
-- Original by Quickz, cleaned from deobfuscated source

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    Players.PlayerAdded:Wait()
    LocalPlayer = Players.LocalPlayer
end

-- Theme colors
local Theme = {
    MainBG = Color3.fromRGB(30, 30, 30),
    BarBG = Color3.fromRGB(37, 37, 38),
    Text = Color3.fromRGB(240, 240, 240),
    SubText = Color3.fromRGB(160, 160, 160),
    Border = Color3.fromRGB(65, 65, 65),
    Accent = Color3.fromRGB(50, 50, 52)
}

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "QuickzDeleteTool"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 100
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui", 15)

-- ============================================
-- LOADING SCREEN
-- ============================================
local LoadingFrame = Instance.new("Frame")
LoadingFrame.Name = "LoadingFrame"
LoadingFrame.Size = UDim2.new(0, 320, 0, 220)
LoadingFrame.Position = UDim2.new(0.5, -160, 0.5, -110)
LoadingFrame.BackgroundColor3 = Theme.MainBG
LoadingFrame.BorderSizePixel = 0
LoadingFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 4)
UICorner.Parent = LoadingFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Theme.Border
UIStroke.Thickness = 1
UIStroke.Parent = LoadingFrame

-- Avatar
local AvatarImage = Instance.new("ImageLabel")
AvatarImage.Size = UDim2.new(0, 64, 0, 64)
AvatarImage.Position = UDim2.new(0.5, -32, 0, 25)
AvatarImage.BackgroundColor3 = Theme.MainBG
AvatarImage.BorderSizePixel = 0
AvatarImage.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150"
AvatarImage.Parent = LoadingFrame
Instance.new("UICorner", AvatarImage).CornerRadius = UDim.new(1, 0)

-- Welcome Text
local WelcomeText = Instance.new("TextLabel")
WelcomeText.Size = UDim2.new(1, 0, 0, 25)
WelcomeText.Position = UDim2.new(0, 0, 0, 105)
WelcomeText.BackgroundTransparency = 1
WelcomeText.Font = Enum.Font.RobotoMono
WelcomeText.Text = "Hello, " .. LocalPlayer.DisplayName .. "."
WelcomeText.TextColor3 = Theme.Text
WelcomeText.TextSize = 15
WelcomeText.Parent = LoadingFrame

-- Status Text
local StatusText = Instance.new("TextLabel")
StatusText.Size = UDim2.new(1, -20, 0, 30)
StatusText.Position = UDim2.new(0, 10, 0, 140)
StatusText.BackgroundTransparency = 1
StatusText.Font = Enum.Font.RobotoMono
StatusText.Text = "[info] loading modules..."
StatusText.TextColor3 = Theme.SubText
StatusText.TextSize = 12
StatusText.TextWrapped = true
StatusText.Parent = LoadingFrame

-- Progress Bar Background
local ProgressBg = Instance.new("Frame")
ProgressBg.Size = UDim2.new(1, -40, 0, 6)
ProgressBg.Position = UDim2.new(0, 20, 0, 180)
ProgressBg.BackgroundColor3 = Theme.Accent
ProgressBg.BorderSizePixel = 0
ProgressBg.Parent = LoadingFrame
Instance.new("UICorner", ProgressBg).CornerRadius = UDim.new(1, 0)

-- Progress Bar
local ProgressBar = Instance.new("Frame")
ProgressBar.Size = UDim2.new(0, 0, 1, 0)
ProgressBar.BackgroundColor3 = Theme.Text
ProgressBar.BorderSizePixel = 0
ProgressBar.Parent = ProgressBg
Instance.new("UICorner", ProgressBar).CornerRadius = UDim.new(1, 0)

-- Progress Text
local ProgressText = Instance.new("TextLabel")
ProgressText.Size = UDim2.new(1, 0, 0, 14)
ProgressText.Position = UDim2.new(0, 0, 0, 190)
ProgressText.BackgroundTransparency = 1
ProgressText.Font = Enum.Font.RobotoMono
ProgressText.Text = "0%"
ProgressText.TextColor3 = Theme.SubText
ProgressText.TextSize = 10
ProgressText.TextXAlignment = Enum.TextXAlignment.Center
ProgressText.Parent = LoadingFrame

local function UpdateProgress(value)
    value = math.clamp(value, 0, 1)
    local tween = TweenService:Create(ProgressBar, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
        Size = UDim2.new(value, 0, 1, 0)
    })
    tween:Play()
    ProgressText.Text = string.format("%d%%", math.floor(value * 100 + 0.5))
end

-- ============================================
-- KEY SYSTEM (Verification)
-- ============================================
local KeyFrame = Instance.new("Frame")
KeyFrame.Name = "KeyFrame"
KeyFrame.Size = UDim2.new(0, 360, 0, 200)
KeyFrame.Position = UDim2.new(0.5, -180, 0.5, -100)
KeyFrame.BackgroundColor3 = Theme.MainBG
KeyFrame.BorderSizePixel = 0
KeyFrame.Visible = false
KeyFrame.Parent = ScreenGui
Instance.new("UICorner", KeyFrame).CornerRadius = UDim.new(0, 4)

local KeyStroke = Instance.new("UIStroke")
KeyStroke.Color = Theme.Border
KeyStroke.Thickness = 1
KeyStroke.Parent = KeyFrame

-- Title Bar
local KeyTitleBar = Instance.new("Frame")
KeyTitleBar.Size = UDim2.new(1, 0, 0, 32)
KeyTitleBar.BackgroundColor3 = Theme.BarBG
KeyTitleBar.BorderSizePixel = 0
KeyTitleBar.Parent = KeyFrame
Instance.new("UICorner", KeyTitleBar).CornerRadius = UDim.new(0, 4)

-- Draggable function (simplified)
local function MakeDraggable(frame, dragHandle)
    local dragging = false
    local dragStart = Vector2.new()
    local startPos = Vector2.new()

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Vector2.new(frame.Position.X.Offset, frame.Position.Y.Offset)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end

        local delta = input.Position - dragStart
        local viewport = workspace.CurrentCamera.ViewportSize
        local size = frame.AbsoluteSize

        frame.Position = UDim2.new(0, math.clamp(startPos.X + delta.X, 0, viewport.X - size.X),
                                   0, math.clamp(startPos.Y + delta.Y, 40, viewport.Y - size.Y))
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

MakeDraggable(KeyFrame, KeyTitleBar)

local KeyTitle = Instance.new("TextLabel")
KeyTitle.Size = UDim2.new(1, -15, 1, 0)
KeyTitle.Position = UDim2.new(0, 12, 0, 0)
KeyTitle.BackgroundTransparency = 1
KeyTitle.Font = Enum.Font.RobotoMono
KeyTitle.Text = "Quickz Key System"
KeyTitle.TextColor3 = Theme.Text
KeyTitle.TextSize = 13
KeyTitle.TextXAlignment = Enum.TextXAlignment.Left
KeyTitle.Parent = KeyTitleBar

-- Token Input
local TokenInput = Instance.new("TextBox")
TokenInput.Size = UDim2.new(1, -40, 0, 30)
TokenInput.Position = UDim2.new(0, 20, 0, 55)
TokenInput.BackgroundColor3 = Theme.BarBG
TokenInput.BorderSizePixel = 1
TokenInput.BorderColor3 = Theme.Border
TokenInput.Font = Enum.Font.RobotoMono
TokenInput.PlaceholderText = "Type authentication token..."
TokenInput.PlaceholderColor3 = Theme.SubText
TokenInput.Text = ""
TokenInput.TextColor3 = Theme.Text
TokenInput.TextSize = 12
TokenInput.Parent = KeyFrame
Instance.new("UICorner", TokenInput).CornerRadius = UDim.new(0, 3)

-- Verify Button
local VerifyBtn = Instance.new("TextButton")
VerifyBtn.Size = UDim2.new(0, 150, 0, 32)
VerifyBtn.Position = UDim2.new(0, 20, 0, 105)
VerifyBtn.BackgroundColor3 = Theme.Text
VerifyBtn.BorderSizePixel = 0
VerifyBtn.Font = Enum.Font.RobotoMono
VerifyBtn.Text = "Verify Token"
VerifyBtn.TextColor3 = Theme.MainBG
VerifyBtn.TextSize = 12
VerifyBtn.Parent = KeyFrame
Instance.new("UICorner", VerifyBtn).CornerRadius = UDim.new(0, 3)

-- Discord Button
local DiscordBtn = Instance.new("TextButton")
DiscordBtn.Size = UDim2.new(0, 150, 0, 32)
DiscordBtn.Position = UDim2.new(1, -170, 0, 105)
DiscordBtn.BackgroundColor3 = Theme.Accent
DiscordBtn.BorderSizePixel = 0
DiscordBtn.Font = Enum.Font.RobotoMono
DiscordBtn.Text = "Get Token (Discord)"
DiscordBtn.TextColor3 = Theme.Text
DiscordBtn.TextSize = 12
DiscordBtn.Parent = KeyFrame
Instance.new("UICorner", DiscordBtn).CornerRadius = UDim.new(0, 3)

-- Status Label
local KeyStatus = Instance.new("TextLabel")
KeyStatus.Size = UDim2.new(1, -40, 0, 25)
KeyStatus.Position = UDim2.new(0, 20, 0, 155)
KeyStatus.BackgroundTransparency = 1
KeyStatus.Font = Enum.Font.RobotoMono
KeyStatus.Text = ""
KeyStatus.TextColor3 = Theme.SubText
KeyStatus.TextSize = 11
KeyStatus.TextXAlignment = Enum.TextXAlignment.Left
KeyStatus.Parent = KeyFrame

-- ============================================
-- MAIN FRAME (Delete Tool)
-- ============================================
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 200, 0, 0)
MainFrame.Position = UDim2.new(0.5, -100, 0.5, -80)
MainFrame.BackgroundColor3 = Theme.MainBG
MainFrame.BackgroundTransparency = 0
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.AutomaticSize = Enum.AutomaticSize.Y
MainFrame.Parent = ScreenGui
MainFrame.ClipsDescendants = false
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 4)

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Theme.Border
MainStroke.Thickness = 1
MainStroke.Parent = MainFrame

local MainLayout = Instance.new("UIListLayout")
MainLayout.SortOrder = Enum.SortOrder.LayoutOrder
MainLayout.Padding = UDim.new(0, 0)
MainLayout.Parent = MainFrame

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.BackgroundColor3 = Theme.BarBG
TitleBar.BorderSizePixel = 0
TitleBar.LayoutOrder = 0
TitleBar.Parent = MainFrame
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 4)

local TitleBarDivider = Instance.new("Frame")
TitleBarDivider.Size = UDim2.new(1, 0, 0.5, 0)
TitleBarDivider.Position = UDim2.new(0, 0, 0.5, 0)
TitleBarDivider.BackgroundColor3 = Theme.BarBG
TitleBarDivider.BorderSizePixel = 0
TitleBarDivider.Parent = TitleBar

MakeDraggable(MainFrame, TitleBar)

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -60, 1, 0)
TitleText.Position = UDim2.new(0, 8, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Font = Enum.Font.RobotoMono
TitleText.Text = "Quickz Delete Tool"
TitleText.TextColor3 = Theme.Text
TitleText.TextSize = 10
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

-- Minimize Button
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 22, 0, 22)
MinBtn.Position = UDim2.new(1, -48, 0.5, -11)
MinBtn.BackgroundColor3 = Theme.Accent
MinBtn.BorderSizePixel = 0
MinBtn.Font = Enum.Font.RobotoMono
MinBtn.Text = "─"
MinBtn.TextColor3 = Theme.SubText
MinBtn.TextSize = 10
MinBtn.Parent = TitleBar
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 3)

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 22, 0, 22)
CloseBtn.Position = UDim2.new(1, -24, 0.5, -11)
CloseBtn.BackgroundColor3 = Theme.Accent
CloseBtn.BorderSizePixel = 0
CloseBtn.Font = Enum.Font.RobotoMono
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Theme.SubText
CloseBtn.TextSize = 13
CloseBtn.Parent = TitleBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 3)

local Divider = Instance.new("Frame")
Divider.Size = UDim2.new(1, 0, 0, 1)
Divider.BackgroundColor3 = Theme.Border
Divider.BorderSizePixel = 0
Divider.LayoutOrder = 1
Divider.Parent = MainFrame

-- Content Frame
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, 0, 0, 0)
ContentFrame.AutomaticSize = Enum.AutomaticSize.Y
ContentFrame.BackgroundTransparency = 1
ContentFrame.BorderSizePixel = 0
ContentFrame.LayoutOrder = 2
ContentFrame.Parent = MainFrame

local ContentLayout = Instance.new("UIListLayout")
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
ContentLayout.Padding = UDim.new(0, 5)
ContentLayout.Parent = ContentFrame

local ContentPadding = Instance.new("UIPadding")
ContentPadding.PaddingLeft = UDim.new(0, 8)
ContentPadding.PaddingRight = UDim.new(0, 8)
ContentPadding.PaddingTop = UDim.new(0, 8)
ContentPadding.PaddingBottom = UDim.new(0, 8)
ContentPadding.Parent = ContentFrame

local function AddSeparator(order, parent)
    local sep = Instance.new("Frame")
    sep.Size = UDim2.new(1, 0, 0, 1)
    sep.BackgroundColor3 = Theme.Border
    sep.BorderSizePixel = 0
    sep.LayoutOrder = order
    sep.Parent = parent or ContentFrame
    return sep
end

local function AddButton(text, order, parent)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 22)
    btn.BackgroundColor3 = Theme.BarBG
    btn.BorderSizePixel = 1
    btn.BorderColor3 = Theme.Border
    btn.Font = Enum.Font.RobotoMono
    btn.Text = text
    btn.TextColor3 = Theme.Text
    btn.TextSize = 10
    btn.LayoutOrder = order
    btn.Parent = parent or ContentFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 3)
    return btn
end

local function AddLabel(text, order, parent)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 12)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.RobotoMono
    lbl.Text = text
    lbl.TextColor3 = Theme.SubText
    lbl.TextSize = 9
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.LayoutOrder = order
    lbl.Parent = parent or ContentFrame
    return lbl
end

-- ============================================
-- DELETE MODE LOGIC
-- ============================================
local deleteMode = false
local deletedParts = {}
local selectedPart = nil
local selectionBox = nil
local renderConn = nil
local inputConn = nil

local function GetSelectionBox()
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

local function ClearSelection()
    if selectionBox then
        selectionBox.Adornee = nil
    end
end

local function GetMouseTarget()
    local mouse = LocalPlayer:GetMouse()
    local camera = workspace.CurrentCamera
    local ray = camera:ScreenPointToRay(mouse.X, mouse.Y)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    local filter = {}
    if LocalPlayer.Character then
        table.insert(filter, LocalPlayer.Character)
    end
    params.FilterDescendantsInstances = filter

    local result = workspace:Raycast(ray.Origin, ray.Direction * 1000, params)
    if result then
        return result.Instance
    end
    return nil
end

local function StartDeleteMode()
    if renderConn then renderConn:Disconnect() end

    renderConn = RunService.RenderStepped:Connect(function()
        if not deleteMode then
            ClearSelection()
            return
        end
        local target = GetMouseTarget()
        if target then
            selectedPart = target
            GetSelectionBox().Adornee = target
        else
            if selectedPart then
                selectedPart = nil
            end
            ClearSelection()
        end
    end)
end

local function StopDeleteMode()
    if renderConn then
        renderConn:Disconnect()
        renderConn = nil
    end
    ClearSelection()
    if selectionBox then
        selectionBox:Destroy()
        selectionBox = nil
    end
end

local function DeletePart()
    if not selectedPart then return end
    local part = selectedPart
    ClearSelection()
    table.insert(deletedParts, {
        part = part,
        originalParent = part.Parent
    })
    part.Parent = nil
end

local function StartInputListener()
    if inputConn then inputConn:Disconnect() end
    inputConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if not deleteMode then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            DeletePart()
        end
    end)
end

local function StopInputListener()
    if inputConn then
        inputConn:Disconnect()
        inputConn = nil
    end
end

-- ============================================
-- BUILD UI
-- ============================================
local statusLabel = AddLabel("[idle]", 0)

local deleteToggle
local function CreateToggle(text, order, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 22)
    frame.BackgroundTransparency = 1
    frame.LayoutOrder = order
    frame.Parent = ContentFrame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -34, 1, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.RobotoMono
    label.Text = text
    label.TextColor3 = Theme.Text
    label.TextSize = 10
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 28, 0, 14)
    toggleBtn.Position = UDim2.new(1, -30, 0.5, -7)
    toggleBtn.BackgroundColor3 = Theme.Border
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Text = ""
    toggleBtn.Parent = frame
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1, 0)

    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 10, 0, 10)
    indicator.Position = UDim2.new(0, 2, 0.5, -5)
    indicator.BackgroundColor3 = Theme.SubText
    indicator.BorderSizePixel = 0
    indicator.Parent = toggleBtn
    Instance.new("UICorner", indicator).CornerRadius = UDim.new(1, 0)

    local toggled = false

    local function SetToggled(state)
        toggled = state
        if toggled then
            TweenService:Create(toggleBtn, TweenInfo.new(0.15), {
                BackgroundColor3 = Theme.Text
            }):Play()
            TweenService:Create(indicator, TweenInfo.new(0.15), {
                Position = UDim2.new(0, 16, 0.5, -5),
                BackgroundColor3 = Theme.MainBG
            }):Play()
        else
            TweenService:Create(toggleBtn, TweenInfo.new(0.15), {
                BackgroundColor3 = Theme.Border
            }):Play()
            TweenService:Create(indicator, TweenInfo.new(0.15), {
                Position = UDim2.new(0, 2, 0.5, -5),
                BackgroundColor3 = Theme.SubText
            }):Play()
        end
        callback(toggled)
    end

    toggleBtn.MouseButton1Click:Connect(function()
        SetToggled(not toggled)
    end)

    return frame, toggleBtn, SetToggled
end

local _, _, setDeleteMode = CreateToggle("Delete Mode", 1, function(state)
    deleteMode = state
    if state then
        statusLabel.Text = "[delete mode ON]"
        StartDeleteMode()
        StartInputListener()
    else
        statusLabel.Text = "[idle]"
        StopDeleteMode()
        StopInputListener()
    end
end)

AddSeparator(2)

-- Undo / Redo All buttons
local buttonRow = Instance.new("Frame")
buttonRow.Size = UDim2.new(1, 0, 0, 22)
buttonRow.BackgroundTransparency = 1
buttonRow.LayoutOrder = 3
buttonRow.Parent = ContentFrame

local buttonLayout = Instance.new("UIListLayout")
buttonLayout.FillDirection = Enum.FillDirection.Horizontal
buttonLayout.SortOrder = Enum.SortOrder.LayoutOrder
buttonLayout.Padding = UDim.new(0, 4)
buttonLayout.Parent = buttonRow

local undoBtn = Instance.new("TextButton")
undoBtn.Size = UDim2.new(0.5, -2, 1, 0)
undoBtn.BackgroundColor3 = Theme.BarBG
undoBtn.BorderSizePixel = 1
undoBtn.BorderColor3 = Theme.Border
undoBtn.Font = Enum.Font.RobotoMono
undoBtn.Text = "⟵ Undo"
undoBtn.TextColor3 = Theme.Text
undoBtn.TextSize = 10
undoBtn.LayoutOrder = 1
undoBtn.Parent = buttonRow
Instance.new("UICorner", undoBtn).CornerRadius = UDim.new(0, 3)

local redoAllBtn = Instance.new("TextButton")
redoAllBtn.Size = UDim2.new(0.5, -2, 1, 0)
redoAllBtn.BackgroundColor3 = Theme.BarBG
redoAllBtn.BorderSizePixel = 1
redoAllBtn.BorderColor3 = Theme.Border
redoAllBtn.Font = Enum.Font.RobotoMono
redoAllBtn.Text = "Redo All ⟶"
redoAllBtn.TextColor3 = Theme.Text
redoAllBtn.TextSize = 10
redoAllBtn.LayoutOrder = 2
redoAllBtn.Parent = buttonRow
Instance.new("UICorner", redoAllBtn).CornerRadius = UDim.new(0, 3)

undoBtn.MouseButton1Click:Connect(function()
    if #deletedParts == 0 then return end
    local entry = table.remove(deletedParts)
    if entry.part then
        pcall(function()
            entry.part.Parent = entry.originalParent
        end)
    end
end)

redoAllBtn.MouseButton1Click:Connect(function()
    for i = #deletedParts, 1, -1 do
        local entry = deletedParts[i]
        if entry.part then
            pcall(function()
                entry.part.Parent = entry.originalParent
            end)
        end
    end
    deletedParts = {}
end)

AddSeparator(4)

-- Theme & Background controls
local themeRow = Instance.new("Frame")
themeRow.Size = UDim2.new(1, 0, 0, 22)
themeRow.BackgroundTransparency = 1
themeRow.LayoutOrder = 5
themeRow.Parent = ContentFrame

local themeLayout = Instance.new("UIListLayout")
themeLayout.FillDirection = Enum.FillDirection.Horizontal
themeLayout.SortOrder = Enum.SortOrder.LayoutOrder
themeLayout.Padding = UDim.new(0, 4)
themeLayout.Parent = themeRow

local themeBtn = Instance.new("TextButton")
themeBtn.Size = UDim2.new(0.5, -2, 1, 0)
themeBtn.BackgroundColor3 = Theme.BarBG
themeBtn.BorderSizePixel = 1
themeBtn.BorderColor3 = Theme.Border
themeBtn.Font = Enum.Font.RobotoMono
themeBtn.Text = "Theme: Dark"
themeBtn.TextColor3 = Theme.Text
themeBtn.TextSize = 9
themeBtn.LayoutOrder = 1
themeBtn.Parent = themeRow
Instance.new("UICorner", themeBtn).CornerRadius = UDim.new(0, 3)

local bgBtn = Instance.new("TextButton")
bgBtn.Size = UDim2.new(0.5, -2, 1, 0)
bgBtn.BackgroundColor3 = Theme.BarBG
bgBtn.BorderSizePixel = 1
bgBtn.BorderColor3 = Theme.Border
bgBtn.Font = Enum.Font.RobotoMono
bgBtn.Text = "BG: 100%"
bgBtn.TextColor3 = Theme.Text
bgBtn.TextSize = 9
bgBtn.LayoutOrder = 2
bgBtn.Parent = themeRow
Instance.new("UICorner", bgBtn).CornerRadius = UDim.new(0, 3)

local uiState = {
    IsLight = false,
    TransparentMode = false
}

themeBtn.MouseButton1Click:Connect(function()
    uiState.IsLight = not uiState.IsLight
    local isLight = uiState.IsLight

    local bgColor = isLight and Color3.fromRGB(240, 240, 240) or Color3.fromRGB(30, 30, 30)
    local barColor = isLight and Color3.fromRGB(220, 220, 224) or Color3.fromRGB(37, 37, 38)
    local borderColor = isLight and Color3.fromRGB(190, 190, 190) or Color3.fromRGB(65, 65, 65)

    themeBtn.Text = isLight and "Theme: Light" or "Theme: Dark"

    TweenService:Create(MainFrame, TweenInfo.new(0.2), {
        BackgroundColor3 = bgColor
    }):Play()
    TweenService:Create(TitleBar, TweenInfo.new(0.2), {
        BackgroundColor3 = barColor
    }):Play()
    TweenService:Create(TitleBarDivider, TweenInfo.new(0.2), {
        BackgroundColor3 = barColor
    }):Play()
    TweenService:Create(MainStroke, TweenInfo.new(0.2), {
        Color = borderColor
    }):Play()
end)

bgBtn.MouseButton1Click:Connect(function()
    uiState.TransparentMode = not uiState.TransparentMode
    bgBtn.Text = uiState.TransparentMode and "BG: 85%" or "BG: 100%"
    TweenService:Create(MainFrame, TweenInfo.new(0.2), {
        BackgroundTransparency = uiState.TransparentMode and 0.15 or 0
    }):Play()
end)

AddSeparator(6)

local shortcutsLabel = AddLabel("[E] toggle UI   [X] delete mode", 7)
shortcutsLabel.TextXAlignment = Enum.TextXAlignment.Center
shortcutsLabel.Size = UDim2.new(1, 0, 0, 12)

-- ============================================
-- MINIMIZED BUTTON
-- ============================================
local miniBtn = Instance.new("TextButton")
miniBtn.Size = UDim2.new(0, 130, 0, 26)
miniBtn.Position = UDim2.new(0.5, -65, 0, -40)
miniBtn.BackgroundColor3 = Theme.BarBG
miniBtn.BorderSizePixel = 1
miniBtn.BorderColor3 = Theme.Border
miniBtn.Font = Enum.Font.RobotoMono
miniBtn.Text = "Quickz Delete Tool"
miniBtn.TextColor3 = Theme.Text
miniBtn.TextSize = 10
miniBtn.Visible = false
miniBtn.Parent = ScreenGui
Instance.new("UICorner", miniBtn).CornerRadius = UDim.new(0, 3)

MakeDraggable(miniBtn, miniBtn)

local uiVisible = true

local function ShowUI()
    uiVisible = true
    MainFrame.Visible = true
    miniBtn.Visible = false
end

local function HideUI()
    uiVisible = false
    MainFrame.Visible = false
    miniBtn.Visible = true
    TweenService:Create(miniBtn, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -65, 0, 45)
    }):Play()
end

local function ToggleUI()
    if uiVisible then
        HideUI()
    else
        ShowUI()
    end
end

-- ============================================
-- EVENT CONNECTIONS
-- ============================================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.E then
        ToggleUI()
    elseif input.KeyCode == Enum.KeyCode.X then
        if MainFrame.Visible then
            setDeleteMode(not deleteMode)
        end
    end
end)

MinBtn.MouseButton1Click:Connect(HideUI)

miniBtn.MouseButton1Click:Connect(function()
    TweenService:Create(miniBtn, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
        Position = UDim2.new(0.5, -65, 0, -40)
    }):Play()
    task.wait(0.2)
    ShowUI()
end)

CloseBtn.MouseButton1Click:Connect(function()
    StopDeleteMode()
    StopInputListener()
    ScreenGui:Destroy()
end)

DiscordBtn.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard("https://discord.gg/WdTbHzcqpU")
    end
end)

VerifyBtn.MouseButton1Click:Connect(function()
    if TokenInput.Text == "Quickz-1920" then
        KeyStatus.Text = "[status] token verified. access granted."
        task.wait(0.5)
        KeyFrame.Visible = false
        MainFrame.Visible = true
    else
        KeyStatus.Text = "[error] invalid authentication token."
        TokenInput.Text = ""
    end
end)

-- ============================================
-- LOADING SEQUENCE
-- ============================================
task.spawn(function()
    UpdateProgress(0.1)
    task.wait(0.9)
    StatusText.Text = "[info] loading delete tool components..."
    UpdateProgress(0.45)
    task.wait(0.6)
    StatusText.Text = "[info] establishing client hooks..."
    UpdateProgress(0.8)
    task.wait(0.4)
    StatusText.Text = "[success] environment loaded."
    UpdateProgress(1)
    task.wait(0.2)

    TweenService:Create(LoadingFrame, TweenInfo.new(0.25), {
        BackgroundTransparency = 1
    }):Play()
    TweenService:Create(WelcomeText, TweenInfo.new(0.15), {
        TextTransparency = 1
    }):Play()
    TweenService:Create(StatusText, TweenInfo.new(0.15), {
        TextTransparency = 1
    }):Play()
    TweenService:Create(AvatarImage, TweenInfo.new(0.15), {
        ImageTransparency = 1
    }):Play()
    TweenService:Create(ProgressBg, TweenInfo.new(0.15), {
        BackgroundTransparency = 1
    }):Play()
    TweenService:Create(ProgressBar, TweenInfo.new(0.15), {
        BackgroundTransparency = 1
    }):Play()
    TweenService:Create(ProgressText, TweenInfo.new(0.15), {
        TextTransparency = 1
    }):Play()

    task.wait(0.25)
    LoadingFrame.Visible = false
    KeyFrame.Visible = true
end)