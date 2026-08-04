-- ========================================
-- WAVEX HUB - FULLY FIXED WITH FALLBACK UI
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
local SilentAim, Wallbang, ESP, FOV, Stamina = false, false, false, true, false
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

local function ToggleStamina(state)
    Stamina = state
    if state then
        RS:BindToRenderStep("Stamina", 0, function()
            if not Stamina then return end
            pcall(function()
                local ps = Player:FindFirstChild("PlayerScripts")
                if ps then
                    for _, child in pairs(ps:GetDescendants()) do
                        if child.Name == "MovementController" and child:IsA("ModuleScript") then
                            local req = require(child)
                            if req then req.Stamina = 100 end
                        end
                    end
                end
            end)
        end)
    else
        RS:UnbindFromRenderStep("Stamina")
    end
end

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
-- UI LOADER (DENGAN FALLBACK)
-- ========================================

local function CreateManualUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Parent = Player:WaitForChild("PlayerGui")
    ScreenGui.Name = "WAVEXHub"

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 340, 0, 330)
    Frame.Position = UDim2.new(0.5, -170, 0.3, 0)
    Frame.BackgroundColor3 = Color3.fromRGB(10, 5, 25)
    Frame.BackgroundTransparency = 0.1
    Frame.BorderSizePixel = 0
    Frame.Active = true
    Frame.Draggable = true
    Frame.Parent = ScreenGui
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 14)

    local Header = Instance.new("Frame", Frame)
    Header.Size = UDim2.new(1,0,0,40)
    Header.BackgroundTransparency = 1

    local Title = Instance.new("TextLabel", Header)
    Title.Size = UDim2.new(0.7,0,1,0)
    Title.Position = UDim2.new(0.05,0,0,0)
    Title.BackgroundTransparency = 1
    Title.Text = "WAVEX HUB"
    Title.TextColor3 = Color3.fromRGB(150, 100, 255)
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16

    local Content = Instance.new("Frame", Frame)
    Content.Size = UDim2.new(1,0,1,-40)
    Content.Position = UDim2.new(0,0,0,40)
    Content.BackgroundTransparency = 1

    local Status = Instance.new("TextLabel", Content)
    Status.Size = UDim2.new(0.9,0,0,25)
    Status.Position = UDim2.new(0.05,0,0.02,0)
    Status.BackgroundTransparency = 1
    Status.Text = "INACTIVE"
    Status.TextColor3 = Color3.fromRGB(200,50,50)
    Status.Font = Enum.Font.GothamBold
    Status.TextSize = 13
    Status.TextXAlignment = Enum.TextXAlignment.Left

    local function Btn(text, x, y, color)
        local b = Instance.new("TextButton", Content)
        b.Size = UDim2.new(0.43,0,0,30)
        b.Position = UDim2.new(x,0,y,0)
        b.BackgroundColor3 = color
        b.BackgroundTransparency = 0.15
        b.Text = text
        b.TextColor3 = Color3.fromRGB(255,255,255)
        b.Font = Enum.Font.GothamBold
        b.TextSize = 12
        Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
        Instance.new("UIStroke", b).Color = Color3.fromRGB(100, 50, 255)
        return b
    end

    local FOVBtn = Btn("FOV ON", 0.05, 0.16, Color3.fromRGB(0,150,100))
    local AimBtn = Btn("AIM OFF", 0.52, 0.16, Color3.fromRGB(150,30,30))
    local WallBtn = Btn("WALL OFF", 0.05, 0.37, Color3.fromRGB(30,30,60))
    local ESPBtn = Btn("ESP OFF", 0.52, 0.37, Color3.fromRGB(30,30,60))
    local StaminaBtn = Btn("STAMINA OFF", 0.05, 0.58, Color3.fromRGB(30,30,60))
    local ModeBtn = Btn("MODE: PC", 0.52, 0.58, Color3.fromRGB(20,30,80))

    FOVBtn.MouseButton1Click:Connect(function()
        FOV = not FOV
        FovCircle.Visible = FOV and SilentAim
        FOVBtn.Text = FOV and "FOV ON" or "FOV OFF"
        FOVBtn.BackgroundColor3 = FOV and Color3.fromRGB(0,200,100) or Color3.fromRGB(150,30,30)
    end)

    AimBtn.MouseButton1Click:Connect(function()
        SilentAim = not SilentAim
        FovCircle.Visible = SilentAim and FOV
        Status.Text = SilentAim and "ACTIVE" or "INACTIVE"
        Status.TextColor3 = SilentAim and Color3.fromRGB(50,200,50) or Color3.fromRGB(200,50,50)
        AimBtn.Text = SilentAim and "AIM ON" or "AIM OFF"
        AimBtn.BackgroundColor3 = SilentAim and Color3.fromRGB(0,200,100) or Color3.fromRGB(150,30,30)
    end)

    WallBtn.MouseButton1Click:Connect(function()
        Wallbang = not Wallbang
        WallBtn.Text = Wallbang and "WALL ON" or "WALL OFF"
        WallBtn.BackgroundColor3 = Wallbang and Color3.fromRGB(0,200,100) or Color3.fromRGB(30,30,60)
    end)

    ESPBtn.MouseButton1Click:Connect(function()
        ToggleESP(not ESP)
        ESPBtn.Text = ESP and "ESP ON" or "ESP OFF"
        ESPBtn.BackgroundColor3 = ESP and Color3.fromRGB(0,200,100) or Color3.fromRGB(30,30,60)
    end)

    StaminaBtn.MouseButton1Click:Connect(function()
        ToggleStamina(not Stamina)
        StaminaBtn.Text = Stamina and "STAMINA ON" or "STAMINA OFF"
        StaminaBtn.BackgroundColor3 = Stamina and Color3.fromRGB(0,200,100) or Color3.fromRGB(30,30,60)
    end)

    ModeBtn.MouseButton1Click:Connect(function()
        AimMode = AimMode == "PC" and "HP" or "PC"
        ModeBtn.Text = "MODE: " .. AimMode
    end)

    -- Notifikasi
    local Notif = Instance.new("TextLabel", ScreenGui)
    Notif.Size = UDim2.new(0,340,0,40)
    Notif.Position = UDim2.new(0.5,-170,0.9,0)
    Notif.BackgroundColor3 = Color3.fromRGB(100,50,255)
    Notif.BackgroundTransparency = 0.15
    Notif.Text = "WAVEX HUB (MANUAL UI) LOADED"
    Notif.TextColor3 = Color3.fromRGB(255,255,255)
    Notif.Font = Enum.Font.GothamBold
    Notif.TextSize = 14
    Instance.new("UICorner", Notif).CornerRadius = UDim.new(0,8)
    Instance.new("UIStroke", Notif).Color = Color3.fromRGB(150,50,255)

    TS:Create(Notif, TweenInfo.new(1), {Position = UDim2.new(0.5,-170,0.8,0)}):Play()
    task.wait(4)
    TS:Create(Notif, TweenInfo.new(0.5), {Position = UDim2.new(0.5,-170,0.95,0)}):Play()
    task.wait(0.5)
    Notif:Destroy()
end

-- ========================================
-- COBA LOAD LIBRARY ARCANE
-- ========================================
local success, library = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/NIcoGabrielRealYtr/Arcane-Library-Modified/refs/heads/main/Source"))()
end)

if success and library and type(library) == "table" then
    -- Library berhasil
    local Window = library:Window({
        Name = "WAVEX Hub",
        Logo = "rbxassetid://93450275909746",
        Size = UDim2.fromOffset(568, 350)
    })

    Window:Category("Combat")
    local AimbotPage = Window:Page({Name = "Aimbot", Icon = "136879043989014"})
    local WallbangPage = Window:Page({Name = "Wallbang", Icon = "136879043989014"})
    local StaminaPage = Window:Page({Name = "Stamina", Icon = "136879043989014"})

    local AimbotSection = AimbotPage:Section({Name = "Aimbot Settings", Icon = "136879043989014"})
    AimbotSection:Toggle({
        Name = "Silent Aim",
        Flag = "SilentAim",
        Callback = function(Value) SilentAim = Value; FovCircle.Visible = FOV and SilentAim end
    })
    AimbotSection:Toggle({
        Name = "Show FOV Circle",
        Flag = "FOV",
        Callback = function(Value) FOV = Value; FovCircle.Visible = FOV and SilentAim end
    })
    AimbotSection:Slider({
        Name = "FOV Radius",
        Flag = "FOVRadius",
        Min = 50, Max = 500, Default = 250, Suffix = "px",
        Callback = function(Value) FovCircle.Radius = Value end
    })
    AimbotSection:Dropdown({
        Name = "Aim Mode",
        Flag = "AimMode",
        Items = {"PC", "HP"},
        Default = "PC",
        Multi = false,
        Callback = function(Value) AimMode = Value end
    })

    local WallbangSection = WallbangPage:Section({Name = "Wallbang", Icon = "136879043989014"})
    WallbangSection:Toggle({
        Name = "Wallbang",
        Flag = "Wallbang",
        Callback = function(Value) Wallbang = Value end
    })

    local StaminaSection = StaminaPage:Section({Name = "Stamina", Icon = "136879043989014"})
    StaminaSection:Toggle({
        Name = "Infinite Stamina",
        Flag = "Stamina",
        Callback = function(Value) ToggleStamina(Value) end
    })

    Window:Category("Visuals")
    local ESPPage = Window:Page({Name = "ESP", Icon = "136879043989014"})
    local ESPSection = ESPPage:Section({Name = "ESP Settings", Icon = "136879043989014"})
    ESPSection:Toggle({
        Name = "Enable ESP",
        Flag = "ESP",
        Callback = function(Value) ToggleESP(Value) end
    })
    ESPSection:Toggle({
        Name = "Show Names",
        Flag = "ShowNames",
        Default = true,
        Callback = function(Value) espSet.ShowName = Value end
    })
    ESPSection:Toggle({
        Name = "Show Skeletons",
        Flag = "ShowSkeletons",
        Default = true,
        Callback = function(Value) espSet.ShowSkeletons = Value end
    })
    ESPSection:Colorpicker({
        Name = "Name Color",
        Flag = "NameColor",
        Default = Color3.fromRGB(0, 255, 255),
        Callback = function(Value) espSet.NameColor = Value end
    })
    ESPSection:Colorpicker({
        Name = "Skeleton Color",
        Flag = "SkeletonColor",
        Default = Color3.fromRGB(0, 255, 255),
        Callback = function(Value) espSet.SkeletonsColor = Value end
    })

    Window:Category("Settings")
    local SettingsPage = Window:Page({Name = "General", Icon = "136879043989014"})
    local SettingsSection = SettingsPage:Section({Name = "UI", Icon = "136879043989014"})
    SettingsSection:Button({
        Name = "Unload WAVEX Hub",
        Callback = function()
            SilentAim = false; Wallbang = false; FOV = false
            FovCircle.Visible = false; FovCircle:Remove()
            ToggleESP(false); ToggleStamina(false)
            for _, esp in pairs(espCache) do cleanEsp(esp) end
            espCache = {}
            Window:Destroy()
            Player.PlayerGui:FindFirstChild("WAVEXHub") and Player.PlayerGui.WAVEXHub:Destroy()
        end
    })

    library:Notification("WAVEX Hub loaded successfully!", 4, "93450275909746")
else
    -- Gagal load library, gunakan UI manual
    CreateManualUI()
    warn("WAVEX Hub: Library gagal dimuat, menggunakan UI manual.")
end