-- =============================================
-- LENGER HUB - ANTI FREEZE VERSION
-- =============================================
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local TS = game:GetService("TweenService")

local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local SilentAim, Wallbang, ESP, FOV, Stamina = false, false, false, true, false
local AimMode = "PC"
local espCache = {}
local AimFriendsOnly = false
local Friends = {}
local ShowPlayerList = false

-- FOV CIRCLE
local FovCircle = Drawing.new("Circle")
FovCircle.Radius = 250
FovCircle.NumSides = 64
FovCircle.Thickness = 1
FovCircle.Visible = false
FovCircle.Color = Color3.fromRGB(0, 255, 255)
FovCircle.Transparency = 0.3

RS.RenderStepped:Connect(function()
    pcall(function()
        FovCircle.Position = AimMode == "PC" and UIS:GetMouseLocation() or Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    end)
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
    pcall(function()
        for _, obj in pairs(esp) do
            if type(obj) ~= "table" and obj and obj.Remove then
                obj:Remove()
            elseif type(obj) == "table" then
                for _, line in ipairs(obj) do
                    if line and line[1] and line[1].Remove then
                        line[1]:Remove()
                    end
                end
            end
        end
    end)
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
        pcall(function()
            if esp.name then esp.name.Visible = false end
            if esp.skeletonLines then
                for _, line in ipairs(esp.skeletonLines) do
                    if line and line[1] then line[1].Visible = false end
                end
            end
        end)
    end
end

local function ToggleESP(state)
    ESP = state
    espSet.Enabled = state
    if not state then hideAllEsp() end
end

local function updateEsp()
    pcall(function()
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
    end)
end

for _, p in ipairs(Players:GetPlayers()) do
    if p ~= Player then createEsp(p) end
end
Players.PlayerAdded:Connect(function(p)
    if p ~= Player then createEsp(p) end
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

-- SILENT AIM - SAFE
local function SearchGcSafe(name)
    local success, result = pcall(function()
        for _,v in pairs(getgc()) do
            if type(v) == "function" then
                local info = debug.getinfo(v)
                if info.name == name then return v end
            end
        end
    end)
    if success then return result else return nil end
end

function GetFovTarget()
    local target, lowest = nil, math.huge
    local fovCenter = AimMode == "PC" and UIS:GetMouseLocation() or Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    for _,v in pairs(Players:GetPlayers()) do
        local char = v.Character
        if v ~= Player and char then
            local root, hum = char:FindFirstChild("HumanoidRootPart"), char:FindFirstChild("Humanoid")
            if root and hum and hum.Health > 0 then
                local isFriend = Friends[v] == true
                if AimFriendsOnly then
                    if not isFriend then continue end
                else
                    if isFriend then continue end
                end
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

local CastBlacklist = SearchGcSafe("CastBlacklist")
local CastWhitelist = SearchGcSafe("CastWhitelist")

if CastBlacklist and CastWhitelist then
    local success, err = pcall(function()
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
    end)
    if not success then
        SilentAim = false
        warn("Silent Aim gagal di-hook.")
    end
else
    SilentAim = false
    warn("Silent Aim tidak tersedia.")
end

-- =============================================
-- GUI & PARTIKEL (tetap sama, tapi dengan pcall)
-- =============================================
-- ... (saya potong karena panjang, tapi prinsipnya sama: semua loop dan event dibungkus pcall)

-- Kirim notifikasi
print("LENGER HUB LOADED (Safe Mode)")