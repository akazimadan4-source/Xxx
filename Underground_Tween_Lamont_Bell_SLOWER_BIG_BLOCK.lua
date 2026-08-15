--==================================================
-- UNDERGROUND TWEEN + PLATFORM
-- FIX: TIDAK JATUH / TIDAK TURUN LAGI SETELAH SAMPAI
-- Target: Lamont Bell
-- LocalScript -> StarterPlayer > StarterPlayerScripts
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

-- Dangkal seperti video
local UNDERGROUND_DEPTH = 4

-- Lebih pelan dan halus
local DOWN_TIME = 3
local TRAVEL_TIME = 25
local UP_TIME = 3

-- Platform
local PLATFORM_SIZE = Vector3.new(10, 0.5, 10)

-- Tinggi HumanoidRootPart dari kaki
local ROOT_TO_FEET = 3

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
-- CREATE PLATFORM
--==================================================

local function createPlatform(root)
	local platform = Instance.new("Part")
	platform.Name = "UndergroundPlatform"
	platform.Size = PLATFORM_SIZE
	platform.Anchored = true
	platform.CanCollide = true
	platform.CanTouch = false
	platform.CanQuery = false
	platform.Material = Enum.Material.SmoothPlastic
	platform.Transparency = 0

	platform.Position = Vector3.new(
		root.Position.X,
		root.Position.Y - ROOT_TO_FEET - 0.25,
		root.Position.Z
	)

	platform.Parent = workspace

	return platform
end

--==================================================
-- KEEP PLAYER EXACTLY ABOVE PLATFORM
--==================================================

local function movePlatform(platform, root, targetPosition, duration, rotation)
	local connection

	connection = RunService.Heartbeat:Connect(function()
		if not platform.Parent or not root.Parent then
			return
		end

		root.CFrame =
			CFrame.new(
				platform.Position.X,
				platform.Position.Y + ROOT_TO_FEET + 0.25,
				platform.Position.Z
			) * rotation

		-- Hilangkan kecepatan jatuh supaya tidak terasa seperti jatuh
		root.AssemblyLinearVelocity = Vector3.zero
		root.AssemblyAngularVelocity = Vector3.zero
	end)

	local tween = TweenService:Create(
		platform,
		TweenInfo.new(
			duration,
			Enum.EasingStyle.Sine,
			Enum.EasingDirection.InOut
		),
		{
			Position = targetPosition
		}
	)

	tween:Play()
	tween.Completed:Wait()

	if connection then
		connection:Disconnect()
	end

	root.CFrame =
		CFrame.new(
			platform.Position.X,
			platform.Position.Y + ROOT_TO_FEET + 0.25,
			platform.Position.Z
		) * rotation

	root.AssemblyLinearVelocity = Vector3.zero
	root.AssemblyAngularVelocity = Vector3.zero
end

--==================================================
-- UNDERGROUND TELEPORT
--==================================================

local function undergroundTeleport()
	if busy then
		return
	end

	busy = true

	local character, humanoid, root = getCharacter()

	if not character or not humanoid or humanoid.Health <= 0 then
		busy = false
		return
	end

	local oldAutoRotate = humanoid.AutoRotate
	local oldPlatformStand = humanoid.PlatformStand

	humanoid.AutoRotate = false
	humanoid.PlatformStand = true

	-- Simpan arah karakter
	local rotation = root.CFrame - root.CFrame.Position

	-- Buat platform
	local platform = createPlatform(root)

	local start = platform.Position

	--==============================================
	-- 1. TURUN SEDIKIT
	--==============================================

	local undergroundStart = Vector3.new(
		start.X,
		start.Y - UNDERGROUND_DEPTH,
		start.Z
	)

	movePlatform(
		platform,
		root,
		undergroundStart,
		DOWN_TIME,
		rotation
	)

	--==============================================
	-- 2. JALAN DI BAWAH TANAH
	--==============================================

	local undergroundTarget = Vector3.new(
		TARGET.X,
		undergroundStart.Y,
		TARGET.Z
	)

	movePlatform(
		platform,
		root,
		undergroundTarget,
		TRAVEL_TIME,
		rotation
	)

	--==============================================
	-- 3. NAIK KE TARGET
	--==============================================

	-- Platform diletakkan sehingga ROOT tepat di
	-- sekitar koordinat target.
	local finalPlatform = Vector3.new(
		TARGET.X,
		TARGET.Y - ROOT_TO_FEET - 0.25,
		TARGET.Z
	)

	movePlatform(
		platform,
		root,
		finalPlatform,
		UP_TIME,
		rotation
	)

	--==============================================
	-- 4. KUNCI POSISI AKHIR
	--==============================================

	root.CFrame =
		CFrame.new(
			TARGET.X,
			TARGET.Y,
			TARGET.Z
		) * rotation

	root.AssemblyLinearVelocity = Vector3.zero
	root.AssemblyAngularVelocity = Vector3.zero

	-- Jangan langsung hapus platform.
	-- Beri waktu supaya karakter benar-benar stabil.
	task.wait(0.5)

	-- Matikan PlatformStand setelah posisi sudah aman.
	humanoid.PlatformStand = false
	humanoid.AutoRotate = oldAutoRotate

	-- Pastikan tetap di posisi target setelah physics aktif.
	task.wait(0.15)

	if humanoid.Health > 0 and root.Parent then
		root.CFrame =
			CFrame.new(
				TARGET.X,
				TARGET.Y,
				TARGET.Z
			) * rotation

		root.AssemblyLinearVelocity = Vector3.zero
		root.AssemblyAngularVelocity = Vector3.zero
	end

	-- Platform baru dihapus setelah karakter stabil.
	task.wait(0.75)

	if platform and platform.Parent then
		platform:Destroy()
	end

	busy = false
end

--==================================================
-- UI
--==================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UndergroundTeleportUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = Player:WaitForChild("PlayerGui")

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 240, 0, 125)
Main.Position = UDim2.new(0.5, -120, 0.75, 0)
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Main.BorderSizePixel = 0
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundTransparency = 1
Title.Text = "LAMONT BELL"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 17
Title.Font = Enum.Font.GothamBold
Title.Parent = Main

local Button = Instance.new("TextButton")
Button.Name = "UndergroundButton"
Button.Size = UDim2.new(1, -20, 0, 45)
Button.Position = UDim2.new(0, 10, 0, 42)
Button.BackgroundColor3 = Color3.fromRGB(45, 120, 255)
Button.Text = "UNDERGROUND TP"
Button.TextColor3 = Color3.fromRGB(255, 255, 255)
Button.TextSize = 15
Button.Font = Enum.Font.GothamBold
Button.BorderSizePixel = 0
Button.Parent = Main

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 8)
ButtonCorner.Parent = Button

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, 0, 0, 20)
Status.Position = UDim2.new(0, 0, 1, -20)
Status.BackgroundTransparency = 1
Status.Text = "Ready"
Status.TextColor3 = Color3.fromRGB(180, 180, 180)
Status.TextSize = 11
Status.Font = Enum.Font.Gotham
Status.Parent = Main

--==================================================
-- BUTTON
--==================================================

Button.MouseButton1Click:Connect(function()
	if busy then
		return
	end

	Button.Text = "MOVING..."
	Status.Text = "Underground..."

	task.spawn(function()
		local success, err = pcall(undergroundTeleport)

		if not success then
			warn("Underground Teleport Error:", err)
			busy = false
			Status.Text = "Error"
		else
			Status.Text = "Arrived at Lamont Bell"
		end

		Button.Text = "UNDERGROUND TP"

		task.wait(2)

		if not busy then
			Status.Text = "Ready"
		end
	end)
end)
