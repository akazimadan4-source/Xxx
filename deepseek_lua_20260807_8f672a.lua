-- WAVEX HUB - CloudWare Style UI (Fixed Size & Clickable)
-- Full Features with Tab System, Slider, Dropdown, Snow Particles

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

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
    ShowSnowParticles = true
}

-- Keybinds
_G.AimbotKey = Enum.KeyCode.E
_G.HitboxKey = nil
_G.ESPKey = nil

-- Whitelist
local Whitelist = {}
local WhitelistGUI = {}

-- Hitbox data
local HitboxOriginal = {}

-- ESP Data
local ESPData = {}
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

-- Drawing objects
local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3.fromRGB(0, 180, 255)
FOVCircle.Thickness = 2
FOVCircle.NumSides = 100
FOVCircle.Filled = false

local DeleteBox = Instance.new("SelectionBox")
DeleteBox.Name = "WAVEX_DeleteHighlight"
DeleteBox.Parent = CoreGui
DeleteBox.Color3 = Color3.fromRGB(255, 0, 0)
DeleteBox.LineThickness = 0.05

-- Stretch
local StretchConn = nil
local function SetStretch(Enabled)
    if StretchConn then
        StretchConn:Disconnect()
        StretchConn = nil
    end
    if not Enabled then return end
    local Scale = 1 - Settings.StretchScale / 100 * 0.45
    StretchConn = RunService.RenderStepped:Connect(function()
        if Camera then
            Camera.CFrame = Camera.CFrame * CFrame.new(0, 0, 0, 1, 0, 0, 0, Scale, 0, 0, 0, 1)
        end
    end)
end

-- ==================== WHITELIST ====================
local function IsWhitelisted(Player)
    return Whitelist[Player.Name] == true
end

local function ToggleWhitelist(Player)
    Whitelist[Player.Name] = not Whitelist[Player.Name]
    if Whitelist[Player.Name] then
        if Player.Character then
            RemoveHitbox(Player.Character)
        end
    else
        if Settings.HitboxEnabled and Player.Character then
            ApplyHitbox(Player.Character)
        end
    end
    UpdateWhitelistGUI()
end

local function UpdateWhitelistGUI()
    for Name, Data in pairs(WhitelistGUI) do
        Data.Toggle.Text = Data.State and "ON" or "OFF"
        Data.Toggle.BackgroundColor3 = Data.State and Color3.fromRGB(60, 200, 60) or Color3.fromRGB(60, 60, 60)
    end
end

-- ==================== HITBOX ====================
local function ApplyHitbox(Character)
    if not Character then return end
    local Torso = Character:FindFirstChild("UpperTorso")
    if not Torso then return end
    local Player = Players:GetPlayerFromCharacter(Character)
    if Player and IsWhitelisted(Player) then return end
    
    if not HitboxOriginal[Torso] then
        HitboxOriginal[Torso] = {
            Size = Torso.Size,
            Transparency = Torso.Transparency
        }
    end
    
    Torso.Size = Vector3.new(Settings.HitboxSize, Settings.HitboxSize, Settings.HitboxSize)
    Torso.Transparency = Settings.HitboxTransparency
    Torso.CanCollide = false
    Torso.Massless = true
end

local function RemoveHitbox(Character)
    if not Character then return end
    local Torso = Character:FindFirstChild("UpperTorso")
    if not Torso or not HitboxOriginal[Torso] then return end
    
    Torso.Size = HitboxOriginal[Torso].Size
    Torso.Transparency = HitboxOriginal[Torso].Transparency
    Torso.CanCollide = true
    Torso.Massless = false
    HitboxOriginal[Torso] = nil
end

local function ApplyHitboxToAll()
    if not Settings.HitboxEnabled then return end
    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and Player.Character and not IsWhitelisted(Player) then
            local Humanoid = Player.Character:FindFirstChildOfClass("Humanoid")
            if Humanoid and Humanoid.Health > 0 then
                ApplyHitbox(Player.Character)
            end
        end
    end
end

local function RemoveAllHitbox()
    for Torso, _ in pairs(HitboxOriginal) do
        if Torso and Torso.Parent then
            Torso.Size = HitboxOriginal[Torso].Size
            Torso.Transparency = HitboxOriginal[Torso].Transparency
            Torso.CanCollide = true
            Torso.Massless = false
        end
    end
    HitboxOriginal = {}
end

-- ==================== HIGHLIGHT ====================
local PlayerHighlights = {}
local ToolHighlights = {}
local SelfHighlight = nil

local function UpdateHighlights()
    for Player, Highlight in pairs(PlayerHighlights) do
        if not Highlight or not Highlight.Parent then
            PlayerHighlights[Player] = nil
        end
    end
    
    if Settings.HighlightEnabled then
        for _, Player in pairs(Players:GetPlayers()) do
            if Player ~= LocalPlayer and Player.Character and not IsWhitelisted(Player) then
                local Humanoid = Player.Character:FindFirstChildOfClass("Humanoid")
                if Humanoid and Humanoid.Health > 0 then
                    if not PlayerHighlights[Player] then
                        local Highlight = Instance.new("Highlight")
                        Highlight.FillColor = Settings.HighlightColor
                        Highlight.OutlineColor = Settings.HighlightOutline
                        Highlight.FillTransparency = Settings.HighlightFillTrans
                        Highlight.OutlineTransparency = 0
                        Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        Highlight.Adornee = Player.Character
                        Highlight.Parent = CoreGui
                        PlayerHighlights[Player] = Highlight
                    else
                        PlayerHighlights[Player].FillColor = Settings.HighlightColor
                        PlayerHighlights[Player].OutlineColor = Settings.HighlightOutline
                        PlayerHighlights[Player].FillTransparency = Settings.HighlightFillTrans
                    end
                end
            end
        end
    else
        for Player, Highlight in pairs(PlayerHighlights) do
            Highlight:Destroy()
        end
        PlayerHighlights = {}
    end
end

local function UpdateSelfHighlight()
    if Settings.SelfHighlightEnabled then
        if not SelfHighlight then
            SelfHighlight = Instance.new("Highlight")
            SelfHighlight.Parent = CoreGui
        end
        if LocalPlayer.Character then
            SelfHighlight.Adornee = LocalPlayer.Character
            SelfHighlight.FillColor = Settings.SelfHighlightColor
            SelfHighlight.OutlineColor = Settings.SelfHighlightOutline
            SelfHighlight.FillTransparency = 0.5
            SelfHighlight.OutlineTransparency = 0
            SelfHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        end
    else
        if SelfHighlight then
            SelfHighlight:Destroy()
            SelfHighlight = nil
        end
    end
end

-- ==================== AIMBOT ====================
local function GetClosestPlayer()
    local Closest, ClosestDist = nil, math.huge
    local MousePos = Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)
    
    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and Player.Character and not IsWhitelisted(Player) then
            local Root = Player.Character:FindFirstChild("HumanoidRootPart")
            local Humanoid = Player.Character:FindFirstChildOfClass("Humanoid")
            if Root and Humanoid and Humanoid.Health > 0 then
                local ScreenPos, OnScreen = Camera:WorldToViewportPoint(Root.Position)
                if OnScreen and ScreenPos.Z > 0 then
                    local Dist = (Vector2.new(ScreenPos.X, ScreenPos.Y) - MousePos).Magnitude
                    if Settings.AimFOVEnabled and Dist > Settings.AimFOVSize then
                    elseif Dist < ClosestDist then
                        Closest, ClosestDist = Player, Dist
                    end
                end
            end
        end
    end
    return Closest
end

local function AimAt(Player)
    if not Player or not Player.Character then return end
    local Root = Player.Character:FindFirstChild("HumanoidRootPart")
    if not Root then return end
    local TargetPos = Root.Position + Vector3.new(0, 1.5, 0)
    Camera.CFrame = CFrame.new(Camera.CFrame.Position, TargetPos)
end

-- ==================== NOTIFICATION ====================
local NotificationCount = 0
local function Notify(Title, Message, Duration)
    Duration = Duration or 3
    NotificationCount = NotificationCount + 1
    local YOffset = 70 + (NotificationCount - 1) * 75
    
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 280, 0, 60)
    Frame.Position = UDim2.new(1, 20, 1, -YOffset)
    Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    Frame.BackgroundTransparency = 0.1
    Frame.BorderSizePixel = 0
    Frame.Parent = CoreGui
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)
    
    local Stroke = Instance.new("UIStroke", Frame)
    Stroke.Color = Color3.fromRGB(255, 255, 255)
    Stroke.Thickness = 1
    Stroke.Transparency = 0.7
    
    local TitleLabel = Instance.new("TextLabel", Frame)
    TitleLabel.Size = UDim2.new(1, -20, 0, 20)
    TitleLabel.Position = UDim2.new(0, 10, 0, 5)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = Title
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 13
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local MsgLabel = Instance.new("TextLabel", Frame)
    MsgLabel.Size = UDim2.new(1, -20, 0, 20)
    MsgLabel.Position = UDim2.new(0, 10, 0, 28)
    MsgLabel.BackgroundTransparency = 1
    MsgLabel.Text = Message
    MsgLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    MsgLabel.Font = Enum.Font.Gotham
    MsgLabel.TextSize = 12
    MsgLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    TweenService:Create(Frame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Position = UDim2.new(1, -(280 + 20), 1, -YOffset)
    }):Play()
    
    task.delay(Duration, function()
        TweenService:Create(Frame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
            Position = UDim2.new(1, 20, 1, -YOffset)
        }):Play()
        task.wait(0.3)
        Frame:Destroy()
        NotificationCount = math.max(0, NotificationCount - 1)
    end)
end

-- ==================== GUI ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "WAVEX_HUB"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true

-- MAIN FRAME
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 380, 0, 480)
MainFrame.Position = UDim2.new(0.5, -190, 0.5, -240)
MainFrame.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
MainFrame.BackgroundTransparency = 0.08
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(255, 255, 255)
MainStroke.Thickness = 1
MainStroke.Transparency = 0.12

-- TITLE BAR
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 12)

local TitleGradient = Instance.new("UIGradient", TitleBar)
TitleGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 40)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 20))
})

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -70, 1, 0)
Title.Position = UDim2.new(0, 14, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "✦ WAVEX HUB"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

local VersionText = Instance.new("TextLabel")
VersionText.Size = UDim2.new(0, 60, 1, 0)
VersionText.Position = UDim2.new(1, -75, 0, 0)
VersionText.BackgroundTransparency = 1
VersionText.Text = "v2.0"
VersionText.TextColor3 = Color3.fromRGB(100, 100, 120)
VersionText.Font = Enum.Font.Gotham
VersionText.TextSize = 11
VersionText.TextXAlignment = Enum.TextXAlignment.Right
VersionText.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -38, 0.5, -14)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = TitleBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 4)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui.Enabled = not ScreenGui.Enabled
end)

CloseBtn.MouseEnter:Connect(function()
    CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
end)
CloseBtn.MouseLeave:Connect(function()
    CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
end)

-- SNOW PARTICLES
local SnowFrame = Instance.new("Frame")
SnowFrame.Size = UDim2.new(1, 0, 1, -40)
SnowFrame.Position = UDim2.new(0, 0, 0, 40)
SnowFrame.BackgroundTransparency = 1
SnowFrame.ClipsDescendants = true
SnowFrame.Parent = MainFrame

local SnowParticles = {}
local SnowCount = 25
local SnowWidth = 380
local SnowHeight = 440

for i = 1, SnowCount do
    local Size = math.random(2, 4)
    local Particle = Instance.new("Frame")
    Particle.Size = UDim2.new(0, Size, 0, Size)
    Particle.BackgroundColor3 = Color3.new(1, 1, 1)
    Particle.BackgroundTransparency = 1 - math.random(20, 60) / 100
    Particle.BorderSizePixel = 0
    Particle.Parent = SnowFrame
    Instance.new("UICorner", Particle).CornerRadius = UDim.new(1, 0)
    
    SnowParticles[i] = {
        Frame = Particle,
        X = math.random(0, SnowWidth),
        Y = math.random(0, SnowHeight),
        Speed = math.random(15, 50),
        Drift = math.random(-8, 8) / 10
    }
    Particle.Position = UDim2.new(0, SnowParticles[i].X, 0, SnowParticles[i].Y)
end

-- TAB BAR
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, 0, 0, 34)
TabBar.Position = UDim2.new(0, 0, 0, 40)
TabBar.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
TabBar.BorderSizePixel = 0
TabBar.Parent = MainFrame

-- TAB CONTAINER
local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(1, 0, 1, -74)
TabContainer.Position = UDim2.new(0, 0, 0, 74)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = MainFrame

local Tabs = {}
local CurrentTab = nil

-- ==================== TAB SYSTEM ====================
local function CreateTab(TabName)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0, 76, 1, 0)
    Btn.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
    Btn.Text = TabName
    Btn.TextColor3 = Color3.fromRGB(100, 100, 130)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 11
    Btn.BorderSizePixel = 0
    Btn.Parent = TabBar
    
    local Indicator = Instance.new("Frame")
    Indicator.Size = UDim2.new(0.5, 0, 0, 2)
    Indicator.Position = UDim2.new(0.25, 0, 1, -2)
    Indicator.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
    Indicator.BorderSizePixel = 0
    Indicator.Visible = false
    Indicator.Parent = Btn
    Instance.new("UICorner", Indicator).CornerRadius = UDim.new(1, 0)
    
    local Content = Instance.new("ScrollingFrame")
    Content.Size = UDim2.new(1, -8, 1, -8)
    Content.Position = UDim2.new(0, 4, 0, 4)
    Content.BackgroundTransparency = 1
    Content.BorderSizePixel = 0
    Content.Visible = false
    Content.Parent = TabContainer
    Content.CanvasSize = UDim2.new(0, 0, 0, 0)
    Content.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Content.ScrollBarThickness = 2
    Content.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 80)
    
    local ContentList = Instance.new("UIListLayout")
    ContentList.SortOrder = Enum.SortOrder.LayoutOrder
    ContentList.Padding = UDim.new(0, 3)
    ContentList.Parent = Content
    
    local TabData = {
        Btn = Btn,
        Content = Content,
        Indicator = Indicator,
        List = ContentList
    }
    
    Btn.MouseButton1Click:Connect(function()
        SwitchTab(TabData)
    end)
    
    Btn.MouseEnter:Connect(function()
        if CurrentTab ~= TabData then
            Btn.TextColor3 = Color3.fromRGB(180, 180, 210)
        end
    end)
    Btn.MouseLeave:Connect(function()
        if CurrentTab ~= TabData then
            Btn.TextColor3 = Color3.fromRGB(100, 100, 130)
        end
    end)
    
    table.insert(Tabs, TabData)
    return TabData
end

local function SwitchTab(TabData)
    if CurrentTab == TabData then return end
    
    if CurrentTab then
        CurrentTab.Content.Visible = false
        CurrentTab.Indicator.Visible = false
        CurrentTab.Btn.TextColor3 = Color3.fromRGB(100, 100, 130)
        CurrentTab.Btn.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
    end
    
    CurrentTab = TabData
    TabData.Content.Visible = true
    TabData.Indicator.Visible = true
    TabData.Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    TabData.Btn.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
end

-- Update tab positions
task.defer(function()
    local TotalTabs = #Tabs
    local TabWidth = 380 / TotalTabs
    for i, Tab in ipairs(Tabs) do
        Tab.Btn.Size = UDim2.new(0, TabWidth, 1, 0)
        Tab.Btn.Position = UDim2.new(0, (i - 1) * TabWidth, 0, 0)
    end
end)

-- ==================== TOGGLE HELPER ====================
local function CreateToggle(Parent, Label, Default, Callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -16, 0, 32)
    Frame.BackgroundTransparency = 1
    Frame.Parent = Parent
    
    local Text = Instance.new("TextLabel")
    Text.Size = UDim2.new(0.6, 0, 1, 0)
    Text.Position = UDim2.new(0, 8, 0, 0)
    Text.BackgroundTransparency = 1
    Text.Text = Label
    Text.TextColor3 = Color3.fromRGB(210, 210, 220)
    Text.Font = Enum.Font.Gotham
    Text.TextSize = 12
    Text.TextXAlignment = Enum.TextXAlignment.Left
    Text.Parent = Frame
    
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 52, 0, 22)
    ToggleBtn.Position = UDim2.new(1, -58, 0.5, -11)
    ToggleBtn.BackgroundColor3 = Default and Color3.fromRGB(0, 180, 255) or Color3.fromRGB(50, 50, 60)
    ToggleBtn.Text = Default and "ON" or "OFF"
    ToggleBtn.TextColor3 = Color3.new(1, 1, 1)
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.TextSize = 10
    ToggleBtn.BorderSizePixel = 0
    ToggleBtn.Parent = Frame
    Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 3)
    
    local State = Default
    ToggleBtn.MouseButton1Click:Connect(function()
        State = not State
        ToggleBtn.BackgroundColor3 = State and Color3.fromRGB(0, 180, 255) or Color3.fromRGB(50, 50, 60)
        ToggleBtn.Text = State and "ON" or "OFF"
        Callback(State)
    end)
    
    return ToggleBtn
end

-- ==================== SLIDER HELPER ====================
local function CreateSlider(Parent, Label, Min, Max, Default, Callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -16, 0, 44)
    Frame.BackgroundTransparency = 1
    Frame.Parent = Parent
    
    local Text = Instance.new("TextLabel")
    Text.Size = UDim2.new(1, 0, 0, 16)
    Text.Position = UDim2.new(0, 8, 0, 0)
    Text.BackgroundTransparency = 1
    Text.Text = Label
    Text.TextColor3 = Color3.fromRGB(210, 210, 220)
    Text.Font = Enum.Font.Gotham
    Text.TextSize = 12
    Text.TextXAlignment = Enum.TextXAlignment.Left
    Text.Parent = Frame
    
    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0, 40, 0, 16)
    ValueLabel.Position = UDim2.new(1, -48, 0, 0)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(Default)
    ValueLabel.TextColor3 = Color3.fromRGB(0, 180, 255)
    ValueLabel.Font = Enum.Font.GothamBold
    ValueLabel.TextSize = 12
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.Parent = Frame
    
    local SliderBg = Instance.new("Frame")
    SliderBg.Size = UDim2.new(1, -8, 0, 4)
    SliderBg.Position = UDim2.new(0, 8, 0, 24)
    SliderBg.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
    SliderBg.BorderSizePixel = 0
    SliderBg.Parent = Frame
    Instance.new("UICorner", SliderBg).CornerRadius = UDim.new(1, 0)
    
    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new((Default - Min) / (Max - Min), 0, 1, 0)
    SliderFill.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
    SliderFill.BorderSizePixel = 0
    SliderFill.Parent = SliderBg
    Instance.new("UICorner", SliderFill).CornerRadius = UDim.new(1, 0)
    
    local SliderBtn = Instance.new("TextButton")
    SliderBtn.Size = UDim2.new(0, 14, 0, 14)
    SliderBtn.Position = UDim2.new((Default - Min) / (Max - Min), -7, 0.5, -7)
    SliderBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SliderBtn.Text = ""
    SliderBtn.BorderSizePixel = 0
    SliderBtn.Parent = SliderBg
    Instance.new("UICorner", SliderBtn).CornerRadius = UDim.new(1, 0)
    
    local Dragging = false
    local Value = Default
    
    local function UpdateSlider(X)
        local Pos = math.clamp((X - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X, 0, 1)
        Value = math.round(Min + Pos * (Max - Min))
        SliderFill.Size = UDim2.new(Pos, 0, 1, 0)
        SliderBtn.Position = UDim2.new(Pos, -7, 0.5, -7)
        ValueLabel.Text = tostring(Value)
        Callback(Value)
    end
    
    SliderBtn.MouseButton1Down:Connect(function()
        Dragging = true
    end)
    
    UserInputService.InputEnded:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(Input)
        if Dragging and Input.UserInputType == Enum.UserInputType.MouseMovement then
            UpdateSlider(Input.Position.X)
        end
    end)
    
    SliderBtn.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            UpdateSlider(Input.Position.X)
        end
    end)
    
    return Value
end

-- ==================== DROPDOWN HELPER ====================
local function CreateDropdown(Parent, Label, Options, Default, Callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -16, 0, 32)
    Frame.BackgroundTransparency = 1
    Frame.Parent = Parent
    
    local Text = Instance.new("TextLabel")
    Text.Size = UDim2.new(0.45, 0, 1, 0)
    Text.Position = UDim2.new(0, 8, 0, 0)
    Text.BackgroundTransparency = 1
    Text.Text = Label
    Text.TextColor3 = Color3.fromRGB(210, 210, 220)
    Text.Font = Enum.Font.Gotham
    Text.TextSize = 12
    Text.TextXAlignment = Enum.TextXAlignment.Left
    Text.Parent = Frame
    
    local DropBtn = Instance.new("TextButton")
    DropBtn.Size = UDim2.new(0.4, 0, 1, -4)
    DropBtn.Position = UDim2.new(0.55, 0, 0, 2)
    DropBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    DropBtn.Text = Default
    DropBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
    DropBtn.Font = Enum.Font.Gotham
    DropBtn.TextSize = 11
    DropBtn.BorderSizePixel = 0
    DropBtn.Parent = Frame
    Instance.new("UICorner", DropBtn).CornerRadius = UDim.new(0, 3)
    
    local DropdownFrame = Instance.new("Frame")
    DropdownFrame.Size = UDim2.new(0.4, 0, 0, 0)
    DropdownFrame.Position = UDim2.new(0.55, 0, 0, 32)
    DropdownFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 33)
    DropdownFrame.BorderSizePixel = 0
    DropdownFrame.ClipsDescendants = true
    DropdownFrame.Visible = false
    DropdownFrame.ZIndex = 10
    DropdownFrame.Parent = Frame
    Instance.new("UICorner", DropdownFrame).CornerRadius = UDim.new(0, 3)
    
    local DropList = Instance.new("UIListLayout")
    DropList.SortOrder = Enum.SortOrder.LayoutOrder
    DropList.Padding = UDim.new(0, 1)
    DropList.Parent = DropdownFrame
    
    local Expanded = false
    local Selected = Default
    
    for _, Option in ipairs(Options) do
        local OptionBtn = Instance.new("TextButton")
        OptionBtn.Size = UDim2.new(1, 0, 0, 24)
        OptionBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 33)
        OptionBtn.Text = Option
        OptionBtn.TextColor3 = Option == Selected and Color3.fromRGB(0, 180, 255) or Color3.fromRGB(170, 170, 190)
        OptionBtn.Font = Enum.Font.Gotham
        OptionBtn.TextSize = 11
        OptionBtn.BorderSizePixel = 0
        OptionBtn.ZIndex = 11
        OptionBtn.Parent = DropdownFrame
        
        OptionBtn.MouseEnter:Connect(function()
            OptionBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
        end)
        OptionBtn.MouseLeave:Connect(function()
            OptionBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 33)
        end)
        OptionBtn.MouseButton1Click:Connect(function()
            Selected = Option
            DropBtn.Text = Option
            DropdownFrame.Visible = false
            Expanded = false
            Callback(Option)
            for _, Btn in pairs(DropdownFrame:GetChildren()) do
                if Btn:IsA("TextButton") then
                    Btn.TextColor3 = Btn.Text == Option and Color3.fromRGB(0, 180, 255) or Color3.fromRGB(170, 170, 190)
                end
            end
        end)
    end
    
    DropBtn.MouseButton1Click:Connect(function()
        Expanded = not Expanded
        DropdownFrame.Visible = Expanded
        DropdownFrame.Size = UDim2.new(0.4, 0, 0, #Options * 24 + 4)
    end)
end

-- ==================== SECTION TITLE ====================
local function CreateSection(Parent, TitleText)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 22)
    Frame.BackgroundTransparency = 1
    Frame.Parent = Parent
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -12, 1, 0)
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = "─── " .. TitleText .. " ───"
    Label.TextColor3 = Color3.fromRGB(255, 200, 50)
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame
end

-- ==================== CREATE TABS ====================
local TabAimbot = CreateTab("Aimbot")
local TabESP = CreateTab("ESP")
local TabHighlight = CreateTab("Highlight")
local TabHitbox = CreateTab("Hitbox")
local TabMisc = CreateTab("Misc")
local TabWhitelist = CreateTab("Whitelist")

-- ==================== TAB: AIMBOT ====================
local AimbotContent = TabAimbot.Content
CreateSection(AimbotContent, "AIMBOT")
CreateToggle(AimbotContent, "Aimbot", false, function(v) Settings.AimActive = v end)
CreateDropdown(AimbotContent, "Aim Mode", {"Camera", "Cursor"}, "Camera", function(v) Settings.AimMode = v end)
CreateDropdown(AimbotContent, "Hold Mode", {"Hold", "Toggle"}, "Hold", function(v) Settings.AimHoldMode = v == "Hold" end)
CreateSlider(AimbotContent, "FOV Size", 20, 400, 100, function(v) Settings.AimFOVSize = v end)
CreateSlider(AimbotContent, "Smoothness", 1, 10, 3, function(v) Settings.AimSmoothness = v end)
CreateToggle(AimbotContent, "FOV Circle", false, function(v) Settings.AimFOVEnabled = v end)
CreateToggle(AimbotContent, "Wall Check", false, function(v) Settings.AimWallCheck = v end)

-- ==================== TAB: ESP ====================
local ESPContent = TabESP.Content
CreateSection(ESPContent, "ESP")
CreateToggle(ESPContent, "Box ESP", false, function(v) Settings.BoxesEnabled = v end)
CreateToggle(ESPContent, "Name ESP", false, function(v) Settings.NamesEnabled = v end)
CreateToggle(ESPContent, "Health ESP", false, function(v) Settings.HealthEnabled = v end)
CreateToggle(ESPContent, "Inventory ESP", false, function(v) Settings.InvEnabled = v end)
CreateToggle(ESPContent, "Skeleton ESP", false, function(v) Settings.SkeletonEnabled = v end)
CreateToggle(ESPContent, "ESP Visible", true, function(v) Settings.ESPVisible = v end)

-- ==================== TAB: HIGHLIGHT ====================
local HighlightContent = TabHighlight.Content
CreateSection(HighlightContent, "HIGHLIGHT")
CreateToggle(HighlightContent, "Player Highlight", false, function(v) 
    Settings.HighlightEnabled = v 
    UpdateHighlights()
end)
CreateToggle(HighlightContent, "Tool Highlight", false, function(v) Settings.ToolHighlightEnabled = v end)
CreateToggle(HighlightContent, "Self Highlight", false, function(v) 
    Settings.SelfHighlightEnabled = v 
    UpdateSelfHighlight()
end)
CreateSlider(HighlightContent, "Highlight Trans", 0, 10, 5, function(v) 
    Settings.HighlightFillTrans = v / 10 
end)

-- ==================== TAB: HITBOX ====================
local HitboxContent = TabHitbox.Content
CreateSection(HitboxContent, "HITBOX")
CreateToggle(HitboxContent, "Hitbox (Big Body)", false, function(v) 
    Settings.HitboxEnabled = v
    if v then
        ApplyHitboxToAll()
        Notify("Hitbox", "Hitbox enabled! Use at own risk.", 3)
    else
        RemoveAllHitbox()
    end
end)
CreateSlider(HitboxContent, "Hitbox Size", 1, 10, 3, function(v) 
    Settings.HitboxSize = v 
    if Settings.HitboxEnabled then
        RemoveAllHitbox()
        ApplyHitboxToAll()
    end
end)
CreateSlider(HitboxContent, "Hitbox Trans", 0, 10, 5, function(v) 
    Settings.HitboxTransparency = v / 10
    if Settings.HitboxEnabled then
        RemoveAllHitbox()
        ApplyHitboxToAll()
    end
end)

-- ==================== TAB: MISC ====================
local MiscContent = TabMisc.Content
CreateSection(MiscContent, "MISC")
CreateToggle(MiscContent, "Speed Boost", false, function(v) 
    Settings.SpeedhackEnabled = v
    local Char = LocalPlayer.Character
    if Char then
        local Humanoid = Char:FindFirstChildOfClass("Humanoid")
        if Humanoid then
            Humanoid.WalkSpeed = v and 23 or 16
        end
    end
end)
CreateToggle(MiscContent, "Stretch Res", false, function(v) 
    Settings.StretchEnabled = v
    SetStretch(v)
end)
CreateSlider(MiscContent, "Stretch Scale", 10, 100, 70, function(v) 
    Settings.StretchScale = v 
    if Settings.StretchEnabled then
        SetStretch(true)
    end
end)
CreateToggle(MiscContent, "Delete Mode", false, function(v) Settings.DeleteActive = v end)
CreateToggle(MiscContent, "Snow Particles", true, function(v) Settings.ShowSnowParticles = v end)

-- ==================== TAB: WHITELIST ====================
local WhitelistContent = TabWhitelist.Content
CreateSection(WhitelistContent, "WHITELIST")

local WhitelistFrame = Instance.new("Frame")
WhitelistFrame.Size = UDim2.new(1, 0, 0, 0)
WhitelistFrame.AutomaticSize = Enum.AutomaticSize.Y
WhitelistFrame.BackgroundTransparency = 1
WhitelistFrame.Parent = WhitelistContent

local WhitelistListLayout = Instance.new("UIListLayout")
WhitelistListLayout.SortOrder = Enum.SortOrder.LayoutOrder
WhitelistListLayout.Padding = UDim.new(0, 2)
WhitelistListLayout.Parent = WhitelistFrame

local function CreateWhitelistToggle(Player)
    if Player == LocalPlayer then return end
    
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 28)
    Frame.BackgroundTransparency = 1
    Frame.Parent = WhitelistFrame
    
    local NameLabel = Instance.new("TextLabel")
    NameLabel.Size = UDim2.new(0.6, 0, 1, 0)
    NameLabel.Position = UDim2.new(0, 8, 0, 0)
    NameLabel.BackgroundTransparency = 1
    NameLabel.Text = Player.Name
    NameLabel.TextColor3 = Color3.fromRGB(210, 210, 220)
    NameLabel.Font = Enum.Font.Gotham
    NameLabel.TextSize = 12
    NameLabel.TextXAlignment = Enum.TextXAlignment.Left
    NameLabel.Parent = Frame
    
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 50, 0, 22)
    ToggleBtn.Position = UDim2.new(1, -58, 0.5, -11)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    ToggleBtn.Text = "OFF"
    ToggleBtn.TextColor3 = Color3.new(1, 1, 1)
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.TextSize = 10
    ToggleBtn.BorderSizePixel = 0
    ToggleBtn.Parent = Frame
    Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 3)
    
    local State = false
    ToggleBtn.MouseButton1Click:Connect(function()
        State = not State
        ToggleBtn.BackgroundColor3 = State and Color3.fromRGB(0, 180, 255) or Color3.fromRGB(50, 50, 60)
        ToggleBtn.Text = State and "ON" or "OFF"
        ToggleWhitelist(Player)
    end)
    
    WhitelistGUI[Player.Name] = {
        Toggle = ToggleBtn,
        State = State
    }
end

-- Add existing players
for _, Player in pairs(Players:GetPlayers()) do
    CreateWhitelistToggle(Player)
end

Players.PlayerAdded:Connect(function(Player)
    task.wait(0.3)
    CreateWhitelistToggle(Player)
end)

Players.PlayerRemoving:Connect(function(Player)
    WhitelistGUI[Player.Name] = nil
    Whitelist[Player.Name] = nil
end)

-- ==================== HITBOX EVENT ====================
local function OnCharacterAdded(Player, Character)
    task.wait(0.5)
    if Settings.HitboxEnabled and not IsWhitelisted(Player) then
        ApplyHitbox(Character)
    end
end

for _, Player in pairs(Players:GetPlayers()) do
    if Player ~= LocalPlayer then
        Player.CharacterAdded:Connect(function(Char)
            OnCharacterAdded(Player, Char)
        end)
        if Player.Character then
            OnCharacterAdded(Player, Player.Character)
        end
    end
end

Players.PlayerAdded:Connect(function(Player)
    Player.CharacterAdded:Connect(function(Char)
        OnCharacterAdded(Player, Char)
    end)
end)

-- ==================== INPUT HANDLER ====================
UserInputService.InputBegan:Connect(function(Input, GameProcessed)
    if GameProcessed then return end
    
    if Input.UserInputType == Enum.UserInputType.MouseButton1 and UserInputService:IsKeyDown(Enum.KeyCode.LeftAlt) then
        if Settings.DeleteActive then
            local Target = LocalPlayer:GetMouse().Target
            if Target and Target:IsA("BasePart") then
                Target.Parent = nil
                Notify("Deleted", "Part deleted!", 1)
            end
        end
    end
    
    if Input.UserInputType == Enum.UserInputType.Keyboard then
        if _G.HitboxKey and Input.KeyCode == _G.HitboxKey then
            Settings.HitboxEnabled = not Settings.HitboxEnabled
            if Settings.HitboxEnabled then
                ApplyHitboxToAll()
                Notify("Hitbox", "Hitbox enabled!", 2)
            else
                RemoveAllHitbox()
                Notify("Hitbox", "Hitbox disabled!", 2)
            end
        end
        if _G.ESPKey and Input.KeyCode == _G.ESPKey then
            Settings.ESPVisible = not Settings.ESPVisible
        end
        if not Settings.AimHoldMode and _G.AimbotKey and Input.KeyCode == _G.AimbotKey then
            Settings.AimToggleState = not Settings.AimToggleState
            Notify("Aimbot", Settings.AimToggleState and "Aimbot ON" or "Aimbot OFF", 1)
        end
    end
end)

-- ==================== MAIN LOOP ====================
RunService.RenderStepped:Connect(function()
    -- Snow Particles
    if Settings.ShowSnowParticles then
        for _, Particle in ipairs(SnowParticles) do
            Particle.Y = Particle.Y + Particle.Speed * 0.016
            Particle.X = Particle.X + Particle.Drift
            if Particle.Y > SnowHeight then
                Particle.Y = -5
                Particle.X = math.random(0, SnowWidth)
            end
            if Particle.X < 0 then Particle.X = SnowWidth end
            if Particle.X > SnowWidth then Particle.X = 0 end
            Particle.Frame.Position = UDim2.new(0, Particle.X, 0, Particle.Y)
            Particle.Frame.Visible = true
        end
    else
        for _, Particle in ipairs(SnowParticles) do
            Particle.Frame.Visible = false
        end
    end
    
    -- FOV Circle
    if Settings.AimFOVEnabled then
        FOVCircle.Visible = true
        FOVCircle.Radius = Settings.AimFOVSize
        local Viewport = Camera.ViewportSize
        FOVCircle.Position = Vector2.new(Viewport.X / 2, Viewport.Y / 2)
    else
        FOVCircle.Visible = false
    end
    
    -- Aimbot
    local AimKey = Settings.AimHoldMode and UserInputService:IsKeyDown(_G.AimbotKey or Enum.KeyCode.E) or Settings.AimToggleState
    if Settings.AimActive and AimKey then
        local Target = GetClosestPlayer()
        if Target then
            AimAt(Target)
        end
    end
    
    -- Speedhack
    if Settings.SpeedhackEnabled then
        local Char = LocalPlayer.Character
        if Char then
            local Humanoid = Char:FindFirstChildOfClass("Humanoid")
            if Humanoid and Humanoid.WalkSpeed ~= 23 then
                Humanoid.WalkSpeed = 23
            end
        end
    end
    
    -- Delete Mode Box
    if Settings.DeleteActive then
        local Target = LocalPlayer:GetMouse().Target
        if Target and Target:IsA("BasePart") then
            DeleteBox.Adornee = Target
        else
            DeleteBox.Adornee = nil
        end
    else
        DeleteBox.Adornee = nil
    end
    
    -- Update Highlights
    UpdateHighlights()
    UpdateSelfHighlight()
end)

-- ==================== CLEANUP ====================
pcall(function()
    for _, v in pairs(CoreGui:GetChildren()) do
        if v.Name == "WAVEX_HUB" then
            v:Destroy()
        end
    end
end)

print("✅ WAVEX HUB Loaded!")
print("❄️ Premium UI with Tabs, Slider, Dropdown, Snow Particles")
Notify("WAVEX HUB", "Loaded successfully! 🚀", 3)