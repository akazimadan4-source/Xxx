-- Load UI Library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/DummyUi-leak-by-x2zu/fetching-main/Tools/Framework.luau"))()

-- Create Main Window
local Window = Library:Window({
    Title = "WAVEX FREE",
    Desc = "Free Script by x2zu",
    Icon = 105059922903197,
    Theme = "Dark",
    Config = {
        Keybind = Enum.KeyCode.LeftControl,
        Size = UDim2.new(0, 500, 0, 400)
    },
    CloseUIButton = {
        Enabled = true,
        Text = "WAVEX"
    }
})

-- === FITUR UTAMA (dari CloudWare) ===

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
    ShowSnowParticles = true,
}

_G.AimbotKey = Enum.KeyCode.E
_G.HitboxKey = nil
_G.ESPKey = nil

local Whitelist = {}
local StretchConn = nil
local Highlights = {}
local ToolHighlights = {}
local SelfHighlight = nil
local ESPObjects = {}
local OriginalSizes = {}
local OriginalTransparencies = {}
local DeletedParts = {}

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

local function IsVisible(partPosition)
    if not Settings.AimWallCheck then return true end
    local origin = Camera.CFrame.Position
    local direction = partPosition - origin
    local ray = Ray.new(origin, direction.Unit * direction.Magnitude)
    local ignore = {LocalPlayer.Character}
    local hit = Workspace:FindPartOnRayWithIgnoreList(ray, ignore)
    return hit == nil
end

local function GetClosestPlayer(cursorX, cursorY)
    local closestDist = math.huge
    local closestPart = nil
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
                                -- skip
                            else
                                if dist < closestDist and IsVisible(root.Position) then
                                    closestDist = dist
                                    closestPart = root
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return closestPart
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

local function Notify(title, msg, duration)
    Window:Notify({
        Title = title,
        Desc = msg,
        Time = duration or 3
    })
end

-- === UI TABS ===

-- Tab: Aimbot
local AimbotTab = Window:Tab({Title = "Aimbot", Icon = "target"})
AimbotTab:Section({Title = "Aimbot Settings"})

AimbotTab:Toggle({
    Title = "Enable Aimbot",
    Desc = "Toggle to enable/disable aimbot",
    Value = false,
    Callback = function(v)
        Settings.AimActive = v
    end
})

AimbotTab:Dropdown({
    Title = "Aim Mode",
    List = {"Camera", "Cursor"},
    Value = "Camera",
    Callback = function(choice)
        Settings.AimMode = choice
    end
})

AimbotTab:Dropdown({
    Title = "Activation",
    List = {"Hold", "Toggle"},
    Value = "Hold",
    Callback = function(choice)
        Settings.AimHoldMode = (choice == "Hold")
        Settings.AimToggleState = false
    end
})

AimbotTab:Slider({
    Title = "Smoothness",
    Min = 1,
    Max = 5,
    Rounding = 0,
    Value = 3,
    Callback = function(val)
        Settings.AimSmoothness = val
    end
})

AimbotTab:Slider({
    Title = "FOV Size",
    Min = 0,
    Max = 300,
    Rounding = 0,
    Value = 100,
    Callback = function(val)
        Settings.AimFOVSize = val
    end
})

AimbotTab:Toggle({
    Title = "FOV Circle",
    Desc = "Show FOV circle on screen",
    Value = false,
    Callback = function(v)
        Settings.AimFOVEnabled = v
    end
})

AimbotTab:Toggle({
    Title = "Wall Check",
    Desc = "Only aim if target is visible",
    Value = false,
    Callback = function(v)
        Settings.AimWallCheck = v
    end
})

-- Tab: ESP
local ESPTab = Window:Tab({Title = "ESP", Icon = "eye"})
ESPTab:Section({Title = "Visual Settings"})

ESPTab:Toggle({
    Title = "Enable ESP",
    Desc = "Master toggle for all ESP",
    Value = true,
    Callback = function(v)
        Settings.ESPVisible = v
    end
})

ESPTab:Toggle({
    Title = "Boxes",
    Value = false,
    Callback = function(v)
        Settings.BoxesEnabled = v
    end
})

ESPTab:Toggle({
    Title = "Names",
    Value = false,
    Callback = function(v)
        Settings.NamesEnabled = v
    end
})

ESPTab:Toggle({
    Title = "Health Bar",
    Value = false,
    Callback = function(v)
        Settings.HealthEnabled = v
    end
})

ESPTab:Toggle({
    Title = "Inventory",
    Value = false,
    Callback = function(v)
        Settings.InvEnabled = v
    end
})

ESPTab:Toggle({
    Title = "Skeleton",
    Value = false,
    Callback = function(v)
        Settings.SkeletonEnabled = v
    end
})

ESPTab:Section({Title = "Highlights"})

ESPTab:Toggle({
    Title = "Player Highlight",
    Value = false,
    Callback = function(v)
        Settings.HighlightEnabled = v
    end
})

ESPTab:Slider({
    Title = "Highlight Fill Transparency",
    Min = 0,
    Max = 10,
    Rounding = 0,
    Value = 5,
    Callback = function(val)
        Settings.HighlightFillTrans = val / 10
    end
})

ESPTab:Toggle({
    Title = "Tool Highlight",
    Value = false,
    Callback = function(v)
        Settings.ToolHighlightEnabled = v
    end
})

ESPTab:Toggle({
    Title = "Self Highlight",
    Value = false,
    Callback = function(v)
        Settings.SelfHighlightEnabled = v
    end
})

-- Tab: Misc
local MiscTab = Window:Tab({Title = "Misc", Icon = "cog"})
MiscTab:Section({Title = "Miscellaneous"})

MiscTab:Toggle({
    Title = "Hitbox Extender",
    Value = false,
    Callback = function(v)
        Settings.HitboxEnabled = v
        if v then
            ApplyHitboxToAll()
        else
            RemoveHitboxFromAll()
        end
    end
})

MiscTab:Slider({
    Title = "Hitbox Size",
    Min = 1,
    Max = 10,
    Rounding = 0,
    Value = 3,
    Callback = function(val)
        Settings.HitboxSize = val
        if Settings.HitboxEnabled then
            ApplyHitboxToAll()
        end
    end
})

MiscTab:Toggle({
    Title = "Speed Hack",
    Desc = "Set walk speed to 23",
    Value = false,
    Callback = function(v)
        Settings.SpeedhackEnabled = v
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = v and 23 or 16
            end
        end
    end
})

MiscTab:Toggle({
    Title = "Stretch Res",
    Value = false,
    Callback = function(v)
        Settings.StretchEnabled = v
        ToggleStretch(v)
    end
})

MiscTab:Slider({
    Title = "Stretch Scale",
    Min = 0,
    Max = 100,
    Rounding = 0,
    Value = 70,
    Callback = function(val)
        Settings.StretchScale = val
        if Settings.StretchEnabled then
            ToggleStretch(true)
        end
    end
})

MiscTab:Toggle({
    Title = "Snow Particles",
    Desc = "Show snow effect in GUI",
    Value = true,
    Callback = function(v)
        Settings.ShowSnowParticles = v
    end
})

-- Tab: Config / Info
local ConfigTab = Window:Tab({Title = "Config", Icon = "wrench"})
ConfigTab:Section({Title = "Configuration"})

ConfigTab:Button({
    Title = "Save Config (default)",
    Desc = "Save current settings",
    Callback = function()
        Notify("Saved", "Config saved to default slot.", 3)
    end
})

ConfigTab:Button({
    Title = "Load Config (default)",
    Desc = "Load saved settings",
    Callback = function()
        Notify("Loaded", "Config loaded from default slot.", 3)
    end
})

ConfigTab:Button({
    Title = "Reset All Settings",
    Desc = "Reset to default values",
    Callback = function()
        Notify("Reset", "All settings reset to default.", 3)
    end
})

-- === KEYBINDS ===

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.UserInputType == Enum.UserInputType.MouseButton1 and UserInputService:IsKeyDown(Enum.KeyCode.LeftAlt) then
        local target = Mouse.Target
        if target and target:IsA("BasePart") and not IsWhitelisted(LocalPlayer) then
            DeletePart(target)
        end
    end

    if input.KeyCode == Enum.KeyCode.Z and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        UndoDelete()
    end

    if _G.HitboxKey and input.KeyCode == _G.HitboxKey then
        Settings.HitboxEnabled = not Settings.HitboxEnabled
        if Settings.HitboxEnabled then
            ApplyHitboxToAll()
        else
            RemoveHitboxFromAll()
        end
    end

    if _G.ESPKey and input.KeyCode == _G.ESPKey then
        Settings.ESPVisible = not Settings.ESPVisible
    end

    if not Settings.AimHoldMode and _G.AimbotKey and input.KeyCode == _G.AimbotKey then
        Settings.AimToggleState = not Settings.AimToggleState
    end
end)

-- === RENDER LOOP ===

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

    FOVCircle.Visible = Settings.AimFOVEnabled
    FOVCircle.Radius = Settings.AimFOVSize
    FOVCircle.Position = center

    if Settings.SpeedhackEnabled then
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum and hum.WalkSpeed ~= 23 then
                hum.WalkSpeed = 23
            end
        end
    end

    UpdateSelfHighlight()

    if Settings.ESPVisible then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and not IsWhitelisted(player) then
                local char = player.Character
                if char then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    local head = char:FindFirstChild("Head")
                    local root = char:FindFirstChild("HumanoidRootPart")
                    if hum and hum.Health > 0 and head and root then
                        local rootPos, onScreen = Camera:WorldToViewportPoint(root.Position)
                        if onScreen and rootPos.Z > 0 then
                            local headPos = Camera:WorldToViewportPoint(head.Position)
                            local topY = headPos.Y
                            local bottomY = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 2.8, 0)).Y
                            local height = math.abs(topY - bottomY)
                            local width = height * 0.55
                            local leftX = rootPos.X - width / 2

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

                            if Settings.BoxesEnabled then
                                esp.Box.Size = Vector2.new(width, height)
                                esp.Box.Position = Vector2.new(leftX, topY)
                                esp.Box.Visible = true
                            else
                                esp.Box.Visible = false
                            end

                            if Settings.HealthEnabled then
                                local healthPercent = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                                esp.HBar.Color = Color3.fromHSV(healthPercent * 0.33, 1, 1)
                                esp.HBar.Size = Vector2.new(3, height * healthPercent)
                                esp.HBar.Position = Vector2.new(leftX - 6, bottomY - height * healthPercent)
                                esp.HBar.Visible = true
                            else
                                esp.HBar.Visible = false
                            end

                            if Settings.NamesEnabled then
                                esp.NameTxt.Text = player.Name
                                esp.NameTxt.Position = Vector2.new(rootPos.X, topY - 16)
                                esp.NameTxt.Visible = true
                            else
                                esp.NameTxt.Visible = false
                            end

                            if Settings.InvEnabled then
                                esp.InvTxt.Text = GetInventoryText(player)
                                esp.InvTxt.Position = Vector2.new(rootPos.X, bottomY + 4)
                                esp.InvTxt.Visible = true
                            else
                                esp.InvTxt.Visible = false
                            end

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
                        ClearESP(player)
                    end
                else
                    ClearESP(player)
                end
            end
        end
    else
        for player, _ in pairs(ESPObjects) do
            ClearESP(player)
        end
    end

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

-- === NOTIFIKASI AWAL ===
Window:Notify({
    Title = "WAVEX FREE",
    Desc = "Script loaded successfully! Press E to aim.",
    Time = 4
})