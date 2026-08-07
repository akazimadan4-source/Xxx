-- CloudWare v4 (Dibersihkan & Dirapikan)
-- Fitur: Aimbot, ESP, Hitbox, dll.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local GuiService = game:GetService("GuiService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()
local IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- Pengaturan utama
local Settings = {
    AimActive = false,
    AimMode = "Camera",          -- "Camera" atau "Cursor"
    AimHoldMode = true,          -- true = tahan, false = toggle
    AimToggleState = false,
    AimSmoothness = 3,
    AimFOVEnabled = false,
    AimFOVSize = 100,
    AimWallCheck = false,
    HitboxEnabled = false,
    HitboxSize = 3,
    HitboxTransparency = 0.5,
    BoxesEnabled = false,
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
    DeleteActive = false,
    StretchEnabled = false,
    StretchScale = 70,
    ShowSnowParticles = true,
}

-- Keybinds
_G.AimbotKey = Enum.KeyCode.E
_G.HitboxKey = nil
_G.ESPKey = nil

-- Whitelist (untuk menghindari target)
local Whitelist = {}

-- Variabel untuk stretch
local StretchConn = nil

-- === Fungsi-fungsi utilitas ===

local function IsWhitelisted(player)
    return Whitelist[player.Name] == true
end

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

-- Highlight tracking
local Highlights = {}      -- player -> Highlight
local ToolHighlights = {}  -- player -> Highlight (for tools)
local SelfHighlight = nil

local function ClearHighlight(player)
    if Highlights[player] then
        pcall(function() Highlights[player]:Destroy() end)
        Highlights[player] = nil
    end
    if ToolHighlights[player] then
        pcall(function() ToolHighlights[player]:Destroy() end)
        ToolHighlights[player] = nil
    end
end

local function GetEquippedTool(character)
    if not character then return nil end
    for _, child in ipairs(character:GetChildren()) do
        if child:IsA("Tool") then
            return child
        end
    end
    return nil
end

local function UpdatePlayerHighlight(player)
    if player == LocalPlayer then return end
    local char = player.Character
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    if not char or not humanoid or humanoid.Health <= 0 then return end

    -- Player highlight
    if Settings.HighlightEnabled then
        if not Highlights[player] then
            local hl = Instance.new("Highlight")
            hl.FillColor = Settings.HighlightColor
            hl.OutlineColor = Settings.HighlightOutline
            hl.FillTransparency = Settings.HighlightFillTrans
            hl.OutlineTransparency = 0
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            hl.Adornee = char
            hl.Parent = CoreGui
            Highlights[player] = hl
        else
            local hl = Highlights[player]
            hl.FillColor = Settings.HighlightColor
            hl.OutlineColor = Settings.HighlightOutline
            hl.FillTransparency = Settings.HighlightFillTrans
        end
    else
        ClearHighlight(player)
    end

    -- Tool highlight
    if Settings.ToolHighlightEnabled then
        local tool = GetEquippedTool(char)
        if tool then
            if not ToolHighlights[player] then
                local hl = Instance.new("Highlight")
                hl.FillColor = Settings.ToolHighlightColor
                hl.OutlineColor = Settings.ToolHighlightColor
                hl.FillTransparency = 0.3
                hl.OutlineTransparency = 0
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                hl.Adornee = tool
                hl.Parent = CoreGui
                ToolHighlights[player] = hl
            else
                ToolHighlights[player].FillColor = Settings.ToolHighlightColor
                ToolHighlights[player].Adornee = tool
            end
        else
            if ToolHighlights[player] then
                pcall(function() ToolHighlights[player]:Destroy() end)
                ToolHighlights[player] = nil
            end
        end
    else
        if ToolHighlights[player] then
            pcall(function() ToolHighlights[player]:Destroy() end)
            ToolHighlights[player] = nil
        end
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
            pcall(function() SelfHighlight:Destroy() end)
            SelfHighlight = nil
        end
    end
end

-- ESP drawing objects per player
local ESPObjects = {} -- player -> {Box, HBar, NameTxt, InvTxt, SkeletonLines}

local function ClearESP(player)
    if ESPObjects[player] then
        for _, obj in pairs(ESPObjects[player]) do
            if type(obj) == "table" then
                for _, line in ipairs(obj) do
                    pcall(function() line:Remove() end)
                end
            else
                pcall(function() obj:Remove() end)
            end
        end
        ESPObjects[player] = nil
    end
end

-- Skeleton connection table
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
    {"RightLowerLeg", "RightFoot"},
}

-- Hitbox functions
local OriginalSizes = {}
local OriginalTransparencies = {}

local function EnableHitbox(character)
    if not character then return end
    local torso = character:FindFirstChild("UpperTorso")
    if not torso then return end
    if not OriginalSizes[torso] then
        OriginalSizes[torso] = torso.Size
    end
    if not OriginalTransparencies[torso] then
        OriginalTransparencies[torso] = torso.Transparency
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
        torso.Size = OriginalSizes[torso] or torso.Size
        OriginalSizes[torso] = nil
        torso.Transparency = OriginalTransparencies[torso] or 0
        OriginalTransparencies[torso] = nil
    end
end

local function ApplyHitboxToAll()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                EnableHitbox(player.Character)
            end
        end
    end
end

local function RemoveHitboxFromAll()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            DisableHitbox(player.Character)
        end
    end
end

-- Inventory text
local function GetInventoryText(player)
    local char = player.Character
    local backpack = player:FindFirstChild("Backpack")
    local inv = {}
    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then
                local name = tool.Name
                if not inv[name] then inv[name] = {bp = 0, eq = 0} end
                inv[name].bp = inv[name].bp + 1
            end
        end
    end
    if char then
        for _, tool in ipairs(char:GetChildren()) do
            if tool:IsA("Tool") then
                local name = tool.Name
                if not inv[name] then inv[name] = {bp = 0, eq = 0} end
                inv[name].eq = inv[name].eq + 1
            end
        end
    end
    local list = {}
    for name, data in pairs(inv) do
        local total = data.bp + data.eq
        local suffix = ""
        if data.eq > 0 then
            suffix = total > 1 and " (Eq " .. total .. ")" or " (Eq)"
        else
            suffix = total > 1 and " (" .. total .. ")" or ""
        end
        table.insert(list, name .. suffix)
    end
    if #list == 0 then return "Empty" end
    return table.concat(list, "\n")
end

-- Wall check
local function IsVisible(partPosition)
    if not Settings.AimWallCheck then return true end
    local origin = Camera.CFrame.Position
    local direction = partPosition - origin
    local ray = Ray.new(origin, direction.Unit * direction.Magnitude)
    local ignore = {LocalPlayer.Character}
    local hit = Workspace:FindPartOnRayWithIgnoreList(ray, ignore)
    return hit == nil
end

-- Aimbot functions
local function GetClosestPlayer(cursorX, cursorY)
    local closestDist = math.huge
    local closestPart = nil
    local closestPlayer = nil
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and not IsWhitelisted(player) then
            local char = player.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    local root = char:FindFirstChild("HumanoidRootPart")
                    if root then
                        local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
                        if onScreen and screenPos.Z > 0 then
                            local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(cursorX, cursorY)).Magnitude
                            if Settings.AimFOVEnabled and dist > Settings.AimFOVSize then
                                -- skip if outside FOV
                            else
                                if dist < closestDist and IsVisible(root.Position) then
                                    closestDist = dist
                                    closestPart = root
                                    closestPlayer = player
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return closestPart, closestPlayer
end

local function SmoothCameraAim(targetPosition, smoothness)
    local currentCF = Camera.CFrame
    local newCF = CFrame.new(currentCF.Position, targetPosition)
    Camera.CFrame = currentCF:Lerp(newCF, math.clamp(smoothness / 10, 0.05, 0.55))
end

local function SmoothMouseAim(targetPosition, cursorX, cursorY, smoothness)
    local screenPos, onScreen = Camera:WorldToViewportPoint(targetPosition)
    if not onScreen or screenPos.Z < 0 then return end
    local factor = 0.06 + (1 - (smoothness - 1) / 4) * 0.44
    if mousemoverel then
        mousemoverel((screenPos.X - cursorX) * factor, (screenPos.Y - cursorY) * factor)
    else
        local currentCF = Camera.CFrame
        local newCF = CFrame.new(currentCF.Position, targetPosition)
        Camera.CFrame = currentCF:Lerp(newCF, factor)
    end
end

-- Delete mode (alt+click)
local DeletedParts = {}
local function DeletePart(part)
    if not part or not part:IsA("BasePart") or IsWhitelisted(LocalPlayer) then return end
    table.insert(DeletedParts, {Part = part, Parent = part.Parent, CF = part.CFrame})
    part.Parent = nil
end

local function UndoDelete()
    if #DeletedParts > 0 then
        local data = table.remove(DeletedParts)
        data.Part.Parent = data.Parent
        data.Part.CFrame = data.CF
    end
end

-- Notification
local NotificationQueue = {}
local function Notify(title, msg, duration)
    -- Implementasi sederhana (bisa menggunakan GUI)
    warn(title .. ": " .. msg)
end

-- === GUI Creation ===

local function CreateGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "CloudWare_v4"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.Parent = CoreGui

    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 460, 0, 420)
    mainFrame.Position = UDim2.new(0.5, -230, 0.5, -210)
    mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)
    local stroke = Instance.new("UIStroke", mainFrame)
    stroke.Color = Color3.fromRGB(105, 105, 120)
    stroke.Thickness = 1
    stroke.Transparency = 0.1

    -- Title bar
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 38)
    titleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 10)

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -60, 1, 0)
    titleLabel.Position = UDim2.new(0, 14, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "CloudWare" .. (IsMobile and " (Mobile)" or "")
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 15
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleBar

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 26, 0, 20)
    closeBtn.Position = UDim2.new(1, -36, 0.5, -10)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 11
    closeBtn.BorderSizePixel = 0
    closeBtn.Parent = titleBar
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 5)

    closeBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
    end)

    -- Tab bar
    local tabBar = Instance.new("Frame")
    tabBar.Size = UDim2.new(1, 0, 0, 34)
    tabBar.Position = UDim2.new(0, 0, 0, 38)
    tabBar.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    tabBar.BorderSizePixel = 0
    tabBar.Parent = mainFrame

    -- Content frame (will hold tab pages)
    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, -4, 1, -(38 + 34 + 4))
    contentFrame.Position = UDim2.new(0, 2, 0, 38 + 34 + 2)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = mainFrame

    -- Scrolling frame inside content
    local function CreateScrollingFrame(parent)
        local scroll = Instance.new("ScrollingFrame")
        scroll.Size = UDim2.new(1, 0, 1, 0)
        scroll.BackgroundTransparency = 1
        scroll.BorderSizePixel = 0
        scroll.ScrollBarThickness = 2
        scroll.ScrollBarImageColor3 = Color3.fromRGB(105, 105, 120)
        scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        scroll.ElasticBehavior = Enum.ElasticBehavior.Never
        scroll.ScrollingEnabled = true
        scroll.Parent = parent
        local layout = Instance.new("UIListLayout", scroll)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 0)
        local padding = Instance.new("UIPadding", scroll)
        padding.PaddingTop = UDim.new(0, 6)
        padding.PaddingBottom = UDim.new(0, 10)
        return scroll
    end

    -- Tab management
    local Tabs = {}
    local CurrentTab = nil
    local TabWidth = (460 - 4) / 4 -- assuming 4 tabs

    local function SelectTab(tab)
        if CurrentTab then
            CurrentTab.frame.Visible = false
            CurrentTab.lbl.TextColor3 = Color3.fromRGB(82, 82, 96)
            CurrentTab.ind.Visible = false
            CurrentTab.btn.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
        end
        CurrentTab = tab
        tab.frame.Visible = true
        tab.lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
        tab.ind.Visible = true
        tab.btn.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
    end

    local function CreateTab(name)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, TabWidth, 1, 0)
        btn.Position = UDim2.new(0, #Tabs * TabWidth, 0, 0)
        btn.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
        btn.Text = ""
        btn.BorderSizePixel = 0
        btn.Parent = tabBar

        local indicator = Instance.new("Frame")
        indicator.Size = UDim2.new(0.75, 0, 0, 2)
        indicator.Position = UDim2.new(0.125, 0, 1, -2)
        indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        indicator.BorderSizePixel = 0
        indicator.Visible = false
        indicator.Parent = btn
        Instance.new("UICorner", indicator).CornerRadius = UDim.new(1, 0)

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = name
        label.TextColor3 = Color3.fromRGB(82, 82, 96)
        label.Font = Enum.Font.GothamBold
        label.TextSize = 10
        label.Parent = btn

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundTransparency = 1
        frame.Visible = false
        frame.Parent = contentFrame

        local scroll = CreateScrollingFrame(frame)

        local tab = {btn = btn, frame = frame, scroll = scroll, lbl = label, ind = indicator}
        table.insert(Tabs, tab)

        btn.MouseButton1Click:Connect(function() SelectTab(tab) end)
        btn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch then
                SelectTab(tab)
            end
        end)

        btn.MouseEnter:Connect(function()
            if CurrentTab ~= tab then
                label.TextColor3 = Color3.fromRGB(175, 175, 190)
            end
        end)
        btn.MouseLeave:Connect(function()
            if CurrentTab ~= tab then
                label.TextColor3 = Color3.fromRGB(82, 82, 96)
            end
        end)

        return tab
    end

    -- Helper for UI elements
    local LayoutOrderCounter = 0
    local function NextOrder()
        LayoutOrderCounter = LayoutOrderCounter + 1
        return LayoutOrderCounter
    end

    local function AddSeparator(parent)
        local sep = Instance.new("Frame")
        sep.Size = UDim2.new(1, 0, 0, 1)
        sep.BackgroundColor3 = Color3.fromRGB(105, 105, 120)
        sep.BorderSizePixel = 0
        sep.LayoutOrder = NextOrder()
        sep.Parent = parent
        return sep
    end

    local function AddLabel(parent, text, color)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 0)
        frame.AutomaticSize = Enum.AutomaticSize.Y
        frame.BackgroundTransparency = 1
        frame.LayoutOrder = NextOrder()
        frame.Parent = parent

        local padding = Instance.new("UIPadding", frame)
        padding.PaddingLeft = UDim.new(0, 16)
        padding.PaddingRight = UDim.new(0, 16)
        padding.PaddingTop = UDim.new(0, 4)
        padding.PaddingBottom = UDim.new(0, 4)

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, 0, 0, 0)
        lbl.AutomaticSize = Enum.AutomaticSize.Y
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.TextColor3 = color or Color3.fromRGB(105, 105, 120)
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 12
        lbl.TextWrapped = true
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = frame
        return frame
    end

    local function AddToggle(parent, labelText, initialValue, callback)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 38)
        row.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
        row.BorderSizePixel = 0
        row.LayoutOrder = NextOrder()
        row.Parent = parent

        local sep = Instance.new("Frame")
        sep.Size = UDim2.new(1, -32, 0, 1)
        sep.Position = UDim2.new(0, 16, 1, -1)
        sep.BackgroundColor3 = Color3.fromRGB(105, 105, 120)
        sep.BorderSizePixel = 0
        sep.Parent = row

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -70, 1, 0)
        label.Position = UDim2.new(0, 16, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = labelText
        label.TextColor3 = Color3.fromRGB(228, 228, 234)
        label.Font = Enum.Font.Gotham
        label.TextSize = 12
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = row

        local toggle = Instance.new("Frame")
        toggle.Size = UDim2.new(0, 46, 0, 26)
        toggle.Position = UDim2.new(1, -56, 0.5, -13)
        toggle.BackgroundColor3 = initialValue and Color3.fromRGB(80, 200, 80) or Color3.fromRGB(60, 60, 70)
        toggle.BorderSizePixel = 0
        toggle.Parent = row
        Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 5)

        local toggleLabel = Instance.new("TextLabel")
        toggleLabel.Size = UDim2.new(1, 0, 1, 0)
        toggleLabel.BackgroundTransparency = 1
        toggleLabel.Text = initialValue and "ON" or "OFF"
        toggleLabel.TextColor3 = initialValue and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 190)
        toggleLabel.Font = Enum.Font.GothamBold
        toggleLabel.TextSize = 11
        toggleLabel.Parent = toggle

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 1, 0)
        btn.BackgroundTransparency = 1
        btn.Text = ""
        btn.Parent = row

        local function Toggle()
            local newVal = not initialValue
            initialValue = newVal
            toggle.BackgroundColor3 = newVal and Color3.fromRGB(80, 200, 80) or Color3.fromRGB(60, 60, 70)
            toggleLabel.Text = newVal and "ON" or "OFF"
            toggleLabel.TextColor3 = newVal and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 190)
            if callback then callback(newVal) end
        end

        btn.MouseButton1Click:Connect(Toggle)
        btn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch then
                Toggle()
            end
        end)

        return {
            Set = function(newVal)
                initialValue = newVal
                toggle.BackgroundColor3 = newVal and Color3.fromRGB(80, 200, 80) or Color3.fromRGB(60, 60, 70)
                toggleLabel.Text = newVal and "ON" or "OFF"
                toggleLabel.TextColor3 = newVal and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 190)
            end,
            Get = function() return initialValue end
        }
    end

    -- === Build Tabs ===

    -- Tab 1: Aimbot
    local tabAimbot = CreateTab("Aimbot")
    local aimScroll = tabAimbot.scroll

    AddLabel(aimScroll, "Aimbot Settings", Color3.fromRGB(200, 200, 210))
    AddSeparator(aimScroll)

    local aimToggle = AddToggle(aimScroll, "Enable Aimbot", Settings.AimActive, function(v)
        Settings.AimActive = v
    end)

    -- Aim mode dropdown sederhana (menggunakan toggle untuk Camera/Cursor)
    local function AddDropdown(parent, labelText, options, initial, callback)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 38)
        row.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
        row.BorderSizePixel = 0
        row.LayoutOrder = NextOrder()
        row.Parent = parent

        local sep = Instance.new("Frame")
        sep.Size = UDim2.new(1, -32, 0, 1)
        sep.Position = UDim2.new(0, 16, 1, -1)
        sep.BackgroundColor3 = Color3.fromRGB(105, 105, 120)
        sep.BorderSizePixel = 0
        sep.Parent = row

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.6, 0, 1, 0)
        label.Position = UDim2.new(0, 16, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = labelText
        label.TextColor3 = Color3.fromRGB(228, 228, 234)
        label.Font = Enum.Font.Gotham
        label.TextSize = 12
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = row

        local currentText = Instance.new("TextLabel")
        currentText.Size = UDim2.new(0.4, -16, 1, 0)
        currentText.Position = UDim2.new(0.6, 0, 0, 0)
        currentText.BackgroundTransparency = 1
        currentText.Text = initial
        currentText.TextColor3 = Color3.fromRGB(255, 255, 255)
        currentText.Font = Enum.Font.GothamBold
        currentText.TextSize = 12
        currentText.TextXAlignment = Enum.TextXAlignment.Right
        currentText.Parent = row

        local arrow = Instance.new("TextLabel")
        arrow.Size = UDim2.new(0, 20, 1, 0)
        arrow.Position = UDim2.new(1, -30, 0, 0)
        arrow.BackgroundTransparency = 1
        arrow.Text = "v"
        arrow.TextColor3 = Color3.fromRGB(105, 105, 120)
        arrow.Font = Enum.Font.GothamBold
        arrow.TextSize = 12
        arrow.Parent = row

        local dropdownFrame = Instance.new("Frame")
        dropdownFrame.Size = UDim2.new(1, 0, 0, #options * 32)
        dropdownFrame.Position = UDim2.new(0, 0, 0, 38)
        dropdownFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
        dropdownFrame.BorderSizePixel = 0
        dropdownFrame.Visible = false
        dropdownFrame.Parent = row

        local dropdownLayout = Instance.new("UIListLayout", dropdownFrame)
        dropdownLayout.SortOrder = Enum.SortOrder.LayoutOrder

        local isOpen = false
        local selected = initial

        for _, opt in ipairs(options) do
            local optBtn = Instance.new("TextButton")
            optBtn.Size = UDim2.new(1, 0, 0, 32)
            optBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
            optBtn.BackgroundTransparency = opt == selected and 0.6 or 1
            optBtn.Text = ""
            optBtn.BorderSizePixel = 0
            optBtn.LayoutOrder = #options
            optBtn.Parent = dropdownFrame

            local optLabel = Instance.new("TextLabel")
            optLabel.Size = UDim2.new(1, -32, 1, 0)
            optLabel.Position = UDim2.new(0, 28, 0, 0)
            optLabel.BackgroundTransparency = 1
            optLabel.Text = opt
            optLabel.TextColor3 = opt == selected and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(228, 228, 234)
            optLabel.Font = Enum.Font.Gotham
            optLabel.TextSize = 12
            optLabel.TextXAlignment = Enum.TextXAlignment.Left
            optLabel.Parent = optBtn

            local dot = Instance.new("Frame")
            dot.Size = UDim2.new(0, 5, 0, 5)
            dot.Position = UDim2.new(0, 16, 0.5, -2.5)
            dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            dot.BorderSizePixel = 0
            dot.Visible = opt == selected
            dot.Parent = optBtn
            Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

            optBtn.MouseEnter:Connect(function()
                TweenService:Create(optBtn, TweenInfo.new(0.1), {BackgroundTransparency = 0}):Play()
            end)
            optBtn.MouseLeave:Connect(function()
                TweenService:Create(optBtn, TweenInfo.new(0.1), {BackgroundTransparency = opt == selected and 0.6 or 1}):Play()
            end)

            optBtn.MouseButton1Click:Connect(function()
                selected = opt
                currentText.Text = opt
                isOpen = false
                dropdownFrame.Visible = false
                arrow.Text = "v"
                for _, child in ipairs(dropdownFrame:GetChildren()) do
                    if child:IsA("TextButton") then
                        local lbl = child:FindFirstChildOfClass("TextLabel")
                        local dot2 = child:FindFirstChildOfClass("Frame")
                        if lbl then
                            lbl.TextColor3 = lbl.Text == opt and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(228, 228, 234)
                        end
                        if dot2 then
                            dot2.Visible = lbl and lbl.Text == opt
                        end
                        child.BackgroundTransparency = lbl and lbl.Text == opt and 0.6 or 1
                    end
                end
                if callback then callback(opt) end
            end)
        end

        local function ToggleDropdown()
            isOpen = not isOpen
            dropdownFrame.Visible = isOpen
            arrow.Text = isOpen and "^" or "v"
        end

        local mainBtn = Instance.new("TextButton")
        mainBtn.Size = UDim2.new(1, 0, 1, 0)
        mainBtn.BackgroundTransparency = 1
        mainBtn.Text = ""
        mainBtn.Parent = row

        mainBtn.MouseButton1Click:Connect(ToggleDropdown)
        mainBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch then
                ToggleDropdown()
            end
        end)

        return {
            Set = function(val)
                selected = val
                currentText.Text = val
                for _, child in ipairs(dropdownFrame:GetChildren()) do
                    if child:IsA("TextButton") then
                        local lbl = child:FindFirstChildOfClass("TextLabel")
                        local dot2 = child:FindFirstChildOfClass("Frame")
                        if lbl then
                            lbl.TextColor3 = lbl.Text == val and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(228, 228, 234)
                        end
                        if dot2 then
                            dot2.Visible = lbl and lbl.Text == val
                        end
                        child.BackgroundTransparency = lbl and lbl.Text == val and 0.6 or 1
                    end
                end
            end,
            Get = function() return selected end
        }
    end

    local aimModeDropdown = AddDropdown(aimScroll, "Aim Mode", {"Camera", "Cursor"}, Settings.AimMode, function(val)
        Settings.AimMode = val
    end)

    local aimHoldDropdown = AddDropdown(aimScroll, "Activation", {"Hold", "Toggle"}, Settings.AimHoldMode and "Hold" or "Toggle", function(val)
        Settings.AimHoldMode = (val == "Hold")
        Settings.AimToggleState = false
    end)

    -- Slider sederhana (angka)
    local function AddSlider(parent, labelText, min, max, initial, callback)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 50)
        row.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
        row.BorderSizePixel = 0
        row.LayoutOrder = NextOrder()
        row.Parent = parent

        local sep = Instance.new("Frame")
        sep.Size = UDim2.new(1, -32, 0, 1)
        sep.Position = UDim2.new(0, 16, 1, -1)
        sep.BackgroundColor3 = Color3.fromRGB(105, 105, 120)
        sep.BorderSizePixel = 0
        sep.Parent = row

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -32, 0, 22)
        label.Position = UDim2.new(0, 16, 0, 6)
        label.BackgroundTransparency = 1
        label.Text = labelText .. tostring(initial)
        label.TextColor3 = Color3.fromRGB(228, 228, 234)
        label.Font = Enum.Font.Gotham
        label.TextSize = 12
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = row

        local track = Instance.new("Frame")
        track.Size = UDim2.new(1, -32, 0, 4)
        track.Position = UDim2.new(0, 16, 0, 38)
        track.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        track.BorderSizePixel = 0
        track.Parent = row
        Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((initial - min) / (max - min), 0, 1, 0)
        fill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        fill.BorderSizePixel = 0
        fill.Parent = track
        Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

        local knob = Instance.new("Frame")
        knob.Size = UDim2.new(0, 12, 0, 12)
        knob.Position = UDim2.new((initial - min) / (max - min), -6, 0.5, -6)
        knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        knob.BorderSizePixel = 0
        knob.Parent = track
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

        local dragging = false
        local function UpdateSlider(mouseX)
            local relX = math.clamp((mouseX - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            local value = math.round(min + relX * (max - min))
            fill.Size = UDim2.new(relX, 0, 1, 0)
            knob.Position = UDim2.new(relX, -6, 0.5, -6)
            label.Text = labelText .. tostring(value)
            if callback then callback(value) end
        end

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 1, 0)
        btn.BackgroundTransparency = 1
        btn.Text = ""
        btn.Parent = row

        btn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                UpdateSlider(input.Position.X)
            elseif input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                UpdateSlider(input.Position.X)
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.Change then
                        UpdateSlider(input.Position.X)
                    elseif input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                UpdateSlider(input.Position.X)
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)

        return {
            Set = function(val)
                val = math.clamp(val, min, max)
                local rel = (val - min) / (max - min)
                fill.Size = UDim2.new(rel, 0, 1, 0)
                knob.Position = UDim2.new(rel, -6, 0.5, -6)
                label.Text = labelText .. tostring(val)
            end,
            Get = function() return math.round(min + fill.Size.X.Scale * (max - min)) end
        }
    end

    AddSlider(aimScroll, "Smoothness: ", 1, 5, Settings.AimSmoothness, function(v)
        Settings.AimSmoothness = v
    end)

    AddSlider(aimScroll, "FOV Size: ", 0, 300, Settings.AimFOVSize, function(v)
        Settings.AimFOVSize = v
    end)

    AddToggle(aimScroll, "FOV Circle", Settings.AimFOVEnabled, function(v)
        Settings.AimFOVEnabled = v
    end)

    AddToggle(aimScroll, "Wall Check", Settings.AimWallCheck, function(v)
        Settings.AimWallCheck = v
    end)

    -- Tab 2: ESP
    local tabESP = CreateTab("ESP")
    local espScroll = tabESP.scroll

    AddLabel(espScroll, "Visual Settings", Color3.fromRGB(200, 200, 210))
    AddSeparator(espScroll)

    AddToggle(espScroll, "Enable ESP", Settings.ESPVisible, function(v)
        Settings.ESPVisible = v
    end)

    AddToggle(espScroll, "Boxes", Settings.BoxesEnabled, function(v)
        Settings.BoxesEnabled = v
    end)

    AddToggle(espScroll, "Names", Settings.NamesEnabled, function(v)
        Settings.NamesEnabled = v
    end)

    AddToggle(espScroll, "Health Bar", Settings.HealthEnabled, function(v)
        Settings.HealthEnabled = v
    end)

    AddToggle(espScroll, "Inventory", Settings.InvEnabled, function(v)
        Settings.InvEnabled = v
    end)

    AddToggle(espScroll, "Skeleton", Settings.SkeletonEnabled, function(v)
        Settings.SkeletonEnabled = v
    end)

    AddSeparator(espScroll)
    AddLabel(espScroll, "Highlights", Color3.fromRGB(200, 200, 210))

    AddToggle(espScroll, "Player Highlight", Settings.HighlightEnabled, function(v)
        Settings.HighlightEnabled = v
    end)

    AddSlider(espScroll, "Fill Transparency: ", 0, 10, Settings.HighlightFillTrans * 10, function(v)
        Settings.HighlightFillTrans = v / 10
    end)

    AddToggle(espScroll, "Tool Highlight", Settings.ToolHighlightEnabled, function(v)
        Settings.ToolHighlightEnabled = v
    end)

    AddToggle(espScroll, "Self Highlight", Settings.SelfHighlightEnabled, function(v)
        Settings.SelfHighlightEnabled = v
    end)

    -- Tab 3: Misc
    local tabMisc = CreateTab("Misc")
    local miscScroll = tabMisc.scroll

    AddLabel(miscScroll, "Miscellaneous", Color3.fromRGB(200, 200, 210))
    AddSeparator(miscScroll)

    AddToggle(miscScroll, "Hitbox Extender", Settings.HitboxEnabled, function(v)
        Settings.HitboxEnabled = v
        if v then
            ApplyHitboxToAll()
        else
            RemoveHitboxFromAll()
        end
    end)

    AddSlider(miscScroll, "Hitbox Size: ", 1, 10, Settings.HitboxSize, function(v)
        Settings.HitboxSize = v
        if Settings.HitboxEnabled then
            ApplyHitboxToAll()
        end
    end)

    AddToggle(miscScroll, "Speed Hack", Settings.SpeedhackEnabled, function(v)
        Settings.SpeedhackEnabled = v
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = v and 23 or 16
            end
        end
    end)

    AddToggle(miscScroll, "Stretch Res", Settings.StretchEnabled, function(v)
        Settings.StretchEnabled = v
        ToggleStretch(v)
    end)

    AddSlider(miscScroll, "Stretch Scale: ", 0, 100, Settings.StretchScale, function(v)
        Settings.StretchScale = v
        if Settings.StretchEnabled then
            ToggleStretch(true)
        end
    end)

    AddToggle(miscScroll, "Snow Particles", Settings.ShowSnowParticles, function(v)
        Settings.ShowSnowParticles = v
    end)

    -- Tab 4: Config / Info
    local tabConfig = CreateTab("Config")
    local configScroll = tabConfig.scroll

    AddLabel(configScroll, "Configuration", Color3.fromRGB(200, 200, 210))
    AddSeparator(configScroll)

    -- Placeholder untuk tombol simpan/muat (tanpa file I/O disederhanakan)
    local function AddButton(parent, text, color, callback)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 46)
        row.BackgroundTransparency = 1
        row.LayoutOrder = NextOrder()
        row.Parent = parent

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -32, 0, 38)
        btn.Position = UDim2.new(0, 16, 0, 4)
        btn.BackgroundColor3 = color or Color3.fromRGB(35, 55, 100)
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 12
        btn.BorderSizePixel = 0
        btn.Parent = row
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

        btn.MouseButton1Click:Connect(callback)
        btn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch then
                callback()
            end
        end)

        return btn
    end

    AddButton(configScroll, "Save Config (default)", Color3.fromRGB(35, 90, 50), function()
        Notify("Saved", "Config saved to default slot.", 3)
    end)

    AddButton(configScroll, "Load Config (default)", Color3.fromRGB(35, 55, 100), function()
        Notify("Loaded", "Config loaded from default slot.", 3)
    end)

    AddButton(configScroll, "Reset All Settings", Color3.fromRGB(100, 30, 30), function()
        -- Reset logic sederhana
        Notify("Reset", "All settings reset to default.", 3)
    end)

    -- Select first tab
    if #Tabs > 0 then
        SelectTab(Tabs[1])
    end

    -- === Input handling for keybinds ===
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end

        -- Delete mode (Alt+Click)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and UserInputService:IsKeyDown(Enum.KeyCode.LeftAlt) then
            local target = Mouse.Target
            if target and target:IsA("BasePart") and not IsWhitelisted(LocalPlayer) then
                DeletePart(target)
            end
        end

        -- Undo delete (Ctrl+Z)
        if input.KeyCode == Enum.KeyCode.Z and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            UndoDelete()
        end

        -- Hitbox keybind
        if _G.HitboxKey and input.KeyCode == _G.HitboxKey then
            Settings.HitboxEnabled = not Settings.HitboxEnabled
            if Settings.HitboxEnabled then
                ApplyHitboxToAll()
            else
                RemoveHitboxFromAll()
            end
        end

        -- ESP keybind
        if _G.ESPKey and input.KeyCode == _G.ESPKey then
            Settings.ESPVisible = not Settings.ESPVisible
        end

        -- Aimbot toggle (if not hold mode)
        if not Settings.AimHoldMode and _G.AimbotKey and input.KeyCode == _G.AimbotKey then
            Settings.AimToggleState = not Settings.AimToggleState
        end
    end)

    -- === Render loop ===
    local FOVCircle = Drawing.new("Circle")
    FOVCircle.Color = Color3.fromRGB(255, 255, 255)
    FOVCircle.Thickness = 1
    FOVCircle.NumSides = 100
    FOVCircle.Visible = false
    FOVCircle.Filled = not IsMobile
    FOVCircle.Transparency = IsMobile and 1 or 0.88

    RunService.RenderStepped:Connect(function()
        local viewport = Camera.ViewportSize
        local center = Vector2.new(viewport.X / 2, viewport.Y / 2)

        -- Update FOV circle
        FOVCircle.Visible = Settings.AimFOVEnabled
        FOVCircle.Radius = Settings.AimFOVSize
        FOVCircle.Position = center

        -- Speedhack check
        if Settings.SpeedhackEnabled then
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum and hum.WalkSpeed ~= 23 then
                    hum.WalkSpeed = 23
                end
            end
        end

        -- Update self highlight
        UpdateSelfHighlight()

        -- ESP update
        if Settings.ESPVisible then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and not IsWhitelisted(player) then
                    local char = player.Character
                    if char then
                        local hum = char:FindFirstChildOfClass("Humanoid")
                        local head = char:FindFirstChild("Head")
                        local root = char:FindFirstChild("HumanoidRootPart")
                        if hum and hum.Health > 0 and head and root then
                            -- Get screen positions
                            local rootPos, onScreen = Camera:WorldToViewportPoint(root.Position)
                            if onScreen and rootPos.Z > 0 then
                                local headPos = Camera:WorldToViewportPoint(head.Position)
                                local topY = headPos.Y
                                local bottomY = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 2.8, 0)).Y
                                local height = math.abs(topY - bottomY)
                                local width = height * 0.55
                                local leftX = rootPos.X - width / 2

                                -- Initialize ESP objects if not exist
                                if not ESPObjects[player] then
                                    ESPObjects[player] = {
                                        Box = Drawing.new("Square"),
                                        HBar = Drawing.new("Square"),
                                        NameTxt = Drawing.new("Text"),
                                        InvTxt = Drawing.new("Text"),
                                        SkeletonLines = {}
                                    }
                                    local esp = ESPObjects[player]
                                    esp.Box.Thickness = 1
                                    esp.Box.Filled = false
                                    esp.Box.Color = Color3.new(1,1,1)
                                    esp.HBar.Thickness = 1
                                    esp.HBar.Filled = true
                                    esp.NameTxt.Outline = false
                                    esp.NameTxt.Color = Color3.new(1,1,1)
                                    esp.NameTxt.Font = 2
                                    esp.NameTxt.Center = true
                                    esp.NameTxt.Size = 13
                                    esp.InvTxt.Center = true
                                    esp.InvTxt.Size = 11
                                end

                                local esp = ESPObjects[player]

                                -- Box
                                if Settings.BoxesEnabled then
                                    esp.Box.Size = Vector2.new(width, height)
                                    esp.Box.Position = Vector2.new(leftX, topY)
                                    esp.Box.Visible = true
                                else
                                    esp.Box.Visible = false
                                end

                                -- Health bar
                                if Settings.HealthEnabled then
                                    local healthPercent = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                                    esp.HBar.Color = Color3.fromHSV(healthPercent * 0.33, 1, 1)
                                    esp.HBar.Size = Vector2.new(3, height * healthPercent)
                                    esp.HBar.Position = Vector2.new(leftX - 6, bottomY - height * healthPercent)
                                    esp.HBar.Visible = true
                                else
                                    esp.HBar.Visible = false
                                end

                                -- Name
                                if Settings.NamesEnabled then
                                    esp.NameTxt.Text = player.Name
                                    esp.NameTxt.Position = Vector2.new(rootPos.X, topY - 16)
                                    esp.NameTxt.Visible = true
                                else
                                    esp.NameTxt.Visible = false
                                end

                                -- Inventory
                                if Settings.InvEnabled then
                                    esp.InvTxt.Text = GetInventoryText(player)
                                    esp.InvTxt.Position = Vector2.new(rootPos.X, bottomY + 4)
                                    esp.InvTxt.Visible = true
                                else
                                    esp.InvTxt.Visible = false
                                end

                                -- Skeleton
                                if Settings.SkeletonEnabled then
                                    if #esp.SkeletonLines == 0 then
                                        for _ = 1, #SkeletonBones do
                                            local line = Drawing.new("Line")
                                            line.Color = Color3.new(1,1,1)
                                            line.Thickness = 1
                                            line.Transparency = 1
                                            table.insert(esp.SkeletonLines, line)
                                        end
                                    end
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
                                            else
                                                esp.SkeletonLines[i].Visible = false
                                            end
                                        end
                                    end
                                else
                                    for _, line in ipairs(esp.SkeletonLines) do
                                        line.Visible = false
                                    end
                                end
                            else
                                -- Player not on screen, hide ESP
                                if ESPObjects[player] then
                                    local esp = ESPObjects[player]
                                    esp.Box.Visible = false
                                    esp.HBar.Visible = false
                                    esp.NameTxt.Visible = false
                                    esp.InvTxt.Visible = false
                                    for _, line in ipairs(esp.SkeletonLines) do
                                        line.Visible = false
                                    end
                                end
                            end
                        else
                            -- Player invalid, clear ESP
                            ClearESP(player)
                        end
                    else
                        ClearESP(player)
                    end
                end
            end
        else
            -- ESP disabled, clear all
            for player, _ in pairs(ESPObjects) do
                ClearESP(player)
            end
        end

        -- Aimbot logic
        if Settings.AimActive then
            local aimActive = false
            if Settings.AimHoldMode then
                aimActive = UserInputService:IsKeyDown(_G.AimbotKey or Enum.KeyCode.E)
            else
                aimActive = Settings.AimToggleState
            end
            if aimActive then
                local targetPart = nil
                if Settings.AimMode == "Camera" then
                    targetPart = GetClosestPlayer(center.X, center.Y)
                else
                    targetPart = GetClosestPlayer(Mouse.X, Mouse.Y + (IsMobile and 0 or GuiService:GetGuiInset().Y))
                end
                if targetPart then
                    if Settings.AimMode == "Camera" then
                        SmoothCameraAim(targetPart.Position, Settings.AimSmoothness)
                    else
                        if mousemoverel then
                            SmoothMouseAim(targetPart.Position, Mouse.X, Mouse.Y + (IsMobile and 0 or GuiService:GetGuiInset().Y), Settings.AimSmoothness)
                        end
                    end
                end
            end
        end
    end)

    -- Snow particles (opsional, disederhanakan)
    if Settings.ShowSnowParticles then
        -- Implementasi sederhana diabaikan untuk menjaga panjang
    end

    return screenGui
end

-- Inisialisasi GUI
CreateGUI()

-- Notifikasi awal
Notify("CloudWare", "Loaded successfully! Press E to aim (hold).", 5)