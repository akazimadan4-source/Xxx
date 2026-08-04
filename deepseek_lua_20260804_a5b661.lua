-- ========================================
-- WAVEX HUB - UI CASSERUS LIBRARY
-- ========================================

-- SERVICES
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local TS = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

-- VARIABLES
local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local SilentAim, Wallbang, ESP, FOV = false, false, false, true
local AimMode = "PC"
local espCache = {}

-- FOV CIRCLE
local FovCircle = Drawing.new("Circle")
FovCircle.Radius = 250
FovCircle.NumSides = 64
FovCircle.Thickness = 1
FovCircle.Visible = false
FovCircle.Color = Color3.fromRGB(0, 255, 255)
FovCircle.Transparency = 0.3

RS.RenderStepped:Connect(function()
    FovCircle.Position = AimMode == "PC" and UIS:GetMouseLocation() or Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
end)

-- ESP SETTINGS
local espSet = {
    Enabled = false,
    ShowName = true,
    ShowSkeletons = true,
    NameColor = Color3.fromRGB(0, 255, 255),
    SkeletonsColor = Color3.fromRGB(0, 255, 255)
}

local bones = {
    {"Head","UpperTorso"},{"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},
    {"RightLowerArm","RightHand"},{"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},
    {"LeftLowerArm","LeftHand"},{"UpperTorso","LowerTorso"},{"LowerTorso","LeftUpperLeg"},
    {"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},{"LowerTorso","RightUpperLeg"},
    {"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"}
}

local function newDraw(class, props)
    local d = Drawing.new(class)
    for k,v in pairs(props) do d[k] = v end
    return d
end

local function cleanEsp(esp)
    if not esp then return end
    for _, obj in pairs(esp) do
        if type(obj) ~= "table" and obj and obj.Remove then
            pcall(function() obj:Remove() end)
        elseif type(obj) == "table" then
            for _, line in ipairs(obj) do
                if line and line[1] and line[1].Remove then
                    pcall(function() line[1]:Remove() end)
                end
            end
        end
    end
end

local function createEsp(p)
    espCache[p] = {
        name = newDraw("Text", {Color = espSet.NameColor, Outline = true, Center = true, Size = 13, Visible = false}),
        skeletonLines = {}
    }
end

local function removeEsp(p)
    local esp = espCache[p]
    if esp then
        cleanEsp(esp)
        espCache[p] = nil
    end
end

local function hideAllEsp()
    for _, esp in pairs(espCache) do
        if esp.name then esp.name.Visible = false end
        if esp.skeletonLines then
            for _, line in ipairs(esp.skeletonLines) do
                if line and line[1] then line[1].Visible = false end
            end
        end
    end
end

local function ToggleESP(state)
    ESP = state
    espSet.Enabled = state
    if not state then hideAllEsp() end
end

local function updateEsp()
    for p, esp in pairs(espCache) do
        if not p or not p.Parent then
            removeEsp(p)
            continue
        end
        
        local char = p.Character
        if not char or not espSet.Enabled then
            if esp.name then esp.name.Visible = false end
            if esp.skeletonLines then
                for _, line in ipairs(esp.skeletonLines) do
                    if line and line[1] then line[1].Visible = false end
                end
            end
            continue
        end
        
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChild("Humanoid")
        
        if not root or not hum or hum.Health <= 0 then
            if esp.name then esp.name.Visible = false end
            if esp.skeletonLines then
                for _, line in ipairs(esp.skeletonLines) do
                    if line and line[1] then line[1].Visible = false end
                end
            end
            continue
        end
        
        local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
        if not onScreen then
            if esp.name then esp.name.Visible = false end
            if esp.skeletonLines then
                for _, line in ipairs(esp.skeletonLines) do
                    if line and line[1] then line[1].Visible = false end
                end
            end
            continue
        end
        
        local hrp2D = Camera:WorldToViewportPoint(root.Position)
        local cSize = (Camera:WorldToViewportPoint(root.Position - Vector3.new(0,3,0)).Y - Camera:WorldToViewportPoint(root.Position + Vector3.new(0,2.6,0)).Y) / 2
        local bSize = Vector2.new(math.floor(cSize * 1.8), math.floor(cSize * 1.9))
        local bPos = Vector2.new(math.floor(hrp2D.X - cSize * 1.8 / 2), math.floor(hrp2D.Y - cSize * 1.6 / 2))
        
        if espSet.ShowName then
            esp.name.Text = p.Name
            esp.name.Position = Vector2.new(bSize.X/2 + bPos.X, bPos.Y - 16)
            esp.name.Visible = true
        else
            esp.name.Visible = false
        end
        
        if espSet.ShowSkeletons then
            if #esp.skeletonLines == 0 then
                for _, bp in ipairs(bones) do
                    if char[bp[1]] and char[bp[2]] then
                        local l = newDraw("Line", {Thickness = 1.5, Color = espSet.SkeletonsColor, Transparency = 0.7, Visible = false})
                        table.insert(esp.skeletonLines, {l, bp[1], bp[2]})
                    end
                end
            end
            for _, ld in ipairs(esp.skeletonLines) do
                if char[ld[2]] and char[ld[3]] then
                    local p1 = Camera:WorldToViewportPoint(char[ld[2]].Position)
                    local p2 = Camera:WorldToViewportPoint(char[ld[3]].Position)
                    ld[1].From = Vector2.new(p1.X, p1.Y)
                    ld[1].To = Vector2.new(p2.X, p2.Y)
                    ld[1].Visible = true
                else
                    ld[1].Visible = false
                end
            end
        else
            for _, ld in ipairs(esp.skeletonLines) do
                if ld and ld[1] then ld[1].Visible = false end
            end
        end
    end
end

for _, p in ipairs(Players:GetPlayers()) do
    if p ~= Player then
        createEsp(p)
    end
end

Players.PlayerAdded:Connect(function(p)
    if p ~= Player then
        createEsp(p)
    end
end)

Players.PlayerRemoving:Connect(removeEsp)
RS.RenderStepped:Connect(updateEsp)

local function SearchGc(name)
    for _,v in pairs(getgc()) do
        if type(v) == "function" then
            local info = debug.getinfo(v)
            if info.name == name then return v end
        end
    end
end

function GetFovTarget()
    local target, lowest = nil, math.huge
    local fovCenter = AimMode == "PC" and UIS:GetMouseLocation() or Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    for _,v in pairs(Players:GetPlayers()) do
        local char = v.Character
        if v ~= Player and char then
            local root, hum = char:FindFirstChild("HumanoidRootPart"), char:FindFirstChild("Humanoid")
            if root and hum and hum.Health > 0 then
                local sp, on = Camera:WorldToViewportPoint(root.Position)
                local dist = (fovCenter - Vector2.new(sp.X, sp.Y)).Magnitude
                if dist < FovCircle.Radius and dist < lowest and on then
                    target, lowest = v, dist
                end
            end
        end
    end
    return target
end

local CastBlacklist = SearchGc("CastBlacklist")
local CastWhitelist = SearchGc("CastWhitelist")
if not CastBlacklist or not CastWhitelist then 
    Player:Kick("Missing Function") 
    return 
end

local OldCast = hookfunction(CastBlacklist, function(...)
    local target = GetFovTarget()
    if target and SilentAim then
        local args = {...}
        args[2] = target.Character.Head.Position - args[1]
        if Wallbang then
            args[3] = {target.Character}
            return CastWhitelist(unpack(args))
        end
        return OldCast(unpack(args))
    end
    return OldCast(...)
end)

-- ========================================
-- UI CASSERUS LIBRARY (EMBEDDED)
-- ========================================
local UILibrary = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local function CreateElement(class, properties)
    local element = Instance.new(class)
    for prop, value in pairs(properties) do
        element[prop] = value
    end
    return element
end
function UILibrary:CreateWindow(title)
    local window = {}
    local tabs = {}
    local Minimized = false
    local ScreenGui = CreateElement("ScreenGui", {
        Name = "UILibWindow",
        Parent = game:GetService("CoreGui"),
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false,
        IgnoreGuiInset = true
    })
    local MainFrame = CreateElement("Frame", {
        Name = "MainFrame",
        Parent = ScreenGui,
        BackgroundColor3 = Color3.fromRGB(15, 15, 15),
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -350, 0.5, -250),
        Size = UDim2.new(0, 700, 0, 500),
        ClipsDescendants = true,
        Visible = true
    })
    CreateElement("UICorner", {CornerRadius = UDim.new(0, 20), Parent = MainFrame})
    CreateElement("UIStroke", {Color = Color3.fromRGB(0, 200, 255), Thickness = 3, Transparency = 0.5, Parent = MainFrame})
    CreateElement("UIGradient", {Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 20)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(10, 10, 10)), ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 20))}, Rotation = 45, Parent = MainFrame})
    local TopBar = CreateElement("Frame", {
        Name = "TopBar",
        Parent = MainFrame,
        BackgroundColor3 = Color3.fromRGB(10, 10, 10),
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 70)
    })
    CreateElement("UICorner", {CornerRadius = UDim.new(0, 20), Parent = TopBar})
    CreateElement("TextLabel", {
        Parent = TopBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 25, 0, 0),
        Size = UDim2.new(0.6, 0, 1, 0),
        Font = Enum.Font.GothamBlack,
        Text = title or "UI Library",
        TextColor3 = Color3.fromRGB(0, 200, 255),
        TextSize = 26,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextStrokeTransparency = 0.9,
        TextStrokeColor3 = Color3.fromRGB(255, 255, 255)
    })
    local CloseButton = CreateElement("TextButton", {
        Parent = TopBar,
        BackgroundColor3 = Color3.fromRGB(255, 80, 80),
        BorderSizePixel = 0,
        Position = UDim2.new(1, -60, 0.5, -20),
        Size = UDim2.new(0, 40, 0, 40),
        Font = Enum.Font.GothamBold,
        Text = "X",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 20
    })
    CreateElement("UICorner", {CornerRadius = UDim.new(0, 12), Parent = CloseButton})
    local MinimizeButton = CreateElement("TextButton", {
        Parent = TopBar,
        BackgroundColor3 = Color3.fromRGB(255, 200, 80),
        BorderSizePixel = 0,
        Position = UDim2.new(1, -110, 0.5, -20),
        Size = UDim2.new(0, 40, 0, 40),
        Font = Enum.Font.GothamBold,
        Text = "-",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 20
    })
    CreateElement("UICorner", {CornerRadius = UDim.new(0, 12), Parent = MinimizeButton})
    local TabContainer = CreateElement("Frame", {
        Name = "TabContainer",
        Parent = MainFrame,
        BackgroundColor3 = Color3.fromRGB(15, 15, 15),
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 70),
        Size = UDim2.new(0, 200, 1, -70)
    })
    CreateElement("UICorner", {CornerRadius = UDim.new(0, 12), Parent = TabContainer})
    CreateElement("UIListLayout", {
        Parent = TabContainer,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 10),
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Top
    })
    local ContentFrame = CreateElement("Frame", {
        Name = "ContentFrame",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 210, 0, 80),
        Size = UDim2.new(1, -220, 1, -90)
    })
    local dragging, dragStart, startPos
    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            local connection
            connection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    connection:Disconnect()
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    CloseButton.MouseEnter:Connect(function() TweenService:Create(CloseButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 100, 100)}):Play() end)
    CloseButton.MouseLeave:Connect(function() TweenService:Create(CloseButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 80, 80)}):Play() end)
    CloseButton.MouseButton1Click:Connect(function()
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)}):Play()
        task.wait(0.3)
        ScreenGui:Destroy()
    end)
    MinimizeButton.MouseEnter:Connect(function() TweenService:Create(MinimizeButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 220, 100)}):Play() end)
    MinimizeButton.MouseLeave:Connect(function() TweenService:Create(MinimizeButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 200, 80)}):Play() end)
    MinimizeButton.MouseButton1Click:Connect(function()
        Minimized = not Minimized
        TabContainer.Visible = not Minimized
        ContentFrame.Visible = not Minimized
        if Minimized then
            TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Size = UDim2.new(0, 700, 0, 70)}):Play()
        else
            TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Size = UDim2.new(0, 700, 0, 500)}):Play()
        end
    end)
    function window:SwitchToTab(tabToSelect)
        for _, tab in pairs(tabs) do
            tab.Page.Visible = false
            if tab.Button.BackgroundColor3 ~= Color3.fromRGB(25, 25, 25) then
                TweenService:Create(tab.Button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(25, 25, 25), TextColor3 = Color3.fromRGB(220, 220, 220)}):Play()
            end
        end
        tabToSelect.Page.Visible = true
        TweenService:Create(tabToSelect.Button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 200, 255), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
    end
    function window:CreateTab(name)
        local tab = {}
        local tabButton = CreateElement("TextButton", {
            Name = name .. "Tab",
            Parent = TabContainer,
            BackgroundColor3 = Color3.fromRGB(25, 25, 25),
            BorderSizePixel = 0,
            Size = UDim2.new(1, -20, 0, 50),
            Font = Enum.Font.GothamBold,
            Text = name,
            TextColor3 = Color3.fromRGB(220, 220, 220),
            TextSize = 18
        })
        CreateElement("UICorner", {CornerRadius = UDim.new(0, 12), Parent = tabButton})
        local tabStroke = CreateElement("UIStroke", {Color = Color3.fromRGB(0, 200, 255), Thickness = 2, Transparency = 0.6, Parent = tabButton})
        local page = CreateElement("ScrollingFrame", {
            Name = name .. "Page",
            Parent = ContentFrame,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            ScrollBarThickness = 5,
            ScrollBarImageColor3 = Color3.fromRGB(0, 200, 255),
            Visible = false
        })
        CreateElement("UIListLayout", {Parent = page, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 15)})
        tab.Button = tabButton
        tab.Page = page
        table.insert(tabs, tab)
        tabButton.MouseEnter:Connect(function()
            TweenService:Create(tabStroke, TweenInfo.new(0.2), {Transparency = 0.4, Thickness = 2.5}):Play()
            if not page.Visible then TweenService:Create(tabButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play() end
        end)
        tabButton.MouseLeave:Connect(function()
            TweenService:Create(tabStroke, TweenInfo.new(0.2), {Transparency = 0.6, Thickness = 2}):Play()
            if not page.Visible then TweenService:Create(tabButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(25, 25, 25)}):Play() end
        end)
        tabButton.MouseButton1Click:Connect(function() window:SwitchToTab(tab) end)
        if #tabs == 1 then window:SwitchToTab(tab) end
        function tab:CreateButton(text, callback)
            local button = CreateElement("TextButton", {
                Parent = page,
                BackgroundColor3 = Color3.fromRGB(25, 25, 25),
                BorderSizePixel = 0,
                Size = UDim2.new(1, -20, 0, 50),
                Font = Enum.Font.GothamBold,
                Text = text,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 18,
                LayoutOrder = #page:GetChildren()
            })
            CreateElement("UICorner", {CornerRadius = UDim.new(0, 12), Parent = button})
            local buttonStroke = CreateElement("UIStroke", {Color = Color3.fromRGB(0, 200, 255), Thickness = 2, Transparency = 0.6, Parent = button})
            button.MouseEnter:Connect(function()
                TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play()
                TweenService:Create(buttonStroke, TweenInfo.new(0.2), {Transparency = 0.4, Thickness = 2.5}):Play()
            end)
            button.MouseLeave:Connect(function()
                TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(25, 25, 25)}):Play()
                TweenService:Create(buttonStroke, TweenInfo.new(0.2), {Transparency = 0.6, Thickness = 2}):Play()
            end)
            button.MouseButton1Click:Connect(function()
                pcall(callback)
                TweenService:Create(button, TweenInfo.new(0.1), {Size = UDim2.new(1, -30, 0, 45)}):Play()
                task.wait(0.1)
                TweenService:Create(button, TweenInfo.new(0.1), {Size = UDim2.new(1, -20, 0, 50)}):Play()
            end)
            return button
        end
        function tab:CreateToggle(text, callback)
            local toggleFrame = CreateElement("Frame", {
                Parent = page,
                BackgroundColor3 = Color3.fromRGB(25, 25, 25),
                BorderSizePixel = 0,
                Size = UDim2.new(1, -20, 0, 50),
                LayoutOrder = #page:GetChildren()
            })
            CreateElement("UICorner", {CornerRadius = UDim.new(0, 12), Parent = toggleFrame})
            CreateElement("TextLabel", {
                Parent = toggleFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 15, 0, 0),
                Size = UDim2.new(0.7, 0, 1, 0),
                Font = Enum.Font.GothamBold,
                Text = text,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 18,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            local toggleButton = CreateElement("TextButton", {
                Parent = toggleFrame,
                BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                BorderSizePixel = 0,
                Position = UDim2.new(1, -70, 0.5, -15),
                Size = UDim2.new(0, 60, 0, 30),
                Text = ""
            })
            CreateElement("UICorner", {CornerRadius = UDim.new(1, 0), Parent = toggleButton})
            local toggleIndicator = CreateElement("Frame", {
                Parent = toggleButton,
                BackgroundColor3 = Color3.fromRGB(150, 150, 150),
                BorderSizePixel = 0,
                Position = UDim2.new(0, 5, 0.5, -10),
                Size = UDim2.new(0, 20, 0, 20)
            })
            CreateElement("UICorner", {CornerRadius = UDim.new(1, 0), Parent = toggleIndicator})
            local toggled = false
            toggleButton.MouseButton1Click:Connect(function()
                toggled = not toggled
                if toggled then
                    TweenService:Create(toggleButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 200, 255)}):Play()
                    TweenService:Create(toggleIndicator, TweenInfo.new(0.2), {Position = UDim2.new(1, -25, 0.5, -10), BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
                else
                    TweenService:Create(toggleButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play()
                    TweenService:Create(toggleIndicator, TweenInfo.new(0.2), {Position = UDim2.new(0, 5, 0.5, -10), BackgroundColor3 = Color3.fromRGB(150, 150, 150)}):Play()
                end
                pcall(callback, toggled)
            end)
            return toggleFrame
        end
        function tab:CreateKeybind(text, callback)
            local keybindFrame = CreateElement("Frame", {
                Parent = page,
                BackgroundColor3 = Color3.fromRGB(25, 25, 25),
                BorderSizePixel = 0,
                Size = UDim2.new(1, -20, 0, 50),
                LayoutOrder = #page:GetChildren()
            })
            CreateElement("UICorner", {CornerRadius = UDim.new(0, 12), Parent = keybindFrame})
            CreateElement("TextLabel", {
                Parent = keybindFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 15, 0, 0),
                Size = UDim2.new(0.6, 0, 1, 0),
                Font = Enum.Font.GothamBold,
                Text = text,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 18,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            local keybindButton = CreateElement("TextButton", {
                Parent = keybindFrame,
                BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                BorderSizePixel = 0,
                Position = UDim2.new(1, -100, 0.5, -15),
                Size = UDim2.new(0, 90, 0, 30),
                Font = Enum.Font.GothamBold,
                Text = "None",
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 16
            })
            CreateElement("UICorner", {CornerRadius = UDim.new(0, 10), Parent = keybindButton})
            local keybindStroke = CreateElement("UIStroke", {Color = Color3.fromRGB(0, 200, 255), Thickness = 2, Transparency = 0.6, Parent = keybindButton})
            local currentKey = nil
            local waiting = false
            keybindButton.MouseButton1Click:Connect(function()
                if waiting then return end
                waiting = true
                keybindButton.Text = "..."
                TweenService:Create(keybindStroke, TweenInfo.new(0.2), {Transparency = 0.4}):Play()
                local connection
                connection = UserInputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        currentKey = input.KeyCode
                        keybindButton.Text = currentKey.Name
                        waiting = false
                        TweenService:Create(keybindStroke, TweenInfo.new(0.2), {Transparency = 0.6}):Play()
                        connection:Disconnect()
                    end
                end)
            end)
            UserInputService.InputBegan:Connect(function(input)
                if currentKey and not waiting and input.KeyCode == currentKey then
                    pcall(callback, currentKey)
                end
            end)
            return keybindFrame
        end
        function tab:CreateSlider(text, min, max, default, callback)
            local sliderFrame = CreateElement("Frame", {
                Parent = page,
                BackgroundColor3 = Color3.fromRGB(25, 25, 25),
                BorderSizePixel = 0,
                Size = UDim2.new(1, -20, 0, 60),
                LayoutOrder = #page:GetChildren()
            })
            CreateElement("UICorner", {CornerRadius = UDim.new(0, 12), Parent = sliderFrame})
            CreateElement("TextLabel", {
                Parent = sliderFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 15, 0, 5),
                Size = UDim2.new(0.5, 0, 0.4, 0),
                Font = Enum.Font.GothamBold,
                Text = text,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 18,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            local valueLabel = CreateElement("TextLabel", {
                Parent = sliderFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0.5, 0, 0, 5),
                Size = UDim2.new(0.5, -20, 0.4, 0),
                Font = Enum.Font.Gotham,
                Text = tostring(default),
                TextColor3 = Color3.fromRGB(200, 200, 200),
                TextSize = 16,
                TextXAlignment = Enum.TextXAlignment.Right
            })
            local sliderBar = CreateElement("TextButton", {
                Parent = sliderFrame,
                BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                BorderSizePixel = 0,
                Position = UDim2.new(0.05, 0, 0.6, 0),
                Size = UDim2.new(0.9, 0, 0.25, 0),
                Text = ""
            })
            CreateElement("UICorner", {CornerRadius = UDim.new(1, 0), Parent = sliderBar})
            local sliderBarStroke = CreateElement("UIStroke", {Color = Color3.fromRGB(0, 200, 255), Thickness = 2, Transparency = 0.6, Parent = sliderBar})
            local fill = CreateElement("Frame", {
                Parent = sliderBar,
                BackgroundColor3 = Color3.fromRGB(0, 200, 255),
                BorderSizePixel = 0,
                Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
            })
            CreateElement("UICorner", {CornerRadius = UDim.new(1, 0), Parent = fill})
            local isDragging = false
            local function updateSlider(inputPos)
                local relativeX = inputPos.X - sliderBar.AbsolutePosition.X
                local ratio = math.clamp(relativeX / sliderBar.AbsoluteSize.X, 0, 1)
                local value = math.floor(min + ratio * (max - min) + 0.5)
                fill.Size = UDim2.new(ratio, 0, 1, 0)
                valueLabel.Text = tostring(value)
                pcall(callback, value)
            end
            sliderBar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    isDragging = true
                    updateSlider(input.Position)
                    local conn
                    conn = input.Changed:Connect(function()
                        if input.UserInputState == Enum.UserInputState.End then
                            isDragging = false
                            conn:Disconnect()
                        end
                    end)
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    updateSlider(input.Position)
                end
            end)
            return sliderFrame
        end
        return tab
    end
    window.ScreenGui = ScreenGui  -- expose for cleanup
    return window
end
-- ========================================
-- END OF LIBRARY
-- ========================================

-- ========================================
-- CREATE UI WITH CASSERUS LIBRARY
-- ========================================
local Library = UILibrary
local Window = Library:CreateWindow("WAVEX HUB")
local MainTab = Window:CreateTab("Main")

-- Silent Aim Toggle
MainTab:CreateToggle("Silent Aim", function(state)
    SilentAim = state
    FovCircle.Visible = SilentAim and FOV
end)

-- FOV Circle Toggle
MainTab:CreateToggle("FOV Circle", function(state)
    FOV = state
    FovCircle.Visible = FOV and SilentAim
end)

-- Wallbang Toggle
MainTab:CreateToggle("Wallbang", function(state)
    Wallbang = state
end)

-- ESP Toggle
MainTab:CreateToggle("ESP", function(state)
    ToggleESP(state)
end)

-- Mode Button (cycle PC/HP)
local modeButton
modeButton = MainTab:CreateButton("Mode: PC", function()
    AimMode = (AimMode == "PC") and "HP" or "PC"
    modeButton.Text = "Mode: " .. AimMode
end)

-- Cleanup on UI close
local ScreenGui = Window.ScreenGui
ScreenGui.Destroying:Connect(function()
    -- Turn off all features
    SilentAim = false
    Wallbang = false
    FOV = false
    ToggleESP(false)
    
    -- Remove FOV circle
    if FovCircle then
        pcall(function() FovCircle:Remove() end)
    end
    
    -- Clean up ESP drawings
    for _, esp in pairs(espCache) do
        cleanEsp(esp)
    end
    espCache = {}
    
    -- Unbind any leftover stamina (just in case)
    RS:UnbindFromRenderStep("Stamina")
end)

print("WAVEX HUB loaded with Casserus UI")