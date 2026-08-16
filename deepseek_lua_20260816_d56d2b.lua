--[[
    AUTO FARM - Simple ON/OFF
    - Tombol toggle besar
    - Support nama item Indonesia/Inggris
    - Farming → Teleport → Auto Sell
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

local function FarmingLoop()
    while farmActive do
        -- WATER
        if HasWater() then
            log("Farming: Water")
            EquipAnyItem({"Water", "Air"})
            task.wait(0.3)
            FireAllPrompts()
            local elapsed = 0
            while elapsed < 21 and farmActive do
                task.wait(0.5)
                elapsed = elapsed + 0.5
            end
        end
        if not farmActive then break end

        -- SUGAR
        if HasSugar() then
            log("Farming: Sugar")
            EquipAnyItem({"Sugar Block Bag", "Tas Blok Gula", "Sugar"})
            task.wait(1)
            if farmActive then FireAllPrompts() end
        end
        if not farmActive then break end
        task.wait(1)

        -- GELATIN
        if HasGelatin() then
            log("Farming: Gelatin")
            EquipAnyItem({"Gelatin"})
            task.wait(1)
            if farmActive then FireAllPrompts() end
        end
        if not farmActive then break end
        task.wait(1)

        -- COOKING
        log("Farming: Cooking...")
        local elapsed = 0
        while elapsed < 46 and farmActive do
            task.wait(0.5)
            elapsed = elapsed + 0.5
        end
        if farmActive then
            FireAllPrompts()
            task.wait(0.5)
        end

        if not farmActive then break end

        -- Check materials
        if not HasWater() and not HasSugar() and not HasGelatin() then
            log("Farming: Materials depleted, stopping farm.")
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
        log("Error: No Water/Air found!")
        return false
    end
    if not HasSugar() then
        log("Error: No Sugar found!")
        return false
    end
    if not HasGelatin() then
        log("Error: No Gelatin found!")
        return false
    end

    log("All materials OK. Starting farming...")

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

    log("Farming finished. Teleporting to seller...")

    -- Teleport to seller
    local SELLER_X = 770.992
    local SELLER_Z = 433.75

    local char = player.Character
    if not char then
        log("Error: No character!")
        return false
    end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then
        log("Error: No HumanoidRootPart!")
        return false
    end

    platformY = heightOffset + 0
    createPlatform(platformY)
    goUnderground()

    teleportTo(Vector3.new(SELLER_X, 0, SELLER_Z), platformY, function(pct)
        log("Teleport progress: " .. pct .. "%")
    end)

    surface()

    log("Arrived at seller. Starting auto sell...")

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
    log("Auto sell finished. Done!")

    return true
end

-- ============================================
-- UI - Simple ON/OFF Button
-- ============================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoFarmToggle"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 160, 0, 60)
frame.Position = UDim2.new(0.5, -80, 0.5, -30)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
frame.BorderSizePixel = 1
frame.BorderColor3 = Color3.fromRGB(55, 55, 60)
frame.Parent = screenGui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

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
makeDraggable(frame)

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(1, -10, 1, -10)
toggleBtn.Position = UDim2.new(0, 5, 0, 5)
toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 80)
toggleBtn.BorderSizePixel = 0
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.Text = "OFF"
toggleBtn.TextColor3 = Color3.fromRGB(255,255,255)
toggleBtn.TextSize = 18
toggleBtn.Parent = frame
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 6)

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
        toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 80)
        log("Stopped by user.")
    else
        -- START
        isRunning = true
        toggleBtn.Text = "ON"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        log("Starting process...")
        processTask = task.spawn(function()
            local success, err = pcall(RunAutoProcess)
            if not success then
                log("ERROR: " .. tostring(err))
            end
            -- Reset UI after finish
            if isRunning then
                isRunning = false
                toggleBtn.Text = "OFF"
                toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 80)
                log("Process finished.")
            end
        end)
    end
end)

log("UI loaded. Click 'OFF' to start, click again to stop.")