-- ============================================================
-- SILENT AIM CORE - LENGER STORE
-- Fitur: Silent Aim dengan Wall Check, Wall Bang, FOV, Hit Chance
-- ============================================================

-- ============================================================
-- KONFIGURASI SILENT AIM
-- ============================================================
local SilentConfig = {
    Enabled = false,           -- Master toggle
    Targetting = false,        -- Apakah sedang aktif (biasanya diatur keybind)
    TargetPart = {"Head"},     -- Bagian tubuh yang ditarget
    MaxDistance = 300,         -- Jarak maksimum target
    WallCheck = false,         -- Cek tembok (tidak tembus)
    WallBang = false,          -- Tembus tembok
    HitChance = 100,           -- Akurasi tembakan (0-100%)
    UseFieldOfView = false,    -- Gunakan FOV
    Radius = 100,              -- Radius FOV
    DrawFieldOfView = false,   -- Gambar lingkaran FOV
    FieldOfViewColor = Color3.new(1,1,1),
    FieldOfViewTransparency = 0.25,
    Sides = 100,               -- Jumlah sisi lingkaran FOV
    Snapline = false,          -- Garis dari mouse ke target
    SnaplineColor = Color3.new(1,1,1),
    SnaplineThickness = 1,
    Keybind = nil,             -- Tombol untuk mengaktifkan (diatur di UI)
    Mode = "nil",              -- Mode: "Always", "Toggle", "Hold"
}

-- ============================================================
-- SERVICES
-- ============================================================
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

local SilentTarget = nil  -- Target saat ini

-- ============================================================
-- FUNGSI UTILITY
-- ============================================================

-- Cek jarak antara pemain dan kamera
local function DistanceCheck(Player, Distance)
    if not Player or not Player.Character then return false end
    local hrp = Player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    return Distance > (Camera.CFrame.Position - hrp.Position).Magnitude
end

-- Cek apakah ada tembok antara kamera dan target
local function WallCheck(Character)
    local Origin = Camera.CFrame.Position
    local Head = Character:FindFirstChild("Head")
    if not Head then return false end
    local Params = RaycastParams.new()
    Params.FilterDescendantsInstances = {LocalPlayer.Character, Camera, Character}
    Params.FilterType = Enum.RaycastFilterType.Blacklist
    Params.IgnoreWater = true
    return not Workspace:Raycast(Origin, Head.Position - Origin, Params)
end

-- ============================================================
-- DAPATKAN TARGET TERDEKAT KE MOUSE (SILENT AIM)
-- ============================================================
local function GetClosestPlayerToMouseSilent()
    -- Cek apakah silent aim aktif
    if not SilentConfig.Enabled or not SilentConfig.Targetting then 
        return nil 
    end

    local PriorityPlayers = {}
    local Plrs = Players:GetPlayers()

    -- CEK PRIORITAS (jika ada library.priority)
    if library and library.priority and #library.priority > 0 then
        for _, Value in ipairs(Plrs) do
            if Value == LocalPlayer then continue end
            if not table.find(library.priority, Value.Name) then continue end
            if table.find(library.whitelist, Value.Name) then continue end
            
            -- Cek apakah target valid
            if not Value.Character then continue end
            local hrp = Value.Character:FindFirstChild("HumanoidRootPart")
            local humanoid = Value.Character:FindFirstChild("Humanoid")
            if not hrp or not humanoid or humanoid.Health <= 0 then continue end
            
            -- Cek ForceField
            if Value.Character:FindFirstChildOfClass("ForceField") then continue end
            
            -- Cek jarak
            if not DistanceCheck(Value, SilentConfig.MaxDistance) then continue end

            -- Ambil target part (random dari daftar)
            local PartName = SilentConfig.TargetPart[math.random(1, #SilentConfig.TargetPart)] or "Head"
            local TargetPart = Value.Character:FindFirstChild(PartName)
            if not TargetPart then
                TargetPart = hrp  -- fallback ke HumanoidRootPart
            end

            -- Cek posisi di layar
            local MouseLocation = Vector2.new(Mouse.X, Mouse.Y)
            local Pos, OnScreen = Camera:WorldToScreenPoint(TargetPart.Position)
            if not OnScreen then continue end

            -- Cek FOV
            local Radius = SilentConfig.UseFieldOfView and SilentConfig.Radius or 9e9
            local Dist = (Vector2.new(Pos.X, Pos.Y) - MouseLocation).Magnitude
            if Radius < Dist then continue end

            -- Cek tembok (jika wall check aktif dan wall bang mati)
            if SilentConfig.WallCheck and not SilentConfig.WallBang then
                if not WallCheck(Value.Character) then continue end
            end

            table.insert(PriorityPlayers, {Player = Value, Distance = Dist})
        end

        -- Urutkan berdasarkan jarak terdekat
        table.sort(PriorityPlayers, function(a, b) 
            return a.Distance < b.Distance 
        end)

        if PriorityPlayers[1] then
            return PriorityPlayers[1].Player
        end
    end

    -- CEK SEMUA PEMAIN (tanpa prioritas)
    local ValidPlayers = {}
    for _, Value in ipairs(Plrs) do
        if Value == LocalPlayer then continue end
        if table.find(library.whitelist, Value.Name) then continue end
        
        -- Cek apakah target valid
        if not Value.Character then continue end
        local hrp = Value.Character:FindFirstChild("HumanoidRootPart")
        local humanoid = Value.Character:FindFirstChild("Humanoid")
        if not hrp or not humanoid or humanoid.Health <= 0 then continue end
        
        -- Cek ForceField
        if Value.Character:FindFirstChildOfClass("ForceField") then continue end
        
        -- Cek jarak
        if not DistanceCheck(Value, SilentConfig.MaxDistance) then continue end

        -- Ambil target part (random dari daftar)
        local PartName = SilentConfig.TargetPart[math.random(1, #SilentConfig.TargetPart)] or "Head"
        local TargetPart = Value.Character:FindFirstChild(PartName)
        if not TargetPart then
            TargetPart = hrp
        end

        -- Cek posisi di layar
        local MouseLocation = Vector2.new(Mouse.X, Mouse.Y)
        local Pos, OnScreen = Camera:WorldToScreenPoint(TargetPart.Position)
        if not OnScreen then continue end

        -- Cek FOV
        local Radius = SilentConfig.UseFieldOfView and SilentConfig.Radius or 9e9
        local Dist = (Vector2.new(Pos.X, Pos.Y) - MouseLocation).Magnitude
        if Radius < Dist then continue end

        -- Cek tembok
        if SilentConfig.WallCheck and not SilentConfig.WallBang then
            if not WallCheck(Value.Character) then continue end
        end

        table.insert(ValidPlayers, {Player = Value, Distance = Dist})
    end

    -- Urutkan berdasarkan jarak terdekat
    table.sort(ValidPlayers, function(a, b) 
        return a.Distance < b.Distance 
    end)

    if ValidPlayers[1] then
        return ValidPlayers[1].Player
    end

    return nil
end

-- ============================================================
-- FUNGSI UNTUK MENDAPATKAN TARGET (dari luar)
-- ============================================================
function GetSilentTarget()
    return SilentTarget
end

function UpdateSilentTarget()
    SilentTarget = GetClosestPlayerToMouseSilent()
    return SilentTarget
end

-- ============================================================
-- HOOK NAMECALL (MEMODIFIKASI TEMBAKAN)
-- ============================================================
if hookmetamethod and getnamecallmethod then
    local oldNamecall = hookmetamethod(Workspace, "__namecall", function(self, ...)
        local args = {...}
        local method = getnamecallmethod()

        -- Jika dipanggil dari script kita, lewati
        if checkcaller() then
            return oldNamecall(self, ...)
        end

        -- Update target terbaru
        SilentTarget = GetClosestPlayerToMouseSilent()

        -- Jika silent aim tidak aktif atau tidak ada target, lanjutkan
        if not SilentConfig.Enabled or not SilentConfig.Targetting or not SilentTarget then
            return oldNamecall(self, ...)
        end

        -- Cek hit chance
        if math.random(0, 100) > SilentConfig.HitChance then
            return oldNamecall(self, ...)
        end

        -- Pilih target part secara random dari daftar
        local PartName = SilentConfig.TargetPart[math.random(1, #SilentConfig.TargetPart)] or "Head"
        local TargetPart = SilentTarget.Character and SilentTarget.Character:FindFirstChild(PartName)
        if not TargetPart then
            TargetPart = SilentTarget.Character and SilentTarget.Character:FindFirstChild("HumanoidRootPart")
        end
        if not TargetPart then 
            return oldNamecall(self, ...) 
        end

        -- ============================================================
        -- METHOD "Raycast" (untuk game modern)
        -- ============================================================
        if method == "Raycast" then
            local origin = args[2]  -- Origin raycast
            if origin then
                -- Ubah arah tembakan ke target
                args[3] = (TargetPart.Position - origin).Unit * 1000

                -- WallBang: tembus tembok
                if SilentConfig.WallBang then
                    local params = RaycastParams.new()
                    params.FilterType = Enum.RaycastFilterType.Include
                    params.IgnoreWater = false
                    params.RespectCanCollide = false
                    
                    -- Sertakan semua part target agar tembus
                    local filterList = {}
                    if SilentTarget.Character then
                        for _, v in ipairs(SilentTarget.Character:GetDescendants()) do
                            if v:IsA("BasePart") or v:IsA("MeshPart") then
                                table.insert(filterList, v)
                            end
                        end
                    end
                    params.FilterDescendantsInstances = filterList
                    args[4] = params
                end

                return oldNamecall(self, unpack(args))
            end
        end

        -- ============================================================
        -- METHOD "FindPartOnRay" (untuk game lawas)
        -- ============================================================
        if string.find(string.lower(method), "findpartonray") then
            local ray = args[2]
            if ray and ray.Origin then
                local origin = ray.Origin
                args[2] = Ray.new(origin, (TargetPart.Position - origin).Unit * 9e17)
                
                -- WallBang: langsung kembalikan target part
                if SilentConfig.WallBang then
                    return TargetPart, TargetPart.Position, Vector3.new(0, 0, 0)
                end
                
                return oldNamecall(self, unpack(args))
            end
        end

        return oldNamecall(self, ...)
    end)
end

-- ============================================================
-- KEYBIND LISTENER (jika mode Hold atau Toggle)
-- ============================================================
UserInputService.InputBegan:Connect(function(Input, GameProcessed)
    if GameProcessed then return end
    if not SilentConfig.Keybind then return end
    
    if Input.KeyCode == SilentConfig.Keybind then
        if SilentConfig.Mode == "Toggle" then
            SilentConfig.Targetting = not SilentConfig.Targetting
        elseif SilentConfig.Mode == "Hold" then
            SilentConfig.Targetting = true
        end
    end
end)

UserInputService.InputEnded:Connect(function(Input, GameProcessed)
    if GameProcessed then return end
    if not SilentConfig.Keybind then return end
    
    if Input.KeyCode == SilentConfig.Keybind then
        if SilentConfig.Mode == "Hold" then
            SilentConfig.Targetting = false
        end
    end
end)

-- ============================================================
-- UPDATE TARGET DI RENDER STEP (untuk performa)
-- ============================================================
RunService.RenderStepped:Connect(function()
    if SilentConfig.Enabled then
        SilentTarget = GetClosestPlayerToMouseSilent()
    end
end)

-- ============================================================
-- FUNGSI UNTUK MENGUBAH KONFIGURASI DARI LUAR
-- ============================================================
function SetSilentEnabled(state) 
    SilentConfig.Enabled = state 
end

function SetSilentTargetting(state) 
    SilentConfig.Targetting = state 
end

function SetSilentMaxDistance(val) 
    SilentConfig.MaxDistance = val 
end

function SetSilentHitChance(val) 
    SilentConfig.HitChance = val 
end

function SetSilentWallCheck(state) 
    SilentConfig.WallCheck = state 
end

function SetSilentWallBang(state) 
    SilentConfig.WallBang = state 
end

function SetSilentTargetParts(parts) 
    SilentConfig.TargetPart = parts 
end

function SetSilentFOV(state) 
    SilentConfig.UseFieldOfView = state 
end

function SetSilentDrawFOV(state) 
    SilentConfig.DrawFieldOfView = state 
end

function SetSilentFOVRadius(val) 
    SilentConfig.Radius = val 
end

function SetSilentFOVSides(val) 
    SilentConfig.Sides = val 
end

function SetSilentSnapline(state) 
    SilentConfig.Snapline = state 
end

function SetSilentSnaplineColor(color) 
    SilentConfig.SnaplineColor = color 
end

function SetSilentSnaplineThickness(val) 
    SilentConfig.SnaplineThickness = val 
end

function SetSilentKeybind(key) 
    SilentConfig.Keybind = key 
end

function SetSilentMode(mode) 
    SilentConfig.Mode = mode 
end

-- ============================================================
-- CONTOH PENGGUNAAN
-- ============================================================
-- SetSilentEnabled(true)
-- SetSilentTargetting(true)
-- SetSilentTargetParts({"Head", "UpperTorso"})
-- SetSilentMaxDistance(500)
-- SetSilentHitChance(100)
-- SetSilentWallCheck(false)
-- SetSilentWallBang(true)
-- SetSilentKeybind(Enum.KeyCode.LeftAlt)
-- SetSilentMode("Hold")
-- ============================================================

print("SILENT AIM LOADED - LENGER STORE")