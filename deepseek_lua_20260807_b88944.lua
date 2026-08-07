-- ========================================
-- WAVEX HUB v2 - Safe Version (No Hooking)
-- ========================================

local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local TS = game:GetService("TweenService")
local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = Player:GetMouse() -- untuk arah tembakan

-- State
local SilentAim = false
local Wallbang = false
local ESP = false
local FOV = true
local AimMode = "PC" -- PC = mouse position, HP = screen center

-- FOV Circle
local FovCircle = Drawing.new("Circle")
FovCircle.Radius = 250
FovCircle.NumSides = 64
FovCircle.Thickness = 1
FovCircle.Visible = false
FovCircle.Color = Color3.fromRGB(0, 255, 255)
FovCircle.Transparency = 0.3

RS.RenderStepped:Connect(function()
    FovCircle.Position = (AimMode == "PC") and UIS:GetMouseLocation() or Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
end)

-- ESP
local espCache = {}
local espSet = { Enabled = false, ShowName = true, ShowSkeletons = true, NameColor = Color3.fromRGB(0,255,255), SkeletonsColor = Color3.fromRGB(0,255,255) }
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
        if obj and obj.Remove then pcall(obj.Remove, obj) end
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
    if esp then cleanEsp(esp); espCache[p] = nil end
end

local function updateEsp()
    for p, esp in pairs(espCache) do
        if not p or not p.Parent then removeEsp(p) continue end
        local char = p.Character
        if not char or not espSet.Enabled then
            if esp.name then esp.name.Visible = false end
            for _, line in ipairs(esp.skeletonLines) do if line[1] then line[1].Visible = false end end
            continue
        end
        local root, hum = char:FindFirstChild("HumanoidRootPart"), char:FindFirstChild("Humanoid")
        if not root or not hum or hum.Health <= 0 then
            if esp.name then esp.name.Visible = false end
            for _, line in ipairs(esp.skeletonLines) do if line[1] then line[1].Visible = false end end
            continue
        end
        local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
        if not onScreen then
            if esp.name then esp.name.Visible = false end
            for _, line in ipairs(esp.skeletonLines) do if line[1] then line[1].Visible = false end end
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
        else esp.name.Visible = false end
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
                else ld[1].Visible = false end
            end
        else
            for _, ld in ipairs(esp.skeletonLines) do if ld[1] then ld[1].Visible = false end end
        end
    end
end

-- Inisialisasi ESP
for _, p in ipairs(Players:GetPlayers()) do if p ~= Player then createEsp(p) end end
Players.PlayerAdded:Connect(function(p) if p ~= Player then createEsp(p) end end)
Players.PlayerRemoving:Connect(removeEsp)
RS.RenderStepped:Connect(updateEsp)

-- Fungsi mendapatkan target terdekat dalam FOV
local function GetClosestTarget()
    local fovCenter = (AimMode == "PC") and UIS:GetMouseLocation() or Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    local best, bestDist = nil, math.huge
    for _, v in pairs(Players:GetPlayers()) do
        if v == Player then continue end
        local char = v.Character
        if char then
            local root = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChild("Humanoid")
            if root and hum and hum.Health > 0 then
                local sp, on = Camera:WorldToViewportPoint(root.Position)
                if on then
                    local dist = (fovCenter - Vector2.new(sp.X, sp.Y)).Magnitude
                    if dist < FovCircle.Radius and dist < bestDist then
                        best, bestDist = v, dist
                    end
                end
            end
        end
    end
    return best
end

-- === SILENT AIM + WALLBANG (tanpa hook) ===
-- Kita akan mengarahkan tembakan dengan memanipulasi Mouse.Hit saat klik
UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        if not SilentAim then return end
        local target = GetClosestTarget()
        if target then
            local targetChar = target.Character
            if targetChar then
                local head = targetChar:FindFirstChild("Head")
                if head then
                    -- Tentukan posisi target (untuk wallbang, kita bisa tetap pakai head)
                    local targetPos = head.Position
                    -- Jika wallbang aktif, kita tidak peduli halangan
                    if Wallbang then
                        -- Kita tetap arahkan ke targetPos, raycast akan diabaikan oleh game
                        -- Tapi karena kita tidak hook, kita coba set Mouse.Hit ke posisi target
                        Mouse.Hit = CFrame.new(targetPos)
                    else
                        -- Cek apakah ada halangan antara kamera dan target
                        local origin = Camera.CFrame.Position
                        local direction = (targetPos - origin).Unit
                        local ray = Ray.new(origin, direction * 1000)
                        local hit, pos = workspace:FindPartOnRay(ray, Player.Character)
                        if not hit or (hit and (hit:IsDescendantOf(targetChar) or hit:IsDescendantOf(Player.Character))) then
                            -- Tidak terhalang
                            Mouse.Hit = CFrame.new(targetPos)
                        end
                    end
                end
            end
        end
    end
end)

-- ========================================
-- UI (sama seperti sebelumnya, tapi tanpa tombol Stamina)
-- ========================================
local function CreateUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Parent = Player:WaitForChild("PlayerGui")
    ScreenGui.Name = "WAVEXHub_v2"
    ScreenGui.ResetOnSpawn = false

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 280, 0, 320)
    Frame.Position = UDim2.new(0.5, -140, 0.3, 0)
    Frame.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
    Frame.BackgroundTransparency = 0.15
    Frame.BorderSizePixel = 0
    Frame.Active = true
    Frame.Draggable = true
    Frame.Parent = ScreenGui
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 10)
    local Stroke = Instance.new("UIStroke", Frame)
    Stroke.Color = Color3.fromRGB(100, 50, 255)
    Stroke.Thickness = 1.5
    Stroke.Transparency = 0.5

    local Title = Instance.new("TextLabel", Frame)
    Title.Size = UDim2.new(1, 0, 0, 35)
    Title.Position = UDim2.new(0, 0, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "WAVEX HUB v2"
    Title.TextColor3 = Color3.fromRGB(180, 130, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18
    Title.TextScaled = true

    local CloseBtn = Instance.new("TextButton", Frame)
    CloseBtn.Size = UDim2.new(0, 25, 0, 25)
    CloseBtn.Position = UDim2.new(1, -30, 0, 5)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 14
    CloseBtn.Parent = Frame

    local Div = Instance.new("Frame", Frame)
    Div.Size = UDim2.new(0.9, 0, 0, 1)
    Div.Position = UDim2.new(0.05, 0, 0, 35)
    Div.BackgroundColor3 = Color3.fromRGB(100, 50, 255)
    Div.BackgroundTransparency = 0.4
    Div.BorderSizePixel = 0

    local Status = Instance.new("TextLabel", Frame)
    Status.Size = UDim2.new(0.9, 0, 0, 20)
    Status.Position = UDim2.new(0.05, 0, 0, 42)
    Status.BackgroundTransparency = 1
    Status.Text = "Status: INACTIVE"
    Status.TextColor3 = Color3.fromRGB(200, 50, 50)
    Status.Font = Enum.Font.GothamBold
    Status.TextSize = 13
    Status.TextXAlignment = Enum.TextXAlignment.Left

    local function ToggleBtn(text, yPos, defaultColor, onColor)
        local btn = Instance.new("TextButton", Frame)
        btn.Size = UDim2.new(0.85, 0, 0, 30)
        btn.Position = UDim2.new(0.075, 0, 0, yPos)
        btn.BackgroundColor3 = defaultColor
        btn.BackgroundTransparency = 0.2
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(255,255,255)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 12
        btn.BorderSizePixel = 0
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        local btnStroke = Instance.new("UIStroke", btn)
        btnStroke.Color = Color3.fromRGB(100, 50, 255)
        btnStroke.Thickness = 1
        btnStroke.Transparency = 0.6
        return btn
    end

    local AimBtn = ToggleBtn("[OFF] Silent Aim", 70, Color3.fromRGB(150,30,30), Color3.fromRGB(0,200,100))
    local FOVBtn = ToggleBtn("[ON] FOV Circle", 110, Color3.fromRGB(0,150,100), Color3.fromRGB(0,200,100))
    local WallBtn = ToggleBtn("[OFF] Wallbang", 150, Color3.fromRGB(30,30,60), Color3.fromRGB(0,200,100))
    local ESPBtn = ToggleBtn("[OFF] ESP", 190, Color3.fromRGB(30,30,60), Color3.fromRGB(0,200,100))
    local ModeBtn = ToggleBtn("Mode: PC", 230, Color3.fromRGB(20,30,80), Color3.fromRGB(80,20,50))

    AimBtn.MouseButton1Click:Connect(function()
        SilentAim = not SilentAim
        FovCircle.Visible = SilentAim and FOV
        Status.Text = "Status: " .. (SilentAim and "ACTIVE" or "INACTIVE")
        Status.TextColor3 = SilentAim and Color3.fromRGB(50,200,50) or Color3.fromRGB(200,50,50)
        AimBtn.Text = SilentAim and "[ON] Silent Aim" or "[OFF] Silent Aim"
        AimBtn.BackgroundColor3 = SilentAim and Color3.fromRGB(0,200,100) or Color3.fromRGB(150,30,30)
    end)

    FOVBtn.MouseButton1Click:Connect(function()
        FOV = not FOV
        FovCircle.Visible = FOV and SilentAim
        FOVBtn.Text = FOV and "[ON] FOV Circle" or "[OFF] FOV Circle"
        FOVBtn.BackgroundColor3 = FOV and Color3.fromRGB(0,200,100) or Color3.fromRGB(150,30,30)
    end)

    WallBtn.MouseButton1Click:Connect(function()
        Wallbang = not Wallbang
        WallBtn.Text = Wallbang and "[ON] Wallbang" or "[OFF] Wallbang"
        WallBtn.BackgroundColor3 = Wallbang and Color3.fromRGB(0,200,100) or Color3.fromRGB(30,30,60)
    end)

    ESPBtn.MouseButton1Click:Connect(function()
        ESP = not ESP
        espSet.Enabled = ESP
        if not ESP then
            for _, esp in pairs(espCache) do
                if esp.name then esp.name.Visible = false end
                for _, line in ipairs(esp.skeletonLines) do if line[1] then line[1].Visible = false end end
            end
        end
        ESPBtn.Text = ESP and "[ON] ESP" or "[OFF] ESP"
        ESPBtn.BackgroundColor3 = ESP and Color3.fromRGB(0,200,100) or Color3.fromRGB(30,30,60)
    end)

    ModeBtn.MouseButton1Click:Connect(function()
        AimMode = AimMode == "PC" and "HP" or "PC"
        ModeBtn.Text = "Mode: " .. AimMode
        ModeBtn.BackgroundColor3 = AimMode == "PC" and Color3.fromRGB(20,30,80) or Color3.fromRGB(80,20,50)
    end)

    CloseBtn.MouseButton1Click:Connect(function()
        SilentAim = false; Wallbang = false; FOV = false
        FovCircle.Visible = false; FovCircle:Remove()
        ESP = false; espSet.Enabled = false
        for _, esp in pairs(espCache) do cleanEsp(esp) end
        espCache = {}
        ScreenGui:Destroy()
    end)

    -- Notifikasi
    local Notif = Instance.new("TextLabel", ScreenGui)
    Notif.Size = UDim2.new(0, 280, 0, 35)
    Notif.Position = UDim2.new(0.5, -140, 0.9, 0)
    Notif.BackgroundColor3 = Color3.fromRGB(100, 50, 255)
    Notif.BackgroundTransparency = 0.15
    Notif.Text = "WAVEX HUB v2 LOADED"
    Notif.TextColor3 = Color3.fromRGB(255,255,255)
    Notif.Font = Enum.Font.GothamBold
    Notif.TextSize = 14
    Instance.new("UICorner", Notif).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", Notif).Color = Color3.fromRGB(150, 50, 255)

    TS:Create(Notif, TweenInfo.new(1), {Position = UDim2.new(0.5, -140, 0.8, 0)}):Play()
    task.wait(4)
    TS:Create(Notif, TweenInfo.new(0.5), {Position = UDim2.new(0.5, -140, 1.0, 0)}):Play()
    task.wait(0.5)
    Notif:Destroy()
end

CreateUI()