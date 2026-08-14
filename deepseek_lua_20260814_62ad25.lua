-- Deobfuscated by NNVN Hub & BaconCheatz
-- Script: LENGER STORE (Full Version)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local GuiService = game:GetService("GuiService")
local VirtualInputManager = pcall(function() return game:GetService("VirtualInputManager") end) and game:GetService("VirtualInputManager") or nil

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()
local IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- ==================== SETTINGS ====================
local Settings = {
    AimActive = false,
    AimMode = "Camera",
    AimHoldMode = true,
    AimToggleState = false,
    AimSmoothness = 3,
    AimFOVEnabled = false,
    AimFOVSize = 100,
    AimWallCheck = false,
    HitboxEnabled = false,
    HitboxSize = 3,
    HitboxTransparency = 0.5,
    BoxesEnabled = false,
    TracersEnabled = false,
    HeadESPEnabled = false,
    NamesEnabled = false,
    HealthEnabled = false,
    InvEnabled = false,
    SkeletonEnabled = false,
    HighlightEnabled = false,
    HighlightFillTrans = 0.5,
    HighlightColor = Color3.fromRGB(255, 50, 50),
    HighlightOutline = Color3.fromRGB(255, 255, 255),
    ToolHighlightEnabled = false,
    ToolHighlightColor = Color3.fromRGB(255, 200, 0),
    SelfHighlightEnabled = false,
    SelfHighlightColor = Color3.fromRGB(0, 200, 255),
    SelfHighlightOutline = Color3.fromRGB(255, 255, 255),
    ESPVisible = true,
    SpeedhackEnabled = false,
    JumpEnabled = false,
    InstantInteractEnabled = false,
    MarshFarmActive = false,
    DeleteActive = false,
    StretchEnabled = false,
    StretchScale = 70,
    ShowSnowParticles = true
}

_G.AimbotKey = Enum.KeyCode.E
_G.HitboxKey = nil
_G.ESPKey = nil

-- ==================== VARIABLES ====================
local ESPObjects = {}
local Highlights = {}
local ToolHighlights = {}
local Whitelist = {}
local HitboxSizes = {}
local HitboxTransparencies = {}
local PromptCache = {}
local DeletedParts = {}
local IsDragging = false
local DragStart = nil
local DragStartPos = nil
local StretchConn = nil
local SelfHighlight = nil
local DeleteHighlight = Instance.new("SelectionBox")
DeleteHighlight.Name = "LENGER_DeleteHighlight"
DeleteHighlight.Parent = CoreGui
DeleteHighlight.Color3 = Color3.fromRGB(255, 0, 0)
DeleteHighlight.LineThickness = 0.05

local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Thickness = 1
FOVCircle.NumSides = 100
FOVCircle.Visible = false
FOVCircle.Filled = not IsMobile
FOVCircle.Transparency = IsMobile and 1 or 0.88

-- ==================== HELPER FUNCTIONS ====================
local function IsPlayerWhitelisted(player)
    return Whitelist[player.Name] == true
end

local function IsPlayerValid(player)
    if player == LocalPlayer then return false end
    local char = player.Character
    if not char then return false end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return false end
    return true
end

local function GetPlayerTool(player)
    local char = player.Character
    if not char then return nil end
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("Tool") then
            return child
        end
    end
    return nil
end

local function GetClosestPlayerToCursor()
    local closest = nil
    local closestDist = math.huge
    local viewport = Camera.ViewportSize
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and not IsPlayerWhitelisted(player) and IsPlayerValid(player) then
            local char = player.Character
            local head = char:FindFirstChild("Head") or char:FindFirstChild("UpperTorso")
            if head then
                local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen and screenPos.Z > 0 then
                    local dist = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                    if dist < closestDist and dist <= Settings.AimFOVSize then
                        closestDist = dist
                        closest = {player = player, part = head}
                    end
                end
            end
        end
    end
    return closest
end

local function AimAtPart(part, smoothness)
    if not part then return end
    local lerpFactor = math.clamp(smoothness / 10, 0.05, 0.55)
    Camera.CFrame = Camera.CFrame:Lerp(
        CFrame.new(Camera.CFrame.Position, part.Position),
        lerpFactor
    )
end

local function SmoothAim(part, mouseX, mouseY, smoothness)
    if not part then return end
    local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
    if not onScreen or screenPos.Z < 0 then return end
    
    local smoothFactor = 0.06 + (1 - (smoothness - 1) / 4) * 0.44
    if mousemoverel then
        mousemoverel((screenPos.X - mouseX) * smoothFactor, (screenPos.Y - mouseY) * smoothFactor)
    else
        Camera.CFrame = Camera.CFrame:Lerp(
            CFrame.new(Camera.CFrame.Position, part.Position),
            smoothFactor
        )
    end
end

-- ==================== HITBOX FUNCTIONS ====================
local function EnableHitbox(character)
    if not character then return end
    local torso = character:FindFirstChild("UpperTorso")
    if not torso then return end
    
    if not HitboxSizes[torso] then
        HitboxSizes[torso] = torso.Size
    end
    if not HitboxTransparencies[torso] then
        HitboxTransparencies[torso] = torso.Transparency
    end
    
    torso.Size = Vector3.new(Settings.HitboxSize, Settings.HitboxSize, Settings.HitboxSize)
    torso.Transparency = Settings.HitboxTransparency
    torso.CanCollide = false
    torso.Massless = true
end

local function DisableHitbox(character)
    if not character then return end
    local torso = character:FindFirstChild("UpperTorso")
    if torso then
        torso.Size = HitboxSizes[torso] or Vector3.new(2, 2, 1)
        HitboxSizes[torso] = nil
        torso.Transparency = HitboxTransparencies[torso] or 0
        HitboxTransparencies[torso] = nil
        torso.CanCollide = true
    end
end

local function ToggleAllHitboxes()
    if Settings.HitboxEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and not IsPlayerWhitelisted(player) then
                local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    EnableHitbox(player.Character)
                end
            end
        end
    else
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                DisableHitbox(player.Character)
            end
        end
    end
end

-- ==================== ESP FUNCTIONS ====================
local SkeletonBones = {
    {"Head", "UpperTorso"},
    {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"},
    {"LeftUpperArm", "LeftLowerArm"},
    {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "RightUpperArm"},
    {"RightUpperArm", "RightLowerArm"},
    {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"},
    {"LeftUpperLeg", "LeftLowerLeg"},
    {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"},
    {"RightUpperLeg", "RightLowerLeg"},
    {"RightLowerLeg", "RightFoot"}
}

local function ClearESP(player)
    if ESPObjects[player] then
        pcall(function()
            for _, obj in pairs(ESPObjects[player]) do
                if obj and obj.Remove then
                    obj:Remove()
                end
            end
        end)
        ESPObjects[player] = nil
    end
    ClearHighlight(player)
end

local function UpdateESP()
    if not Settings.ESPVisible then return end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer or IsPlayerWhitelisted(player) then
            ClearESP(player)
            continue
        end
        
        if not IsPlayerValid(player) then
            ClearESP(player)
            continue
        end
        
        local char = player.Character
        local rootPart = char:FindFirstChild("HumanoidRootPart")
        if not rootPart then continue end
        
        local rootPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
        if not onScreen or rootPos.Z < 0 then continue end
        
        local distance = (rootPart.Position - Camera.CFrame.Position).Magnitude
        if distance > 1200 then continue end
        
        if not ESPObjects[player] then
            ESPObjects[player] = {
                Box = Drawing.new("Square"),
                HBar = Drawing.new("Square"),
                NameTxt = Drawing.new("Text"),
                InvTxt = Drawing.new("Text"),
                TracerLine = Drawing.new("Line"),
                HeadCircle = Drawing.new("Circle"),
                SkeletonLines = {}
            }
            
            local esp = ESPObjects[player]
            esp.Box.Thickness = 1
            esp.Box.Filled = false
            esp.Box.Color = Color3.new(1, 1, 1)
            
            esp.HBar.Thickness = 1
            esp.HBar.Filled = true
            
            esp.NameTxt.Outline = false
            esp.NameTxt.Color = Color3.new(1, 1, 1)
            esp.NameTxt.Font = 2
            esp.NameTxt.Center = true
            esp.NameTxt.Size = 13
            
            esp.InvTxt.Outline = false
            esp.InvTxt.Color = Color3.new(1, 1, 1)
            esp.InvTxt.Font = 2
            esp.InvTxt.Center = true
            esp.InvTxt.Size = 11
            
            esp.TracerLine.Thickness = 1
            esp.TracerLine.Color = Color3.new(1, 1, 1)
            
            esp.HeadCircle.Thickness = 1
            esp.HeadCircle.Filled = false
            esp.HeadCircle.Color = Color3.new(1, 1, 1)
        end
        
        local esp = ESPObjects[player]
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        local head = char:FindFirstChild("Head")
        local torso = char:FindFirstChild("UpperTorso")
        
        if not head or not torso then continue end
        
        local headPos = Camera:WorldToViewportPoint(head.Position)
        local torsoPos = Camera:WorldToViewportPoint(torso.Position)
        local footPos = Camera:WorldToViewportPoint(rootPart.Position - Vector3.new(0, 2.8, 0))
        
        local height = math.abs(footPos.Y - headPos.Y)
        if height < 1 then continue end
        
        local width = height * 0.55
        local boxPos = Vector2.new(headPos.X - width / 2, headPos.Y)
        
        -- Box ESP
        if Settings.BoxesEnabled then
            esp.Box.Size = Vector2.new(width, height)
            esp.Box.Position = boxPos
            esp.Box.Visible = true
        end
        
        -- Health Bar
        if Settings.HealthEnabled then
            local healthPercent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
            esp.HBar.Color = Color3.fromHSV(healthPercent * 0.33, 1, 1)
            esp.HBar.Size = Vector2.new(3, height * healthPercent)
            esp.HBar.Position = Vector2.new(boxPos.X - 6, boxPos.Y + height - height * healthPercent)
            esp.HBar.Visible = true
        end
        
        -- Name ESP
        if Settings.NamesEnabled then
            esp.NameTxt.Text = player.Name
            esp.NameTxt.Position = Vector2.new(headPos.X, boxPos.Y - 16)
            esp.NameTxt.Visible = true
        end
        
        -- Inventory ESP
        if Settings.InvEnabled then
            local tool = GetPlayerTool(player)
            esp.InvTxt.Text = tool and tool.Name or "Empty"
            esp.InvTxt.Position = Vector2.new(headPos.X, boxPos.Y + height + 4)
            esp.InvTxt.Visible = true
        end
        
        -- Tracers
        if Settings.TracersEnabled then
            esp.TracerLine.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            esp.TracerLine.To = Vector2.new(headPos.X, headPos.Y)
            esp.TracerLine.Visible = true
        end
        
        -- Head Circle
        if Settings.HeadESPEnabled then
            local headScreen, headOnScreen = Camera:WorldToViewportPoint(head.Position)
            if headOnScreen and headScreen.Z > 0 then
                esp.HeadCircle.Position = Vector2.new(headScreen.X, headScreen.Y)
                esp.HeadCircle.Radius = 600 / headScreen.Z
                esp.HeadCircle.Visible = true
            end
        end
        
        -- Skeleton
        if Settings.SkeletonEnabled and #esp.SkeletonLines == 0 then
            for _ = 1, #SkeletonBones do
                local line = Drawing.new("Line")
                line.Color = Color3.new(1, 1, 1)
                line.Thickness = 1
                line.Transparency = 1
                table.insert(esp.SkeletonLines, line)
            end
        end
        
        if Settings.SkeletonEnabled then
            for i, bonePair in ipairs(SkeletonBones) do
                local part1 = char:FindFirstChild(bonePair[1])
                local part2 = char:FindFirstChild(bonePair[2])
                if part1 and part2 then
                    local pos1, on1 = Camera:WorldToViewportPoint(part1.Position)
                    local pos2, on2 = Camera:WorldToViewportPoint(part2.Position)
                    if on1 and on2 and pos1.Z > 0 and pos2.Z > 0 then
                        esp.SkeletonLines[i].From = Vector2.new(pos1.X, pos1.Y)
                        esp.SkeletonLines[i].To = Vector2.new(pos2.X, pos2.Y)
                        esp.SkeletonLines[i].Visible = true
                    end
                end
            end
        end
    end
end

-- ==================== HIGHLIGHT FUNCTIONS ====================
local function ClearHighlight(player)
    if Highlights[player] then
        pcall(function()
            Highlights[player]:Destroy()
        end)
        Highlights[player] = nil
    end
    if ToolHighlights[player] then
        pcall(function()
            ToolHighlights[player]:Destroy()
        end)
        ToolHighlights[player] = nil
    end
end

local function UpdateHighlight(player)
    if player == LocalPlayer then return end
    if not IsPlayerValid(player) then
        ClearHighlight(player)
        return
    end
    
    local char = player.Character
    
    if Settings.HighlightEnabled then
        if not Highlights[player] then
            local highlight = Instance.new("Highlight")
            highlight.FillColor = Settings.HighlightColor
            highlight.OutlineColor = Settings.HighlightOutline
            highlight.FillTransparency = Settings.HighlightFillTrans
            highlight.OutlineTransparency = 0
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlight.Adornee = char
            highlight.Parent = CoreGui
            Highlights[player] = highlight
        else
            local highlight = Highlights[player]
            highlight.FillColor = Settings.HighlightColor
            highlight.OutlineColor = Settings.HighlightOutline
            highlight.FillTransparency = Settings.HighlightFillTrans
        end
    elseif Settings.ToolHighlightEnabled then
        local tool = GetPlayerTool(player)
        if tool then
            if not ToolHighlights[player] then
                local highlight = Instance.new("Highlight")
                highlight.FillColor = Settings.ToolHighlightColor
                highlight.OutlineColor = Settings.ToolHighlightColor
                highlight.FillTransparency = 0.3
                highlight.OutlineTransparency = 0
                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                highlight.Adornee = tool
                highlight.Parent = CoreGui
                ToolHighlights[player] = highlight
            else
                ToolHighlights[player].FillColor = Settings.ToolHighlightColor
                ToolHighlights[player].OutlineColor = Settings.ToolHighlightColor
            end
        else
            ClearHighlight(player)
        end
    else
        ClearHighlight(player)
    end
end

local function UpdateSelfHighlight()
    if Settings.SelfHighlightEnabled then
        if not SelfHighlight then
            SelfHighlight = Instance.new("Highlight")
            SelfHighlight.Parent = CoreGui
        end
        local char = LocalPlayer.Character
        SelfHighlight.Adornee = char
        SelfHighlight.FillColor = Settings.SelfHighlightColor
        SelfHighlight.OutlineColor = Settings.SelfHighlightOutline
        SelfHighlight.FillTransparency = 0.5
        SelfHighlight.OutlineTransparency = 0
        SelfHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    else
        if SelfHighlight then
            pcall(function()
                SelfHighlight:Destroy()
            end)
            SelfHighlight = nil
        end
    end
end

-- ==================== STRETCH RESOLUTION ====================
local function GetStretchFactor()
    return 1 - Settings.StretchScale / 100 * 0.45
end

local function ToggleStretch(enabled)
    if StretchConn then
        StretchConn:Disconnect()
        StretchConn = nil
    end
    if not enabled then return end
    
    local factor = GetStretchFactor()
    StretchConn = RunService.RenderStepped:Connect(function()
        if Camera then
            Camera.CFrame = Camera.CFrame * CFrame.new(0, 0, 0, 1, 0, 0, 0, factor, 0, 0, 0, 1)
        end
    end)
end

-- ==================== INSTANT INTERACT ====================
local function EnableInstantInteract(prompt)
    if not prompt:IsA("ProximityPrompt") then return end
    if not PromptCache[prompt] then
        PromptCache[prompt] = {
            HoldDuration = prompt.HoldDuration,
            RequiresLineOfSight = prompt.RequiresLineOfSight,
            MaxActivationDistance = prompt.MaxActivationDistance
        }
    end
    prompt.HoldDuration = 0
    prompt.RequiresLineOfSight = false
    prompt.MaxActivationDistance = 50
end

local function DisableInstantInteract(prompt)
    if not prompt:IsA("ProximityPrompt") then return end
    if PromptCache[prompt] then
        prompt.HoldDuration = PromptCache[prompt].HoldDuration
        prompt.RequiresLineOfSight = PromptCache[prompt].RequiresLineOfSight
        prompt.MaxActivationDistance = PromptCache[prompt].MaxActivationDistance
        PromptCache[prompt] = nil
    end
end

local function ApplyInstantInteractToAll()
    for _, descendant in ipairs(Workspace:GetDescendants()) do
        if descendant:IsA("ProximityPrompt") then
            EnableInstantInteract(descendant)
        end
    end
end

local function RemoveInstantInteractFromAll()
    for _, descendant in ipairs(Workspace:GetDescendants()) do
        if descendant:IsA("ProximityPrompt") then
            DisableInstantInteract(descendant)
        end
    end
    PromptCache = {}
end

-- ==================== MARSH FARM ====================
local function UseItem(itemName, holdTime)
    if not Settings.MarshFarmActive then return end
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChildOfClass("Humanoid") then return end
    
    local backpack = LocalPlayer.Backpack
    local tool = backpack:FindFirstChild(itemName)
    if not tool then
        tool = char:FindFirstChild(itemName)
        if not tool then return end
    end
    
    -- Equip tool
    if VirtualInputManager then
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        task.wait(holdTime)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
    else
        -- Fallback using fireproximityprompt
        local rootPart = char:FindFirstChild("HumanoidRootPart")
        if rootPart then
            for _, descendant in ipairs(Workspace:GetDescendants()) do
                if descendant:IsA("ProximityPrompt") then
                    if (descendant.Parent.Position - rootPart.Position).Magnitude < 15 then
                        pcall(function()
                            fireproximityprompt(descendant)
                        end)
                    end
                end
            end
        end
        task.wait(holdTime)
    end
end

task.spawn(function()
    while true do
        if Settings.MarshFarmActive then
            UseItem("Water", 1)
            task.wait(21.5)
            UseItem("Sugar Block Bag", 1)
            task.wait(1.5)
            UseItem("Gelatin", 1)
            task.wait(46.5)
            UseItem("Empty Bag", 1)
            task.wait(1)
        else
            task.wait(1)
        end
    end
end)

-- ==================== DELETE MODE ====================
local function IsPartInPlayer(part)
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character and part:IsDescendantOf(player.Character) then
            return true
        end
    end
    return false
end

-- ==================== NOTIFICATION SYSTEM ====================
local NotificationCount = 0

local function Notify(title, message, duration)
    duration = duration or 3
    local isMobile = IsMobile
    
    local width = isMobile and math.min(240, Camera.ViewportSize.X - 20) or 290
    
    local frame = Instance.new("Frame", CoreGui)
    frame.Size = UDim2.new(0, width, 0, 0)
    frame.Position = UDim2.new(1, -(width + 12), 1, -70 - NotificationCount)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
    frame.BorderSizePixel = 0
    frame.AutomaticSize = Enum.AutomaticSize.Y
    frame.ZIndex = 50
    
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    
    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Thickness = 1
    stroke.Transparency = 0.75
    
    local padding = Instance.new("UIPadding", frame)
    padding.PaddingLeft = UDim.new(0, 12)
    padding.PaddingRight = UDim.new(0, 12)
    padding.PaddingTop = UDim.new(0, 10)
    padding.PaddingBottom = UDim.new(0, 10)
    
    local layout = Instance.new("UIListLayout", frame)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 3)
    
    local titleLabel = Instance.new("TextLabel", frame)
    titleLabel.Size = UDim2.new(1, 0, 0, 15)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 13
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.LayoutOrder = 1
    titleLabel.ZIndex = 51
    
    local msgLabel = Instance.new("TextLabel", frame)
    msgLabel.Size = UDim2.new(1, 0, 0, 0)
    msgLabel.AutomaticSize = Enum.AutomaticSize.Y
    msgLabel.BackgroundTransparency = 1
    msgLabel.Text = message
    msgLabel.TextColor3 = Color3.fromRGB(180, 180, 190)
    msgLabel.Font = Enum.Font.Gotham
    msgLabel.TextSize = 12
    msgLabel.TextWrapped = true
    msgLabel.TextXAlignment = Enum.TextXAlignment.Left
    msgLabel.LayoutOrder = 2
    msgLabel.ZIndex = 51
    
    NotificationCount = NotificationCount + 75
    
    task.delay(duration, function()
        local tween = TweenService:Create(frame, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
            Position = UDim2.new(1, 20, frame.Position.Y.Scale, frame.Position.Y.Offset)
        })
        tween:Play()
        task.wait(0.3)
        frame:Destroy()
        NotificationCount = math.max(0, NotificationCount - 75)
    end)
end

-- ==================== GUI CREATION ====================
local function CreateGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "LENGER_STORE"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.IgnoreGuiInset = true
    screenGui.Parent = CoreGui
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, IsMobile and math.min(Camera.ViewportSize.X - 16, 390) or 460, 0, IsMobile and math.min(Camera.ViewportSize.Y - 40, 490) or 420)
    mainFrame.Position = UDim2.new(0.5, -mainFrame.Size.X.Offset / 2, 0.5, -mainFrame.Size.Y.Offset / 2)
    mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
    mainFrame.BorderSizePixel = 0
    mainFrame.ZIndex = 5
    mainFrame.Parent = screenGui
    
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)
    
    local stroke = Instance.new("UIStroke", mainFrame)
    stroke.Color = Color3.fromRGB(30, 30, 35)
    stroke.Thickness = 1
    stroke.Transparency = 0.1
    
    -- Title Bar
    local titleBar = Instance.new("Frame", mainFrame)
    titleBar.Size = UDim2.new(1, 0, 0, IsMobile and 42 or 38)
    titleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
    titleBar.BorderSizePixel = 0
    titleBar.ZIndex = 6
    
    -- Title Label (LENGER STORE)
    local titleLabel = Instance.new("TextLabel", titleBar)
    titleLabel.Size = UDim2.new(1, -60, 1, 0)
    titleLabel.Position = UDim2.new(0, 16, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "☁ LENGER STORE"  -- <-- NAMA BARU
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = IsMobile and 14 or 13
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.ZIndex = 7
    
    -- Tab Bar
    local tabBar = Instance.new("Frame", mainFrame)
    tabBar.Size = UDim2.new(1, 0, 0, IsMobile and 40 or 34)
    tabBar.Position = UDim2.new(0, 0, 0, IsMobile and 42 or 38)
    tabBar.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    tabBar.BorderSizePixel = 0
    tabBar.ZIndex = 6
    
    -- Content Frame
    local contentFrame = Instance.new("Frame", mainFrame)
    contentFrame.Size = UDim2.new(1, -4, 1, -(IsMobile and 42 or 38) - (IsMobile and 40 or 34) - 4)
    contentFrame.Position = UDim2.new(0, 2, 0, (IsMobile and 42 or 38) + (IsMobile and 40 or 34) + 2)
    contentFrame.BackgroundTransparency = 1
    contentFrame.ClipsDescendants = true
    contentFrame.ZIndex = 20
    
    -- Tabs
    local tabs = {}
    local activeTab = nil
    local tabCount = 0
    
    local function CreateTab(name)
        tabCount = tabCount + 1
        local tabWidth = (mainFrame.Size.X.Offset - 32) / 4
        
        local button = Instance.new("TextButton", tabBar)
        button.Size = UDim2.new(0, tabWidth, 1, 0)
        button.Position = UDim2.new(0, (tabCount - 1) * tabWidth, 0, 0)
        button.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
        button.BackgroundTransparency = 0
        button.Text = ""
        button.BorderSizePixel = 0
        button.ZIndex = 9
        
        local indicator = Instance.new("Frame", button)
        indicator.Size = UDim2.new(0.75, 0, 0, 2)
        indicator.Position = UDim2.new(0.125, 0, 1, -2)
        indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        indicator.BorderSizePixel = 0
        indicator.Visible = false
        indicator.ZIndex = 10
        Instance.new("UICorner", indicator).CornerRadius = UDim.new(1, 0)
        
        local label = Instance.new("TextLabel", button)
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = name
        label.TextColor3 = Color3.fromRGB(82, 82, 96)
        label.Font = Enum.Font.GothamBold
        label.TextSize = IsMobile and 11 or 10
        label.ZIndex = 10
        
        local frame = Instance.new("Frame", contentFrame)
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundTransparency = 1
        frame.Visible = false
        frame.ZIndex = 6
        
        local scroll = Instance.new("ScrollingFrame", frame)
        scroll.Size = UDim2.new(1, 0, 1, 0)
        scroll.BackgroundTransparency = 1
        scroll.BorderSizePixel = 0
        scroll.ScrollBarThickness = IsMobile and 3 or 2
        scroll.ScrollBarImageColor3 = Color3.fromRGB(180, 180, 190)
        scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        scroll.ElasticBehavior = Enum.ElasticBehavior.Never
        scroll.ScrollingEnabled = true
        scroll.ZIndex = 6
        
        local layout = Instance.new("UIListLayout", scroll)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 0)
        
        local padding = Instance.new("UIPadding", scroll)
        padding.PaddingTop = UDim.new(0, 6)
        padding.PaddingBottom = UDim.new(0, 10)
        
        local tabData = {
            btn = button,
            frame = frame,
            scroll = scroll,
            lbl = label,
            ind = indicator
        }
        table.insert(tabs, tabData)
        
        button.MouseButton1Click:Connect(function()
            ActivateTab(tabData)
        end)
        button.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch then
                ActivateTab(tabData)
            end
        end)
        button.MouseEnter:Connect(function()
            if activeTab ~= tabData then
                label.TextColor3 = Color3.fromRGB(200, 200, 210)
            end
        end)
        button.MouseLeave:Connect(function()
            if activeTab ~= tabData then
                label.TextColor3 = Color3.fromRGB(82, 82, 96)
            end
        end)
        
        return tabData
    end
    
    local function ActivateTab(tab)
        if activeTab then
            activeTab.frame.Visible = false
            activeTab.lbl.TextColor3 = Color3.fromRGB(82, 82, 96)
            activeTab.ind.Visible = false
            activeTab.btn.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
        end
        activeTab = tab
        tab.frame.Visible = true
        tab.lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
        tab.ind.Visible = true
        tab.btn.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
    end
    
    -- Helper GUI functions
    local rowCount = 0
    local rowHeight = IsMobile and 58 or 50
    
    local function AddRow(parent, label, value, min, max, callback)
        rowCount = rowCount + 1
        local row = Instance.new("Frame", parent)
        row.Size = UDim2.new(1, 0, 0, rowHeight)
        row.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
        row.BorderSizePixel = 0
        row.LayoutOrder = rowCount
        row.ZIndex = 7
        
        local sep = Instance.new("Frame", row)
        sep.Size = UDim2.new(1, -32, 0, 1)
        sep.Position = UDim2.new(0, 16, 1, -1)
        sep.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        sep.BorderSizePixel = 0
        sep.ZIndex = 7
        
        local labelFrame = Instance.new("Frame", row)
        labelFrame.Size = UDim2.new(1, 0, 0, 22)
        labelFrame.Position = UDim2.new(0, 0, 0, 6)
        labelFrame.BackgroundTransparency = 1
        labelFrame.ZIndex = 8
        
        local textLabel = Instance.new("TextLabel", labelFrame)
        textLabel.Size = UDim2.new(1, -32, 1, 0)
        textLabel.Position = UDim2.new(0, 16, 0, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.Text = label .. tostring(value)
        textLabel.TextColor3 = Color3.fromRGB(220, 220, 230)
        textLabel.Font = Enum.Font.Gotham
        textLabel.TextSize = IsMobile and 15 or 13
        textLabel.TextXAlignment = Enum.TextXAlignment.Left
        textLabel.ZIndex = 8
        
        local sliderBg = Instance.new("Frame", row)
        sliderBg.Size = UDim2.new(1, -32, 0, IsMobile and 5 or 4)
        sliderBg.Position = UDim2.new(0, 16, 0, rowHeight - (IsMobile and 5 or 4) - 10)
        sliderBg.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
        sliderBg.BorderSizePixel = 0
        sliderBg.ZIndex = 8
        Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1, 0)
        
        local sliderFill = Instance.new("Frame", sliderBg)
        sliderFill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
        sliderFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        sliderFill.BorderSizePixel = 0
        sliderFill.ZIndex = 9
        Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(1, 0)
        
        local thumbSize = IsMobile and 15 or 11
        local thumb = Instance.new("Frame", sliderBg)
        thumb.Size = UDim2.new(0, thumbSize, 0, thumbSize)
        thumb.Position = UDim2.new((value - min) / (max - min), -thumbSize / 2, 0.5, -thumbSize / 2)
        thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        thumb.BorderSizePixel = 0
        thumb.ZIndex = 10
        Instance.new("UICorner", thumb).CornerRadius = UDim.new(1, 0)
        
        local isDragging = false
        
        local function UpdateSlider(mouseX)
            local percent = math.clamp((mouseX - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
            local newValue = math.round(min + percent * (max - min))
            value = newValue
            sliderFill.Size = UDim2.new(percent, 0, 1, 0)
            thumb.Position = UDim2.new(percent, -thumbSize / 2, 0.5, -thumbSize / 2)
            textLabel.Text = label .. tostring(newValue)
            if callback then callback(newValue) end
        end
        
        local btn = Instance.new("TextButton", row)
        btn.Size = UDim2.new(1, 0, 1, 0)
        btn.BackgroundTransparency = 1
        btn.Text = ""
        btn.ZIndex = 11
        
        btn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isDragging = true
                UpdateSlider(input.Position.X)
                if input.UserInputType == Enum.UserInputType.Touch then
                    input.Changed:Connect(function()
                        if not isDragging then return end
                        if input.UserInputState == Enum.UserInputState.Change then
                            UpdateSlider(input.Position.X)
                        elseif input.UserInputState == Enum.UserInputState.End then
                            isDragging = false
                        end
                    end)
                end
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                UpdateSlider(input.Position.X)
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                isDragging = false
            end
        end)
        
        return row
    end
    
    -- Create tabs
    local aimTab = CreateTab("Aim")
    local espTab = CreateTab("ESP")
    local playerTab = CreateTab("Player")
    local miscTab = CreateTab("Misc")
    
    -- Activate first tab
    ActivateTab(aimTab)
    
    -- Return GUI objects
    return screenGui, mainFrame, contentFrame, aimTab, espTab, playerTab, miscTab
end

-- ==================== MAIN SCRIPT ====================
local function Main()
    -- Create GUI
    local screenGui, mainFrame, contentFrame, aimTab, espTab, playerTab, miscTab = CreateGUI()
    
    -- ==================== INPUT HANDLING ====================
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        -- Delete Mode (Alt + Click)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and UserInputService:IsKeyDown(Enum.KeyCode.LeftAlt) then
            local target = Mouse.Target
            if target and target:IsA("BasePart") and not IsPartInPlayer(target) then
                table.insert(DeletedParts, {
                    Part = target,
                    Parent = target.Parent,
                    CF = target.CFrame
                })
                target.Parent = nil
            end
        end
        
        -- Undo Delete (Ctrl + Z)
        if input.KeyCode == Enum.KeyCode.Z and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            if #DeletedParts > 0 then
                local data = table.remove(DeletedParts)
                data.Part.Parent = data.Parent
                data.Part.CFrame = data.CF
            end
        end
        
        -- Toggle Hitbox
        if _G.HitboxKey and input.KeyCode == _G.HitboxKey then
            Settings.HitboxEnabled = not Settings.HitboxEnabled
            ToggleAllHitboxes()
        end
        
        -- Toggle ESP
        if _G.ESPKey and input.KeyCode == _G.ESPKey then
            Settings.ESPVisible = not Settings.ESPVisible
        end
        
        -- Toggle Aimbot
        if not Settings.AimHoldMode and _G.AimbotKey and input.KeyCode == _G.AimbotKey then
            Settings.AimToggleState = not Settings.AimToggleState
        end
    end)
    
    -- ==================== RENDER LOOP ====================
    local lastESPUpdate = 0
    local espUpdateRate = 0.1
    
    RunService.RenderStepped:Connect(function()
        local viewport = Camera.ViewportSize
        local now = tick()
        
        -- Update FOV Circle
        FOVCircle.Visible = Settings.AimFOVEnabled
        FOVCircle.Radius = Settings.AimFOVSize
        FOVCircle.Position = Settings.AimMode == "Camera" and Vector2.new(viewport.X / 2, viewport.Y / 2) or Vector2.new(Mouse.X, Mouse.Y)
        
        -- Speedhack
        if Settings.SpeedhackEnabled then
            local char = LocalPlayer.Character
            local humanoid = char and char:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.WalkSpeed ~= 23 then
                humanoid.WalkSpeed = 23
            end
        end
        
        -- Delete Highlight
        if Settings.DeleteActive then
            local target = Mouse.Target
            DeleteHighlight.Adornee = (target and target:IsA("BasePart") and not IsPartInPlayer(target)) and target or nil
        else
            DeleteHighlight.Adornee = nil
        end
        
        -- Aimbot
        local shouldAim = false
        if Settings.AimActive then
            if Settings.AimHoldMode then
                shouldAim = UserInputService:IsKeyDown(_G.AimbotKey) or (IsMobile and true)
            else
                shouldAim = Settings.AimToggleState
            end
        end
        
        if shouldAim then
            local target = GetClosestPlayerToCursor()
            if target then
                if Settings.AimMode == "Camera" then
                    AimAtPart(target.part, Settings.AimSmoothness)
                else
                    SmoothAim(target.part, Mouse.X, Mouse.Y, Settings.AimSmoothness)
                end
            end
        end
        
        -- Update ESP (rate limited)
        if now - lastESPUpdate >= espUpdateRate then
            lastESPUpdate = now
            UpdateESP()
            UpdateSelfHighlight()
            
            -- Update highlights for all players
            if Settings.ESPVisible and (Settings.HighlightEnabled or Settings.ToolHighlightEnabled) then
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer then
                        UpdateHighlight(player)
                    end
                end
            end
        end
        
        -- Update ESP visibility based on settings
        if not Settings.ESPVisible then
            -- Hide all ESP objects
            for _, esp in pairs(ESPObjects) do
                pcall(function()
                    if esp.Box then esp.Box.Visible = false end
                    if esp.HBar then esp.HBar.Visible = false end
                    if esp.NameTxt then esp.NameTxt.Visible = false end
                    if esp.InvTxt then esp.InvTxt.Visible = false end
                    if esp.TracerLine then esp.TracerLine.Visible = false end
                    if esp.HeadCircle then esp.HeadCircle.Visible = false end
                    if esp.SkeletonLines then
                        for _, line in ipairs(esp.SkeletonLines) do
                            line.Visible = false
                        end
                    end
                end)
            end
        end
    end)
    
    -- ==================== CLEANUP ====================
    local function Cleanup()
        Settings.AimActive = false
        Settings.AimFOVEnabled = false
        Settings.HitboxEnabled = false
        Settings.BoxesEnabled = false
        Settings.TracersEnabled = false
        Settings.HeadESPEnabled = false
        Settings.NamesEnabled = false
        Settings.HealthEnabled = false
        Settings.InvEnabled = false
        Settings.SkeletonEnabled = false
        Settings.ESPVisible = false
        Settings.HighlightEnabled = false
        Settings.ToolHighlightEnabled = false
        Settings.SelfHighlightEnabled = false
        Settings.SpeedhackEnabled = false
        Settings.DeleteActive = false
        Settings.StretchEnabled = false
        Settings.InstantInteractEnabled = false
        Settings.MarshFarmActive = false
        Settings.JumpEnabled = false
        Settings.AimToggleState = false
        
        -- Reset speed
        pcall(function()
            local char = LocalPlayer.Character
            local humanoid = char and char:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = 16
            end
        end)
        
        -- Clear highlights
        pcall(function()
            for _, highlight in pairs(Highlights) do
                highlight:Destroy()
            end
            Highlights = {}
            for _, highlight in pairs(ToolHighlights) do
                highlight:Destroy()
            end
            ToolHighlights = {}
            if SelfHighlight then
                SelfHighlight:Destroy()
                SelfHighlight = nil
            end
        end)
        
        -- Clear ESP
        for player, esp in pairs(ESPObjects) do
            ClearESP(player)
        end
        ESPObjects = {}
        
        -- Disable hitboxes
        ToggleAllHitboxes()
        
        -- Disable stretch
        ToggleStretch(false)
        
        -- Disable instant interact
        RemoveInstantInteractFromAll()
        
        -- Remove GUI
        pcall(function()
            screenGui:Destroy()
        end)
        
        Notify("LENGER STORE", "All features disabled.", 2)
    end
    
    -- Hook cleanup to game closing
    game:BindToClose(Cleanup)
    
    -- Add close button to GUI
    local closeBtn = Instance.new("ImageButton", mainFrame)
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -38, 0, 4)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Image = "rbxassetid://11104560049"
    closeBtn.ZIndex = 10
    
    closeBtn.MouseButton1Click:Connect(function()
        screenGui.Visible = false
        if IsMobile then
            -- Show reopen button for mobile
            local reopenBtn = Instance.new("ImageButton", CoreGui)
            reopenBtn.Size = UDim2.new(0, 60, 0, 60)
            reopenBtn.Position = UDim2.new(0.5, -30, 1, -80)
            reopenBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
            reopenBtn.Image = "rbxassetid://11104559303"
            reopenBtn.BorderSizePixel = 0
            reopenBtn.ZIndex = 100
            Instance.new("UICorner", reopenBtn).CornerRadius = UDim.new(1, 0)
            
            reopenBtn.MouseButton1Click:Connect(function()
                screenGui.Visible = true
                reopenBtn:Destroy()
            end)
            reopenBtn.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch then
                    screenGui.Visible = true
                    reopenBtn:Destroy()
                end
            end)
            
            Notify("LENGER STORE", "Hidden. Tap ☀ to reopen.", 4)
        else
            Notify("LENGER STORE", "Hidden. Press " .. _G.AimbotKey.Name .. " to reopen.", 4)
        end
    end)
    
    -- Mobile reopen button
    if IsMobile then
        local reopenBtn = Instance.new("ImageButton", CoreGui)
        reopenBtn.Size = UDim2.new(0, 60, 0, 60)
        reopenBtn.Position = UDim2.new(0.5, -30, 1, -80)
        reopenBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
        reopenBtn.Image = "rbxassetid://11104559303"
        reopenBtn.BorderSizePixel = 0
        reopenBtn.ZIndex = 100
        Instance.new("UICorner", reopenBtn).CornerRadius = UDim.new(1, 0)
        
        reopenBtn.MouseButton1Click:Connect(function()
            screenGui.Visible = not screenGui.Visible
        end)
        reopenBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch then
                screenGui.Visible = not screenGui.Visible
            end
        end)
    end
    
    -- Keyboard reopen
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == _G.AimbotKey then
            screenGui.Visible = not screenGui.Visible
        end
    end)
    
    Notify("LENGER STORE", "Loaded successfully!", 3)
    Notify("LENGER STORE", "Press " .. _G.AimbotKey.Name .. " to toggle aimbot", 4)
end

-- ==================== INIT ====================
local success, err = pcall(Main)
if not success then
    warn("LENGER STORE failed to load: " .. tostring(err))
    Notify("LENGER STORE", "Failed to load: " .. tostring(err), 5)
end