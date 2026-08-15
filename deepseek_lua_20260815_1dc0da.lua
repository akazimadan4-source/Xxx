-- LENGER STORE v2
-- Clean version by request

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")
local VirtualUser = game:GetService("VirtualUser")

local Player = Players.LocalPlayer
local StorePurchase = ReplicatedStorage:FindFirstChild("RemoteEvents") and ReplicatedStorage.RemoteEvents:FindFirstChild("StorePurchase")

-- Warna
local Colors = {
    bg = Color3.fromRGB(8, 8, 16),
    surface = Color3.fromRGB(13, 13, 22),
    panel = Color3.fromRGB(18, 18, 28),
    card = Color3.fromRGB(22, 22, 36),
    sidebar = Color3.fromRGB(10, 10, 20),
    accent = Color3.fromRGB(0, 110, 220),
    accentDim = Color3.fromRGB(0, 70, 150),
    accentGlow = Color3.fromRGB(50, 150, 255),
    text = Color3.fromRGB(230, 235, 255),
    textMid = Color3.fromRGB(150, 160, 200),
    textDim = Color3.fromRGB(80, 85, 120),
    green = Color3.fromRGB(40, 200, 100),
    red = Color3.fromRGB(220, 60, 70),
    border = Color3.fromRGB(40, 45, 65)
}

-- Buat GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LENGER_STORE"
ScreenGui.Parent = Player.PlayerGui
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global

-- Main Frame
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 520, 0, 420)
Main.Position = UDim2.new(0.5, -260, 0.5, -210)
Main.BackgroundColor3 = Colors.bg
Main.Active = true
Main.Draggable = true

local MainCorner = Instance.new("UICorner", Main)
MainCorner.CornerRadius = UDim.new(0, 12)

local MainStroke = Instance.new("UIStroke", Main)
MainStroke.Color = Colors.border
MainStroke.Thickness = 1

-- Header
local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 46)
Header.BackgroundColor3 = Colors.surface

local HeaderCorner = Instance.new("UICorner", Header)
HeaderCorner.CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel", Header)
Title.Position = UDim2.new(0, 28, 0, 0)
Title.Size = UDim2.new(0, 200, 1, 0)
Title.BackgroundTransparency = 1
Title.Text = "LENGER STORE"
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 15
Title.TextColor3 = Colors.text
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Close Button
local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -38, 0.5, -14)
CloseBtn.BackgroundColor3 = Color3.fromRGB(50, 15, 22)
CloseBtn.Text = "x"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 12
CloseBtn.TextColor3 = Colors.red
CloseBtn.BorderSizePixel = 0

local CloseCorner = Instance.new("UICorner", CloseBtn)
CloseCorner.CornerRadius = UDim.new(0, 6)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Minimize Button
local MinBtn = Instance.new("TextButton", Header)
MinBtn.Size = UDim2.new(0, 28, 0, 28)
MinBtn.Position = UDim2.new(1, -72, 0.5, -14)
MinBtn.BackgroundColor3 = Colors.card
MinBtn.Text = "-"
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 14
MinBtn.TextColor3 = Colors.textMid
MinBtn.BorderSizePixel = 0

local MinCorner = Instance.new("UICorner", MinBtn)
MinCorner.CornerRadius = UDim.new(0, 6)

local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        local t = TweenService:Create(Main, TweenInfo.new(0.22, Enum.EasingStyle.Quint), {
            Size = UDim2.new(0, 520, 0, 46)
        })
        t:Play()
    else
        local t = TweenService:Create(Main, TweenInfo.new(0.22, Enum.EasingStyle.Quint), {
            Size = UDim2.new(0, 520, 0, 420)
        })
        t:Play()
    end
end)

-- Sidebar
local Sidebar = Instance.new("Frame", Main)
Sidebar.Size = UDim2.new(0, 70, 1, -46)
Sidebar.Position = UDim2.new(0, 0, 0, 46)
Sidebar.BackgroundColor3 = Colors.sidebar

local SidebarDiv = Instance.new("Frame", Main)
SidebarDiv.Size = UDim2.new(0, 1, 1, -46)
SidebarDiv.Position = UDim2.new(0, 69, 0, 46)
SidebarDiv.BackgroundColor3 = Colors.border
SidebarDiv.BorderSizePixel = 0

local SidebarLayout = Instance.new("UIListLayout", Sidebar)
SidebarLayout.Padding = UDim.new(0, 4)
SidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
SidebarLayout.VerticalAlignment = Enum.VerticalAlignment.Top
SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder

local SidebarPad = Instance.new("UIPadding", Sidebar)
SidebarPad.PaddingTop = UDim.new(0, 10)

-- Content
local Content = Instance.new("Frame", Main)
Content.Size = UDim2.new(1, -70, 1, -46)
Content.Position = UDim2.new(0, 70, 0, 46)
Content.BackgroundColor3 = Colors.panel
Content.ClipsDescendants = true

-- Tab system
local Tabs = {}
local TabBtns = {}

local function SwitchTab(tab)
    for name, frame in pairs(Tabs) do
        frame.Visible = (name == tab)
    end
    for name, btn in pairs(TabBtns) do
        local ind = btn:FindFirstChild("Indicator")
        if name == tab then
            btn.BackgroundColor3 = Colors.accentDim
            btn.BackgroundTransparency = 0
            btn.TextColor3 = Colors.accentGlow
            if ind then ind.Visible = true end
        else
            btn.BackgroundTransparency = 1
            btn.TextColor3 = Colors.textDim
            if ind then ind.Visible = false end
        end
    end
end

local function CreateTab(name, order)
    local btn = Instance.new("TextButton", Sidebar)
    btn.Size = UDim2.new(0, 62, 0, 36)
    btn.BackgroundTransparency = 1
    btn.Text = name
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 10
    btn.TextColor3 = Colors.textDim
    btn.BorderSizePixel = 0
    btn.LayoutOrder = order
    btn.TextStrokeTransparency = 1

    local bcorner = Instance.new("UICorner", btn)
    bcorner.CornerRadius = UDim.new(0, 7)

    local ind = Instance.new("Frame", btn)
    ind.Name = "Indicator"
    ind.Size = UDim2.new(0, 2, 0, 18)
    ind.Position = UDim2.new(0, 0, 0.5, -9)
    ind.BackgroundColor3 = Colors.accent
    ind.BorderSizePixel = 0
    ind.Visible = false

    local icorner = Instance.new("UICorner", ind)
    icorner.CornerRadius = UDim.new(0, 2)

    local frame = Instance.new("ScrollingFrame", Content)
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    frame.ScrollBarThickness = 3
    frame.ScrollBarImageColor3 = Colors.accentSoft
    frame.Visible = false
    frame.BorderSizePixel = 0

    local layout = Instance.new("UIListLayout", frame)
    layout.Padding = UDim.new(0, 6)
    layout.SortOrder = Enum.SortOrder.LayoutOrder

    local pad = Instance.new("UIPadding", frame)
    pad.PaddingTop = UDim.new(0, 12)
    pad.PaddingLeft = UDim.new(0, 10)
    pad.PaddingRight = UDim.new(0, 10)
    pad.PaddingBottom = UDim.new(0, 12)

    Tabs[name] = frame
    TabBtns[name] = btn

    btn.MouseButton1Click:Connect(function()
        SwitchTab(name)
    end)

    return btn, frame
end

-- Helper functions
local function AddLabel(parent, text, order)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(1, 0, 0, 22)
    f.BackgroundTransparency = 1
    f.LayoutOrder = order or 0

    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(1, 0, 1, 0)
    l.BackgroundTransparency = 1
    l.Text = string.upper(text)
    l.Font = Enum.Font.GothamBold
    l.TextSize = 9
    l.TextColor3 = Colors.textDim
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextStrokeTransparency = 1

    local d = Instance.new("Frame", f)
    d.Size = UDim2.new(1, 0, 0, 1)
    d.Position = UDim2.new(0, 0, 1, -1)
    d.BackgroundColor3 = Colors.border
    d.BorderSizePixel = 0

    return f
end

local function AddStat(parent, label, order)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(1, 0, 0, 30)
    f.BackgroundColor3 = Colors.card
    f.BorderSizePixel = 0
    f.LayoutOrder = order or 0

    local c = Instance.new("UICorner", f)
    c.CornerRadius = UDim.new(0, 8)

    local l = Instance.new("TextLabel", f)
    l.Position = UDim2.new(0, 12, 0, 0)
    l.Size = UDim2.new(0.6, 0, 1, 0)
    l.BackgroundTransparency = 1
    l.Text = label
    l.Font = Enum.Font.GothamSemibold
    l.TextSize = 11
    l.TextColor3 = Colors.textMid
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextStrokeTransparency = 1

    local v = Instance.new("TextLabel", f)
    v.Position = UDim2.new(0.6, 0, 0, 0)
    v.Size = UDim2.new(0.4, -10, 1, 0)
    v.BackgroundTransparency = 1
    v.Text = "0"
    v.Font = Enum.Font.GothamBold
    v.TextSize = 12
    v.TextColor3 = Colors.accentGlow
    v.TextXAlignment = Enum.TextXAlignment.Right
    v.TextStrokeTransparency = 1

    return v
end

local function AddButton(parent, text, bg, order)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(1, 0, 0, 36)
    b.BackgroundColor3 = bg or Colors.accentDim
    b.Font = Enum.Font.GothamBold
    b.TextSize = 12
    b.TextColor3 = Colors.text
    b.Text = text
    b.BorderSizePixel = 0
    b.LayoutOrder = order or 0
    b.TextStrokeTransparency = 1

    local c = Instance.new("UICorner", b)
    c.CornerRadius = UDim.new(0, 8)

    b.MouseEnter:Connect(function()
        local t = TweenService:Create(b, TweenInfo.new(0.12), {
            BackgroundColor3 = Colors.accent
        })
        t:Play()
    end)

    b.MouseLeave:Connect(function()
        local t = TweenService:Create(b, TweenInfo.new(0.12), {
            BackgroundColor3 = bg or Colors.accentDim
        })
        t:Play()
    end)

    return b
end

local function AddCard(parent, height, order)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(1, 0, 0, height or 46)
    f.BackgroundColor3 = Colors.card
    f.BorderSizePixel = 0
    f.LayoutOrder = order or 0

    local c = Instance.new("UICorner", f)
    c.CornerRadius = UDim.new(0, 8)

    return f
end

-- Helper functions
local function CountItem(name)
    local count = 0
    local bp = Player.Backpack
    if bp then
        for _, child in pairs(bp:GetChildren()) do
            if child.Name == name then
                count = count + 1
            end
        end
    end
    local char = Player.Character
    if char then
        for _, child in pairs(char:GetChildren()) do
            if child:IsA("Tool") and child.Name == name then
                count = count + 1
            end
        end
    end
    return count
end

local function EquipTool(name)
    local char = Player.Character
    local bp = Player.Backpack
    local tool = bp and bp:FindFirstChild(name)
    if not tool then
        tool = char and char:FindFirstChild(name)
    end
    if tool and char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:EquipTool(tool)
            task.wait(0.3)
            return true
        end
    end
    return false
end

local function SendE(hold)
    VirtualInputManager:SendKeyEvent(true, "E", false, game)
    task.wait(hold or 0.7)
    VirtualInputManager:SendKeyEvent(false, "E", false, game)
end

-- BUAT TAB
CreateTab("AUTO", 1)
CreateTab("FULLY", 2)
CreateTab("MS POT", 3)
CreateTab("BUY", 4)
CreateTab("SET", 5)

-- AUTO TAB
local AutoTab = Tabs["AUTO"]
AddLabel(AutoTab, "MS LOOP AUTO COOK", 1)

local WStat = AddStat(AutoTab, "Water", 2)
local SStat = AddStat(AutoTab, "Sugar Block Bag", 3)
local GStat = AddStat(AutoTab, "Gelatin", 4)
local EStat = AddStat(AutoTab, "Empty Bag", 5)

AddLabel(AutoTab, "CONTROL", 6)

local StatusCard = AddCard(AutoTab, 40, 7)
local StatusText = Instance.new("TextLabel", StatusCard)
StatusText.Size = UDim2.new(1, -20, 1, 0)
StatusText.Position = UDim2.new(0, 12, 0, 0)
StatusText.BackgroundTransparency = 1
StatusText.Text = "STOPPED"
StatusText.Font = Enum.Font.GothamBold
StatusText.TextSize = 13
StatusText.TextColor3 = Colors.red
StatusText.TextXAlignment = Enum.TextXAlignment.Left
StatusText.TextStrokeTransparency = 1

local StartBtn = AddButton(AutoTab, "START MS LOOP", Colors.green, 8)
local Running = false

local function AutoLoop()
    while Running do
        WStat.Text = tostring(CountItem("Water"))
        SStat.Text = tostring(CountItem("Sugar Block Bag"))
        GStat.Text = tostring(CountItem("Gelatin"))
        EStat.Text = tostring(CountItem("Empty Bag"))

        StatusText.Text = "COOKING..."
        StatusText.TextColor3 = Colors.accentGlow

        if Running then
            EquipTool("Water")
            SendE(0.7)
            task.wait(20)
        end

        if Running then
            EquipTool("Sugar Block Bag")
            SendE(0.7)
            task.wait(1)
        end

        if Running then
            EquipTool("Gelatin")
            SendE(0.7)
            task.wait(1)
            task.wait(45)
        end

        if Running then
            EquipTool("Empty Bag")
            SendE(0.7)
            task.wait(1)
        end

        WStat.Text = tostring(CountItem("Water"))
        SStat.Text = tostring(CountItem("Sugar Block Bag"))
        GStat.Text = tostring(CountItem("Gelatin"))
        EStat.Text = tostring(CountItem("Empty Bag"))

        task.wait(2)
    end
    StatusText.Text = "STOPPED"
    StatusText.TextColor3 = Colors.red
end

StartBtn.MouseButton1Click:Connect(function()
    if not Running then
        Running = true
        StartBtn.Text = "STOP MS LOOP"
        StartBtn.BackgroundColor3 = Colors.red
        StatusText.Text = "RUNNING"
        StatusText.TextColor3 = Colors.green
        task.spawn(AutoLoop)
    else
        Running = false
        StartBtn.Text = "START MS LOOP"
        StartBtn.BackgroundColor3 = Colors.green
        StatusText.Text = "STOPPED"
        StatusText.TextColor3 = Colors.red
    end
end)

-- FULLY TAB
local FullyTab = Tabs["FULLY"]
AddLabel(FullyTab, "AUTO FULLY", 1)

local FWStat = AddStat(FullyTab, "Water", 2)
local FSStat = AddStat(FullyTab, "Sugar Block Bag", 3)
local FGStat = AddStat(FullyTab, "Gelatin", 4)
local FEStat = AddStat(FullyTab, "Empty Bag", 5)

AddLabel(FullyTab, "SETTING", 6)

-- Slider sederhana
local SliderCard = AddCard(FullyTab, 54, 7)
local SliderLabel = Instance.new("TextLabel", SliderCard)
SliderLabel.Position = UDim2.new(0, 12, 0, 8)
SliderLabel.Size = UDim2.new(0.5, 0, 0, 16)
SliderLabel.BackgroundTransparency = 1
SliderLabel.Text = "TARGET FULLY"
SliderLabel.Font = Enum.Font.GothamSemibold
SliderLabel.TextSize = 11
SliderLabel.TextColor3 = Colors.textMid
SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
SliderLabel.TextStrokeTransparency = 1

local SliderVal = Instance.new("TextLabel", SliderCard)
SliderVal.Position = UDim2.new(0.8, 0, 0, 8)
SliderVal.Size = UDim2.new(0.2, -10, 0, 16)
SliderVal.BackgroundTransparency = 1
SliderVal.Text = "5"
SliderVal.Font = Enum.Font.GothamBold
SliderVal.TextSize = 12
SliderVal.TextColor3 = Colors.accentGlow
SliderVal.TextXAlignment = Enum.TextXAlignment.Right
SliderVal.TextStrokeTransparency = 1

local TargetFully = 5

local FStatusCard = AddCard(FullyTab, 40, 8)
local FStatusText = Instance.new("TextLabel", FStatusCard)
FStatusText.Size = UDim2.new(1, -20, 1, 0)
FStatusText.Position = UDim2.new(0, 12, 0, 0)
FStatusText.BackgroundTransparency = 1
FStatusText.Text = "STOPPED"
FStatusText.Font = Enum.Font.GothamBold
FStatusText.TextSize = 13
FStatusText.TextColor3 = Colors.red
FStatusText.TextXAlignment = Enum.TextXAlignment.Left
FStatusText.TextStrokeTransparency = 1

local FStartBtn = AddButton(FullyTab, "START FULLY", Colors.green, 9)
local FRunning = false
local FCount = 0

local function FullyLoop()
    local items = {"Water", "Sugar Block Bag", "Gelatin", "Empty Bag"}

    while FRunning do
        FWStat.Text = tostring(CountItem("Water"))
        FSStat.Text = tostring(CountItem("Sugar Block Bag"))
        FGStat.Text = tostring(CountItem("Gelatin"))
        FEStat.Text = tostring(CountItem("Empty Bag"))

        FStatusText.Text = "RUNNING..."
        FStatusText.TextColor3 = Colors.green

        for _, item in ipairs(items) do
            if not FRunning then break end
            if item == "Empty Bag" then
                FStatusText.Text = "SELLING..."
                FStatusText.TextColor3 = Colors.accentGlow
                if StorePurchase then
                    for _, sell in ipairs({"Water", "Sugar Block Bag", "Gelatin"}) do
                        if not FRunning then break end
                        StorePurchase:FireServer(sell, 1)
                        task.wait(0.4)
                    end
                end
                FStatusText.Text = "SELL COMPLETE!"
                FStatusText.TextColor3 = Colors.green
                task.wait(1)
            else
                FStatusText.Text = "COOKING " .. item
                FStatusText.TextColor3 = Colors.accentGlow
                EquipTool(item)
                SendE(0.7)
                task.wait(1)
            end
        end

        FCount = FCount + 1
        FStatusText.Text = "LOOP " .. FCount .. "/" .. TargetFully
        FStatusText.TextColor3 = Colors.accentGlow
        task.wait(2)

        if FCount >= TargetFully then
            FRunning = false
            FStartBtn.Text = "START FULLY"
            FStartBtn.BackgroundColor3 = Colors.green
            FStatusText.Text = "COMPLETE!"
            FStatusText.TextColor3 = Colors.green
            task.wait(2)
            FStatusText.Text = "STOPPED"
            FStatusText.TextColor3 = Colors.red
            FCount = 0
        end
    end
end

FStartBtn.MouseButton1Click:Connect(function()
    if not FRunning then
        FRunning = true
        FCount = 0
        FStartBtn.Text = "RUNNING..."
        FStartBtn.BackgroundColor3 = Colors.accentDim
        task.spawn(FullyLoop)
    else
        FRunning = false
        FStartBtn.Text = "START FULLY"
        FStartBtn.BackgroundColor3 = Colors.green
        FStatusText.Text = "STOPPED"
        FStatusText.TextColor3 = Colors.red
        FCount = 0
    end
end)

-- MS POT TAB
local POTTab = Tabs["MS POT"]
AddLabel(POTTab, "MS POT SELLER", 1)

local PStatusCard = AddCard(POTTab, 40, 2)
local PStatusText = Instance.new("TextLabel", PStatusCard)
PStatusText.Size = UDim2.new(1, -20, 1, 0)
PStatusText.Position = UDim2.new(0, 12, 0, 0)
PStatusText.BackgroundTransparency = 1
PStatusText.Text = "STOPPED"
PStatusText.Font = Enum.Font.GothamBold
PStatusText.TextSize = 13
PStatusText.TextColor3 = Colors.red
PStatusText.TextXAlignment = Enum.TextXAlignment.Left
PStatusText.TextStrokeTransparency = 1

local PCountLabel = Instance.new("TextLabel", PStatusCard)
PCountLabel.Size = UDim2.new(1, -20, 0, 16)
PCountLabel.Position = UDim2.new(0, 12, 0, 20)
PCountLabel.BackgroundTransparency = 1
PCountLabel.Text = "Sold: 0"
PCountLabel.Font = Enum.Font.GothamSemibold
PCountLabel.TextSize = 11
PCountLabel.TextColor3 = Colors.textMid
PCountLabel.TextXAlignment = Enum.TextXAlignment.Left
PCountLabel.TextStrokeTransparency = 1

local PStartBtn = AddButton(POTTab, "START SELL", Colors.green, 3)
local PRunning = false
local PCount = 0

local function POTLoop()
    local pots = {"Small Marshmallow Bag", "Medium Marshmallow Bag", "Large Marshmallow Bag"}

    while PRunning do
        local found = {}

        local bp = Player.Backpack
        if bp then
            for _, child in pairs(bp:GetChildren()) do
                if child:IsA("Tool") then
                    for _, name in ipairs(pots) do
                        if child.Name == name then
                            table.insert(found, child)
                        end
                    end
                end
            end
        end

        local char = Player.Character
        if char then
            for _, child in pairs(char:GetChildren()) do
                if child:IsA("Tool") then
                    for _, name in ipairs(pots) do
                        if child.Name == name then
                            table.insert(found, child)
                        end
                    end
                end
            end
        end

        if #found > 0 then
            for _, tool in ipairs(found) do
                if not PRunning then break end

                if tool.Parent == Player.Backpack then
                    local hum = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
                    if hum then
                        hum:EquipTool(tool)
                        task.wait(0.3)
                    end
                end

                PStatusText.Text = "SELLING..."
                PStatusText.TextColor3 = Colors.accentGlow

                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                task.wait(0.5)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)

                PCount = PCount + 1
                PCountLabel.Text = "Sold: " .. PCount
                task.wait(1)
            end
        else
            PStatusText.Text = "NO ITEMS"
            PStatusText.TextColor3 = Colors.red
            task.wait(2)
        end
    end

    PStatusText.Text = "STOPPED"
    PStatusText.TextColor3 = Colors.red
    PStartBtn.Text = "START SELL"
    PStartBtn.BackgroundColor3 = Colors.green
end

PStartBtn.MouseButton1Click:Connect(function()
    if not PRunning then
        PRunning = true
        PCount = 0
        PStartBtn.Text = "STOP SELL"
        PStartBtn.BackgroundColor3 = Colors.red
        PStatusText.Text = "RUNNING"
        PStatusText.TextColor3 = Colors.green
        task.spawn(POTLoop)
    else
        PRunning = false
        PStartBtn.Text = "START SELL"
        PStartBtn.BackgroundColor3 = Colors.green
        PStatusText.Text = "STOPPED"
        PStatusText.TextColor3 = Colors.red
    end
end)

-- BUY TAB
local BuyTab = Tabs["BUY"]
AddLabel(BuyTab, "BUY ITEMS", 1)

local BStatusCard = AddCard(BuyTab, 40, 2)
local BStatusText = Instance.new("TextLabel", BStatusCard)
BStatusText.Size = UDim2.new(1, -20, 1, 0)
BStatusText.Position = UDim2.new(0, 12, 0, 0)
BStatusText.BackgroundTransparency = 1
BStatusText.Text = "READY"
BStatusText.Font = Enum.Font.GothamBold
BStatusText.TextSize = 13
BStatusText.TextColor3 = Colors.textMid
BStatusText.TextXAlignment = Enum.TextXAlignment.Left
BStatusText.TextStrokeTransparency = 1

-- Buy amount slider sederhana
local BASlider = AddCard(BuyTab, 54, 3)
local BALabel = Instance.new("TextLabel", BASlider)
BALabel.Position = UDim2.new(0, 12, 0, 8)
BALabel.Size = UDim2.new(0.5, 0, 0, 16)
BALabel.BackgroundTransparency = 1
BALabel.Text = "BUY AMOUNT"
BALabel.Font = Enum.Font.GothamSemibold
BALabel.TextSize = 11
BALabel.TextColor3 = Colors.textMid
BALabel.TextXAlignment = Enum.TextXAlignment.Left
BALabel.TextStrokeTransparency = 1

local BAVal = Instance.new("TextLabel", BASlider)
BAVal.Position = UDim2.new(0.8, 0, 0, 8)
BAVal.Size = UDim2.new(0.2, -10, 0, 16)
BAVal.BackgroundTransparency = 1
BAVal.Text = "10"
BAVal.Font = Enum.Font.GothamBold
BAVal.TextSize = 12
BAVal.TextColor3 = Colors.accentGlow
BAVal.TextXAlignment = Enum.TextXAlignment.Right
BAVal.TextStrokeTransparency = 1

local BStartBtn = AddButton(BuyTab, "BUY ITEMS", Colors.accent, 4)
local BRunning = false

local function BuyLoop()
    local items = {"Water", "Sugar Block Bag", "Gelatin", "Empty Bag"}
    local amount = tonumber(BAVal.Text) or 10

    BStatusText.Text = "BUYING..."
    BStatusText.TextColor3 = Colors.accentGlow

    for _, item in ipairs(items) do
        if not BRunning then break end

        BStatusText.Text = "BUYING " .. item .. " x" .. amount
        for i = 1, amount do
            if not BRunning then break end
            if StorePurchase then
                StorePurchase:FireServer(item, 1)
                task.wait(0.4)
            end
        end
        task.wait(0.5)
    end

    BStatusText.Text = "PURCHASE COMPLETE!"
    BStatusText.TextColor3 = Colors.green
    task.wait(2)
    BStatusText.Text = "READY"
    BStatusText.TextColor3 = Colors.textMid
    BStartBtn.Text = "BUY ITEMS"
    BStartBtn.BackgroundColor3 = Colors.accent
    BRunning = false
end

BStartBtn.MouseButton1Click:Connect(function()
    if not BRunning then
        BRunning = true
        BStartBtn.Text = "BUYING..."
        BStartBtn.BackgroundColor3 = Colors.accentDim
        task.spawn(BuyLoop)
    else
        BRunning = false
        BStartBtn.Text = "BUY ITEMS"
        BStartBtn.BackgroundColor3 = Colors.accent
        BStatusText.Text = "STOPPED"
        BStatusText.TextColor3 = Colors.red
        task.wait(1)
        BStatusText.Text = "READY"
        BStatusText.TextColor3 = Colors.textMid
    end
end)

-- SETTINGS TAB
local SetTab = Tabs["SET"]
AddLabel(SetTab, "SETTINGS", 1)

-- Auto AFK
local AFKCard = AddCard(SetTab, 50, 2)
local AFKLabel = Instance.new("TextLabel", AFKCard)
AFKLabel.Position = UDim2.new(0, 12, 0, 0)
AFKLabel.Size = UDim2.new(0.6, 0, 1, 0)
AFKLabel.BackgroundTransparency = 1
AFKLabel.Text = "AUTO AFK"
AFKLabel.Font = Enum.Font.GothamSemibold
AFKLabel.TextSize = 11
AFKLabel.TextColor3 = Colors.textMid
AFKLabel.TextXAlignment = Enum.TextXAlignment.Left
AFKLabel.TextStrokeTransparency = 1

local AFKToggle = Instance.new("TextButton", AFKCard)
AFKToggle.Size = UDim2.new(0, 50, 0, 26)
AFKToggle.Position = UDim2.new(1, -62, 0.5, -13)
AFKToggle.BackgroundColor3 = Colors.green
AFKToggle.Text = "ON"
AFKToggle.Font = Enum.Font.GothamBold
AFKToggle.TextSize = 10
AFKToggle.TextColor3 = Colors.text
AFKToggle.BorderSizePixel = 0
AFKToggle.TextStrokeTransparency = 1

local AFKCorner = Instance.new("UICorner", AFKToggle)
AFKCorner.CornerRadius = UDim.new(0, 6)

local AFKEnabled = true

AFKToggle.MouseButton1Click:Connect(function()
    AFKEnabled = not AFKEnabled
    if AFKEnabled then
        AFKToggle.BackgroundColor3 = Colors.green
        AFKToggle.Text = "ON"
    else
        AFKToggle.BackgroundColor3 = Colors.red
        AFKToggle.Text = "OFF"
    end
end)

-- Auto AFK
Player.Idled:Connect(function()
    if AFKEnabled then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

-- Auto update stats
task.spawn(function()
    while true do
        task.wait(1)
        if Tabs["AUTO"] and Tabs["AUTO"].Visible then
            WStat.Text = tostring(CountItem("Water"))
            SStat.Text = tostring(CountItem("Sugar Block Bag"))
            GStat.Text = tostring(CountItem("Gelatin"))
            EStat.Text = tostring(CountItem("Empty Bag"))
        end
        if Tabs["FULLY"] and Tabs["FULLY"].Visible then
            FWStat.Text = tostring(CountItem("Water"))
            FSStat.Text = tostring(CountItem("Sugar Block Bag"))
            FGStat.Text = tostring(CountItem("Gelatin"))
            FEStat.Text = tostring(CountItem("Empty Bag"))
        end
    end
end)

-- Switch to AUTO
SwitchTab("AUTO")

-- Keybind Left Control + L
ContextActionService:BindAction("ToggleLENGER", function(act, state)
    if state == Enum.UserInputState.Begin then
        Main.Visible = not Main.Visible
    end
end, false, Enum.KeyCode.LeftControl, Enum.KeyCode.L)

-- Pastikan terlihat
Main.Visible = true

print("LENGER STORE v2 loaded!")
print("Press Left Control + L to toggle")