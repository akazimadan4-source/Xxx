--[[
    AUTO FARM SCRIPT
    UI dengan Pack Counter + Full Auto Toggle
]]

-- ============================================
-- SERVICES
-- ============================================
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 15)

-- ============================================
-- UI CREATION
-- ============================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoFarmUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = PlayerGui

-- MAIN FRAME
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 220)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -110)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

-- Shadow/Stroke
local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(40, 40, 50)
Stroke.Thickness = 1
Stroke.Parent = MainFrame

-- ============================================
-- HEADER (Title Bar)
-- ============================================
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 35)
Header.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
Header.BorderSizePixel = 0
Header.Parent = MainFrame
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 10, 0, 0)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.Text = "🚜 AUTO FARM"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.Position = UDim2.new(1, -30, 0.5, -12)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Font = Enum.Font.Gotham
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
CloseBtn.TextSize = 16
CloseBtn.Parent = Header

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- ============================================
-- PACK COUNT SECTION
-- ============================================
local PackFrame = Instance.new("Frame")
PackFrame.Size = UDim2.new(1, -24, 0, 70)
PackFrame.Position = UDim2.new(0, 12, 0, 48)
PackFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
PackFrame.BorderSizePixel = 0
PackFrame.Parent = MainFrame
Instance.new("UICorner", PackFrame).CornerRadius = UDim.new(0, 8)

-- Label "Jumlah Pack (0/?)"
local PackLabel = Instance.new("TextLabel")
PackLabel.Size = UDim2.new(1, 0, 0, 22)
PackLabel.Position = UDim2.new(0, 0, 0, 4)
PackLabel.BackgroundTransparency = 1
PackLabel.Font = Enum.Font.Gotham
PackLabel.Text = "📦 Jumlah Pack (0/?)"
PackLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
PackLabel.TextSize = 12
PackLabel.TextXAlignment = Enum.TextXAlignment.Center
PackLabel.Parent = PackFrame

-- Counter Container
local CounterContainer = Instance.new("Frame")
CounterContainer.Size = UDim2.new(1, -20, 0, 32)
CounterContainer.Position = UDim2.new(0, 10, 0, 28)
CounterContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
CounterContainer.BorderSizePixel = 0
CounterContainer.Parent = PackFrame
Instance.new("UICorner", CounterContainer).CornerRadius = UDim.new(0, 6)

-- Minus Button
local MinusBtn = Instance.new("TextButton")
MinusBtn.Size = UDim2.new(0, 32, 1, 0)
MinusBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
MinusBtn.BorderSizePixel = 0
MinusBtn.Font = Enum.Font.GothamBold
MinusBtn.Text = "−"
MinusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinusBtn.TextSize = 20
MinusBtn.Parent = CounterContainer
Instance.new("UICorner", MinusBtn).CornerRadius = UDim.new(0, 6, 0, 0)

-- Value Display
local ValueLabel = Instance.new("TextLabel")
ValueLabel.Size = UDim2.new(1, -64, 1, 0)
ValueLabel.Position = UDim2.new(0, 32, 0, 0)
ValueLabel.BackgroundTransparency = 1
ValueLabel.Font = Enum.Font.GothamBold
ValueLabel.Text = "1"
ValueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
ValueLabel.TextSize = 22
ValueLabel.TextXAlignment = Enum.TextXAlignment.Center
ValueLabel.Parent = CounterContainer

-- Plus Button
local PlusBtn = Instance.new("TextButton")
PlusBtn.Size = UDim2.new(0, 32, 1, 0)
PlusBtn.Position = UDim2.new(1, -32, 0, 0)
PlusBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
PlusBtn.BorderSizePixel = 0
PlusBtn.Font = Enum.Font.GothamBold
PlusBtn.Text = "+"
PlusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
PlusBtn.TextSize = 20
PlusBtn.Parent = CounterContainer
Instance.new("UICorner", PlusBtn).CornerRadius = UDim.new(0, 0, 6, 0)

-- ============================================
-- FULL AUTO BUTTON
-- ============================================
local AutoContainer = Instance.new("Frame")
AutoContainer.Size = UDim2.new(1, -24, 0, 45)
AutoContainer.Position = UDim2.new(0, 12, 0, 128)
AutoContainer.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
AutoContainer.BorderSizePixel = 0
AutoContainer.Parent = MainFrame
Instance.new("UICorner", AutoContainer).CornerRadius = UDim.new(0, 8)

-- Full Auto Button (kiri)
local FullAutoBtn = Instance.new("TextButton")
FullAutoBtn.Size = UDim2.new(0.5, -4, 1, 0)
FullAutoBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
FullAutoBtn.BorderSizePixel = 0
FullAutoBtn.Font = Enum.Font.GothamBold
FullAutoBtn.Text = "▶ FULL AUTO"
FullAutoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FullAutoBtn.TextSize = 14
FullAutoBtn.Parent = AutoContainer
Instance.new("UICorner", FullAutoBtn).CornerRadius = UDim.new(0, 8)

-- Status Button (kanan)
local StatusBtn = Instance.new("TextButton")
StatusBtn.Size = UDim2.new(0.5, -4, 1, 0)
StatusBtn.Position = UDim2.new(0.5, 4, 0, 0)
StatusBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
StatusBtn.BorderSizePixel = 0
StatusBtn.Font = Enum.Font.Gotham
StatusBtn.Text = "⏸ IDLE"
StatusBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusBtn.TextSize = 12
StatusBtn.Parent = AutoContainer
Instance.new("UICorner", StatusBtn).CornerRadius = UDim.new(0, 8)

-- ============================================
-- MAKE DRAGGABLE
-- ============================================
local function MakeDraggable(frame)
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
           input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end

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

MakeDraggable(MainFrame)

-- ============================================
-- COUNTER LOGIC
-- ============================================
local packCount = 1

local function UpdatePackCount()
    ValueLabel.Text = tostring(packCount)
    PackLabel.Text = "📦 Jumlah Pack (" .. packCount .. "/?)"
end

MinusBtn.MouseButton1Click:Connect(function()
    if packCount > 1 then
        packCount = packCount - 1
        UpdatePackCount()
    end
end)

PlusBtn.MouseButton1Click:Connect(function()
    if packCount < 99 then
        packCount = packCount + 1
        UpdatePackCount()
    end
end)

-- ============================================
-- FARM VARIABLES
-- ============================================
local isFarming = false
local farmTask = nil
local antiAfkTask = nil
local antiAfkEnabled = false

local BagPrices = {
    ["Small Marshmallow Bag"] = 1470,
    ["Medium Marshmallow Bag"] = 2840,
    ["Large Marshmallow Bag"] = 4150
}

local BagNames = {"Small Marshmallow Bag", "Medium Marshmallow Bag", "Large Marshmallow Bag"}
local RequiredItems = {"Water", "Empty Bag", "Sugar Block Bag", "Gelatin"}

local RightPos = CFrame.new(1138.20325, 7.88028622, 451.605072)
local LamontBellPos = Vector3.new(510.33, -3.57, 597.75)

local platform = nil
local platform2 = nil
local originalCFrame = nil

-- ============================================
-- UTILITY FUNCTIONS
-- ============================================
local function CountItem(name)
    local count = 0
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    local character = LocalPlayer.Character

    if backpack then
        for _, child in ipairs(backpack:GetChildren()) do
            if child.Name == name then
                count = count + 1
            end
        end
    end
    if character then
        for _, child in ipairs(character:GetChildren()) do
            if child.Name == name then
                count = count + 1
            end
        end
    end
    return count
end

local function CountBags()
    local count = 0
    for _, name in ipairs(BagNames) do
        count = count + CountItem(name)
    end
    return count
end

local function HasTool(name)
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    local character = LocalPlayer.Character
    if backpack and backpack:FindFirstChild(name) then return true end
    if character and character:FindFirstChild(name) then return true end
    return false
end

local function EquipTool(name)
    local character = LocalPlayer.Character
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not character or not backpack then return false end

    local tool = backpack:FindFirstChild(name)
    if not tool then return false end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false end

    pcall(function()
        humanoid:EquipTool(tool)
    end)

    task.wait(0.3)
    return character:FindFirstChild(name) ~= nil
end

-- ============================================
-- PROMPT FUNCTIONS
-- ============================================
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

-- ============================================
-- POSITION FUNCTIONS
-- ============================================
local function CreatePlatform(cframe, name)
    local part = Instance.new("Part")
    part.Name = name
    part.Size = Vector3.new(2000, 1, 2000)
    part.Anchored = true
    part.CanCollide = true
    part.Transparency = 0.5
    part.CFrame = cframe * CFrame.new(0, -11, 0)
    part.Parent = workspace
    return part
end

local function GoUnderMap(part)
    local character = LocalPlayer.Character
    if not character then return end
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    root.Anchored = true
    task.wait(0.05)
    pcall(function()
        root.CFrame = part.CFrame + Vector3.new(0, 3.5, 0)
    end)
    task.wait(0.1)
    root.Anchored = false
end

local function GoToPosition(pos)
    local character = LocalPlayer.Character
    if not character then return end
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    local startPos = root.Position
    local distance = (startPos - pos).Magnitude
    if distance < 1 then return end
    
    local speed = math.clamp(distance / 3, 10, 60)
    local steps = math.ceil(speed / 0.5)
    local stepSize = speed / steps

    humanoid.WalkSpeed = 0
    humanoid.JumpPower = 0

    for i = 1, steps do
        if not isFarming then break end
        local t = i / steps
        local smooth = t * t * (3 - 2 * t)
        pcall(function()
            root.CFrame = CFrame.new(startPos:Lerp(pos, smooth))
        end)
        task.wait(stepSize / speed)
    end

    pcall(function()
        root.CFrame = CFrame.new(pos)
    end)

    humanoid.WalkSpeed = 16
    humanoid.JumpPower = 50
end

local function SetCamera(cframe)
    pcall(function()
        workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
        workspace.CurrentCamera.CFrame = cframe
    end)
end

local function ResetCamera()
    pcall(function()
        workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
    end)
end

local function RestorePosition()
    local character = LocalPlayer.Character
    if character then
        local root = character:FindFirstChild("HumanoidRootPart")
        if root and originalCFrame then
            pcall(function()
                root.CFrame = originalCFrame
            end)
        end
    end
    if platform and platform.Parent then platform:Destroy() end
    if platform2 and platform2.Parent then platform2:Destroy() end
    platform = nil
    platform2 = nil
    ResetCamera()
end

-- ============================================
-- LAMONT BELL
-- ============================================
local function GetLamontBellPrompt()
    local map = workspace:FindFirstChild("Map")
    if not map then return nil end
    local houses = map:FindFirstChild("Houses")
    if not houses then return nil end
    local wh1 = houses:FindFirstChild("WH1")
    if not wh1 then return nil end
    local interior = wh1:FindFirstChild("Interior")
    if not interior then return nil end

    for _, child in ipairs(interior:GetDescendants()) do
        if child:IsA("ProximityPrompt") then
            local parent = child.Parent
            if parent and parent.Name == "UpperTorso" then
                local model = parent.Parent
                if model and model.Name == "Lamont Bell" then
                    return child
                end
            end
        end
    end
    return nil
end

-- ============================================
-- FARM LOOP
-- ============================================
local function FarmLoop()
    while isFarming do
        -- Water
        if HasTool("Water") then
            StatusBtn.Text = "💧 Water"
            if EquipTool("Water") then
                task.wait(0.3)
                FireAllPrompts()
                local elapsed = 0
                while elapsed < 21 and isFarming do
                    task.wait(0.5)
                    elapsed = elapsed + 0.5
                    StatusBtn.Text = "💧 " .. math.ceil(21 - elapsed) .. "s"
                end
            end
        end

        if not isFarming then break end
        task.wait(1)

        -- Sugar
        if HasTool("Sugar Block Bag") then
            StatusBtn.Text = "🍬 Sugar"
            if EquipTool("Sugar Block Bag") then
                task.wait(1)
                if isFarming then
                    FireAllPrompts()
                end
            end
        end

        if not isFarming then break end
        task.wait(1)

        -- Gelatin
        if HasTool("Gelatin") then
            StatusBtn.Text = "🧊 Gelatin"
            if EquipTool("Gelatin") then
                task.wait(1)
                if isFarming then
                    FireAllPrompts()
                end
            end
        end

        if not isFarming then break end
        task.wait(1)

        -- Empty Bag
        if HasTool("Empty Bag") then
            StatusBtn.Text = "🎒 Empty"
            if EquipTool("Empty Bag") then
                task.wait(1)
                if isFarming then
                    local elapsed = 0
                    while elapsed < 46 and isFarming do
                        task.wait(0.5)
                        elapsed = elapsed + 0.5
                        StatusBtn.Text = "🔥 " .. math.ceil(46 - elapsed) .. "s"
                    end
                    if isFarming then
                        FireAllPrompts()
                        task.wait(0.5)
                    end
                end
            end
        end

        if not isFarming then break end
        
        -- Check items
        if not HasTool("Water") and not HasTool("Sugar Block Bag") and 
           not HasTool("Gelatin") and not HasTool("Empty Bag") then
            StatusBtn.Text = "⏸ NO ITEMS"
            task.wait(2)
            StopFarming()
            break
        end
    end
end

-- ============================================
-- MAIN AUTO FUNCTION
-- ============================================
local function RunAuto()
    local character = LocalPlayer.Character
    if not character then
        StatusBtn.Text = "⚠️ No char"
        return
    end

    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then
        StatusBtn.Text = "⚠️ No char"
        return
    end

    -- Check items
    local hasWater = HasTool("Water")
    local hasSugar = HasTool("Sugar Block Bag")
    local hasGelatin = HasTool("Gelatin")
    local hasEmpty = HasTool("Empty Bag")

    if not hasWater or not hasSugar or not hasGelatin or not hasEmpty then
        StatusBtn.Text = "⚠️ Missing items!"
        return
    end

    originalCFrame = root.CFrame

    -- Phase 1: Underground
    StatusBtn.Text = "⏬ Under..."
    platform = CreatePlatform(root.CFrame, "AutoPlatform1")
    GoUnderMap(platform)
    task.wait(0.3)
    SetCamera(RightPos)

    isFarming = true
    ExpandAllPrompts()

    StatusBtn.Text = "▶ FARMING"
    farmTask = task.spawn(FarmLoop)

    -- Wait for items to deplete
    while isFarming do
        task.wait(1)
        if not HasTool("Water") and not HasTool("Sugar Block Bag") and 
           not HasTool("Gelatin") and not HasTool("Empty Bag") then
            StopFarming()
            break
        end
    end

    task.wait(0.5)

    -- Cleanup
    if platform and platform.Parent then
        platform:Destroy()
        platform = nil
    end

    local char2 = LocalPlayer.Character
    if not char2 then
        StatusBtn.Text = "⚠️ No char"
        return
    end

    local root2 = char2:FindFirstChild("HumanoidRootPart")
    if not root2 then
        StatusBtn.Text = "⚠️ No char"
        return
    end

    -- Phase 2: Deeper
    StatusBtn.Text = "⏬ Deeper..."
    platform2 = CreatePlatform(root2.CFrame, "AutoPlatform2")
    GoUnderMap(platform2)
    task.wait(0.2)
    ResetCamera()

    local char3 = LocalPlayer.Character
    if not char3 then
        StatusBtn.Text = "⚠️ No char"
        RestorePosition()
        return
    end

    local root3 = char3:FindFirstChild("HumanoidRootPart")
    if not root3 then
        StatusBtn.Text = "⚠️ No char"
        RestorePosition()
        return
    end

    local pos = root3.Position

    -- Walk to Lamont Bell
    StatusBtn.Text = "🚶 Walking..."
    GoToPosition(LamontBellPos)

    task.wait(0.2)
    SetCamera(CFrame.new(511.947815, -5.5166769, 603.071838))

    local prompt = GetLamontBellPrompt()
    if not prompt then
        StatusBtn.Text = "⚠️ No NPC!"
        GoToPosition(pos)
        RestorePosition()
        return
    end

    -- Selling
    StatusBtn.Text = "💰 Selling..."
    while isFarming do
        local bag = nil
        for _, name in ipairs(BagNames) do
            if HasTool(name) then
                bag = name
                break
            end
        end

        if not bag then
            StatusBtn.Text = "✅ All sold!"
            break
        end

        EquipTool(bag)
        task.wait(0.2)
        if prompt and prompt.Parent then
            pcall(function()
                fireproximityprompt(prompt)
            end)
        end

        local totalBags = CountBags()
        StatusBtn.Text = "💰 " .. totalBags .. " left"
        task.wait(1.5)

        if totalBags == 0 then break end
    end

    ResetCamera()
    StatusBtn.Text = "↩ Returning..."
    GoToPosition(pos)
    task.wait(0.5)

    RestorePosition()
    StatusBtn.Text = "⏸ IDLE"
end

-- ============================================
-- FARM CONTROL
-- ============================================
function StartFarming()
    if isFarming then return end
    
    FullAutoBtn.Text = "⏹ STOP"
    FullAutoBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    StatusBtn.Text = "▶ STARTING..."
    StatusBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)

    task.spawn(RunAuto)
end

function StopFarming()
    isFarming = false

    if farmTask then
        task.cancel(farmTask)
        farmTask = nil
    end

    FullAutoBtn.Text = "▶ FULL AUTO"
    FullAutoBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
    StatusBtn.Text = "⏸ IDLE"
    StatusBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)

    RestorePosition()
end

-- ============================================
-- BUTTON EVENTS
-- ============================================
FullAutoBtn.MouseButton1Click:Connect(function()
    if isFarming then
        StopFarming()
    else
        StartFarming()
    end
end)

-- ============================================
-- CHARACTER RESET
-- ============================================
LocalPlayer.CharacterRemoving:Connect(function()
    if isFarming then
        StopFarming()
    end
end)

print("✅ Auto Farm UI Loaded!")
print("📌 Atur jumlah pack dengan + dan -")
print("📌 Klik FULL AUTO untuk mulai")