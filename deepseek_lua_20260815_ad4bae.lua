--==================================================
-- UNDERGROUND TWEEN + MOVING PLATFORM (ULTRA STABLE)
-- Target: Lamont Bell
-- LocalScript: StarterPlayer > StarterPlayerScripts
--==================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer

--==================================================
-- TARGET LAMONT BELL
--==================================================

local TARGET = Vector3.new(
    510.8173828125,
    4.581132888793945,
    601.048095703125
)

--==================================================
-- SETTINGS
--==================================================

local UNDERGROUND_DEPTH = 30
local PLATFORM_SIZE = Vector3.new(7, 0.6, 7)

local DOWN_TIME = 0.6
local TRAVEL_TIME = 3
local UP_TIME = 0.6

local busy = false

--==================================================
-- CHARACTER
--==================================================

local function getCharacter()
    local character = Player.Character or Player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    local root = character:WaitForChild("HumanoidRootPart")
    return character, humanoid, root
end

--==================================================
-- CREATE PLATFORM WITH ATTACHMENT
--==================================================

local function createPlatform(root)
    local platform = Instance.new("Part")
    platform.Name = "UndergroundPlatform"
    platform.Size = PLATFORM_SIZE
    platform.Anchored = true
    platform.CanCollide = true
    platform.CanTouch = false
    platform.CanQuery = false
    platform.Transparency = 0
    platform.Material = Enum.Material.SmoothPlastic
    platform.BrickColor = BrickColor.new("Bright blue")
    platform.Parent = workspace
    
    platform.CFrame = CFrame.new(
        root.Position.X,
        root.Position.Y - 3.1,
        root.Position.Z
    )
    
    -- Buat attachment di platform
    local platAtt = Instance.new("Attachment")
    platAtt.Parent = platform
    platAtt.Position = Vector3.new(0, 3.1, 0) -- titik di atas platform (sejajar dengan root)
    
    -- Buat attachment di root (karakter)
    local rootAtt = Instance.new("Attachment")
    rootAtt.Parent = root
    rootAtt.Position = Vector3.new(0, 0, 0)
    
    -- Buat AlignPosition untuk mengikat root ke platform
    local alignPos = Instance.new("AlignPosition")
    alignPos.Parent = platform
    alignPos.Attachment0 = platAtt
    alignPos.Attachment1 = rootAtt
    alignPos.MaxForce = 100000
    alignPos.MaxVelocity = 100
    alignPos.RigidityEnabled = true
    alignPos.Responsiveness = 200
    alignPos.Enabled = true
    
    -- Buat AlignOrientation agar karakter tetap tegak
    local alignOri = Instance.new("AlignOrientation")
    alignOri.Parent = platform
    alignOri.Attachment0 = platAtt
    alignOri.Attachment1 = rootAtt
    alignOri.MaxTorque = 100000
    alignOri.RigidityEnabled = true
    alignOri.Responsiveness = 200
    alignOri.Enabled = true
    
    return platform, platAtt, rootAtt, alignPos, alignOri
end

--==================================================
-- UNDERGROUND TELEPORT (STABLE WITH ALIGN)
--==================================================

local function undergroundTeleport()
    if busy then return end
    busy = true
    
    local character, humanoid, root = getCharacter()
    
    if not character or not humanoid or humanoid.Health <= 0 then
        busy = false
        return
    end
    
    -- Simpan state
    local oldAutoRotate = humanoid.AutoRotate
    local oldPlatformStand = humanoid.PlatformStand
    
    humanoid.AutoRotate = false
    humanoid.PlatformStand = true
    
    -- Buat platform dan attachment
    local platform, platAtt, rootAtt, alignPos, alignOri = createPlatform(root)
    
    -- Hitung posisi
    local currentPos = platform.Position
    local offset = root.Position - platform.Position -- sebenarnya tidak terlalu dipakai karena align
    
    local undergroundStart = Vector3.new(
        currentPos.X,
        currentPos.Y - UNDERGROUND_DEPTH,
        currentPos.Z
    )
    
    local undergroundTarget = Vector3.new(
        TARGET.X,
        currentPos.Y - UNDERGROUND_DEPTH,
        TARGET.Z
    )
    
    local finalPosition = Vector3.new(
        TARGET.X,
        TARGET.Y - 3.1,
        TARGET.Z
    )
    
    -- Fungsi untuk menggerakkan platform dengan tween
    local function movePlatformTo(targetPos, duration)
        local tween = TweenService:Create(
            platform,
            TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut),
            { Position = targetPos }
        )
        tween:Play()
        tween.Completed:Wait()
    end
    
    -- 1. Turun
    movePlatformTo(undergroundStart, DOWN_TIME)
    
    -- 2. Bergerak di bawah tanah
    movePlatformTo(undergroundTarget, TRAVEL_TIME)
    
    -- 3. Naik
    movePlatformTo(finalPosition, UP_TIME)
    
    -- Matikan align agar karakter bebas
    alignPos.Enabled = false
    alignOri.Enabled = false
    
    -- Hapus attachment dan align
    platAtt:Destroy()
    rootAtt:Destroy()
    alignPos:Destroy()
    alignOri:Destroy()
    
    -- Pastikan posisi akhir tepat (sedikit koreksi)
    local finalCharPos = finalPosition + Vector3.new(0, 3.1, 0) -- karena platform di bawah 3.1
    root.CFrame = CFrame.new(finalCharPos) * (root.CFrame - root.CFrame.Position)
    
    -- Kembalikan physics
    task.wait(0.1)
    humanoid.PlatformStand = oldPlatformStand
    humanoid.AutoRotate = oldAutoRotate
    
    -- Hapus platform
    if platform and platform.Parent then
        platform:Destroy()
    end
    
    busy = false
end

-- UI SAMA SEPERTI SEBELUMNYA...
-- (saya sertakan UI yang sama tapi saya ringkas agar tidak terlalu panjang)