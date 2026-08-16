--[[
    AUTO FARM - SIMPLE ON/OFF
    UI seperti gambar: Tombol ON/OFF besar, status di bawah
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui", 10)

-- ============================================
-- DEBUG
-- ============================================
local function log(msg)
    print("[AutoFarm] " .. msg)
end
log("Script loaded!")

-- ============================================
-- ITEM FUNCTIONS (Support multi nama)
-- ============================================
local function HasAnyItem(names)
    local bp = player:FindFirstChild("Backpack")
    local char = player.Character
    for _, name in ipairs(names) do
        if bp and bp:FindFirstChild(name) then return true end
        if char and char:FindFirstChild(name) then return true end
    end
    return false
end

local function HasWater()
    return HasAnyItem({"Water", "Air"})
end

local function HasSugar()
    return HasAnyItem({"Sugar Block Bag", "Tas Blok Gula", "Sugar"})
end

local function HasGelatin()
    return HasAnyItem({"Gelatin"})
end

local function EquipAnyItem(names)
    local bp = player:FindFirstChild("Backpack")
    if not bp then return false end
    for _, name in ipairs(names) do
        local tool = bp:FindFirstChild(name)
        if tool then
            local char = player.Character
            if not char then return false end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hum then return false end
            pcall(function()
                hum:EquipTool(tool)
            end)
            task.wait(0.3)
            return true
        end
    end
    return false
end

-- ============================================
-- PROXIMITY PROMPT FUNCTIONS
-- ============================================
local function FindPromptsInModel(model, callback)
    for _, child in ipairs(model:GetDescendants()) do
        if child.Name == "Cooking Pot" then
            local attach = child:FindFirstChild("Attachment")
            if attach then
                local prompt = attach:FindFirstChildOfClass("ProximityPrompt")
                if prompt then callback(prompt) end
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
                if interior then table.insert(interiors, interior) end
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
                        if interior then table.insert(interiors, interior) end
                    end
                    if child:IsA("Folder") or child:IsA("Model") then
                        local apt2 = child:FindFirstChild("Apartment")
                        if apt2 then
                            local interior2 = apt2:FindFirstChild("Interior")
                            if interior2 then table.insert(interiors, interior2) end
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

-- ============================================
-- TELEPORT SYSTEM (Underground)
-- ============================================
local platform = nil
local platformY = nil
local heartbeatConn = nil
local isMoving = false
local speed = 14
local heightOffset = -11
local surfaceOffset = 3

local function createPlatform(yPos)
    if platform and platform.Parent then return platform end
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
        platform:Destroy()
    end
    if heartbeatConn then
        heartbeatConn:Disconnect()
        heartbeatConn = nil
    end
    platform = nil
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

local function teleportTo(targetPos, yBase)
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
        local step = delta.Unit * math.min(moveSpeed * dt, distRemaining)
        local newPos = currentPos + step
        pcall(function()
            hrpNow.CFrame = CFrame.new(newPos.X, targetY, newPos.Y)
        end)
    end)

    while not finished do
        task.wait(0.05)
    end

    isMoving = false
    humanoid.WalkSpeed = origSpeed
    humanoid.JumpPower = origJump
end

-- ============================================
-- SELL SYSTEM
-- ============================================
local SELL_ITEMS = {
    "Small Marshmallow Bag", "Medium Marshmallow Bag", "Large Marshmallow Bag",
    "Water", "Air",
    "Sugar Block Bag", "Tas Blok Gula",
    "Gelatin"
}

local function IsSellable(item)
    for _, name in ipairs(SELL_ITEMS) do
        if item.Name == name then return true end
    end
    return false
end

local function GetAllItems()
    local items = {}
    local bp = player:FindFirstChild("Backpack")
    local char = player.Character
    if bp then
        for _, child in pairs(bp:GetChildren()) do
            if child:IsA("Tool") then table.insert(items, child) end
        end
    end
    if char then
        for _, child in pairs(char:GetChildren()) do
            if child:IsA("Tool") then table.insert(items, child) end
        end
    end
    return items
end

local function EquipSellItem(item)
    local char = player.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return false end
    if item.Parent == player:FindFirstChild("Backpack") then
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

local sellRunning = false
local sellTask = nil

local function StartSellLoop()
    if sellRunning then return end
    sellRunning = true
    sellTask = task.spawn(function()
        while sellRunning do
            local items = GetAllItems()
            local sold = 0
            for _, item in ipairs(items) do
                if IsSellable(item) then
                    if EquipSellItem(item) then
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

-- ============================================
-- FARMING PROCESS
-- ============================================
local isFarming = false
local farmTask = nil
local farmActive = false
local statusText = nil

local function SetStatus(text)
    if statusText then
        statusText.Text = text
    end
    log(text)
end

local function FarmingLoop()
    while farmActive do
        -- WATER
        if HasWater() then
            SetStatus("Farming: Water...")
            EquipAnyItem({"Water", "Air"})
            task.wait(0.3)
            FireAllPrompts()
            local elapsed = 0
            while elapsed < 21 and farmActive do
                task.wait(0.5)
                elapsed = elapsed + 0.5
                SetStatus("Water: " .. math.ceil(21 - elapsed) .. "s")
            end
        end
        if not farmActive then break end

        -- SUGAR
        if HasSugar() then
            SetStatus("Farming: Sugar...")
            EquipAnyItem({"Sugar Block Bag", "Tas Blok Gula", "Sugar"})
            task.wait(1)
            if farmActive then FireAllPrompts() end
        end
        if not farmActive then break end
        task.wait(1)

        -- GELATIN
        if HasGelatin() then
            SetStatus("Farming: Gelatin...")
            EquipAnyItem({"Gelatin"})
            task.wait(1)
            if farmActive then FireAllPrompts() end
        end
        if not farmActive then break end
        task.wait(1)

        -- COOKING
        SetStatus("Cooking...")
        local elapsed = 0
        while elapsed < 46 and farmActive do
            task.wait(0.5)
            elapsed = elapsed + 0.5
            SetStatus("Cooking: " .. math.ceil(46 - elapsed) .. "s")
        end
        if farmActive then
            FireAllPrompts()
            task.wait(0.5)
        end

        if not farmActive then break end

        -- Check materials
        if not HasWater() and not HasSugar() and not HasGelatin() then
            SetStatus("Materials depleted!")
            break
        end
    end
end

-- ============================================
-- MAIN AUTO PROCESS
-- ============================================
local function RunAutoProcess()
    -- Check materials
    if not HasWater() then
        SetStatus("ERROR: No Water/Air!")
        return false
    end
    if not HasSugar() then
        SetStatus("ERROR: No Sugar!")
        return false
    end
    if not HasGelatin() then
        SetStatus("ERROR: No Gelatin!")
        return false
    end

    SetStatus("Starting farming...")

    -- Expand prompts
    ExpandAllPrompts()

    -- Start farming loop
    farmActive = true
    farmTask = task.spawn(FarmingLoop)

    -- Wait until materials depleted or stopped
    while farmActive do
        task.wait(1)
        if not HasWater() and not HasSugar() and not HasGelatin() then
            farmActive = false
            break
        end
    end

    if farmTask then
        task.cancel(farmTask)
        farmTask = nil
    end

    SetStatus("Teleporting to seller...")

    -- Teleport to seller
    local SELLER_X = 770.992
    local SELLER_Z = 433.75

    local char = player.Character
    if not char then
        SetStatus("ERROR: No character!")
        return false
    end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then
        SetStatus("ERROR: No HumanoidRootPart!")
        return false
    end

    platformY = heightOffset + 0
    createPlatform(platformY)
    goUnderground()

    SetStatus("Teleporting...")
    teleportTo(Vector3.new(SELLER_X, 0, SELLER_Z), platformY)

    surface()

    SetStatus("Arrived! Auto selling...")

    -- Start selling
    StartSellLoop()

    -- Wait for sell to finish or stop
    while sellRunning do
        task.wait(2)
        local hasSellable = false
        for _, item in ipairs(GetAllItems()) do
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
    SetStatus("DONE! ✓")
    return true
end

-- ============================================
-- UI - SEPERTI GAMBAR (Farmer ON/OFF)
-- ============================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoFarmToggle"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = PlayerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 150, 0, 80)
mainFrame.Position = UDim2.new(0.5, -75, 0.5, -40)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
mainFrame.BorderSizePixel = 1
mainFrame.BorderColor3 = Color3.fromRGB(40, 40, 50)
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)

-- Draggable
local function makeDraggable(f)
    local dragging = false
    local dragStart, startPos
    f.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = Vector2.new(input.Position.X, input.Position.Y)
            startPos = Vector2.new(f.Position.X.Offset, f.Position.Y.Offset)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
        local delta = Vector2.new(input.Position.X, input.Position.Y) - dragStart
        local vp = workspace.CurrentCamera.ViewportSize
        local sz = f.AbsoluteSize
        f.Position = UDim2.new(0, math.clamp(startPos.X + delta.X, 0, vp.X - sz.X), 0, math.clamp(startPos.Y + delta.Y, 0, vp.Y - sz.Y))
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end
makeDraggable(mainFrame)

-- Label "Auto Farm"
local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, 0, 0, 20)
label.Position = UDim2.new(0, 0, 0, 4)
label.BackgroundTransparency = 1
label.Font = Enum.Font.GothamBold
label.Text = "AUTO FARM"
label.TextColor3 = Color3.fromRGB(255, 255, 255)
label.TextSize = 11
label.TextXAlignment = Enum.TextXAlignment.Center
label.Parent = mainFrame

-- Status text (seperti "Farmer")
statusText = Instance.new("TextLabel")
statusText.Size = UDim2.new(1, 0, 0, 16)
statusText.Position = UDim2.new(0, 0, 0, 24)
statusText.BackgroundTransparency = 1
statusText.Font = Enum.Font.Gotham
statusText.Text = "Farmer • OFF"
statusText.TextColor3 = Color3.fromRGB(200, 200, 200)
statusText.TextSize = 10
statusText.TextXAlignment = Enum.TextXAlignment.Center
statusText.Parent = mainFrame

-- Toggle Button (seperti tombol "OFF")
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0.8, 0, 0, 24)
toggleBtn.Position = UDim2.new(0.1, 0, 0, 44)
toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
toggleBtn.BorderSizePixel = 1
toggleBtn.BorderColor3 = Color3.fromRGB(80, 80, 90)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.Text = "OFF"
toggleBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
toggleBtn.TextSize = 14
toggleBtn.Parent = mainFrame
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 4)

-- ============================================
-- TOGGLE LOGIC
-- ============================================
local isRunning = false
local processTask = nil

toggleBtn.MouseButton1Click:Connect(function()
    if isRunning then
        -- STOP
        isRunning = false
        farmActive = false
        if farmTask then task.cancel(farmTask); farmTask = nil end
        StopSellLoop()
        destroyPlatform()
        if processTask then task.cancel(processTask); processTask = nil end
        toggleBtn.Text = "OFF"
        toggleBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
        toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        statusText.Text = "Farmer • OFF"
        statusText.TextColor3 = Color3.fromRGB(200, 200, 200)
        log("Stopped by user.")
    else
        -- START
        isRunning = true
        toggleBtn.Text = "ON"
        toggleBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
        toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 80, 40)
        statusText.Text = "Farmer • ON"
        statusText.TextColor3 = Color3.fromRGB(100, 255, 100)
        log("Starting process...")
        processTask = task.spawn(function()
            local success, err = pcall(RunAutoProcess)
            if not success then
                log("ERROR: " .. tostring(err))
                statusText.Text = "ERROR!"
                statusText.TextColor3 = Color3.fromRGB(255, 50, 50)
            end
            -- Reset UI after finish
            if isRunning then
                isRunning = false
                toggleBtn.Text = "OFF"
                toggleBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
                toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
                statusText.Text = "Farmer • OFF"
                statusText.TextColor3 = Color3.fromRGB(200, 200, 200)
                log("Process finished.")
            end
        end)
    end
end)

log("UI loaded! Click OFF/ON to start/stop auto farm.")

-- Auto start (opsional, biarkan user yang klik)