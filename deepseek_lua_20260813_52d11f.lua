-- Deobfuscated & Cleaned Script
-- Original: DYYYKZZ Hub for game

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local VirtualInput = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")

-- Variables
local Character = LocalPlayer.Character
local Backpack = LocalPlayer:WaitForChild("Backpack")
local isDealerMode = false
local isFarming = false
local isInstantPrompt = false
local isSelling = false
local isFPSBoost = false
local cookedCount = 0
local maxCookies = 1
local runtime = 0

-- Teleport Locations
local locations = {
    apartment3 = CFrame.new(984.73, 11.27, 245.78),
    marsDealer = CFrame.new(509.64, 4.52, 600.15),
    apartment1 = CFrame.new(1142.16, 10.11, 448.6),
    apartment2 = CFrame.new(1142.15, 11.02, 421.16)
}

-- Functions

-- Find tool in backpack
local function findTool(toolName)
    local count = 0
    for _, tool in pairs(Backpack:GetDescendants()) do
        if tool:IsA("Tool") and tool.Name == toolName then
            count = count + 1
        end
    end
    return count
end

-- Equip tool
local function equipTool(toolName)
    local tool = Backpack:FindFirstChild(toolName)
    if tool then
        LocalPlayer.Character.Humanoid:EquipTool(tool)
        task.wait(0.6)
        return true
    end
    return false
end

-- Press E key
local function pressE()
    VirtualInput:SendKeyEvent(true, "E", false, game)
    task.wait(0.15)
    VirtualInput:SendKeyEvent(false, "E", false, game)
end

-- Teleport function
local function teleportTo(character, targetCFrame)
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return
    end
    character.PrimaryPart = character.HumanoidRootPart
    character:SetPrimaryPartCFrame(targetCFrame)
end

-- Find nearest vehicle
local function findNearestVehicle()
    if not Character or not Character:FindFirstChild("HumanoidRootPart") then
        return nil
    end
    
    local nearestVehicle = nil
    local minDistance = 20
    local charPos = Character.HumanoidRootPart.Position
    
    for _, part in pairs(workspace:GetDescendants()) do
        if part:IsA("BasePart") and part.Parent and part.Parent:IsA("Model") then
            local dist = (part.Position - charPos).Magnitude
            if dist < minDistance then
                local modelName = part.Parent.Name:lower()
                if modelName:find("motor") or modelName:find("bike") or modelName:find("car") then
                    nearestVehicle = part.Parent
                    minDistance = dist
                end
            end
        end
    end
    
    return nearestVehicle
end

-- Farming loop
local function startFarming()
    while isFarming do
        cookedCount = 0
        
        -- Water
        if equipTool("Water") then
            task.wait(0.8)
            pressE()
        end
        task.wait(21)
        
        -- Sugar
        if equipTool("Sugar Block Bag") then
            task.wait(0.8)
            pressE()
        end
        task.wait(1)
        
        -- Gelatin
        if equipTool("Gelatin") then
            task.wait(0.8)
            pressE()
        end
        task.wait(46)
        
        -- Empty Bag
        if equipTool("Empty Bag") then
            task.wait(0.8)
            pressE()
        end
        task.wait(2)
        
        cookedCount = cookedCount + 1
        
        if cookedCount >= maxCookies then
            isFarming = false
        end
    end
end

-- Instant prompt loop
local function startInstantPrompt()
    while isInstantPrompt do
        for _, prompt in pairs(workspace:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") then
                prompt.HoldDuration = 0
            end
        end
        task.wait(1)
    end
end

-- Selling loop
local function startSelling()
    while isSelling do
        local items = {
            "Small Marshmallow Bag",
            "Medium Marshmallow Bag", 
            "Large Marshmallow Bag",
            "Marshmallow"
        }
        
        for _, item in pairs(items) do
            if equipTool(item) then
                task.wait(0.8)
                pressE()
                task.wait(0.3)
            end
        end
        task.wait(1)
    end
end

-- FPS Boost
local function startFPSBoost()
    isFPSBoost = true
    local steps = 0
    
    task.spawn(function()
        local boostSteps = {
            function() Lighting.ShadowSoftness = 0.8 end,
            function() Lighting.ShadowSoftness = 0.5 end,
            function() Lighting.Brightness = 2.5 end,
            function() Lighting.Brightness = 1.5 end,
            function() 
                Lighting.FogEnd = 8000
                Lighting.FogStart = 4000
            end,
            function()
                Lighting.FogEnd = 4000
                Lighting.FogStart = 2000
            end,
            function() Lighting.OutdoorAmbient = Color3.fromRGB(100, 100, 100) end,
            function() Lighting.OutdoorAmbient = Color3.fromRGB(80, 80, 80) end,
            function() Lighting.Outlines = false end,
            function() Lighting.ExposureCompensation = -0.5 end,
            function() Lighting.ExposureCompensation = -1 end,
            function() Lighting.GlobalShadows = false end,
            function()
                workspace.Terrain.WaterWaveSize = 0
                workspace.Terrain.WaterWaveSpeed = 0
            end
        }
        
        for i, step in pairs(boostSteps) do
            if not isFPSBoost then break end
            steps = i
            pcall(step)
            task.wait(2)
        end
        
        isFPSBoost = false
    end)
end

-- Character added handler
LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    Backpack = LocalPlayer:WaitForChild("Backpack")
    if isDealerMode then
        task.wait(0.1)
        char:WaitForChild("HumanoidRootPart").CFrame = locations.apartment3
    end
end)

-- Anti-idle
LocalPlayer.Idled:Connect(function()
    VirtualInput:SendKeyEvent(true, "W", false, game)
    task.wait()
    VirtualInput:SendKeyEvent(false, "W", false, game)
end)

-- UI Creation
local function createUI()
    -- Remove existing UI
    local existingUI = CoreGui:FindFirstChild("DYYYKZZ_HUB")
    if existingUI then
        existingUI:Destroy()
    end
    
    -- Main ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "DYYYKZZ_HUB"
    screenGui.Parent = CoreGui
    
    -- Main Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 350, 0, 500)
    mainFrame.Position = UDim2.new(0.5, -175, 0.5, -250)
    mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = screenGui
    
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)
    
    -- Header
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 40)
    header.BackgroundColor3 = Color3.fromRGB(20, 20, 32)
    header.Parent = mainFrame
    Instance.new("UICorner", header).CornerRadius = UDim.new(0, 10)
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0, 200, 0, 40)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.Text = "DYYYKZZ HUB"
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    
    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 25, 0, 25)
    closeBtn.Position = UDim2.new(1, -32, 0, 8)
    closeBtn.Text = "✕"
    closeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    closeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 11
    closeBtn.Parent = header
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1, 0)
    
    closeBtn.MouseButton1Click:Connect(function()
        isFarming = false
        isInstantPrompt = false
        isSelling = false
        isDealerMode = false
        isFPSBoost = false
        screenGui:Destroy()
    end)
    
    -- Minimize Button
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Size = UDim2.new(0, 25, 0, 25)
    minimizeBtn.Position = UDim2.new(1, -60, 0, 8)
    minimizeBtn.Text = "−"
    minimizeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    minimizeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.TextSize = 11
    minimizeBtn.Parent = header
    Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(1, 0)
    
    -- Restore Button (hidden initially)
    local restoreBtn = Instance.new("TextButton")
    restoreBtn.Size = UDim2.new(0, 6, 0, 80)
    restoreBtn.Position = UDim2.new(0, 0, 0.5, -40)
    restoreBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    restoreBtn.Text = "▶"
    restoreBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    restoreBtn.Font = Enum.Font.GothamBold
    restoreBtn.TextSize = 10
    restoreBtn.Visible = false
    restoreBtn.Parent = screenGui
    Instance.new("UICorner", restoreBtn).CornerRadius = UDim.new(0, 3)
    
    minimizeBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
        restoreBtn.Visible = true
    end)
    
    restoreBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = true
        restoreBtn.Visible = false
    end)
    
    -- Tab buttons container
    local tabContainer = Instance.new("Frame")
    tabContainer.Size = UDim2.new(1, 0, 0, 35)
    tabContainer.Position = UDim2.new(0, 0, 0, 40)
    tabContainer.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    tabContainer.Parent = mainFrame
    
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    tabLayout.Padding = UDim.new(0, 8)
    tabLayout.Parent = tabContainer
    
    -- Content container
    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, -20, 1, -85)
    contentFrame.Position = UDim2.new(0, 10, 0, 80)
    contentFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 32)
    contentFrame.Parent = mainFrame
    Instance.new("UICorner", contentFrame).CornerRadius = UDim.new(0, 8)
    
    -- Scrolling frame
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, 0, 1, 0)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.ScrollBarThickness = 3
    scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 100)
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 560)
    scrollFrame.Parent = contentFrame
    
    local scrollLayout = Instance.new("UIListLayout")
    scrollLayout.Padding = UDim.new(0, 8)
    scrollLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    scrollLayout.Parent = scrollFrame
    
    -- UI Helper Functions
    local function addLabel(text)
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0, 310, 0, 22)
        label.Text = text
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.fromRGB(200, 200, 220)
        label.Font = Enum.Font.GothamBold
        label.TextSize = 12
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = scrollFrame
        return label
    end
    
    local function addToggleButton(text, callback, emoji)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 310, 0, 32)
        btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
        btn.Text = emoji .. " " .. text
        btn.TextColor3 = Color3.fromRGB(220, 220, 240)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 10
        btn.Parent = scrollFrame
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 7)
        
        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(80, 80, 100)
        stroke.Thickness = 1
        stroke.Parent = btn
        
        local toggled = false
        btn.MouseButton1Click:Connect(function()
            toggled = not toggled
            if toggled then
                btn.BackgroundColor3 = Color3.fromRGB(50, 150, 70)
                stroke.Color = Color3.fromRGB(100, 200, 120)
            else
                btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
                stroke.Color = Color3.fromRGB(80, 80, 100)
            end
            callback(toggled)
        end)
        
        return btn
    end
    
    local function addInfoRow(label, value)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 310, 0, 20)
        frame.BackgroundTransparency = 1
        frame.Parent = scrollFrame
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(0, 120, 0, 20)
        nameLabel.Text = label
        nameLabel.BackgroundTransparency = 1
        nameLabel.TextColor3 = Color3.fromRGB(160, 160, 180)
        nameLabel.Font = Enum.Font.Gotham
        nameLabel.TextSize = 10
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Parent = frame
        
        local valueLabel = Instance.new("TextLabel")
        valueLabel.Size = UDim2.new(0, 180, 0, 20)
        valueLabel.Position = UDim2.new(1, -180, 0, 0)
        valueLabel.Text = value
        valueLabel.BackgroundTransparency = 1
        valueLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
        valueLabel.Font = Enum.Font.GothamBold
        valueLabel.TextSize = 10
        valueLabel.TextXAlignment = Enum.TextXAlignment.Right
        valueLabel.Parent = frame
        
        return valueLabel
    end
    
    local function addButtonRow(parent, text, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 72, 0, 32)
        btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(220, 220, 240)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 9
        btn.Parent = parent
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        
        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(80, 80, 100)
        stroke.Thickness = 1
        stroke.Parent = btn
        
        btn.MouseButton1Click:Connect(callback)
        return btn
    end
    
    -- Build UI
    
    -- Top row buttons
    local topRow = Instance.new("Frame")
    topRow.Size = UDim2.new(0, 310, 0, 32)
    topRow.BackgroundTransparency = 1
    topRow.Parent = scrollFrame
    
    local topLayout = Instance.new("UIListLayout")
    topLayout.FillDirection = Enum.FillDirection.Horizontal
    topLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    topLayout.Padding = UDim.new(0, 6)
    topLayout.Parent = topRow
    
    addToggleButton("Dealer 🚗", function(state)
        isDealerMode = state
        if state and Character and Character:FindFirstChild("HumanoidRootPart") then
            Character:BreakJoints()
        end
    end, "🚗")
    
    addToggleButton("Farm 🌾", function(state)
        isFarming = state
        if state then
            task.spawn(startFarming)
        end
    end, "🌾")
    
    addToggleButton("Insta ⚡", function(state)
        isInstantPrompt = state
        if state then
            task.spawn(startInstantPrompt)
        end
    end, "⚡")
    
    addToggleButton("Sell 💰", function(state)
        isSelling = state
        if state then
            task.spawn(startSelling)
        end
    end, "💰")
    
    -- Info rows
    local statusLabel = addInfoRow("Status", "Idle")
    local cookedLabel = addInfoRow("Cooked", "0")
    local runtimeLabel = addInfoRow("Runtime", "00:00")
    local fpsLabel = addInfoRow("FPS Boost", "OFF")
    
    -- FPS Boost button
    local fpsBoostBtn = Instance.new("TextButton")
    fpsBoostBtn.Size = UDim2.new(0, 310, 0, 38)
    fpsBoostBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    fpsBoostBtn.Text = "START FPS BOOST (13 Steps)"
    fpsBoostBtn.TextColor3 = Color3.fromRGB(220, 220, 240)
    fpsBoostBtn.Font = Enum.Font.GothamBold
    fpsBoostBtn.TextSize = 11
    fpsBoostBtn.Parent = scrollFrame
    Instance.new("UICorner", fpsBoostBtn).CornerRadius = UDim.new(0, 7)
    
    local fpsStroke = Instance.new("UIStroke")
    fpsStroke.Color = Color3.fromRGB(80, 80, 100)
    fpsStroke.Thickness = 1
    fpsStroke.Parent = fpsBoostBtn
    
    local fpsToggled = false
    fpsBoostBtn.MouseButton1Click:Connect(function()
        fpsToggled = not fpsToggled
        if fpsToggled then
            fpsBoostBtn.Text = "STOP FPS BOOST"
            fpsBoostBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 70)
            fpsStroke.Color = Color3.fromRGB(100, 200, 120)
            startFPSBoost()
        else
            fpsBoostBtn.Text = "START FPS BOOST (13 Steps)"
            fpsBoostBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
            fpsStroke.Color = Color3.fromRGB(80, 80, 100)
            isFPSBoost = false
        end
    end)
    
    -- Teleport buttons row
    local teleportRow = Instance.new("Frame")
    teleportRow.Size = UDim2.new(0, 310, 0, 38)
    teleportRow.BackgroundTransparency = 1
    teleportRow.Parent = scrollFrame
    
    local teleportLayout = Instance.new("UIListLayout")
    teleportLayout.FillDirection = Enum.FillDirection.Horizontal
    teleportLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    teleportLayout.Padding = UDim.new(0, 5)
    teleportLayout.Parent = teleportRow
    
    addButtonRow(teleportRow, "Apart 3\n984, 11", function()
        if Character then
            teleportTo(Character, locations.apartment3)
        end
    end)
    
    addButtonRow(teleportRow, "Mars Dlr\n509, 4", function()
        if Character then
            teleportTo(Character, locations.marsDealer)
        end
    end)
    
    addButtonRow(teleportRow, "Apart 1\n1142, 10", function()
        if Character then
            teleportTo(Character, locations.apartment1)
        end
    end)
    
    addButtonRow(teleportRow, "Apart 2\n1142, 11", function()
        if Character then
            teleportTo(Character, locations.apartment2)
        end
    end)
    
    -- UI Update Loop
    local startTime = tick()
    task.spawn(function()
        while true do
            task.wait(0.5)
            
            -- Update runtime
            local elapsed = tick() - startTime
            runtimeLabel.Text = string.format("%02d:%02d", math.floor(elapsed / 60), math.floor(elapsed % 60))
            
            -- Update cooked count
            cookedLabel.Text = tostring(cookedCount)
            
            -- Update status
            statusLabel.Text = isFarming and "Farming..." or "Idle"
            
            -- Update FPS boost status
            fpsLabel.Text = isFPSBoost and "ON (" .. "..." .. "/13)" or "OFF"
            
            -- Auto-stop farming when done
            if isFarming and cookedCount >= maxCookies then
                isFarming = false
            end
            
            -- Check if screen still exists
            if not screenGui.Parent then
                break
            end
        end
    end)
    
    -- Animate opening
    mainFrame.Size = UDim2.new(0, 350, 0, 0)
    local tween = TweenService:Create(mainFrame, 
        TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {Size = UDim2.new(0, 350, 0, 500)}
    )
    tween:Play()
end

-- Create UI
createUI()