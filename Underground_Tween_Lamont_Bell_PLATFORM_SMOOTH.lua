--==================================================
-- UNDERGROUND TWEEN + PLATFORM (SMOOTH VERSION)
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

-- Lebih dangkal supaya tidak terlihat jatuh terlalu jauh.
local UNDERGROUND_DEPTH = 8

-- Dibuat lebih lambat seperti gerakan di video.
local DOWN_TIME = 1.25
local TRAVEL_TIME = 7
local UP_TIME = 1.25

-- Ukuran block/pijakan.
local PLATFORM_SIZE = Vector3.new(6, 0.5, 6)

-- Jarak root karakter dari permukaan atas platform.
local ROOT_HEIGHT = 3.0

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
	platform.CFrame = CFrame.new(
		root.Position.X,
		root.Position.Y - ROOT_HEIGHT,
		root.Position.Z
	)
	platform.Parent = workspace

	return platform
end

--==================================================
-- MOVE PLATFORM + KEEP CHARACTER STANDING
--==================================================

local function movePlatform(platform, root, humanoid, targetPosition, duration)
	local rotation = root.CFrame - root.CFrame.Position

	-- Posisi root selalu tepat di atas platform.
	local function updateCharacter()
		if platform.Parent and root.Parent then
			root.CFrame = CFrame.new(
				platform.Position.X,
				platform.Position.Y + ROOT_HEIGHT,
				platform.Position.Z
			) * rotation
		end
	end

	updateCharacter()

	local connection = RunService.Heartbeat:Connect(updateCharacter)

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

	updateCharacter()

	connection:Disconnect()
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

	-- Block dibuat tepat di bawah kaki.
	local platform = createPlatform(root)

	-- Posisi awal platform.
	local start = platform.Position

	-- Turun sedikit saja.
	local undergroundStart = Vector3.new(
		start.X,
		start.Y - UNDERGROUND_DEPTH,
		start.Z
	)

	-- Bergerak di bawah tanah menuju Lamont Bell.
	local undergroundTarget = Vector3.new(
		TARGET.X,
		undergroundStart.Y,
		TARGET.Z
	)

	-- Posisi akhir platform tepat di bawah kaki
	-- ketika sudah sampai Lamont Bell.
	local finalPosition = Vector3.new(
		TARGET.X,
		TARGET.Y - ROOT_HEIGHT,
		TARGET.Z
	)

	-- 1. TURUN PERLAHAN
	movePlatform(
		platform,
		root,
		humanoid,
		undergroundStart,
		DOWN_TIME
	)

	-- 2. BERGERAK PERLAHAN DI BAWAH TANAH
	movePlatform(
		platform,
		root,
		humanoid,
		undergroundTarget,
		TRAVEL_TIME
	)

	-- 3. NAIK PERLAHAN DI TUJUAN
	movePlatform(
		platform,
		root,
		humanoid,
		finalPosition,
		UP_TIME
	)

	-- Pastikan karakter tepat berdiri di atas platform.
	root.CFrame =
		CFrame.new(finalPosition.X, finalPosition.Y + ROOT_HEIGHT, finalPosition.Z)
		* (root.CFrame - root.CFrame.Position)

	task.wait(0.25)

	-- Kembalikan kontrol karakter.
	humanoid.PlatformStand = oldPlatformStand
	humanoid.AutoRotate = oldAutoRotate

	-- Hapus block setelah karakter sudah sampai.
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
