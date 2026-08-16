--[[
    AUTO FARM - Simple UI
    Tanpa emoji, clean design
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui", 15)

-- ============================================
-- UI CREATION
-- ============================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoFarm"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = PlayerGui

-- Colors
local colors = {
    bg = Color3.fromRGB(25, 25, 30),
    bar = Color3.fromRGB(35, 35, 40),
    text = Color3.fromRGB(255, 255, 255),
    sub = Color3.fromRGB(160, 160, 160),
    border = Color3.fromRGB(55, 55, 60),
    accent = Color3.fromRGB(50, 50, 55),
    green = Color3.fromRGB(0, 180, 80),
    red = Color3.fromRGB(200, 50, 50)
}

-- MAIN FRAME
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 320, 0, 220)
mainFrame.Position = UDim2.new(0.5, -160, 0.5, -110)
mainFrame.BackgroundColor3 = colors.bg
mainFrame.BorderSizePixel = 1
mainFrame.BorderColor3 = colors.border
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)

-- ============================================
-- HEADER (Title Bar)
-- ============================================
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 32)
header.BackgroundColor3 = colors.bar
header.BorderSizePixel = 0
header.Parent = mainFrame
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 8, 0, 0)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -50, 1, 0)
title.Position = UDim2.new(0, 12, 0, 0)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.Text = "AUTO FARM"
title.TextColor3 = colors.text
title.TextSize = 13
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

-- Minimize button
local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 25, 1, 0)
minBtn.Position = UDim2.new(1, -50, 0, 0)
minBtn.BackgroundTransparency = 1
minBtn.Font = Enum.Font.Gotham
minBtn.Text = "-"
minBtn.TextColor3 = colors.text
minBtn.TextSize = 16
minBtn.Parent = header

-- Close button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 25, 1, 0)
closeBtn.Position = UDim2.new(1, -25, 0, 0)
closeBtn.BackgroundTransparency = 1
closeBtn.Font = Enum.Font.Gotham
closeBtn.Text = "x"
closeBtn.TextColor3 = colors.text
closeBtn.TextSize = 14
closeBtn.Parent = header

-- ============================================
-- DRAG FUNCTION
-- ============================================
local function makeDraggable(frame)
    local dragging = false
    local dragStart = nil
    local startPos = nil

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = Vector2.new(input.Position.X, input.Position.Y)
            startPos = Vector2.new(frame.Position.X.Offset, frame.Position.Y.Offset)
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
            0,
            math.clamp(startPos.X + delta.X, 0, viewport.X - size.X),
            0,
            math.clamp(startPos.Y + delta.Y, 0, viewport.Y - size.Y)
        )
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

makeDraggable(mainFrame)

-- ============================================
-- CONTENT
-- ============================================
local content = Instance.new("Frame")
content.Size = UDim2.new(1, -20, 1, -45)
content.Position = UDim2.new(0, 10, 0, 40)
content.BackgroundTransparency = 1
content.Parent = mainFrame

local layout = Instance.new("UIListLayout")
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 10)
layout.Parent = content

-- ============================================
-- STATUS LABEL
-- ============================================
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0, 20)
statusLabel.BackgroundTransparency = 1
statusLabel.Font = Enum.Font.Gotham
statusLabel.Text = "Status: ready"
statusLabel.TextColor3 = colors.sub
statusLabel.TextSize = 11
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.LayoutOrder = 0
statusLabel.Parent = content

-- ============================================
-- START / STOP BUTTON
-- ============================================
local startBtn = Instance.new("TextButton")
startBtn.Size = UDim2.new(1, 0, 0, 35)
startBtn.LayoutOrder = 1
startBtn.BackgroundColor3 = colors.green
startBtn.BorderSizePixel = 0
startBtn.Font = Enum.Font.GothamBold
startBtn.Text = "START FARMING"
startBtn.TextColor3 = colors.text
startBtn.TextSize = 14
startBtn.Parent = content
Instance.new("UICorner", startBtn).CornerRadius = UDim.new(0, 4)

-- ============================================
-- TARGET INFO
-- ============================================
local targetLabel = Instance.new("TextLabel")
targetLabel.Size = UDim2.new(1, 0, 0, 30)
targetLabel.LayoutOrder = 2
targetLabel.BackgroundTransparency = 1
targetLabel.Font = Enum.Font.Gotham
targetLabel.Text = "Target: Marshmallow Seller\n(770.99, 433.75)"
targetLabel.TextColor3 = colors.sub
targetLabel.TextSize = 10
targetLabel.TextXAlignment = Enum.TextXAlignment.Left
targetLabel.Parent = content

-- ============================================
-- MINIMIZE PANEL
-- ============================================
local minPanel = Instance.new("Frame")
minPanel.Size = UDim2.new(0, 140, 0, 28)
minPanel.Position = UDim2.new(0.5, -70, 0, -50)
minPanel.BackgroundColor3 = colors.bg
minPanel.BorderSizePixel = 1
minPanel.BorderColor3 = colors.border
minPanel.Visible = false
minPanel.Parent = screenGui
Instance.new("UICorner", minPanel).CornerRadius = UDim.new(0, 4)

local minLabel = Instance.new("TextLabel")
minLabel.Size = UDim2.new(1, 0, 1, 0)
minLabel.BackgroundTransparency = 1
minLabel.Font = Enum.Font.Gotham
minLabel.Text = "AUTO FARM"
minLabel.TextColor3 = colors.text
minLabel.TextSize = 11
minLabel.Parent = minPanel
makeDraggable(minPanel)

-- ============================================
-- BUTTON FUNCTIONS
-- ============================================
local isRunning = false
local farmTask = nil
local teleportTask = nil
local sellTask = nil
local sellRunning = false

-- SELL SYSTEM
local SELL_ITEMS = {
    "Small Marshmallow Bag",
    "Medium Marshmallow Bag",
    "Large Marshmallow Bag",
    "Water",
    "Sugar Block Bag",
    "Gelatin"
}

local function IsSellable(item)
    for _, name in ipairs(SELL_ITEMS) do
        if item.Name == name then
            return true
        end
    end
    return false
end

local function GetAllItems()
    local items = {}
    local bp = player.Backpack
    local char = player.Character
    if bp then
        for _, child in pairs(bp:GetChildren()) do
            if child:IsA("Tool") then
                table.insert(items, child)
            end
        end
    end
    if char then
        for _, child in pairs(char:GetChildren()) do
            if child:IsA("Tool") then
                table.insert(items, child)
            end
        end
    end
    return items
end

local function EquipItem(item)
    local char = player.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return false end
    if item.Parent == player.Backpack then
        hum:EquipTool(item)
        task.wait(0.3)
    end
    return true
end

local function PressE()
    VirtualInputManager:SendKeyEvent(true, "E", false, game)
    task.wait(0.5)
    VirtualInputManager:SendKeyEvent(false, "E", false, game)
    task.wait(0.3)
end

local function StartSellLoop()
    if sellRunning then return end
    sellRunning = true
    sellTask = task.spawn(function()
        while sellRunning do
            local items = GetAllItems()
            local sold = 0
            for _, item in ipairs(items) do
                if IsSellable(item) then
                    if EquipItem(item) then
                        PressE()
                        sold = sold + 1
                        task.wait(0.5)
                    end
                end
            end
            if sold == 0 then
                task.wait(5)
            else
                task.wait(2)
            end
        end
    end)
end

local function StopSellLoop()
    sellRunning = false
    if sellTask then
        task.cancel(sellTask)
        sellTask = nil
    end
end

-- FARMING SYSTEM
local function CountItem(name)
    local count = 0
    local bp = player.Backpack
    local char = player.Character
    if bp then
        for _, child in pairs(bp:GetChildren()) do
            if child.Name == name then
                count = count + 1
            end
        end
    end
    if char then
        for _, child in pairs(char:GetChildren()) do
            if child.Name == name then
                count = count + 1
            end
        end
    end
    return count
end

local function HasTool(name)
    local bp = player.Backpack
    local char = player.Character
    if bp and bp:FindFirstChild(name) then return true end
    if char and char:FindFirstChild(name) then return true end
    return false
end

local function EquipTool(name)
    local char = player.Character
    local bp = player.Backpack
    if not char or not bp then return false end
    local tool = bp:FindFirstChild(name)
    if not tool then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return false end
    pcall(function()
        hum:EquipTool(tool)
    end)
    local timeout = 0
    while timeout < 20 do
        if char:FindFirstChild(name) then
            return true
        end
        task.wait(0.05)
        timeout = timeout + 0.05
    end
    return false
end

local function FindPromptsInModel(model, callback)
    for _, child in ipairs(model:GetDescendants()) do
        if child.Name == "Cooking Pot" then
            local attach = child:FindFirstChild("Attachment")
            if attach then
                local prompt = attach:FindFirstChildOfClass("ProximityPrompt")
                if prompt then
                    callback(prompt)
                end
            end
            if not prompt then
                for _, desc in ipairs(child:GetDescendants()) do
                    if desc:IsA("ProximityPrompt") then
                        callback(desc)
                    end
                end
            end
        end
    end
end

local function GetAllInteriors()
    local interiors = {}
    local map = workspace:FindFirstChild("Map")
    if not map then return interiors end
    pcall(function()
        local houses = map:FindFirstChild("Houses")
        if houses then
            local wh1 = houses:FindFirstChild("WH1")
            if wh1 then
                local interior = wh1:FindFirstChild("Interior")
                if interior then
                    table.insert(interiors, interior)
                end
            end
        end
    end)
    pcall(function()
        local apartments = map:FindFirstChild("Apartments")
        if apartments then
            for _, child in ipairs(apartments:GetChildren()) do
                pcall(function()
                    local apt = child:FindFirstChild("Apartment")
                    if apt then
                        local interior = apt:FindFirstChild("Interior")
                        if interior then
                            table.insert(interiors, interior)
                        end
                    end
                    if child:IsA("Folder") or child:IsA("Model") then
                        local apt2 = child:FindFirstChild("Apartment")
                        if apt2 then
                            local interior2 = apt2:FindFirstChild("Interior")
                            if interior2 then
                                table.insert(interiors, interior2)
                            end
                        end
                    end
                end)
            end
        end
    end)
    return interiors
end

local function ExpandAllPrompts()
    for _, interior in ipairs(GetAllInteriors()) do
        FindPromptsInModel(interior, function(prompt)
            pcall(function()
                prompt.MaxActivationDistance = 9999
                prompt.RequiresLineOfSight = false
            end)
        end)
    end
end

local function FireAllPrompts()
    for _, interior in ipairs(GetAllInteriors()) do
        FindPromptsInModel(interior, function(prompt)
            pcall(function()
                if prompt and prompt.Parent then
                    fireproximityprompt(prompt)
                end
            end)
        end)
        task.wait(0.05)
    end
end

-- TELEPORT SYSTEM
local platform = nil
local platformY = nil
local heartbeatConn = nil
local isMoving = false
local speed = 14
local heightOffset = -11
local surfaceOffset = 3
local slowdownDist = 20
local slowdownMin = 0.15

local function createPlatform(yPos)
    if platform and platform.Parent then
        return platform
    end
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local part = Instance.new("Part")
    part.Name = "Quickz_Platform"
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

local function destroyPlatform()
    if platform and platform.Parent then
        platform.Transparency = 1
    end
    if heartbeatConn then
        heartbeatConn:Disconnect()
        heartbeatConn = nil
    end
end

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
        local moveStep = delta.Unit * math.min(moveSpeed * dt, distRemaining)
        local newPos = currentPos + moveStep
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

-- ============================================
-- MAIN PROCESS
-- ============================================
local function DoFarmingAndSell()
    if isRunning then return end
    isRunning = true
    startBtn.Text = "STOP FARMING"
    startBtn.BackgroundColor3 = colors.red

    statusLabel.Text = "Status: starting..."
    statusLabel.TextColor3 = colors.text

    task.spawn(function()
        -- 1. CEK BAHAN
        statusLabel.Text = "Status: checking materials..."
        if not HasTool("Water") or not HasTool("Sugar Block Bag") or 
           not HasTool("Gelatin") or not HasTool("Empty Bag") then
            statusLabel.Text = "Status: not enough materials!"
            statusLabel.TextColor3 = colors.red
            isRunning = false
            startBtn.Text = "START FARMING"
            startBtn.BackgroundColor3 = colors.green
            return
        end

        -- 2. FARMING LOOP
        ExpandAllPrompts()
        local farming = true
        statusLabel.Text = "Status: farming..."
        statusLabel.TextColor3 = colors.text

        farmTask = task.spawn(function()
            while farming and isRunning do
                -- Water
                if HasTool("Water") then
                    statusLabel.Text = "Status: Water..."
                    EquipTool("Water")
                    task.wait(0.3)
                    FireAllPrompts()
                    local elapsed = 0
                    while elapsed < 21 and farming and isRunning do
                        task.wait(0.5)
                        elapsed = elapsed + 0.5
                        statusLabel.Text = "Status: Water " .. math.ceil(21 - elapsed) .. "s"
                    end
                end
                if not isRunning then break end

                -- Sugar
                if HasTool("Sugar Block Bag") then
                    statusLabel.Text = "Status: Sugar..."
                    EquipTool("Sugar Block Bag")
                    task.wait(1)
                    if isRunning then FireAllPrompts() end
                end
                if not isRunning then break end
                task.wait(1)

                -- Gelatin
                if HasTool("Gelatin") then
                    statusLabel.Text = "Status: Gelatin..."
                    EquipTool("Gelatin")
                    task.wait(1)
                    if isRunning then FireAllPrompts() end
                end
                if not isRunning then break end
                task.wait(1)

                -- Empty Bag
                if HasTool("Empty Bag") then
                    statusLabel.Text = "Status: Empty Bag..."
                    EquipTool("Empty Bag")
                    task.wait(1)
                    if isRunning then
                        local elapsed = 0
                        while elapsed < 46 and farming and isRunning do
                            task.wait(0.5)
                            elapsed = elapsed + 0.5
                            statusLabel.Text = "Status: Cooking " .. math.ceil(46 - elapsed) .. "s"
                        end
                        if isRunning then
                            FireAllPrompts()
                            task.wait(0.5)
                        end
                    end
                end

                if not isRunning then break end

                -- Cek bahan habis
                if not HasTool("Water") and not HasTool("Sugar Block Bag") and 
                   not HasTool("Gelatin") and not HasTool("Empty Bag") then
                    statusLabel.Text = "Status: materials depleted"
                    break
                end
            end
        end)

        -- Tunggu farming selesai
        while farming and isRunning do
            task.wait(1)
            if not HasTool("Water") and not HasTool("Sugar Block Bag") and 
               not HasTool("Gelatin") and not HasTool("Empty Bag") then
                farming = false
                break
            end
        end

        if farmTask then
            task.cancel(farmTask)
            farmTask = nil
        end

        if not isRunning then
            statusLabel.Text = "Status: stopped"
            statusLabel.TextColor3 = colors.sub
            return
        end

        -- 3. TELEPORT KE PENJUAL
        statusLabel.Text = "Status: teleporting to seller..."
        statusLabel.TextColor3 = colors.text

        platformY = heightOffset + 0
        createPlatform(platformY)
        goUnderground()

        local SELLER_X = 770.992
        local SELLER_Z = 433.75

        teleportTo(Vector3.new(SELLER_X, 0, SELLER_Z), platformY, function(pct)
            statusLabel.Text = "Status: teleport " .. pct .. "%"
        end)

        surface()

        if not isRunning then
            statusLabel.Text = "Status: stopped"
            statusLabel.TextColor3 = colors.sub
            return
        end

        statusLabel.Text = "Status: arrived at seller"

        -- 4. AUTO SELL
        statusLabel.Text = "Status: selling..."
        StartSellLoop()

        -- Tunggu sell selesai (atau di-stop)
        while sellRunning and isRunning do
            task.wait(2)
            local items = GetAllItems()
            local hasSellable = false
            for _, item in ipairs(items) do
                if IsSellable(item) then
                    hasSellable = true
                    break
                end
            end
            if not hasSellable then
                break
            end
        end

        StopSellLoop()

        -- SELESAI
        statusLabel.Text = "Status: done!"
        statusLabel.TextColor3 = colors.green
        isRunning = false
        startBtn.Text = "START FARMING"
        startBtn.BackgroundColor3 = colors.green
    end)
end

-- ============================================
-- BUTTON EVENTS
-- ============================================
startBtn.MouseButton1Click:Connect(function()
    if isRunning then
        -- STOP
        isRunning = false
        if farmTask then
            task.cancel(farmTask)
            farmTask = nil
        end
        StopSellLoop()
        destroyPlatform()
        statusLabel.Text = "Status: stopped"
        statusLabel.TextColor3 = colors.sub
        startBtn.Text = "START FARMING"
        startBtn.BackgroundColor3 = colors.green
    else
        -- START
        DoFarmingAndSell()
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    isRunning = false
    if farmTask then task.cancel(farmTask) end
    StopSellLoop()
    destroyPlatform()
    screenGui:Destroy()
end)

minBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    minPanel.Visible = true
    minPanel:TweenPosition(UDim2.new(0.5, -70, 0, 45), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.3, true)
end)

minPanel.MouseButton1Click:Connect(function()
    minPanel:TweenPosition(UDim2.new(0.5, -70, 0, -50), Enum.EasingDirection.In, Enum.EasingStyle.Quart, 0.2, true, function()
        minPanel.Visible = false
        mainFrame.Visible = true
    end)
end)

print("Auto Farm loaded!")
print("Click START FARMING to begin.")