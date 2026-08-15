--==================================================
-- UNDERGROUND TWEEN + MOVING PLATFORM
-- Target: Lamont Bell
-- LocalScript: StarterPlayer > StarterPlayerScripts
--==================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

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
	platform.Transparency = 0
	platform.Material = Enum.Material.SmoothPlastic
	platform.Parent = workspace

	-- Sedikit di bawah kaki
	platform.CFrame = CFrame.new(
		root.Position.X,
		root.Position.Y - 3.1,
		root.Position.Z
	)

	return platform
end

--==================================================
-- MOVE PLATFORM + CHARACTER
--==================================================

local function movePlatform(platform, root, targetPosition, duration)
	local startPlatformY = platform.Position.Y
	local offset = root.Position - platform.Position

	local startPosition = platform.Position

	local tween = TweenService:Create(
		platform,
		TweenInfo.new(
			duration,
			Enum.EasingStyle.Linear,
			Enum.EasingDirection.InOut
		),
		{
			Position = targetPosition
		}
	)

	tween:Play()

	-- Menjaga karakter tetap berada di atas platform
	local connection
	connection = game:GetService("RunService").Heartbeat:Connect(function()
		if platform.Parent and root.Parent then
			root.CFrame = CFrame.new(
				platform.Position + offset
			) * (root.CFrame - root.CFrame.Position)
		end
	end)

	tween.Completed:Wait()

	if connection then
		connection:Disconnect()
	end

	-- Pastikan posisi akhir tepat
	root.CFrame = CFrame.new(
		platform.Position + offset
	) * (root.CFrame - root.CFrame.Position)
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

	-- Buat platform tepat di bawah karakter
	local platform = createPlatform(root)

	local offset = root.Position - platform.Position

	-- Posisi platform ketika sudah di bawah tanah
	local undergroundStart = Vector3.new(
		platform.Position.X,
		platform.Position.Y - UNDERGROUND_DEPTH,
		platform.Position.Z
	)

	-- Posisi platform di bawah Lamont Bell
	local undergroundTarget = Vector3.new(
		TARGET.X,
		platform.Position.Y - UNDERGROUND_DEPTH,
		TARGET.Z
	)

	--==================================================
	-- 1. TURUN BERSAMA PLATFORM
	--==================================================

	movePlatform(
		platform,
		root,
		undergroundStart,
		DOWN_TIME
	)

	--==================================================
	-- 2. BERGERAK DI BAWAH TANAH
	--==================================================

	movePlatform(
		platform,
		root,
		undergroundTarget,
		TRAVEL_TIME
	)

	--==================================================
	-- 3. NAIK DI DEPAN LAMONT BELL
	--==================================================

	local finalPlatformPosition = Vector3.new(
		TARGET.X,
		TARGET.Y - 3.1,
		TARGET.Z
	)

	movePlatform(
		platform,
		root,
		finalPlatformPosition,
		UP_TIME
	)

	-- Kembalikan physics
	humanoid.PlatformStand = oldPlatformStand
	humanoid.AutoRotate = oldAutoRotate

	-- Hapus platform setelah sampai
	task.wait(0.15)

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
	Status.Text = "Platform going underground"

	task.spawn(function()

		local success, err = pcall(function()
			undergroundTeleport()
		end)

		if not success then
			warn("Underground Teleport Error:", err)
			busy = false
		end

		Button.Text = "UNDERGROUND TP"

		if success then
			Status.Text = "Arrived at Lamont Bell"
		else
			Status.Text = "Error"
		end

		task.wait(2)

		if not busy then
			Status.Text = "Ready"
		end
	end)
end)
