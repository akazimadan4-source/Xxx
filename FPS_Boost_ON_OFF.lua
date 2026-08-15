-- FPS BOOST ON/OFF
-- LocalScript -> StarterPlayer > StarterPlayerScripts

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local enabled = false
local saved = {}
local connection

local gui = Instance.new("ScreenGui")
gui.Name = "FPSBoostUI"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local button = Instance.new("TextButton")
button.Size = UDim2.fromOffset(170, 48)
button.Position = UDim2.new(1, -185, 0, 80)
button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
button.BorderSizePixel = 0
button.Text = "FPS BOOST: OFF"
button.TextColor3 = Color3.new(1, 1, 1)
button.TextSize = 16
button.Font = Enum.Font.GothamBold
button.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = button

local function save(obj, property)
	saved[obj] = saved[obj] or {}
	if saved[obj][property] == nil then
		local ok, value = pcall(function()
			return obj[property]
		end)
		if ok then saved[obj][property] = value end
	end
end

local function optimize(obj)
	if obj:IsA("Texture") or obj:IsA("Decal") then
		save(obj, "Transparency")
		obj.Transparency = 1

	elseif obj:IsA("SurfaceAppearance") then
		save(obj, "Parent")
		obj.Parent = nil

	elseif obj:IsA("MeshPart") then
		save(obj, "TextureID")
		save(obj, "Material")
		save(obj, "Reflectance")
		pcall(function() obj.TextureID = "" end)
		pcall(function() obj.Material = Enum.Material.SmoothPlastic end)
		pcall(function() obj.Reflectance = 0 end)

	elseif obj:IsA("SpecialMesh") then
		save(obj, "TextureId")
		pcall(function() obj.TextureId = "" end)

	elseif obj:IsA("BasePart") then
		save(obj, "Material")
		save(obj, "Reflectance")
		pcall(function() obj.Material = Enum.Material.SmoothPlastic end)
		pcall(function() obj.Reflectance = 0 end)

	elseif obj:IsA("ParticleEmitter")
		or obj:IsA("Trail")
		or obj:IsA("Beam")
		or obj:IsA("Smoke")
		or obj:IsA("Fire") then
		save(obj, "Enabled")
		pcall(function() obj.Enabled = false end)
	end
end

local function enableBoost()
	if enabled then return end
	enabled = true

	button.Text = "FPS BOOST: ON"
	button.BackgroundColor3 = Color3.fromRGB(35, 150, 70)

	for _, obj in ipairs(workspace:GetDescendants()) do
		optimize(obj)
	end

	connection = workspace.DescendantAdded:Connect(function(obj)
		if enabled then
			task.defer(function()
				if enabled then optimize(obj) end
			end)
		end
	end)
end

local function disableBoost()
	if not enabled then return end
	enabled = false

	button.Text = "FPS BOOST: OFF"
	button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)

	if connection then
		connection:Disconnect()
		connection = nil
	end

	for obj, properties in pairs(saved) do
		if obj then
			for property, value in pairs(properties) do
				pcall(function()
					obj[property] = value
				end)
			end
		end
	end

	table.clear(saved)
end

button.MouseButton1Click:Connect(function()
	if enabled then
		disableBoost()
	else
		enableBoost()
	end
end)
