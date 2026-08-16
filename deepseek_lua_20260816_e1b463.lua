--[[
    AUTO FARM - X2ZU UI INTEGRATION (FULL SCRIPT)
    - Toggle ON/OFF untuk start/stop farming
    - Status real-time di UI
    - Support multi nama item (Water/Air, Sugar Block Bag/Tas Blok Gula)
    - Auto teleport ke Marshmallow Seller (770.99, 433.75)
    - Auto sell semua item yang bisa dijual
]]

-- ============================================
-- LOAD UI LIBRARY
-- ============================================
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/DummyUi-leak-by-x2zu/fetching-main/Tools/Framework.luau"))()

-- ============================================
-- CREATE MAIN WINDOW
-- ============================================
local Window = Library:Window({
    Title = "Auto Farm",
    Desc = "Simple ON/OFF Auto Farm",
    Icon = 105059922903197,
    Theme = "Dark",
    Config = {
        Keybind = Enum.KeyCode.LeftControl,
        Size = UDim2.new(0, 450, 0, 350)
    },
    CloseUIButton = {
        Enabled = true,
        Text = "X"
    }
})

-- ============================================
-- TAB: MAIN
-- ============================================
local MainTab = Window:Tab({Title = "Main", Icon = "star"})

-- Section: Status
MainTab:Section({Title = "Status"})
local StatusCode = MainTab:Code({
    Title = "Auto Farm Status",
    Code = "Ready"
})

-- Fungsi update status
local function SetStatus(text)
    StatusCode:SetCode(text)
end

-- Section: Control
MainTab:Section({Title = "Control"})

-- Variabel state
local isRunning = false
local farmThread = nil
local sellThread = nil
local farmingActive = false

-- ============================================
-- FUNGSI AUTO FARM (Semua logika)
-- ============================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local player = Players.LocalPlayer

-- ITEM FUNCTIONS
local function HasAnyItem(names)
    local bp = player:FindFirstChild("Backpack")
    local char = player.Character
    for _, name in ipairs(names) do
        if bp and bp:FindFirstChild(name) then return true end
        if char and char:FindFirstChild(name) then return true end
    end
    return false
end

local function HasWater() return HasAnyItem({"Water", "Air"}) end
local function HasSugar() return HasAnyItem({"Sugar Block Bag", "Tas Blok Gula", "Sugar"}) end
local function HasGelatin() return HasAnyItem({"Gelatin"}) end

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
            pcall(function() hum:EquipTool(tool) end)
            task.wait(0.3)
            return true
        end
    end
    return false
end

-- PROXIMITY PROMPT FUNCTIONS
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
                    if desc:IsA("ProximityPrompt") then callback(desc) end
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
                if prompt and prompt.Parent then fireproximityprompt(prompt) end
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
    if platform and platform.Parent then platform:Destroy() end
    if heartbeatConn then heartbeatConn:Disconnect() end
    platform = nil
    heartbeatConn = nil
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
    pcall(function() hrp.CFrame = CFrame.new(hrp.Position.X, targetY, hrp.Position.Z) end)
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
            pcall(function() hrpNow.CFrame = CFrame.new(targetPos.X, targetY, targetPos.Z) end)
            finished = true
            if moveConn then moveConn:Disconnect() end
            return
        end

        local step = delta.Unit * math.min(speed * dt, distRemaining)
        local newPos = currentPos + step
        pcall(function() hrpNow.CFrame = CFrame.new(newPos.X, targetY, newPos.Y) end)
    end)

    while not finished do task.wait(0.05) end
    isMoving = false
    humanoid.WalkSpeed = origSpeed
    humanoid.JumpPower = origJump
end

-- SELL SYSTEM
local SELL_ITEMS = {
    "Small Marshmallow Bag", "Medium Marshmallow Bag", "Large Marshmallow Bag",
    "Water", "Air", "Sugar Block Bag", "Tas Blok Gula", "Gelatin"
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
            if sold == 0 then task.wait(5) else task.wait(2) end
        end
    end)
end

local function StopSellLoop()
    sellRunning = false
    if sellTask then task.cancel(sellTask); sellTask = nil end
end

-- ============================================
-- FARMING CORE
-- ============================================
local farmActive = false
local farmTask = nil

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

        if not HasWater() and not HasSugar() and not HasGelatin() then
            SetStatus("Materials depleted!")
            break
        end
    end
end

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

    if farmTask then task.cancel(farmTask); farmTask = nil end

    SetStatus("Teleporting to seller...")
    local SELLER_X, SELLER_Z = 770.992, 433.75

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
    teleportTo(Vector3.new(SELLER_X, 0, SELLER_Z), platformY)
    surface()

    SetStatus("Arrived! Auto selling...")
    StartSellLoop()

    while sellRunning do
        task.wait(2)
        local hasSellable = false
        for _, item in ipairs(GetAllItems()) do
            if IsSellable(item) then
                hasSellable = true
                break
            end
        end
        if not hasSellable then break
    end

    StopSellLoop()
    SetStatus("DONE! ✓")
    return true
end

-- ============================================
-- TOGGLE UI (ON/OFF)
-- ============================================
local toggleValue = false
local processThread = nil

MainTab:Toggle({
    Title = "Enable Auto Farm",
    Desc = "Toggle ON to start farming, OFF to stop",
    Value = false,
    Callback = function(v)
        toggleValue = v
        if v then
            -- START
            if isRunning then return end
            isRunning = true
            SetStatus("Starting...")
            Window:Notify({
                Title = "Auto Farm",
                Desc = "Farming started!",
                Time = 2
            })
            processThread = task.spawn(function()
                local success, err = pcall(RunAutoProcess)
                if not success then
                    SetStatus("ERROR: " .. tostring(err))
                    Window:Notify({
                        Title = "Error",
                        Desc = tostring(err),
                        Time = 4
                    })
                end
                -- Reset toggle when done
                if isRunning then
                    isRunning = false
                    -- Update toggle UI? Library doesn't provide direct setValue, but we can toggle back via callback? 
                    -- We'll just reset state and let user toggle again.
                    -- We can't change toggle value from code, but user can toggle again.
                end
            end)
        else
            -- STOP
            isRunning = false
            farmActive = false
            if farmTask then task.cancel(farmTask); farmTask = nil end
            StopSellLoop()
            destroyPlatform()
            if processThread then task.cancel(processThread); processThread = nil end
            SetStatus("Stopped by user.")
            Window:Notify({
                Title = "Auto Farm",
                Desc = "Farming stopped.",
                Time = 2
            })
        end
    end
})

-- ============================================
-- BUTTON MANUAL START/STOP (opsional)
-- ============================================
MainTab:Button({
    Title = "Force Stop",
    Desc = "Emergency stop if toggle fails",
    Callback = function()
        if isRunning then
            isRunning = false
            farmActive = false
            if farmTask then task.cancel(farmTask); farmTask = nil end
            StopSellLoop()
            destroyPlatform()
            if processThread then task.cancel(processThread); processThread = nil end
            SetStatus("Emergency stopped.")
            Window:Notify({
                Title = "Auto Farm",
                Desc = "Emergency stop executed.",
                Time = 2
            })
        else
            Window:Notify({
                Title = "Auto Farm",
                Desc = "Not running.",
                Time = 2
            })
        end
    end
})

-- ============================================
-- NOTIFIKASI AWAL
-- ============================================
Window:Notify({
    Title = "Auto Farm",
    Desc = "Toggle ON to start farming. Make sure you have Water, Sugar, and Gelatin.",
    Time = 5
})

print("[AutoFarm] UI loaded with X2ZU Library.")