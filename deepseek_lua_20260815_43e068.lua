-- Script LENGER STORE
-- Clean version - No obfuscation

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")
local VirtualUser = game:GetService("VirtualUser")

local Player = Players.LocalPlayer
local Character = Player.Character
local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")

local StorePurchase = ReplicatedStorage:FindFirstChild("RemoteEvents") and ReplicatedStorage.RemoteEvents:FindFirstChild("StorePurchase")

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LENGER_STORE"
ScreenGui.Parent = Player:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Color Theme
local Colors = {
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

-- Main Frame
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 520, 0, 420)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -210)
MainFrame.BackgroundColor3 = Colors.bg
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = false

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 12)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Colors.border
MainStroke.Thickness = 1

-- Header
local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 46)
Header.BackgroundColor3 = Colors.surface
Header.ZIndex = 2

local HeaderCorner = Instance.new("UICorner", Header)
HeaderCorner.CornerRadius = UDim.new(0, 12)

local HeaderTitle = Instance.new("TextLabel", Header)
HeaderTitle.Position = UDim2.new(0, 28, 0, 0)
HeaderTitle.Size = UDim2.new(0, 160, 1, 0)
HeaderTitle.BackgroundTransparency = 1
HeaderTitle.Text = "LENGER STORE"
HeaderTitle.Font = Enum.Font.GothamBlack
HeaderTitle.TextSize = 15
HeaderTitle.TextColor3 = Colors.text
HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left

-- Close Button
local CloseButton = Instance.new("TextButton", Header)
CloseButton.Size = UDim2.new(0, 28, 0, 28)
CloseButton.Position = UDim2.new(1, -38, 0.5, -14)
CloseButton.BackgroundColor3 = Color3.fromRGB(50, 15, 22)
CloseButton.Text = "x"
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 12
CloseButton.TextColor3 = Colors.red
CloseButton.BorderSizePixel = 0

local CloseCorner = Instance.new("UICorner", CloseButton)
CloseCorner.CornerRadius = UDim.new(0, 6)

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Minimize Button
local MinimizeButton = Instance.new("TextButton", Header)
MinimizeButton.Size = UDim2.new(0, 28, 0, 28)
MinimizeButton.Position = UDim2.new(1, -72, 0.5, -14)
MinimizeButton.BackgroundColor3 = Colors.card
MinimizeButton.Text = "-"
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.TextSize = 14
MinimizeButton.TextColor3 = Colors.textMid
MinimizeButton.BorderSizePixel = 0

local MinimizeCorner = Instance.new("UICorner", MinimizeButton)
MinimizeCorner.CornerRadius = UDim.new(0, 6)

MinimizeButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Sidebar
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 70, 1, -46)
Sidebar.Position = UDim2.new(0, 0, 0, 46)
Sidebar.BackgroundColor3 = Colors.sidebar
Sidebar.ZIndex = 2
Sidebar.ClipsDescendants = false

local SidebarDivider = Instance.new("Frame", MainFrame)
SidebarDivider.Size = UDim2.new(0, 1, 1, -46)
SidebarDivider.Position = UDim2.new(0, 69, 0, 46)
SidebarDivider.BackgroundColor3 = Colors.border
SidebarDivider.BorderSizePixel = 0
SidebarDivider.ZIndex = 3

local SidebarLayout = Instance.new("UIListLayout", Sidebar)
SidebarLayout.Padding = UDim.new(0, 4)
SidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
SidebarLayout.VerticalAlignment = Enum.VerticalAlignment.Top
SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder

local SidebarPadding = Instance.new("UIPadding", Sidebar)
SidebarPadding.PaddingTop = UDim.new(0, 10)

-- Content
local Content = Instance.new("Frame", MainFrame)
Content.Size = UDim2.new(1, -70, 1, -46)
Content.Position = UDim2.new(0, 70, 0, 46)
Content.BackgroundColor3 = Colors.panel
Content.ClipsDescendants = true

-- Tab System
local Tabs = {}
local TabButtons = {}
local CurrentTab = "AUTO"

local function SwitchTab(tab)
    for name, content in pairs(Tabs) do
        content.Visible = (name == tab)
    end
    for name, button in pairs(TabButtons) do
        local indicator = button:FindFirstChild("Frame")
        if name == tab then
            button.BackgroundColor3 = Colors.accentDim
            button.BackgroundTransparency = 0
            button.TextColor3 = Colors.accentGlow
            if indicator then indicator.Visible = true end
        else
            button.BackgroundTransparency = 1
            button.TextColor3 = Colors.textDim
            if indicator then indicator.Visible = false end
        end
    end
    CurrentTab = tab
end

local function CreateTab(label, order)
    local Button = Instance.new("TextButton", Sidebar)
    Button.Size = UDim2.new(0, 62, 0, 36)
    Button.BackgroundTransparency = 1
    Button.Text = label
    Button.Font = Enum.Font.GothamBold
    Button.TextSize = 10
    Button.TextColor3 = Colors.textDim
    Button.BorderSizePixel = 0
    Button.LayoutOrder = order
    Button.TextStrokeTransparency = 1

    local ButtonCorner = Instance.new("UICorner", Button)
    ButtonCorner.CornerRadius = UDim.new(0, 7)

    local Indicator = Instance.new("Frame", Button)
    Indicator.Size = UDim2.new(0, 2, 0, 18)
    Indicator.Position = UDim2.new(0, 0, 0.5, -9)
    Indicator.BackgroundColor3 = Colors.accent
    Indicator.BorderSizePixel = 0
    Indicator.Visible = false

    local IndicatorCorner = Instance.new("UICorner", Indicator)
    IndicatorCorner.CornerRadius = UDim.new(0, 2)

    local TabContent = Instance.new("ScrollingFrame", Content)
    TabContent.Size = UDim2.new(1, 0, 1, 0)
    TabContent.BackgroundTransparency = 1
    TabContent.ScrollBarThickness = 3
    TabContent.ScrollBarImageColor3 = Colors.accentSoft
    TabContent.Visible = false
    TabContent.BorderSizePixel = 0

    local TabLayout = Instance.new("UIListLayout", TabContent)
    TabLayout.Padding = UDim.new(0, 6)
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local TabPadding = Instance.new("UIPadding", TabContent)
    TabPadding.PaddingTop = UDim.new(0, 12)
    TabPadding.PaddingLeft = UDim.new(0, 10)
    TabPadding.PaddingRight = UDim.new(0, 10)
    TabPadding.PaddingBottom = UDim.new(0, 12)

    Tabs[label] = TabContent
    TabButtons[label] = Button

    Button.MouseButton1Click:Connect(function()
        SwitchTab(label)
    end)

    return Button, TabContent
end

-- UI Helpers
local function AddLabel(parent, text, order)
    local Frame = Instance.new("Frame", parent)
    Frame.Size = UDim2.new(1, 0, 0, 22)
    Frame.BackgroundTransparency = 1
    Frame.LayoutOrder = order or 0

    local Label = Instance.new("TextLabel", Frame)
    Label.Size = UDim2.new(1, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = string.upper(text)
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 9
    Label.TextColor3 = Colors.textDim
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.TextStrokeTransparency = 1

    local Divider = Instance.new("Frame", Frame)
    Divider.Size = UDim2.new(1, 0, 0, 1)
    Divider.Position = UDim2.new(0, 0, 1, -1)
    Divider.BackgroundColor3 = Colors.border
    Divider.BorderSizePixel = 0

    return Frame
end

local function AddStat(parent, label, order)
    local Frame = Instance.new("Frame", parent)
    Frame.Size = UDim2.new(1, 0, 0, 30)
    Frame.BackgroundColor3 = Colors.card
    Frame.BorderSizePixel = 0
    Frame.LayoutOrder = order or 0

    local Corner = Instance.new("UICorner", Frame)
    Corner.CornerRadius = UDim.new(0, 8)

    local Label = Instance.new("TextLabel", Frame)
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.Size = UDim2.new(0.6, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = label
    Label.Font = Enum.Font.GothamSemibold
    Label.TextSize = 11
    Label.TextColor3 = Colors.textMid
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.TextStrokeTransparency = 1

    local Value = Instance.new("TextLabel", Frame)
    Value.Position = UDim2.new(0.6, 0, 0, 0)
    Value.Size = UDim2.new(0.4, -10, 1, 0)
    Value.BackgroundTransparency = 1
    Value.Text = "0"
    Value.Font = Enum.Font.GothamBold
    Value.TextSize = 12
    Value.TextColor3 = Colors.accentGlow
    Value.TextXAlignment = Enum.TextXAlignment.Right
    Value.TextStrokeTransparency = 1

    return Value
end

local function AddButton(parent, text, bgColor, order)
    local Button = Instance.new("TextButton", parent)
    Button.Size = UDim2.new(1, 0, 0, 36)
    Button.BackgroundColor3 = bgColor or Colors.accentDim
    Button.Font = Enum.Font.GothamBold
    Button.TextSize = 12
    Button.TextColor3 = Colors.text
    Button.Text = text
    Button.BorderSizePixel = 0
    Button.LayoutOrder = order or 0
    Button.TextStrokeTransparency = 1

    local Corner = Instance.new("UICorner", Button)
    Corner.CornerRadius = UDim.new(0, 8)

    Button.MouseEnter:Connect(function()
        local tween = TweenService:Create(Button, TweenInfo.new(0.12), {
            BackgroundColor3 = Colors.accent
        })
        tween:Play()
    end)

    Button.MouseLeave:Connect(function()
        local tween = TweenService:Create(Button, TweenInfo.new(0.12), {
            BackgroundColor3 = bgColor or Colors.accentDim
        })
        tween:Play()
    end)

    return Button
end

local function AddCard(parent, height, order)
    local Frame = Instance.new("Frame", parent)
    Frame.Size = UDim2.new(1, 0, 0, height or 46)
    Frame.BackgroundColor3 = Colors.card
    Frame.BorderSizePixel = 0
    Frame.LayoutOrder = order or 0

    local Corner = Instance.new("UICorner", Frame)
    Corner.CornerRadius = UDim.new(0, 8)

    return Frame
end

local function AddSlider(parent, label, min, max, default, order, callback)
    local Frame = AddCard(parent, 54, order)

    local Label = Instance.new("TextLabel", Frame)
    Label.Position = UDim2.new(0, 12, 0, 8)
    Label.Size = UDim2.new(1, -80, 0, 16)
    Label.BackgroundTransparency = 1
    Label.Text = label
    Label.Font = Enum.Font.GothamSemibold
    Label.TextSize = 11
    Label.TextColor3 = Colors.textMid
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.TextStrokeTransparency = 1

    local Value = Instance.new("TextLabel", Frame)
    Value.Position = UDim2.new(1, -52, 0, 8)
    Value.Size = UDim2.new(0, 42, 0, 16)
    Value.BackgroundTransparency = 1
    Value.Text = tostring(default)
    Value.Font = Enum.Font.GothamBold
    Value.TextSize = 12
    Value.TextColor3 = Colors.accentGlow
    Value.TextXAlignment = Enum.TextXAlignment.Right
    Value.TextStrokeTransparency = 1

    local Track = Instance.new("Frame", Frame)
    Track.Position = UDim2.new(0, 12, 0, 34)
    Track.Size = UDim2.new(1, -24, 0, 5)
    Track.BackgroundColor3 = Colors.border
    Track.BorderSizePixel = 0
    Track.Active = true

    local TrackCorner = Instance.new("UICorner", Track)
    TrackCorner.CornerRadius = UDim.new(1, 0)

    local Fill = Instance.new("Frame", Track)
    Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Colors.accent
    Fill.BorderSizePixel = 0

    local FillCorner = Instance.new("UICorner", Fill)
    FillCorner.CornerRadius = UDim.new(1, 0)

    local Handle = Instance.new("Frame", Track)
    Handle.Size = UDim2.new(0, 14, 0, 14)
    Handle.Position = UDim2.new((default - min) / (max - min), -7, 0.5, -7)
    Handle.BackgroundColor3 = Color3.new(1, 1, 1)
    Handle.BorderSizePixel = 0

    local HandleCorner = Instance.new("UICorner", Handle)
    HandleCorner.CornerRadius = UDim.new(1, 0)

    local HandleStroke = Instance.new("UIStroke", Handle)
    HandleStroke.Color = Colors.accent
    HandleStroke.Thickness = 2

    local dragging = false

    local function UpdateSlider(mouseX)
        local pos = math.clamp((mouseX - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
        local value = math.floor(min + pos * (max - min))
        Handle.Position = UDim2.new(pos, -7, 0.5, -7)
        Fill.Size = UDim2.new(pos, 0, 1, 0)
        Value.Text = tostring(value)
        if callback then callback(value) end
    end

    Track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            UpdateSlider(input.Position.X)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            UpdateSlider(input.Position.X)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    return Frame, Value
end

-- Helper Functions
local function CountItem(itemName)
    local count = 0
    local backpack = Player.Backpack
    if backpack then
        for _, child in pairs(backpack:GetChildren()) do
            if child.Name == itemName then
                count = count + 1
            end
        end
    end
    local character = Player.Character
    if character then
        for _, child in pairs(character:GetChildren()) do
            if child:IsA("Tool") and child.Name == itemName then
                count = count + 1
            end
        end
    end
    return count
end

local function EquipTool(toolName)
    local character = Player.Character
    local backpack = Player.Backpack
    local tool = backpack and backpack:FindFirstChild(toolName)
    if not tool then
        tool = character and character:FindFirstChild(toolName)
    end
    if tool and character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:EquipTool(tool)
            task.wait(0.3)
            return true
        end
    end
    return false
end

local function SendKey(key, hold)
    VirtualInputManager:SendKeyEvent(true, key, false, game)
    task.wait(hold or 0.7)
    VirtualInputManager:SendKeyEvent(false, key, false, game)
end

-- Auto Loop Function
local function AutoLoop()
    while Running do
        -- Update stats
        WaterStat.Text = tostring(CountItem("Water"))
        SugarStat.Text = tostring(CountItem("Sugar Block Bag"))
        GelatinStat.Text = tostring(CountItem("Gelatin"))
        EmptyBagStat.Text = tostring(CountItem("Empty Bag"))

        StatusText.Text = "COOKING..."
        
        -- Cook Water
        if Running then
            EquipTool("Water")
            SendKey("E", 0.7)
            task.wait(20)
        end
        
        -- Cook Sugar
        if Running then
            EquipTool("Sugar Block Bag")
            SendKey("E", 0.7)
            task.wait(1)
        end
        
        -- Cook Gelatin
        if Running then
            EquipTool("Gelatin")
            SendKey("E", 0.7)
            task.wait(1)
            task.wait(45)
        end
        
        -- Empty Bag
        if Running then
            EquipTool("Empty Bag")
            SendKey("E", 0.7)
            task.wait(1)
        end
        
        -- Update stats after loop
        WaterStat.Text = tostring(CountItem("Water"))
        SugarStat.Text = tostring(CountItem("Sugar Block Bag"))
        GelatinStat.Text = tostring(CountItem("Gelatin"))
        EmptyBagStat.Text = tostring(CountItem("Empty Bag"))
        
        task.wait(2)
    end
    StatusText.Text = "STOPPED"
end

-- Create Tabs
CreateTab("AUTO", 1)
CreateTab("FULLY", 2)
CreateTab("MS POT", 3)
CreateTab("BUY", 4)
CreateTab("SETTINGS", 5)

-- AUTO TAB
local AutoTab = Tabs["AUTO"]

AddLabel(AutoTab, "MS LOOP AUTO COOK", 1)

WaterStat = AddStat(AutoTab, "Water", 2)
SugarStat = AddStat(AutoTab, "Sugar Block Bag", 3)
GelatinStat = AddStat(AutoTab, "Gelatin", 4)
EmptyBagStat = AddStat(AutoTab, "Empty Bag", 5)

AddLabel(AutoTab, "CONTROL", 6)

StatusFrame = AddCard(AutoTab, 40, 7)
StatusText = Instance.new("TextLabel", StatusFrame)
StatusText.Size = UDim2.new(1, -20, 1, 0)
StatusText.Position = UDim2.new(0, 12, 0, 0)
StatusText.BackgroundTransparency = 1
StatusText.Text = "STOPPED"
StatusText.Font = Enum.Font.GothamBold
StatusText.TextSize = 13
StatusText.TextColor3 = Colors.red
StatusText.TextXAlignment = Enum.TextXAlignment.Left
StatusText.TextStrokeTransparency = 1

local StartButton = AddButton(AutoTab, "START MS LOOP", Colors.green, 8)
local Running = false

StartButton.MouseButton1Click:Connect(function()
    if not Running then
        Running = true
        StartButton.Text = "STOP MS LOOP"
        StartButton.BackgroundColor3 = Colors.red
        StatusText.Text = "RUNNING"
        StatusText.TextColor3 = Colors.green
        task.spawn(AutoLoop)
    else
        Running = false
        StartButton.Text = "START MS LOOP"
        StartButton.BackgroundColor3 = Colors.green
        StatusText.Text = "STOPPED"
        StatusText.TextColor3 = Colors.red
    end
end)

-- FULLY TAB
local FullyTab = Tabs["FULLY"]

AddLabel(FullyTab, "AUTO FULLY", 1)

local FullyWaterStat = AddStat(FullyTab, "Water", 2)
local FullySugarStat = AddStat(FullyTab, "Sugar Block Bag", 3)
local FullyGelatinStat = AddStat(FullyTab, "Gelatin", 4)
local FullyEmptyStat = AddStat(FullyTab, "Empty Bag", 5)

AddLabel(FullyTab, "SETTING", 6)

local TargetFully = 5
local SliderFrame, SliderValue = AddSlider(FullyTab, "TARGET FULLY", 1, 50, 5, 7, function(value)
    TargetFully = value
end)

local FullyStatusFrame = AddCard(FullyTab, 40, 8)
local FullyStatusText = Instance.new("TextLabel", FullyStatusFrame)
FullyStatusText.Size = UDim2.new(1, -20, 1, 0)
FullyStatusText.Position = UDim2.new(0, 12, 0, 0)
FullyStatusText.BackgroundTransparency = 1
FullyStatusText.Text = "STOPPED"
FullyStatusText.Font = Enum.Font.GothamBold
FullyStatusText.TextSize = 13
FullyStatusText.TextColor3 = Colors.red
FullyStatusText.TextXAlignment = Enum.TextXAlignment.Left
FullyStatusText.TextStrokeTransparency = 1

local FullyStartButton = AddButton(FullyTab, "START FULLY", Colors.green, 9)
local FullyRunning = false
local CurrentFullyCount = 0

-- Fully Loop Function
local function FullyLoop()
    local items = {"Water", "Sugar Block Bag", "Gelatin", "Empty Bag"}
    
    while FullyRunning do
        -- Update stats
        FullyWaterStat.Text = tostring(CountItem("Water"))
        FullySugarStat.Text = tostring(CountItem("Sugar Block Bag"))
        FullyGelatinStat.Text = tostring(CountItem("Gelatin"))
        FullyEmptyStat.Text = tostring(CountItem("Empty Bag"))
        
        FullyStatusText.Text = "RUNNING..."
        FullyStatusText.TextColor3 = Colors.green
        
        -- Cook items
        for _, itemName in ipairs(items) do
            if not FullyRunning then break end
            if itemName == "Empty Bag" then
                -- Sell items
                FullyStatusText.Text = "SELLING..."
                FullyStatusText.TextColor3 = Colors.accentGlow
                if StorePurchase then
                    for _, sellItem in ipairs({"Water", "Sugar Block Bag", "Gelatin"}) do
                        if not FullyRunning then break end
                        StorePurchase:FireServer(sellItem, 1)
                        task.wait(0.4)
                    end
                end
                FullyStatusText.Text = "SELL COMPLETE!"
                FullyStatusText.TextColor3 = Colors.green
                task.wait(1)
            else
                FullyStatusText.Text = "COOKING " .. itemName
                FullyStatusText.TextColor3 = Colors.accentGlow
                EquipTool(itemName)
                SendKey("E", 0.7)
                task.wait(1)
            end
        end
        
        CurrentFullyCount = CurrentFullyCount + 1
        FullyStatusText.Text = "LOOP " .. CurrentFullyCount .. "/" .. TargetFully
        FullyStatusText.TextColor3 = Colors.accentGlow
        task.wait(2)
        
        if CurrentFullyCount >= TargetFully then
            FullyRunning = false
            FullyStartButton.Text = "START FULLY"
            FullyStartButton.BackgroundColor3 = Colors.green
            FullyStatusText.Text = "COMPLETE!"
            FullyStatusText.TextColor3 = Colors.green
            task.wait(2)
            FullyStatusText.Text = "STOPPED"
            FullyStatusText.TextColor3 = Colors.red
            CurrentFullyCount = 0
        end
    end
end

FullyStartButton.MouseButton1Click:Connect(function()
    if not FullyRunning then
        FullyRunning = true
        CurrentFullyCount = 0
        FullyStartButton.Text = "RUNNING..."
        FullyStartButton.BackgroundColor3 = Colors.accentDim
        task.spawn(FullyLoop)
    else
        FullyRunning = false
        FullyStartButton.Text = "START FULLY"
        FullyStartButton.BackgroundColor3 = Colors.green
        FullyStatusText.Text = "STOPPED"
        FullyStatusText.TextColor3 = Colors.red
        CurrentFullyCount = 0
    end
end)

-- MS POT TAB
local MSPotTab = Tabs["MS POT"]

AddLabel(MSPotTab, "MS POT SELLER", 1)

local MSPotStatusFrame = AddCard(MSPotTab, 40, 2)
local MSPotStatusText = Instance.new("TextLabel", MSPotStatusFrame)
MSPotStatusText.Size = UDim2.new(1, -20, 1, 0)
MSPotStatusText.Position = UDim2.new(0, 12, 0, 0)
MSPotStatusText.BackgroundTransparency = 1
MSPotStatusText.Text = "STOPPED"
MSPotStatusText.Font = Enum.Font.GothamBold
MSPotStatusText.TextSize = 13
MSPotStatusText.TextColor3 = Colors.red
MSPotStatusText.TextXAlignment = Enum.TextXAlignment.Left
MSPotStatusText.TextStrokeTransparency = 1

local MSPotCountLabel = Instance.new("TextLabel", MSPotStatusFrame)
MSPotCountLabel.Size = UDim2.new(1, -20, 0, 16)
MSPotCountLabel.Position = UDim2.new(0, 12, 0, 20)
MSPotCountLabel.BackgroundTransparency = 1
MSPotCountLabel.Text = "Sold: 0"
MSPotCountLabel.Font = Enum.Font.GothamSemibold
MSPotCountLabel.TextSize = 11
MSPotCountLabel.TextColor3 = Colors.textMid
MSPotCountLabel.TextXAlignment = Enum.TextXAlignment.Left
MSPotCountLabel.TextStrokeTransparency = 1

local MSPotStartButton = AddButton(MSPotTab, "START SELL", Colors.green, 3)
local MSPotRunning = false
local MSPotCount = 0

local function MSPotLoop()
    local potItems = {
        "Small Marshmallow Bag",
        "Medium Marshmallow Bag",
        "Large Marshmallow Bag"
    }
    
    while MSPotRunning do
        local foundItems = {}
        
        -- Find items in backpack
        local backpack = Player.Backpack
        if backpack then
            for _, child in pairs(backpack:GetChildren()) do
                if child:IsA("Tool") then
                    for _, name in ipairs(potItems) do
                        if child.Name == name then
                            table.insert(foundItems, child)
                        end
                    end
                end
            end
        end
        
        -- Find items in character
        local character = Player.Character
        if character then
            for _, child in pairs(character:GetChildren()) do
                if child:IsA("Tool") then
                    for _, name in ipairs(potItems) do
                        if child.Name == name then
                            table.insert(foundItems, child)
                        end
                    end
                end
            end
        end
        
        if #foundItems > 0 then
            for _, tool in ipairs(foundItems) do
                if not MSPotRunning then break end
                
                -- Equip tool if in backpack
                if tool.Parent == Player.Backpack then
                    local humanoid = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        humanoid:EquipTool(tool)
                        task.wait(0.3)
                    end
                end
                
                MSPotStatusText.Text = "SELLING..."
                MSPotStatusText.TextColor3 = Colors.accentGlow
                
                -- Send E key to sell
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                task.wait(0.5)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                
                MSPotCount = MSPotCount + 1
                MSPotCountLabel.Text = "Sold: " .. MSPotCount
                task.wait(1)
            end
        else
            MSPotStatusText.Text = "NO ITEMS FOUND"
            MSPotStatusText.TextColor3 = Colors.red
            task.wait(2)
        end
    end
    
    MSPotStatusText.Text = "STOPPED"
    MSPotStatusText.TextColor3 = Colors.red
    MSPotStartButton.Text = "START SELL"
    MSPotStartButton.BackgroundColor3 = Colors.green
end

MSPotStartButton.MouseButton1Click:Connect(function()
    if not MSPotRunning then
        MSPotRunning = true
        MSPotCount = 0
        MSPotStartButton.Text = "STOP SELL"
        MSPotStartButton.BackgroundColor3 = Colors.red
        MSPotStatusText.Text = "RUNNING"
        MSPotStatusText.TextColor3 = Colors.green
        task.spawn(MSPotLoop)
    else
        MSPotRunning = false
        MSPotStartButton.Text = "START SELL"
        MSPotStartButton.BackgroundColor3 = Colors.green
        MSPotStatusText.Text = "STOPPED"
        MSPotStatusText.TextColor3 = Colors.red
    end
end)

-- BUY TAB
local BuyTab = Tabs["BUY"]

AddLabel(BuyTab, "BUY ITEMS", 1)

local BuyStatusFrame = AddCard(BuyTab, 40, 2)
local BuyStatusText = Instance.new("TextLabel", BuyStatusFrame)
BuyStatusText.Size = UDim2.new(1, -20, 1, 0)
BuyStatusText.Position = UDim2.new(0, 12, 0, 0)
BuyStatusText.BackgroundTransparency = 1
BuyStatusText.Text = "READY"
BuyStatusText.Font = Enum.Font.GothamBold
BuyStatusText.TextSize = 13
BuyStatusText.TextColor3 = Colors.textMid
BuyStatusText.TextXAlignment = Enum.TextXAlignment.Left
BuyStatusText.TextStrokeTransparency = 1

local BuyAmountSlider, BuyAmountValue = AddSlider(BuyTab, "BUY AMOUNT", 1, 100, 10, 3)

local BuyStartButton = AddButton(BuyTab, "BUY ITEMS", Colors.accent, 4)
local BuyRunning = false

local function BuyLoop()
    local items = {"Water", "Sugar Block Bag", "Gelatin", "Empty Bag"}
    local amount = tonumber(BuyAmountValue.Text) or 10
    
    BuyStatusText.Text = "BUYING..."
    BuyStatusText.TextColor3 = Colors.accentGlow
    
    for _, itemName in ipairs(items) do
        if not BuyRunning then break end
        
        BuyStatusText.Text = "BUYING " .. itemName .. " x" .. amount
        for i = 1, amount do
            if not BuyRunning then break end
            if StorePurchase then
                StorePurchase:FireServer(itemName, 1)
                task.wait(0.4)
            end
        end
        task.wait(0.5)
    end
    
    BuyStatusText.Text = "PURCHASE COMPLETE!"
    BuyStatusText.TextColor3 = Colors.green
    task.wait(2)
    BuyStatusText.Text = "READY"
    BuyStatusText.TextColor3 = Colors.textMid
    BuyStartButton.Text = "BUY ITEMS"
    BuyStartButton.BackgroundColor3 = Colors.accent
    BuyRunning = false
end

BuyStartButton.MouseButton1Click:Connect(function()
    if not BuyRunning then
        BuyRunning = true
        BuyStartButton.Text = "BUYING..."
        BuyStartButton.BackgroundColor3 = Colors.accentDim
        task.spawn(BuyLoop)
    else
        BuyRunning = false
        BuyStartButton.Text = "BUY ITEMS"
        BuyStartButton.BackgroundColor3 = Colors.accent
        BuyStatusText.Text = "STOPPED"
        BuyStatusText.TextColor3 = Colors.red
        task.wait(1)
        BuyStatusText.Text = "READY"
        BuyStatusText.TextColor3 = Colors.textMid
    end
end)

-- SETTINGS TAB
local SettingsTab = Tabs["SETTINGS"]

AddLabel(SettingsTab, "SETTINGS", 1)

-- Auto AFK
local AutoAFKFrame = AddCard(SettingsTab, 50, 2)
local AutoAFKLabel = Instance.new("TextLabel", AutoAFKFrame)
AutoAFKLabel.Position = UDim2.new(0, 12, 0, 0)
AutoAFKLabel.Size = UDim2.new(0.6, 0, 1, 0)
AutoAFKLabel.BackgroundTransparency = 1
AutoAFKLabel.Text = "AUTO AFK"
AutoAFKLabel.Font = Enum.Font.GothamSemibold
AutoAFKLabel.TextSize = 11
AutoAFKLabel.TextColor3 = Colors.textMid
AutoAFKLabel.TextXAlignment = Enum.TextXAlignment.Left
AutoAFKLabel.TextStrokeTransparency = 1

local AutoAFKToggle = Instance.new("TextButton", AutoAFKFrame)
AutoAFKToggle.Size = UDim2.new(0, 50, 0, 26)
AutoAFKToggle.Position = UDim2.new(1, -62, 0.5, -13)
AutoAFKToggle.BackgroundColor3 = Colors.green
AutoAFKToggle.Text = "ON"
AutoAFKToggle.Font = Enum.Font.GothamBold
AutoAFKToggle.TextSize = 10
AutoAFKToggle.TextColor3 = Colors.text
AutoAFKToggle.BorderSizePixel = 0
AutoAFKToggle.TextStrokeTransparency = 1

local AutoAFKCorner = Instance.new("UICorner", AutoAFKToggle)
AutoAFKCorner.CornerRadius = UDim.new(0, 6)

local AFKEnabled = true

AutoAFKToggle.MouseButton1Click:Connect(function()
    AFKEnabled = not AFKEnabled
    if AFKEnabled then
        AutoAFKToggle.BackgroundColor3 = Colors.green
        AutoAFKToggle.Text = "ON"
    else
        AutoAFKToggle.BackgroundColor3 = Colors.red
        AutoAFKToggle.Text = "OFF"
    end
end)

-- Auto AFK Handler
Player.Idled:Connect(function()
    if AFKEnabled then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

-- Auto Update Stats
task.spawn(function()
    while true do
        task.wait(1)
        if Tabs["AUTO"] and Tabs["AUTO"].Visible then
            if WaterStat and SugarStat and GelatinStat and EmptyBagStat then
                WaterStat.Text = tostring(CountItem("Water"))
                SugarStat.Text = tostring(CountItem("Sugar Block Bag"))
                GelatinStat.Text = tostring(CountItem("Gelatin"))
                EmptyBagStat.Text = tostring(CountItem("Empty Bag"))
            end
        end
        if Tabs["FULLY"] and Tabs["FULLY"].Visible then
            if FullyWaterStat and FullySugarStat and FullyGelatinStat and FullyEmptyStat then
                FullyWaterStat.Text = tostring(CountItem("Water"))
                FullySugarStat.Text = tostring(CountItem("Sugar Block Bag"))
                FullyGelatinStat.Text = tostring(CountItem("Gelatin"))
                FullyEmptyStat.Text = tostring(CountItem("Empty Bag"))
            end
        end
    end
end)

-- Switch to default tab
SwitchTab("AUTO")

-- Keybind to toggle GUI
ContextActionService:BindAction("ToggleGUI", function(actionName, inputState)
    if inputState == Enum.UserInputState.Begin then
        MainFrame.Visible = not MainFrame.Visible
    end
end, false, Enum.KeyCode.LeftControl)

-- Minimize on start
MainFrame.Size = UDim2.new(0, 520, 0, 46)

-- Minimize button functionality
MinimizeButton.MouseButton1Click:Connect(function()
    if MainFrame.Size.Y.Offset == 46 then
        local tween = TweenService:Create(MainFrame, TweenInfo.new(0.22, Enum.EasingStyle.Quint), {
            Size = UDim2.new(0, 520, 0, 420)
        })
        tween:Play()
    else
        local tween = TweenService:Create(MainFrame, TweenInfo.new(0.22, Enum.EasingStyle.Quint), {
            Size = UDim2.new(0, 520, 0, 46)
        })
        tween:Play()
    end
end)

print("LENGER STORE loaded successfully!")