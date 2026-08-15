-- Deobfuscated and Cleaned Version
-- Original source: 1786781816448_pr_2260dd0c_191HP.lua

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Constants
local TARGET_CFRAME = CFrame.new(729.86, 3.71, 444.46) * CFrame.Angles(-3.14, 0.01, -3.14)
local APARTMENT_CFRAME = CFrame.new(537.71, 4.59, -537.09) * CFrame.Angles(-1.2, -1.56, -1.2)

-- Teleport position presets
local TELEPORT_POSITIONS = {
    {pos = CFrame.new(770.992, 3.71, 433.75)},
    {pos = CFrame.new(510.061, 4.476, 600.548)},
    {pos = CFrame.new(1137.992, 9.932, 449.753)},
    {pos = CFrame.new(1139.174, 9.932, 420.556)},
    {pos = CFrame.new(984.856, 9.932, 247.28)},
    {pos = CFrame.new(988.311, 9.932, 221.664)},
    {pos = CFrame.new(923.954, 9.932, 42.202)},
    {pos = CFrame.new(895.721, 9.932, 41.928)},
    {pos = CFrame.new(1166.33, 3.36, -29.77)},
    {pos = CFrame.new(1065.19, 28.47, 420.76)},
    {pos = CFrame.new(1202.3, 3.71, -220.91)},
    {pos = CFrame.new(1179.72, 3.71, -230.21)},
    {pos = CFrame.new(1202.31, 3.71, -182.55)}
}

-- Colors
local COLORS = {
    bg = Color3.fromRGB(8, 8, 16),
    surface = Color3.fromRGB(13, 13, 22),
    panel = Color3.fromRGB(18, 18, 28),
    card = Color3.fromRGB(22, 22, 36),
    sidebar = Color3.fromRGB(10, 10, 20),
    accent = Color3.fromRGB(0, 110, 220),
    accentDim = Color3.fromRGB(0, 70, 150),
    accentGlow = Color3.fromRGB(50, 150, 255),
    accentSoft = Color3.fromRGB(0, 90, 190),
    text = Color3.fromRGB(230, 235, 255),
    textMid = Color3.fromRGB(150, 160, 200),
    textDim = Color3.fromRGB(80, 85, 120),
    green = Color3.fromRGB(40, 200, 100),
    red = Color3.fromRGB(220, 60, 70),
    border = Color3.fromRGB(40, 45, 65)
}

-- Variables
local antiAfkActive = true
local fullyLoopRunning = false
local fullyLoopTarget = 5
local sellLoopRunning = false
local autoMsLoopRunning = false
local blinkEnabled = true

-- UI References
local tabs = {}
local tabButtons = {}
local currentTab = "AUTO"

-- Helper Functions

local function teleportToPosition(pos)
    local char = LocalPlayer.Character
    if not char then return end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    hrp.Anchored = true
    hrp.CFrame = pos
    task.wait(0.05)
    hrp.Anchored = false
end

local function teleportVehicle(model, pos)
    if not model then return false end
    
    local parts = model:GetDescendants()
    for _, part in ipairs(parts) do
        if part:IsA("BasePart") then
            pcall(function()
                part.AssemblyLinearVelocity = Vector3.zero
                part.AssemblyAngularVelocity = Vector3.zero
                part.Anchored = true
            end)
        end
    end
    
    task.wait(0.05)
    
    if model.PrimaryPart then
        model:SetPrimaryPartCFrame(pos)
    end
    
    task.wait(0.05)
    
    for _, part in ipairs(parts) do
        if part:IsA("BasePart") then
            pcall(function()
                part.Anchored = false
                part.AssemblyLinearVelocity = Vector3.zero
                part.AssemblyAngularVelocity = Vector3.zero
            end)
        end
    end
    
    return true
end

local function getPlayerPosition()
    local char = LocalPlayer.Character
    if not char then return false end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    
    return hrp.CFrame
end

local function getItemCount(itemName)
    local count = 0
    
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        for _, tool in pairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and tool.Name == itemName then
                count = count + 1
            end
        end
    end
    
    local char = LocalPlayer.Character
    if char then
        for _, tool in pairs(char:GetChildren()) do
            if tool:IsA("Tool") and tool.Name == itemName then
                count = count + 1
            end
        end
    end
    
    return count
end

local function equipTool(toolName)
    local char = LocalPlayer.Character
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    
    local tool = backpack and backpack:FindFirstChild(toolName)
    if not tool then
        tool = char and char:FindFirstChild(toolName)
        if not tool then return false end
    end
    
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid:EquipTool(tool)
        task.wait(0.3)
        return true
    end
    
    return false
end

local function sendKeyE(hold)
    VirtualInputManager:SendKeyEvent(true, "E", false, game)
    task.wait(hold or 0.7)
    VirtualInputManager:SendKeyEvent(false, "E", false, game)
end

-- Auto MS Loop Functions

local function updateAutoMsCounts()
    local waterCount = getItemCount("Water")
    local sugarCount = getItemCount("Sugar Block Bag")
    local gelatinCount = getItemCount("Gelatin")
    local emptyBagCount = getItemCount("Empty Bag")
    
    -- Update UI labels if they exist
    -- (UI references will be set later)
end

local function cookMsLoop()
    pcall(function()
        equipTool("Water")
        sendKeyE(0.7)
        task.wait(1)
        
        equipTool("Sugar Block Bag")
        sendKeyE(0.7)
        task.wait(1)
        
        equipTool("Gelatin")
        sendKeyE(0.7)
        task.wait(1)
        
        task.wait(45)
        
        equipTool("Empty Bag")
        sendKeyE(0.7)
        task.wait(1)
    end)
end

local function autoMsLoop()
    while autoMsLoopRunning do
        updateAutoMsCounts()
        cookMsLoop()
        updateAutoMsCounts()
        task.wait(2)
    end
end

-- Fully Auto Loop Functions

local function updateFullyCounts()
    -- Update UI labels
end

local function buyItems(amount)
    local remote = ReplicatedStorage:FindFirstChild("RemoteEvents")
    if not remote then return end
    
    local storePurchase = remote:FindFirstChild("StorePurchase")
    if not storePurchase then return end
    
    local items = {"Water", "Sugar Block Bag", "Gelatin"}
    
    for _, item in ipairs(items) do
        if not fullyLoopRunning then break end
        
        for i = 1, amount do
            if not fullyLoopRunning then break end
            pcall(function()
                storePurchase:FireServer(item, 1)
            end)
            task.wait(0.4)
        end
        task.wait(0.5)
    end
end

local function sellItems()
    -- Sell all marshmallow bags
    local items = {
        "Small Marshmallow Bag",
        "Medium Marshmallow Bag",
        "Large Marshmallow Bag"
    }
    
    for _, item in ipairs(items) do
        if not fullyLoopRunning then break end
        -- Sell logic here
    end
end

local function fullyLoop()
    while fullyLoopRunning do
        -- Teleport to NPC
        teleportToPosition(TELEPORT_POSITIONS[1].pos)
        task.wait(1)
        
        buyItems(fullyLoopTarget)
        
        if not fullyLoopRunning then break end
        
        -- Return to apartment
        teleportToPosition(APARTMENT_CFRAME)
        task.wait(1)
        
        updateFullyCounts()
        
        -- Cook MS
        for i = 1, fullyLoopTarget do
            if not fullyLoopRunning then break end
            cookMsLoop()
            updateFullyCounts()
            task.wait(0.5)
        end
        
        if not fullyLoopRunning then break end
        
        -- Teleport for selling
        teleportToPosition(TELEPORT_POSITIONS[1].pos)
        task.wait(1)
        
        sellItems()
        
        if not fullyLoopRunning then break end
        
        task.wait(2)
    end
    
    fullyLoopRunning = false
end

-- Sell Loop Functions

local function getEquippedTools()
    local tools = {}
    local sellableItems = {"Water", "Sugar Block Bag", "Gelatin", "Empty Bag"}
    
    local char = LocalPlayer.Character
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    
    if backpack then
        for _, tool in pairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and table.find(sellableItems, tool.Name) then
                table.insert(tools, tool)
            end
        end
    end
    
    if char then
        for _, tool in pairs(char:GetChildren()) do
            if tool:IsA("Tool") and table.find(sellableItems, tool.Name) then
                table.insert(tools, tool)
            end
        end
    end
    
    return tools
end

local function sellLoop()
    while sellLoopRunning do
        local tools = getEquippedTools()
        
        if #tools > 0 then
            for _, tool in ipairs(tools) do
                if not sellLoopRunning then
                    task.wait(0.5)
                    break
                end
                
                if tool and tool.Parent == LocalPlayer:FindFirstChild("Backpack") then
                    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        humanoid:EquipTool(tool)
                        task.wait(0.3)
                    end
                end
                
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                task.wait(0.1)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                task.wait(1)
            end
        else
            task.wait(2)
        end
    end
end

-- UI Creation

local function createUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "191_STORE"
    screenGui.Parent = PlayerGui
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Main Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 520, 0, 420)
    mainFrame.Position = UDim2.new(0.5, -260, 0.5, -210)
    mainFrame.BackgroundColor3 = COLORS.bg
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.ClipsDescendants = false
    mainFrame.Parent = screenGui
    
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)
    
    local stroke = Instance.new("UIStroke", mainFrame)
    stroke.Color = COLORS.border
    stroke.Thickness = 1
    
    -- Title Bar
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 46)
    titleBar.BackgroundColor3 = COLORS.surface
    titleBar.ZIndex = 2
    titleBar.Parent = mainFrame
    Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 12)
    
    local titleBarBottom = Instance.new("Frame")
    titleBarBottom.Size = UDim2.new(1, 0, 0, 12)
    titleBarBottom.Position = UDim2.new(0, 0, 1, -12)
    titleBarBottom.BackgroundColor3 = COLORS.surface
    titleBarBottom.BorderSizePixel = 0
    titleBarBottom.Parent = titleBar
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Position = UDim2.new(0, 28, 0, 0)
    titleLabel.Size = UDim2.new(0, 160, 1, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "191 STORE"
    titleLabel.Font = Enum.Font.GothamBlack
    titleLabel.TextSize = 15
    titleLabel.TextColor3 = COLORS.text
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleBar
    
    -- Close Button
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 28, 0, 28)
    closeButton.Position = UDim2.new(1, -38, 0.5, -14)
    closeButton.BackgroundColor3 = Color3.fromRGB(50, 15, 22)
    closeButton.Text = "x"
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextSize = 12
    closeButton.TextColor3 = COLORS.red
    closeButton.BorderSizePixel = 0
    closeButton.Parent = titleBar
    Instance.new("UICorner", closeButton).CornerRadius = UDim.new(0, 6)
    
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    -- Minimize Button
    local minimizeButton = Instance.new("TextButton")
    minimizeButton.Size = UDim2.new(0, 28, 0, 28)
    minimizeButton.Position = UDim2.new(1, -72, 0.5, -14)
    minimizeButton.BackgroundColor3 = COLORS.card
    minimizeButton.Text = "-"
    minimizeButton.Font = Enum.Font.GothamBold
    minimizeButton.TextSize = 14
    minimizeButton.TextColor3 = COLORS.textMid
    minimizeButton.BorderSizePixel = 0
    minimizeButton.Parent = titleBar
    Instance.new("UICorner", minimizeButton).CornerRadius = UDim.new(0, 6)
    
    local minimized = false
    minimizeButton.MouseButton1Click:Connect(function()
        minimized = not minimized
        mainFrame.Visible = not minimized
    end)
    
    -- Sidebar
    local sidebar = Instance.new("Frame")
    sidebar.Size = UDim2.new(0, 70, 1, -46)
    sidebar.Position = UDim2.new(0, 0, 0, 46)
    sidebar.BackgroundColor3 = COLORS.sidebar
    sidebar.ZIndex = 2
    sidebar.ClipsDescendants = false
    sidebar.Parent = mainFrame
    
    local sidebarDivider = Instance.new("Frame")
    sidebarDivider.Size = UDim2.new(0, 1, 1, -46)
    sidebarDivider.Position = UDim2.new(0, 69, 0, 46)
    sidebarDivider.BackgroundColor3 = COLORS.border
    sidebarDivider.BorderSizePixel = 0
    sidebarDivider.ZIndex = 3
    sidebarDivider.Parent = mainFrame
    
    local sidebarLayout = Instance.new("UIListLayout", sidebar)
    sidebarLayout.Padding = UDim.new(0, 4)
    sidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    sidebarLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    sidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    local sidebarPadding = Instance.new("UIPadding", sidebar)
    sidebarPadding.PaddingTop = UDim.new(0, 10)
    
    -- Content Area
    local contentArea = Instance.new("Frame")
    contentArea.Size = UDim2.new(1, -70, 1, -46)
    contentArea.Position = UDim2.new(0, 70, 0, 46)
    contentArea.BackgroundColor3 = COLORS.panel
    contentArea.ClipsDescendants = true
    contentArea.Parent = mainFrame
    
    -- Tab System
    local tabNames = {"AUTO", "FULLY", "TP", "MS POT", "BUY", "SELL", "SETTINGS"}
    local tabFrames = {}
    
    for _, tabName in ipairs(tabNames) do
        -- Tab Button
        local tabButton = Instance.new("TextButton", sidebar)
        tabButton.Size = UDim2.new(0, 62, 0, 36)
        tabButton.BackgroundTransparency = 1
        tabButton.Text = tabName
        tabButton.Font = Enum.Font.GothamBold
        tabButton.TextSize = 10
        tabButton.TextColor3 = COLORS.textDim
        tabButton.BorderSizePixel = 0
        tabButton.LayoutOrder = #tabFrames + 1
        tabButton.TextStrokeTransparency = 1
        Instance.new("UICorner", tabButton).CornerRadius = UDim.new(0, 7)
        
        local indicator = Instance.new("Frame", tabButton)
        indicator.Size = UDim2.new(0, 2, 0, 18)
        indicator.Position = UDim2.new(0, 0, 0.5, -9)
        indicator.BackgroundColor3 = COLORS.accent
        indicator.BorderSizePixel = 0
        indicator.Visible = false
        Instance.new("UICorner", indicator).CornerRadius = UDim.new(0, 2)
        
        -- Tab Content
        local tabFrame = Instance.new("ScrollingFrame", contentArea)
        tabFrame.Size = UDim2.new(1, 0, 1, 0)
        tabFrame.BackgroundTransparency = 1
        tabFrame.ScrollBarThickness = 3
        tabFrame.ScrollBarImageColor3 = COLORS.accentSoft
        tabFrame.Visible = false
        tabFrame.BorderSizePixel = 0
        
        local tabLayout = Instance.new("UIListLayout", tabFrame)
        tabLayout.Padding = UDim.new(0, 6)
        tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
        
        local tabPadding = Instance.new("UIPadding", tabFrame)
        tabPadding.PaddingTop = UDim.new(0, 12)
        tabPadding.PaddingLeft = UDim.new(0, 10)
        tabPadding.PaddingRight = UDim.new(0, 10)
        tabPadding.PaddingBottom = UDim.new(0, 12)
        
        tabFrames[tabName] = tabFrame
        tabButtons[tabName] = tabButton
        
        tabButton.MouseButton1Click:Connect(function()
            switchTab(tabName)
        end)
    end
    
    -- Switch Tab Function
    function switchTab(tabName)
        currentTab = tabName
        
        for name, frame in pairs(tabFrames) do
            frame.Visible = (name == tabName)
        end
        
        for name, button in pairs(tabButtons) do
            if name == tabName then
                button.BackgroundColor3 = COLORS.accentDim
                button.BackgroundTransparency = 0
                button.TextColor3 = COLORS.accentGlow
            else
                button.BackgroundTransparency = 1
                button.TextColor3 = COLORS.textDim
            end
        end
    end
    
    -- UI Helper Functions
    function createSection(parent, title, order)
        local frame = Instance.new("Frame", parent)
        frame.Size = UDim2.new(1, 0, 0, 22)
        frame.BackgroundTransparency = 1
        frame.LayoutOrder = order or 0
        
        local label = Instance.new("TextLabel", frame)
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = string.upper(title)
        label.Font = Enum.Font.GothamBold
        label.TextSize = 9
        label.TextColor3 = COLORS.textDim
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.TextStrokeTransparency = 1
        
        local divider = Instance.new("Frame", frame)
        divider.Size = UDim2.new(1, 0, 0, 1)
        divider.Position = UDim2.new(0, 0, 1, -1)
        divider.BackgroundColor3 = COLORS.border
        divider.BorderSizePixel = 0
        
        return frame
    end
    
    function createCard(parent, height, order)
        local frame = Instance.new("Frame", parent)
        frame.Size = UDim2.new(1, 0, 0, height or 46)
        frame.BackgroundColor3 = COLORS.card
        frame.BorderSizePixel = 0
        frame.LayoutOrder = order or 0
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
        return frame
    end
    
    function createInfoRow(parent, label, order)
        local frame = createCard(parent, 30, order)
        
        local labelText = Instance.new("TextLabel", frame)
        labelText.Position = UDim2.new(0, 12, 0, 0)
        labelText.Size = UDim2.new(0.6, 0, 1, 0)
        labelText.BackgroundTransparency = 1
        labelText.Text = label
        labelText.Font = Enum.Font.GothamSemibold
        labelText.TextSize = 11
        labelText.TextColor3 = COLORS.textMid
        labelText.TextXAlignment = Enum.TextXAlignment.Left
        labelText.TextStrokeTransparency = 1
        
        local valueText = Instance.new("TextLabel", frame)
        valueText.Position = UDim2.new(0.6, 0, 0, 0)
        valueText.Size = UDim2.new(0.4, -10, 1, 0)
        valueText.BackgroundTransparency = 1
        valueText.Text = "0"
        valueText.Font = Enum.Font.GothamBold
        valueText.TextSize = 12
        valueText.TextColor3 = COLORS.accentGlow
        valueText.TextXAlignment = Enum.TextXAlignment.Right
        valueText.TextStrokeTransparency = 1
        
        return valueText
    end
    
    function createSlider(parent, label, min, max, defaultValue, order, callback)
        local frame = createCard(parent, 54, order)
        
        local labelText = Instance.new("TextLabel", frame)
        labelText.Position = UDim2.new(0, 12, 0, 8)
        labelText.Size = UDim2.new(1, -80, 0, 16)
        labelText.BackgroundTransparency = 1
        labelText.Text = label
        labelText.Font = Enum.Font.GothamSemibold
        labelText.TextSize = 11
        labelText.TextColor3 = COLORS.textMid
        labelText.TextXAlignment = Enum.TextXAlignment.Left
        labelText.TextStrokeTransparency = 1
        
        local valueLabel = Instance.new("TextLabel", frame)
        valueLabel.Position = UDim2.new(1, -52, 0, 8)
        valueLabel.Size = UDim2.new(0, 42, 0, 16)
        valueLabel.BackgroundTransparency = 1
        valueLabel.Text = tostring(defaultValue)
        valueLabel.Font = Enum.Font.GothamBold
        valueLabel.TextSize = 12
        valueLabel.TextColor3 = COLORS.accentGlow
        valueLabel.TextXAlignment = Enum.TextXAlignment.Right
        valueLabel.TextStrokeTransparency = 1
        
        local track = Instance.new("Frame", frame)
        track.Position = UDim2.new(0, 12, 0, 34)
        track.Size = UDim2.new(1, -24, 0, 5)
        track.BackgroundColor3 = COLORS.border
        track.BorderSizePixel = 0
        track.Active = true
        Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)
        
        local fill = Instance.new("Frame", track)
        fill.Size = UDim2.new((defaultValue - min) / (max - min), 0, 1, 0)
        fill.BackgroundColor3 = COLORS.accent
        fill.BorderSizePixel = 0
        Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
        
        local handle = Instance.new("Frame", track)
        handle.Size = UDim2.new(0, 14, 0, 14)
        handle.Position = UDim2.new((defaultValue - min) / (max - min), -7, 0.5, -7)
        handle.BackgroundColor3 = Color3.new(1, 1, 1)
        handle.BorderSizePixel = 0
        Instance.new("UICorner", handle).CornerRadius = UDim.new(1, 0)
        
        local handleStroke = Instance.new("UIStroke", handle)
        handleStroke.Color = COLORS.accent
        handleStroke.Thickness = 2
        
        local dragging = false
        
        local function updateSlider(inputX)
            local percent = math.clamp((inputX - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            local value = math.floor(min + percent * (max - min))
            
            handle.Position = UDim2.new(percent, -7, 0.5, -7)
            fill.Size = UDim2.new(percent, 0, 1, 0)
            valueLabel.Text = tostring(value)
            
            if callback then
                callback(value)
            end
        end
        
        track.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or 
               input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                updateSlider(input.Position.X)
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                updateSlider(input.Position.X)
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or 
               input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
        
        return frame, valueLabel
    end
    
    function createButton(parent, text, color, order)
        local button = Instance.new("TextButton", parent)
        button.Size = UDim2.new(1, 0, 0, 36)
        button.BackgroundColor3 = color or COLORS.accentDim
        button.Font = Enum.Font.GothamBold
        button.TextSize = 12
        button.TextColor3 = COLORS.text
        button.Text = text
        button.BorderSizePixel = 0
        button.LayoutOrder = order or 0
        button.TextStrokeTransparency = 1
        Instance.new("UICorner", button).CornerRadius = UDim.new(0, 8)
        
        button.MouseEnter:Connect(function()
            local tween = TweenService:Create(button, TweenInfo.new(0.12), {
                BackgroundColor3 = COLORS.accent
            })
            tween:Play()
        end)
        
        button.MouseLeave:Connect(function()
            local tween = TweenService:Create(button, TweenInfo.new(0.12), {
                BackgroundColor3 = color or COLORS.accentDim
            })
            tween:Play()
        end)
        
        return button
    end
    
    -- Build AUTO Tab
    local autoTab = tabFrames["AUTO"]
    
    createSection(autoTab, "MS LOOP AUTO COOK", 1)
    local waterCount = createInfoRow(autoTab, "Water", 2)
    local sugarCount = createInfoRow(autoTab, "Sugar Block Bag", 3)
    local gelatinCount = createInfoRow(autoTab, "Gelatin", 4)
    local emptyBagCount = createInfoRow(autoTab, "Empty Bag", 5)
    
    createSection(autoTab, "CONTROL", 6)
    
    local statusFrame = createCard(autoTab, 40, 7)
    local statusLabel = Instance.new("TextLabel", statusFrame)
    statusLabel.Size = UDim2.new(1, -20, 1, 0)
    statusLabel.Position = UDim2.new(0, 12, 0, 0)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "STOPPED"
    statusLabel.Font = Enum.Font.GothamBold
    statusLabel.TextSize = 13
    statusLabel.TextColor3 = COLORS.red
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.TextStrokeTransparency = 1
    
    local startMsButton = createButton(autoTab, "START MS LOOP", COLORS.green, 8)
    local stopMsButton = createButton(autoTab, "STOP MS LOOP", COLORS.red, 9)
    stopMsButton.Visible = false
    
    local function updateAutoMsCountsUI()
        waterCount.Text = tostring(getItemCount("Water"))
        sugarCount.Text = tostring(getItemCount("Sugar Block Bag"))
        gelatinCount.Text = tostring(getItemCount("Gelatin"))
        emptyBagCount.Text = tostring(getItemCount("Empty Bag"))
    end
    
    startMsButton.MouseButton1Click:Connect(function()
        if not autoMsLoopRunning then
            autoMsLoopRunning = true
            startMsButton.Text = "RUNNING..."
            startMsButton.BackgroundColor3 = COLORS.accentDim
            statusLabel.Text = "RUNNING"
            statusLabel.TextColor3 = COLORS.green
            task.spawn(autoMsLoop)
        end
    end)
    
    stopMsButton.MouseButton1Click:Connect(function()
        autoMsLoopRunning = false
        startMsButton.Text = "START MS LOOP"
        startMsButton.BackgroundColor3 = COLORS.green
        statusLabel.Text = "STOPPED"
        statusLabel.TextColor3 = COLORS.red
    end)
    
    -- Build FULLY Tab
    local fullyTab = tabFrames["FULLY"]
    
    createSection(fullyTab, "AUTO FULLY", 1)
    local fWaterCount = createInfoRow(fullyTab, "Water", 2)
    local fSugarCount = createInfoRow(fullyTab, "Sugar Block Bag", 3)
    local fGelatinCount = createInfoRow(fullyTab, "Gelatin", 4)
    local fEmptyBagCount = createInfoRow(fullyTab, "Empty Bag", 5)
    
    createSection(fullyTab, "SETTING", 6)
    
    local targetSlider, targetValue = createSlider(fullyTab, "TARGET FULLY", 1, 50, 5, 7, function(value)
        fullyLoopTarget = value
    end)
    
    local fStatusFrame = createCard(fullyTab, 40, 8)
    local fStatusLabel = Instance.new("TextLabel", fStatusFrame)
    fStatusLabel.Size = UDim2.new(1, -20, 1, 0)
    fStatusLabel.Position = UDim2.new(0, 12, 0, 0)
    fStatusLabel.BackgroundTransparency = 1
    fStatusLabel.Text = "STOPPED"
    fStatusLabel.Font = Enum.Font.GothamBold
    fStatusLabel.TextSize = 13
    fStatusLabel.TextColor3 = COLORS.red
    fStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    fStatusLabel.TextStrokeTransparency = 1
    
    local startFullyButton = createButton(fullyTab, "START FULLY", COLORS.green, 9)
    local stopFullyButton = createButton(fullyTab, "STOP FULLY", COLORS.red, 10)
    stopFullyButton.Visible = false
    
    local function updateFullyCountsUI()
        fWaterCount.Text = tostring(getItemCount("Water"))
        fSugarCount.Text = tostring(getItemCount("Sugar Block Bag"))
        fGelatinCount.Text = tostring(getItemCount("Gelatin"))
        fEmptyBagCount.Text = tostring(getItemCount("Empty Bag"))
    end
    
    local apartmentPosition = nil
    
    startFullyButton.MouseButton1Click:Connect(function()
        if fullyLoopRunning then return end
        
        local char = LocalPlayer.Character
        if not char then
            fStatusLabel.Text = "NO CHARACTER!"
            fStatusLabel.TextColor3 = COLORS.red
            return
        end
        
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then
            fStatusLabel.Text = "CANNOT GET POSITION!"
            fStatusLabel.TextColor3 = COLORS.red
            return
        end
        
        apartmentPosition = hrp.Position
        fullyLoopRunning = true
        
        startFullyButton.Text = "RUNNING..."
        startFullyButton.BackgroundColor3 = COLORS.accentDim
        fStatusLabel.Text = "RUNNING"
        fStatusLabel.TextColor3 = COLORS.green
        
        task.spawn(fullyLoop)
    end)
    
    stopFullyButton.MouseButton1Click:Connect(function()
        fullyLoopRunning = false
        startFullyButton.Text = "START FULLY"
        startFullyButton.BackgroundColor3 = COLORS.green
        fStatusLabel.Text = "STOPPED"
        fStatusLabel.TextColor3 = COLORS.red
    end)
    
    -- Build TP Tab (Teleport presets)
    local tpTab = tabFrames["TP"]
    
    createSection(tpTab, "TELEPORT LOCATIONS", 1)
    
    local tpButtons = {}
    local locationNames = {
        "NPC 1",
        "NPC 2",
        "Location 3",
        "Location 4",
        "Location 5",
        "Location 6",
        "Location 7",
        "Location 8",
        "Location 9",
        "Location 10",
        "Location 11",
        "Location 12",
        "Location 13"
    }
    
    for i, name in ipairs(locationNames) do
        local btn = createButton(tpTab, name, COLORS.accentDim, i + 1)
        btn.MouseButton1Click:Connect(function()
            if TELEPORT_POSITIONS[i] then
                teleportToPosition(TELEPORT_POSITIONS[i].pos)
            end
        end)
        tpButtons[i] = btn
    end
    
    -- Build MS POT Tab
    local msPotTab = tabFrames["MS POT"]
    
    createSection(msPotTab, "MS POT SETTINGS", 1)
    -- Add MS Pot settings here
    
    -- Build BUY Tab
    local buyTab = tabFrames["BUY"]
    
    createSection(buyTab, "BUY ITEMS", 1)
    -- Add Buy items UI here
    
    -- Build SELL Tab
    local sellTab = tabFrames["SELL"]
    
    createSection(sellTab, "SELL LOOP", 1)
    
    local sellStatusFrame = createCard(sellTab, 40, 2)
    local sellStatusLabel = Instance.new("TextLabel", sellStatusFrame)
    sellStatusLabel.Size = UDim2.new(1, -20, 1, 0)
    sellStatusLabel.Position = UDim2.new(0, 12, 0, 0)
    sellStatusLabel.BackgroundTransparency = 1
    sellStatusLabel.Text = "STOPPED"
    sellStatusLabel.Font = Enum.Font.GothamBold
    sellStatusLabel.TextSize = 13
    sellStatusLabel.TextColor3 = COLORS.red
    sellStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    sellStatusLabel.TextStrokeTransparency = 1
    
    local sellCountLabel = Instance.new("TextLabel", createCard(sellTab, 30, 3))
    sellCountLabel.Size = UDim2.new(1, -20, 1, 0)
    sellCountLabel.Position = UDim2.new(0, 12, 0, 0)
    sellCountLabel.BackgroundTransparency = 1
    sellCountLabel.Text = "Sold: 0 items"
    sellCountLabel.Font = Enum.Font.GothamBold
    sellCountLabel.TextSize = 12
    sellCountLabel.TextColor3 = COLORS.accentGlow
    sellCountLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local startSellButton = createButton(sellTab, "START SELL LOOP", COLORS.green, 4)
    local stopSellButton = createButton(sellTab, "STOP SELL LOOP", COLORS.red, 5)
    stopSellButton.Visible = false
    
    local sellCount = 0
    
    startSellButton.MouseButton1Click:Connect(function()
        if sellLoopRunning then return end
        
        sellLoopRunning = true
        sellCount = 0
        startSellButton.Text = "RUNNING..."
        startSellButton.BackgroundColor3 = COLORS.accentDim
        sellStatusLabel.Text = "RUNNING"
        sellStatusLabel.TextColor3 = COLORS.green
        sellCountLabel.Text = "Sold: 0 items"
        
        task.spawn(sellLoop)
    end)
    
    stopSellButton.MouseButton1Click:Connect(function()
        sellLoopRunning = false
        startSellButton.Text = "START SELL LOOP"
        startSellButton.BackgroundColor3 = COLORS.green
        sellStatusLabel.Text = "STOPPED"
        sellStatusLabel.TextColor3 = COLORS.red
    end)
    
    -- Build SETTINGS Tab
    local settingsTab = tabFrames["SETTINGS"]
    
    createSection(settingsTab, "SETTINGS", 1)
    
    -- Anti-AFK toggle
    local antiAfkFrame = createCard(settingsTab, 40, 2)
    local antiAfkLabel = Instance.new("TextLabel", antiAfkFrame)
    antiAfkLabel.Size = UDim2.new(0.6, -20, 1, 0)
    antiAfkLabel.Position = UDim2.new(0, 12, 0, 0)
    antiAfkLabel.BackgroundTransparency = 1
    antiAfkLabel.Text = "ANTI-AFK"
    antiAfkLabel.Font = Enum.Font.GothamSemibold
    antiAfkLabel.TextSize = 12
    antiAfkLabel.TextColor3 = COLORS.textMid
    antiAfkLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local antiAfkButton = createButton(antiAfkFrame, "ON", COLORS.green, 0)
    antiAfkButton.Size = UDim2.new(0, 80, 0, 30)
    antiAfkButton.Position = UDim2.new(0.7, 0, 0.5, -15)
    
    antiAfkButton.MouseButton1Click:Connect(function()
        antiAfkActive = not antiAfkActive
        if antiAfkActive then
            antiAfkButton.Text = "ON"
            antiAfkButton.BackgroundColor3 = COLORS.green
        else
            antiAfkButton.Text = "OFF"
            antiAfkButton.BackgroundColor3 = COLORS.red
        end
    end)
    
    -- Blink toggle
    local blinkFrame = createCard(settingsTab, 40, 3)
    local blinkLabel = Instance.new("TextLabel", blinkFrame)
    blinkLabel.Size = UDim2.new(0.6, -20, 1, 0)
    blinkLabel.Position = UDim2.new(0, 12, 0, 0)
    blinkLabel.BackgroundTransparency = 1
    blinkLabel.Text = "BLINK"
    blinkLabel.Font = Enum.Font.GothamSemibold
    blinkLabel.TextSize = 12
    blinkLabel.TextColor3 = COLORS.textMid
    blinkLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local blinkButton = createButton(blinkFrame, "ON", COLORS.green, 0)
    blinkButton.Size = UDim2.new(0, 80, 0, 30)
    blinkButton.Position = UDim2.new(0.7, 0, 0.5, -15)
    
    blinkButton.MouseButton1Click:Connect(function()
        blinkEnabled = not blinkEnabled
        if blinkEnabled then
            blinkButton.Text = "ON"
            blinkButton.BackgroundColor3 = COLORS.green
        else
            blinkButton.Text = "OFF"
            blinkButton.BackgroundColor3 = COLORS.red
        end
    end)
    
    -- Blink Forward button
    local blinkForwardButton = createButton(settingsTab, "BLINK FORWARD", COLORS.accentDim, 4)
    blinkForwardButton.MouseButton1Click:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end
        
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = hrp.CFrame + hrp.CFrame.LookVector * 8
        end
    end)
    
    -- Blink Backward button
    local blinkBackwardButton = createButton(settingsTab, "BLINK BACKWARD", COLORS.accentDim, 5)
    blinkBackwardButton.MouseButton1Click:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end
        
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = hrp.CFrame - hrp.CFrame.LookVector * 8
        end
    end)
    
    -- Jump Up button
    local jumpUpButton = createButton(settingsTab, "JUMP UP", COLORS.accentDim, 6)
    jumpUpButton.MouseButton1Click:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end
        
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = hrp.CFrame * CFrame.new(0, 5, 0)
        end
    end)
    
    -- Jump Down button
    local jumpDownButton = createButton(settingsTab, "JUMP DOWN", COLORS.accentDim, 7)
    jumpDownButton.MouseButton1Click:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end
        
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = hrp.CFrame * CFrame.new(0, -5, 0)
        end
    end)
    
    -- Delete Object button
    local deleteButton = createButton(settingsTab, "DELETE OBJECT", COLORS.red, 8)
    local undoDeleteButton = createButton(settingsTab, "UNDO DELETE", COLORS.accentDim, 9)
    
    local deletedObjects = {}
    
    deleteButton.MouseButton1Click:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end
        
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        local rayParams = RaycastParams.new()
        rayParams.FilterDescendantsInstances = {char}
        rayParams.FilterType = Enum.RaycastFilterType.Exclude
        
        local result = workspace:Raycast(hrp.Position, Vector3.new(0, -15, 0), rayParams)
        
        if result then
            local obj = result.Instance
            if obj then
                table.insert(deletedObjects, {
                    object = obj:Clone(),
                    parent = obj.Parent
                })
                obj:Destroy()
            end
        end
        
        task.wait(0.3)
    end)
    
    undoDeleteButton.MouseButton1Click:Connect(function()
        local data = table.remove(deletedObjects)
        if data then
            data.object.Parent = data.parent
        end
    end)
    
    -- Keyboard shortcuts
    -- Toggle UI with Insert key
    ContextActionService:BindAction("ToggleUI", function(actionName, inputState)
        if inputState == Enum.UserInputState.Begin then
            screenGui.Visible = not screenGui.Visible
        end
    end, false, Enum.KeyCode.Insert)
    
    -- Blink forward with B key
    ContextActionService:BindAction("BlinkForward", function(actionName, inputState)
        if inputState == Enum.UserInputState.Begin and blinkEnabled then
            local char = LocalPlayer.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.CFrame = hrp.CFrame + hrp.CFrame.LookVector * 8
                end
            end
        end
    end, false, Enum.KeyCode.B)
    
    -- Blink backward with V key
    ContextActionService:BindAction("BlinkBackward", function(actionName, inputState)
        if inputState == Enum.UserInputState.Begin and blinkEnabled then
            local char = LocalPlayer.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.CFrame = hrp.CFrame - hrp.CFrame.LookVector * 8
                end
            end
        end
    end, false, Enum.KeyCode.V)
    
    -- Auto-update counts
    task.spawn(function()
        while screenGui.Parent do
            if autoTab and autoTab.Visible then
                updateAutoMsCountsUI()
            end
            if fullyTab and fullyTab.Visible then
                updateFullyCountsUI()
            end
            task.wait(1)
        end
    end)
    
    -- Anti-AFK
    LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
    
    -- Character added handler
    LocalPlayer.CharacterAdded:Connect(function(char)
        task.wait(0.1)
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.Anchored = true
            hrp.CFrame = TARGET_CFRAME
            task.wait(0.05)
            hrp.Anchored = false
        end
    end)
    
    -- Switch to AUTO tab by default
    switchTab("AUTO")
    
    return screenGui
end

-- Initialize
createUI()