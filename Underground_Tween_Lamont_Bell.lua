local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer

local TargetPosition = Vector3.new(
	510.8173828125,
	4.581132888793945,
	601.048095703125
)

local UndergroundDepth = 30
local DownTime = 0.5
local TravelTime = 3
local UpTime = 0.5
local Teleporting = false

local function GetCharacter()
	local Character = Player.Character or Player.CharacterAdded:Wait()
	local Humanoid = Character:WaitForChild("Humanoid")
	local Root = Character:WaitForChild("HumanoidRootPart")
	return Character, Humanoid, Root
end

local function TweenRoot(Root, TargetCFrame, Duration)
	local Tween = TweenService:Create(
		Root,
		TweenInfo.new(Duration, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut),
		{CFrame = TargetCFrame}
	)
	Tween:Play()
	Tween.Completed:Wait()
end

local function UndergroundTeleport()
	if Teleporting then return end
	Teleporting = true

	local Character, Humanoid, Root = GetCharacter()

	if not Character or not Root or Humanoid.Health <= 0 then
		Teleporting = false
		return
	end

	local LookVector = Root.CFrame.LookVector
	local StartPosition = Root.Position

	local UndergroundStart = Vector3.new(
		StartPosition.X,
		StartPosition.Y - UndergroundDepth,
		StartPosition.Z
	)

	local UndergroundTarget = Vector3.new(
		TargetPosition.X,
		TargetPosition.Y - UndergroundDepth,
		TargetPosition.Z
	)

	local OldAutoRotate = Humanoid.AutoRotate
	Humanoid.AutoRotate = false

	TweenRoot(
		Root,
		CFrame.lookAt(UndergroundStart, UndergroundStart + LookVector),
		DownTime
	)

	TweenRoot(
		Root,
		CFrame.lookAt(UndergroundTarget, UndergroundTarget + LookVector),
		TravelTime
	)

	TweenRoot(
		Root,
		CFrame.lookAt(TargetPosition, TargetPosition + LookVector),
		UpTime
	)

	Humanoid.AutoRotate = OldAutoRotate
	Teleporting = false
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UndergroundTeleportUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = Player:WaitForChild("PlayerGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 230, 0, 115)
Main.Position = UDim2.new(0.5, -115, 0.75, 0)
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

Button.MouseButton1Click:Connect(function()
	if Teleporting then return end

	Button.Text = "TELEPORTING..."
	Status.Text = "Moving underground..."

	task.spawn(function()
		UndergroundTeleport()

		if not Teleporting then
			Button.Text = "UNDERGROUND TP"
			Status.Text = "Arrived at Lamont Bell"

			task.wait(2)
			Status.Text = "Ready"
		end
	end)
end)
