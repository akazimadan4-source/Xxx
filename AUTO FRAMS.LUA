--[[
    Script untuk Delta Executor di HP
    Bagian 1/7 - Inisialisasi & Fallback Functions
]]

-- ============ FALLBACK FUNCTIONS ============
local function safeCloneref(obj)
    if type(obj) == "table" then return obj end
    return obj
end

local hasBuffer = pcall(function() return buffer.create(1) end)
local hasSethidden = pcall(function() return sethiddenproperty end)

-- ============ INITIALIZATION ============
repeat task.wait() until game:IsLoaded()
repeat task.wait() until (os.time() - game.Players.LocalPlayer:GetAttribute("JoinTime") or 0) >= 30

if not game:GetService("Players").LocalPlayer.Character then 
    game:GetService("Players").LocalPlayer.CharacterAdded:Wait()
end

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")
local Stats = game:GetService("Stats")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = Workspace.CurrentCamera

-- ============ CONFIG ============
local Config = {
    ["Functions"] = {};
    ["IsOwned_Bike"] = "...";
    ["AutoFarm"] = {
        ["Running"] = false;
        ["MovementType"] = "...";
        ["Marshmallow"] = {
            ["Enabled"] = false;
            ["BatchAmount"] = 1;
            ["Status"] = {
                ["Earned"] = 0;
                ["Total_Sold"] = 0;
                ["Sold_Type"] = {
                    ["Small Marshmallow Bag"] = 0;
                    ["Medium Marshmallow Bag"] = 0;
                    ["Large Marshmallow Bag"] = 0;
                };
            };
        };
        ["Chips"] = {
            ["Enabled"] = false;
            ["Status"] = {
                ["Earned"] = 0;
                ["Delivered"] = 0;
            };
        };
        ["Card"] = {
            ["Enabled"] = false;
            ["Status"] = {
                ["Earned"] = 0;
                ["Swipes"] = 0;
            };
        };
    };
    ["Locations"] = {
        ["Enabled"] = false;
        ["MovementType"] = "...";
        ["Locations"] = {}
    }
}

local IS_AFK = false

-- ============ ANTI-AFK ============
do
    local function handleIdle()
        if not IS_AFK then
            IS_AFK = true
            pcall(function()
                VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
                task.wait(0.5)
                VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
            end)
        end
    end
    
    LocalPlayer.Idled:Connect(handleIdle)
    
    UserInputService.InputBegan:Connect(function()
        if IS_AFK then IS_AFK = false end
    end)
end

-- ============ HELPER FUNCTIONS ============
local function pressE()
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        task.wait(0.1)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
    end)
end

local function fireProximityPrompt(pp)
    if not pp then return false end
    local success, isPrompt = pcall(function() return pp:IsA("ProximityPrompt") end)
    if not success or not isPrompt then return false end
    if not pp.Parent then return false end
    
    pcall(function()
        pp.MaxActivationDistance = 50
        pp.Enabled = true
        pp.HoldDuration = 0
        pp.RequiresLineOfSight = false
        if pp.Parent and pp.Parent:IsA("BasePart") then
            workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, pp.Parent.Position)
        end
        pp:InputHoldBegin()
        task.wait(0.05)
        pp:InputHoldEnd()
    end)
    return true
end

local function safeEquip(toolName)
    local c = LocalPlayer.Character
    local hum = c and c:FindFirstChildOfClass("Humanoid")
    if not hum then return false end
    local tool = LocalPlayer.Backpack:FindFirstChild(toolName) or c:FindFirstChild(toolName)
    if not tool then return false end
    pcall(function() hum:EquipTool(tool) end)
    task.wait(0.3)
    return true
end

local function getItemCount(name)
    local n = 0
    for _, v in ipairs(LocalPlayer.Backpack:GetChildren()) do 
        if v.Name == name then n = n + 1 end 
    end
    if LocalPlayer.Character then
        for _, v in ipairs(LocalPlayer.Character:GetChildren()) do 
            if v.Name == name then n = n + 1 end 
        end
    end
    return n
end

-- ============ BIKE FUNCTIONS ============
getgenv().Find_Bike = function()
    for _, Value in Workspace:GetChildren() do
        if Value:FindFirstChild("Owner") and string.match(tostring(Value), LocalPlayer.Name .. "'s Car") and Value:FindFirstChild("Body") and Value:FindFirstChild("Body"):FindFirstChild("Passenger") then
            return Value
        end
    end
    return nil
end

local RoadSidewalkFolder = Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("Roads/Sidewalks")
local NoclipParts = {}

-- ============ NO CLIP ============
local function SetNoCollide(part, value)
    if hasSethidden then
        pcall(function() sethiddenproperty(part, "CanCollide", value) end)
    else
        pcall(function() part.CanCollide = value end)
    end
end

local ExclusionsSideWalk_Folder = function(Part)
    return (RoadSidewalkFolder and Part:IsDescendantOf(RoadSidewalkFolder))
        or (Part.Name == "default")
        or (Part.Name == "Sidewalk")
        or (Part.Name == "Floor")
        or (Part.Name == "Collision")
        or (Part.Name == "QuaterCylinder")
        or Part:IsDescendantOf(LocalPlayer.Character)
        or (Part.Parent and Part.Parent:IsA("Model") and Players:GetPlayerFromCharacter(Part.Parent) ~= nil)
        or (Part:IsA("VehicleSeat") or Part:IsA("Vehicle"))
        or (Part.Name == "AntiFall_Platform1")
        or (Part.Name == "AntiFall_Platform2")
end

local Reset_Noclip = function()
    for part, props in pairs(NoclipParts) do
        if part:IsA("BasePart") then
            SetNoCollide(part, props.CanCollide)
        end
    end
    NoclipParts = {}
end

local Noclip = function()
    local Character = LocalPlayer.Character
    if not Character then return end
    local Root = Character:FindFirstChild("HumanoidRootPart")
    if not Root then return end
    local Pos = Root.Position
    local radius = 15
    local region = Region3.new(Pos - Vector3.new(radius, radius, radius), Pos + Vector3.new(radius, radius, radius))
    local parts = Workspace:FindPartsInRegion3(region, nil, math.huge)
    for _, part in ipairs(parts) do
        if part:IsA("BasePart") and not ExclusionsSideWalk_Folder(part) and not Workspace:FindFirstChild("Do not touch") then
            if not NoclipParts[part] then
                NoclipParts[part] = { CanCollide = part.CanCollide }
                SetNoCollide(part, false)
            end
        end
    end
end

-- ============ LOOK DOWN ============
local LookDownConnection
LookDown = function(Zoom, Front)
    if LookDownConnection then return end
    LookDownConnection = RunService.RenderStepped:Connect(function()
        local Character = LocalPlayer.Character
        if not Character then return end
        local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
        if not HumanoidRootPart then return end
        local characterPos = HumanoidRootPart.Position
        local lookDirection = HumanoidRootPart.CFrame.LookVector
        local flatLook = Vector3.new(lookDirection.X, 0, lookDirection.Z).Unit
        local targetCFrame = CFrame.lookAt(characterPos, characterPos + flatLook)
        if Front then
            targetCFrame = targetCFrame * CFrame.Angles(0, 0, 0)
        else
            targetCFrame = targetCFrame * CFrame.Angles(math.rad(-80), 0, 0)
        end
        local cameraPosition = characterPos - (targetCFrame.LookVector * Zoom)
        Camera.CFrame = CFrame.lookAt(cameraPosition, characterPos)
    end)
end

-- ============ SPAWN BIKE ============
SpawnBike = function()
    local Bike = Find_Bike()
    local b = {1}
    
    if Bike == nil then
        ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("RPC"):FireServer(b, "Spawn", "DirtBike")
        local BikeForce = false
        task.spawn(function() task.wait(3); BikeForce = true end)
        repeat task.wait() until Find_Bike() ~= nil or BikeForce == true
        Bike = Find_Bike()
        task.wait()
        if Bike == nil then 
            Library:Notification("Bike Teleport", "Your bike was not found!", 3) 
            return "Failed" 
        end
    end

    if Bike and Bike.DriveSeat and Bike.DriveSeat.Occupant ~= nil and Bike.DriveSeat.Occupant ~= LocalPlayer.Character.Humanoid then
        ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("RPC"):FireServer(b, "Spawn", "DirtBike")
        local BikeForce = false
        task.spawn(function() task.wait(3); BikeForce = true end)
        repeat task.wait() until Find_Bike() ~= nil or BikeForce == true
        Bike = Find_Bike()
        task.wait()
        if Bike == nil then 
            Library:Notification("Bike Teleport", "Your bike was not found!", 3) 
            return "Failed" 
        end
    end

    pcall(function()
        Bike.DriveSeat.Attachment.ProximityPrompt.HoldDuration = 0
        Bike.DriveSeat.Attachment.ProximityPrompt.RequiresLineOfSight = false
    end)
    
    LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(0, 9e9, 0)
    task.wait(1)
    LocalPlayer.Character.HumanoidRootPart.CFrame = Bike.PrimaryPart.CFrame
    Library:Notification("Bike Teleport", "Bike Spawned!", 3)
    task.wait(0.5)
    Library:Notification("Bike Teleport", "Sit on it to use Bike mode!", 5)
end

-- ============ SAFE MODE ============
local SafeModeRunning = false
local _SM_HeartbeatConnection = nil
local _SM_MeshPart = nil
local _SM_MeshPart2 = nil
local _SM_Root = nil

local function SafeModeCleanup()
    SafeModeRunning = false
    if _SM_HeartbeatConnection then
        _SM_HeartbeatConnection:Disconnect()
        _SM_HeartbeatConnection = nil
    end
    if _SM_Root then _SM_Root.Anchored = false end
    if _SM_MeshPart and _SM_MeshPart.Parent then _SM_MeshPart:Destroy() end
    if _SM_MeshPart2 and _SM_MeshPart2.Parent then _SM_MeshPart2:Destroy() end
    Reset_Noclip()
end

local chipFarmActive = false
local MarshmallowFarm_Thread

local function anyFarmRunning()
    return getgenv().CardFarm == true or chipFarmActive == true or MarshmallowFarm_Thread ~= nil
end
-- ============ TELEPORT ============
Teleport = function(Destination)
    local MovementType = Config["AutoFarm"]["MovementType"]

    if MovementType == "Safe Mode" then
        if LocalPlayer.Character.Humanoid.SeatPart and LocalPlayer.Character.Humanoid.SeatPart.Name == "DriveSeat" then
            Library:Notification("Safe Teleport", "Bike seat detected! (Unmount/Unsit)", 3)
            return
        end

        local Root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not Root then return "Failed" end

        _SM_Root = Root
        _SM_MeshPart = Instance.new("Part")
        _SM_MeshPart.Name = "AntiFall_Platform1"
        _SM_MeshPart.Size = Vector3.new(2048, 2, 2048)
        _SM_MeshPart.CFrame = CFrame.new(0, -6.5, 0)
        _SM_MeshPart.Transparency = 0.3
        _SM_MeshPart.Anchored = true
        _SM_MeshPart.CanCollide = true
        _SM_MeshPart.Parent = Workspace

        _SM_MeshPart2 = Instance.new("Part")
        _SM_MeshPart2.Name = "AntiFall_Platform2"
        _SM_MeshPart2.Size = Vector3.new(2048, 2, 2048)
        _SM_MeshPart2.CFrame = CFrame.new(935, -6.5, 65)
        _SM_MeshPart2.Transparency = 0.3
        _SM_MeshPart2.Anchored = true
        _SM_MeshPart2.CanCollide = true
        _SM_MeshPart2.Parent = Workspace

        _SM_HeartbeatConnection = RunService.Stepped:Connect(function()
            if Root and Root.Parent then Noclip() end
        end)

        SafeModeRunning = true

        local UndergroundPos = Vector3.new(Root.Position.X, -1, Root.Position.Z)
        local Tween_Root = TweenService:Create(Root,
            TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
            { CFrame = CFrame.new(UndergroundPos) * CFrame.Angles(0, math.atan2(Root.CFrame.LookVector.X, Root.CFrame.LookVector.Z), 0) }
        )
        Tween_Root:Play()
        Tween_Root.Completed:Wait()
        task.wait(0.2)

        local GoalPos = Vector3.new(Destination.X, -2.1378674507141113, Destination.Z)
        LookDown(15, false)

        while anyFarmRunning() and Root and Root.Parent and (Vector3.new(Root.Position.X, 0, Root.Position.Z) - Vector3.new(GoalPos.X, 0, GoalPos.Z)).Magnitude > (1.7 + math.random() * 0.1) do
            local Direction = (GoalPos - Root.Position).Unit
            local LookTarget = Vector3.new(GoalPos.X, -2.1378674507141113, GoalPos.Z)
            local NextPosition = Root.Position + Direction
            Noclip()
            Root.CFrame = CFrame.new(
                Vector3.new(NextPosition.X, -2.1378674507141113, NextPosition.Z),
                LookTarget
            )
            task.wait(0.05)
        end

        if LookDownConnection then
            LookDownConnection:Disconnect()
            LookDownConnection = nil
        end

        if not anyFarmRunning() then
            SafeModeCleanup()
            if Root and Root.Parent then
                local surfacePos = Vector3.new(Root.Position.X, 3, Root.Position.Z)
                local Tween_Up = TweenService:Create(Root,
                    TweenInfo.new(1, Enum.EasingStyle.Linear),
                    { CFrame = CFrame.new(surfacePos) * CFrame.Angles(0, math.atan2(Root.CFrame.LookVector.X, Root.CFrame.LookVector.Z), 0) }
                )
                Tween_Up:Play()
                Tween_Up.Completed:Wait()
            end
            return "Stopped"
        end

        Root.CFrame = Destination
        task.wait(0.1)
        SafeModeCleanup()
        return "Success"

    elseif MovementType == "Bike" then
        local Bike = Find_Bike()
        if Bike == nil then
            Library:Notification("Bike Teleport", "Your bike was not found!", 3)
            return "Failed"
        end
        if LocalPlayer.Character.Humanoid.SeatPart and LocalPlayer.Character.Humanoid.SeatPart.Name == "DriveSeat" then
            for _ = 1, 50 do
                Bike:SetPrimaryPartCFrame(Destination + Vector3.new(0, 1.5, 0))
            end
            task.wait(1)
            for _ = 1, 10 do
                Bike:SetPrimaryPartCFrame(Destination + Vector3.new(0, 1.5, 0))
            end
            for _, Value in Bike:GetDescendants() do
                pcall(function() Value.Velocity = CFrame.new(0, 0, 0) end)
                pcall(function() Value.RotVelocity = CFrame.new(0, 0, 0) end)
            end
            Library:Notification("Bike Teleport", "Success!", 3)
        else
            Library:Notification("Bike Teleport", "Your bike was not seated, Please sit on your bike.", 3)
        end
        return "Success"

    elseif MovementType == "" or MovementType == nil then
        Library:Notification("Teleport", "No Teleport Method Selected.", 3)
    end
end

-- ============ APARTMENT FUNCTIONS ============
local Apartments_Lists = {"BH1", "BH2", "BH3", "BH4", "Home 1", "Home 2", "Home 3", "Home 4", "LT1", "WH1"}

BuyApartment = function()
    task.spawn(function()
        local Owns_Apartment = function(Apartment)
            local Board = Apartment:FindFirstChild("Board")
            local Label = Board and Board:FindFirstChild("name") and Board.name:FindFirstChild("SurfaceGui") and Board.name.SurfaceGui:FindFirstChild("TextLabel")
            return Label and Label.Text == LocalPlayer.Name
        end

        local Is_Vacant = function(Apartment)
            local Board = Apartment:FindFirstChild("Board")
            local Label = Board and Board:FindFirstChild("name") and Board.name:FindFirstChild("SurfaceGui") and Board.name.SurfaceGui:FindFirstChild("TextLabel")
            return Label and Label.Text == "VACANT"
        end

        local Apartments = Workspace.Map:FindFirstChild("APTS")
        local Houses = Workspace.Map:FindFirstChild("Houses")
        if not Apartments or not Houses then return false end

        local SelectedApartment = nil
        for _, ApartmentName in ipairs(Apartments_Lists) do
            local APT = Apartments:FindFirstChild(ApartmentName)
            if APT and APT:IsA("Model") then
                if Owns_Apartment(APT) then
                    SelectedApartment = APT
                    break
                elseif not SelectedApartment and Is_Vacant(APT) then
                    SelectedApartment = APT
                end
            end
        end

        if Owns_Apartment(SelectedApartment) then
            Library:Notification("AutoFarm", "Apartment " .. SelectedApartment.Name .. " is already bought!", 3)
            return
        end

        if not SelectedApartment then return false end

        local Board = SelectedApartment:FindFirstChild("Board")
        if Board then
            Library:Notification("AutoFarm", "Teleporting to apartment...", 3)
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(0, 9e9, 0)
            task.wait(1)
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(Board:GetPivot().Position)
        end

        if Is_Vacant(SelectedApartment) then
            local prompt = Board and Board:FindFirstChild("backboard") and Board.backboard:FindFirstChild("ProximityPrompt")
            if prompt then
                pcall(function()
                    prompt.HoldDuration = 0
                    prompt.RequiresLineOfSight = false
                end)
                task.wait(0.5)
                fireProximityPrompt(prompt)
            else
                return false
            end
        end
    end)
end

GetUnclaimedApartment = function()
    local Apartment = nil
    for _, Value in Workspace.Map.APTS:GetChildren() do
        if Value:FindFirstChild("name", true) and Value:FindFirstChild("name", true):FindFirstChild("TextLabel", true) then
            local Cache = nil
            if Workspace.Map.Locations.Apartments:FindFirstChild(Value.Name) or Workspace.Map.Houses:FindFirstChild(Value.Name) then
                Cache = Workspace.Map.Locations.Apartments:FindFirstChild(Value.Name) or Workspace.Map.Houses:FindFirstChild(Value.Name)
            end
            if not Cache then goto continue end
            local Interior = Cache:FindFirstChild("Interior") or Cache
            if Cache and Interior:FindFirstChild("Cooking Pot", true) and Value:FindFirstChild("name", true):FindFirstChild("TextLabel", true).Text == "VACANT" then
                Apartment = Value
                break
            end
        end
        ::continue::
    end
    return Apartment
end

GetPersonalApartment = function()
    local Apartment = nil
    for _, Value in Workspace.Map.APTS:GetChildren() do
        if Value:FindFirstChild("name", true) and Value:FindFirstChild("name", true):FindFirstChild("TextLabel", true) then
            if Value:FindFirstChild("name", true):FindFirstChild("TextLabel", true).Text == LocalPlayer.Name then
                Apartment = Value
                break
            end
        end
    end
    return Apartment
end

local Get_House = function()
    for _, Value in Workspace.Map.APTS:GetChildren() do
        if Value:FindFirstChild("Board") then
            local Name = Value:FindFirstChild("Board").name.SurfaceGui.TextLabel.Text
            if Name == LocalPlayer.Name then
                return Workspace.Map.Houses:FindFirstChild(Value.Name) or Workspace.Map.Locations.Apartments:FindFirstChild(Value.Name)
            end
        end
    end
    return nil
end
-- ============ MARSHMALLOW FARM ============
local MarshMallowStep = "Water"

local MarshmallowSellPrice = {
    ["Small Marshmallow Bag"] = 1470;
    ["Medium Marshmallow Bag"] = 2840;
    ["Large Marshmallow Bag"] = 4050;
}

local MarshmallowItems = {
    "Small Marshmallow Bag";
    "Medium Marshmallow Bag";
    "Large Marshmallow Bag";
}

local GetNumberOfItemsInBackpack = function(Name)
    local Amount = 0
    for _, Value in ipairs(LocalPlayer.Backpack:GetChildren()) do
        if Value.Name == Name then Amount = Amount + 1 end
    end
    if LocalPlayer.Character then
        for _, Value in ipairs(LocalPlayer.Character:GetChildren()) do
            if Value:IsA("Tool") and Value.Name == Name then Amount = Amount + 1 end
        end
    end
    return Amount
end

local GetMarshmallowItem = function(name)
    for _, itemName in ipairs(MarshmallowItems) do
        if name == itemName then return itemName end
    end
    return nil
end

local Task_Text
task.spawn(function()
    while task.wait(0.1) do
        local Main = LocalPlayer.PlayerGui:FindFirstChild("Main")
        if Main then
            local TaskUpdate = Main:FindFirstChild("TaskUpdate")
            if TaskUpdate and TaskUpdate:FindFirstChild("TextLabel") then
                Task_Text = TaskUpdate:FindFirstChild("TextLabel").Text
            end
        end
    end
end)
Start_MarshmallowFarm = function()
    MarshmallowFarm_Thread = task.spawn(function()
        while task.wait(1) do
            if not Config["AutoFarm"]["Marshmallow"]["Enabled"] then goto continue end

            local Marshmellow_Increment = Config["AutoFarm"]["Marshmallow"]["BatchAmount"]
            local Items = {"Gelatin", "Sugar Block Bag", "Water"}
            local Items_Price = {
                ["Gelatin"] = 70;
                ["Sugar Block Bag"] = 100;
                ["Water"] = 20;
            }

            Teleport(CFrame.new(510, 4, 602))

            for _, Value in ipairs(Items) do
                local CurrentAmount = GetNumberOfItemsInBackpack(Value)
                local CraftedAmount = 0
                for _, marshItem in ipairs(MarshmallowItems) do
                    CraftedAmount = CraftedAmount + GetNumberOfItemsInBackpack(marshItem)
                end

                local NeededAmount = math.max(Marshmellow_Increment - CraftedAmount, 0)
                local MissingAmount = math.max(NeededAmount - CurrentAmount, 0)
                if MissingAmount > 0 then
                    for _ = 1, MissingAmount do
                        local Added = false
                        local Child_Added
                        Child_Added = LocalPlayer.Backpack.ChildAdded:Connect(function(Child)
                            if Child.Name == Value then
                                Config["AutoFarm"]["Marshmallow"]["Status"]["Earned"] = Config["AutoFarm"]["Marshmallow"]["Status"]["Earned"] - Items_Price[Value]
                                Added = true
                                if Child_Added then Child_Added:Disconnect() end
                            end
                        end)
                        local StartTime = os.clock()
                        repeat
                            task.wait(0.1)
                            ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("StorePurchase"):FireServer(Value)
                        until Added == true or (os.clock() - StartTime) > 1
                        if not Added and Child_Added then Child_Added:Disconnect() end
                    end
                end
            end

            task.wait(2.5)

            local House = Get_House()
            if not House then
                local HouseToBuy = GetUnclaimedApartment()
                if not HouseToBuy then
                    repeat
                        task.wait(1)
                        Library:Notification("Apartment", "No House owned! Buying one...", 5)
                        HouseToBuy = GetUnclaimedApartment()
                    until HouseToBuy
                end
                Teleport(HouseToBuy.Board.backboard.CFrame)
                LookDown(10, true)
                task.wait(1)
                fireProximityPrompt(HouseToBuy.Board:FindFirstChildWhichIsA("ProximityPrompt", true))
                if LookDownConnection then LookDownConnection:Disconnect(); LookDownConnection = nil end
                task.wait(1)
                House = Get_House()
            end

            local Personal_Apartment = GetPersonalApartment()

            if Personal_Apartment.Door.Interact.Rotation ~= Vector3.new(0, 90, 0) and Personal_Apartment.Door.Interact.Rotation ~= Vector3.new(0, -90, 0) and Personal_Apartment.Door.Interact.Rotation ~= Vector3.new(180, 0, 180) then
                pcall(function()
                    Personal_Apartment.Door.Interact.Attachment.ProximityPrompt.HoldDuration = 0
                    Personal_Apartment.Door.Interact.Attachment.ProximityPrompt.RequiresLineOfSight = false
                end)
                local Tween = TweenService:Create(LocalPlayer.Character.HumanoidRootPart,
                    TweenInfo.new(2, Enum.EasingStyle.Linear),
                    { CFrame = Personal_Apartment.Door.Interact.CFrame }
                )
                Tween:Play()
                Tween.Completed:Wait()
                Tween = nil
                task.wait(0.5)
                fireProximityPrompt(Personal_Apartment.Door.Interact.Attachment.ProximityPrompt)
                task.wait(1)
            end

            if Personal_Apartment.Door.DoorLock.Part.Rotation ~= Vector3.new(90, 0, 0) then
                pcall(function()
                    Personal_Apartment.Door.DoorLock.Part.ProximityPrompt.HoldDuration = 0
                    Personal_Apartment.Door.DoorLock.Part.ProximityPrompt.RequiresLineOfSight = false
                end)
                local Tween = TweenService:Create(LocalPlayer.Character.HumanoidRootPart,
                    TweenInfo.new(2, Enum.EasingStyle.Linear),
                    { CFrame = Personal_Apartment.Door.Interact.CFrame }
                )
                Tween:Play()
                Tween.Completed:Wait()
                Tween = nil
                task.wait(0.5)
                fireProximityPrompt(Personal_Apartment.Door.DoorLock.Part.ProximityPrompt)
                task.wait(0.5)
            end

            local Interior = House:FindFirstChild("Interior") or House
            for _, Value in Interior:GetChildren() do
                if Value.Name == "Floor" or Value.Name == "Cooking Pot" or Value.Name == "Stove" then
                    Value.CanCollide = false
                end
            end

            local Pot = Interior["Cooking Pot"]
            Teleport(Pot.CFrame)
local tween_and_prompt = function(Prompt)
    if House.Parent.Name == "Apartments" then
        pcall(function()
            Prompt.HoldDuration = 0
            Prompt.MaxActivationDistance = 50
            Prompt.RequiresLineOfSight = false
        end)
        local Tween = TweenService:Create(LocalPlayer.Character.HumanoidRootPart,
            TweenInfo.new(1, Enum.EasingStyle.Linear),
            { CFrame = Pot.CFrame + Vector3.new(0, 7, 0) }
        )
        Tween:Play()
        Tween.Completed:Wait()
        Tween = nil
        LookDown(10, true)
        task.wait(0.5)
        fireProximityPrompt(Prompt)
        if LookDownConnection then LookDownConnection:Disconnect(); LookDownConnection = nil end
        task.wait(2.5)
        Tween = TweenService:Create(LocalPlayer.Character.HumanoidRootPart,
            TweenInfo.new(1, Enum.EasingStyle.Linear),
            { CFrame = Pot.CFrame + Vector3.new(0, 16, 0) }
        )
        Tween:Play()
        Tween.Completed:Wait()
        Tween = nil
    else
        pcall(function()
            Prompt.HoldDuration = 0
            Prompt.MaxActivationDistance = 50
            Prompt.RequiresLineOfSight = false
        end)
        LookDown(8, false)
        fireProximityPrompt(Prompt)
        if LookDownConnection then LookDownConnection:Disconnect(); LookDownConnection = nil end
    end
end

local BIKE_WAIT_POS = CFrame.new(-750, 4, 393)

local function bikeWaitAndReturn(waitType)
    if Config["AutoFarm"]["MovementType"] ~= "Bike" then return end

    Teleport(BIKE_WAIT_POS)

    if waitType == "Water" then
        repeat task.wait() until Pot.Timer.TextLabel.Text == "0"
    elseif waitType == "Sugar" then
        repeat task.wait() until Task_Text == "Pour gelatin into the pot."
    elseif waitType == "Gelatin" then
        repeat task.wait() until Pot.Timer.TextLabel.Text == "0"
    end

    Teleport(Pot.CFrame)
    task.wait(0.5)
end

if not (House.Parent.Name == "Apartments") then
    local Tween = TweenService:Create(LocalPlayer.Character.HumanoidRootPart,
        TweenInfo.new(1, Enum.EasingStyle.Linear),
        { CFrame = Pot.CFrame - Vector3.new(0, 7, 0) }
    )
    Tween:Play()
    Tween.Completed:Wait()
    Tween = nil
end

if MarshMallowStep == "Sugar Block Bag" then
    repeat task.wait() until Pot.Timer.TextLabel.Text == "0"
    if not LocalPlayer.Character:FindFirstChild("Sugar Block Bag") then
        LocalPlayer.Character.Humanoid:EquipTool(LocalPlayer.Backpack:FindFirstChild("Sugar Block Bag"))
    end
    Library:Notification("Steps", "Sugar Block Bag", 5)
    repeat 
        task.wait(1) 
        tween_and_prompt(Pot.Attachment.ProximityPrompt) 
    until Task_Text == "Pour gelatin into the pot."
    if not (House.Parent.Name == "Apartments") then task.wait(2.5) end
    LocalPlayer.Character.Humanoid:UnequipTools()
    MarshMallowStep = "Gelatin"
end

if MarshMallowStep == "Gelatin" then
    LocalPlayer.Character.Humanoid:UnequipTools()
    if not LocalPlayer.Character:FindFirstChild("Gelatin") then
        LocalPlayer.Character.Humanoid:EquipTool(LocalPlayer.Backpack:FindFirstChild("Gelatin"))
    end
    Library:Notification("Steps", "Gelatin", 5)
    repeat 
        task.wait(1) 
        tween_and_prompt(Pot.Attachment.ProximityPrompt) 
    until Task_Text == "Let the solution cook for 45 seconds."
    if not (House.Parent.Name == "Apartments") then task.wait(2.5) end
    MarshMallowStep = "Collect"
end

if MarshMallowStep == "Collect" then
    repeat task.wait() until Pot.Timer.TextLabel.Text == "0"
    if not LocalPlayer.Character:FindFirstChild("Empty Bag") then
        LocalPlayer.Character.Humanoid:EquipTool(LocalPlayer.Backpack:FindFirstChild("Empty Bag"))
    end
    Library:Notification("Steps", "Collect", 5)
    repeat 
        task.wait(1) 
        tween_and_prompt(Pot.Attachment.ProximityPrompt) 
    until LocalPlayer.Character:FindFirstChild("Empty Bag") == nil
    if not (House.Parent.Name == "Apartments") then task.wait(2.5) end
    LocalPlayer.Character.Humanoid:UnequipTools()
    MarshMallowStep = "Water"
end
            if MarshMallowStep ~= "Sell" then
                local Water, Gel, Sug = {}, {}, {}
                for _, Value in ipairs(LocalPlayer.Backpack:GetChildren()) do
                    if Value.Name == "Sugar Block Bag" then table.insert(Sug, Value)
                    elseif Value.Name == "Gelatin" then table.insert(Gel, Value)
                    elseif Value.Name == "Water" then table.insert(Water, Value) end
                end

                local highestCommon = math.min(#Water, #Gel, #Sug)

                for i = 1, highestCommon do
                    if MarshMallowStep == "Water" then
                        if not LocalPlayer.Character:FindFirstChild("Water") then
                            LocalPlayer.Character.Humanoid:EquipTool(LocalPlayer.Backpack:FindFirstChild("Water"))
                        end
                        Library:Notification("Steps", "Water", 5)
                        repeat 
                            task.wait(1) 
                            tween_and_prompt(Pot.Attachment.ProximityPrompt) 
                        until Task_Text == "Wait 20 seconds for your water to boil."

                        if Config["AutoFarm"]["MovementType"] == "Bike" then
                            bikeWaitAndReturn("Water")
                        end

                        if not (House.Parent.Name == "Apartments") then task.wait(2.5) end
                        MarshMallowStep = "Sugar Block Bag"
                    end

                    if MarshMallowStep == "Sugar Block Bag" then
                        repeat task.wait() until Pot.Timer.TextLabel.Text == "0"
                        if not LocalPlayer.Character:FindFirstChild("Sugar Block Bag") then
                            LocalPlayer.Character.Humanoid:EquipTool(LocalPlayer.Backpack:FindFirstChild("Sugar Block Bag"))
                        end
                        Library:Notification("Steps", "Sugar Block Bag", 5)
                        repeat 
                            task.wait(1) 
                            tween_and_prompt(Pot.Attachment.ProximityPrompt) 
                        until Task_Text == "Pour gelatin into the pot."

                        if Config["AutoFarm"]["MovementType"] == "Bike" then
                            bikeWaitAndReturn("Sugar")
                        end

                        if not (House.Parent.Name == "Apartments") then task.wait(2.5) end
                        LocalPlayer.Character.Humanoid:UnequipTools()
                        MarshMallowStep = "Gelatin"
                    end

                    if MarshMallowStep == "Gelatin" then
                        repeat task.wait() until Pot.Timer.TextLabel.Text == "0"
                        local HumanoidConnection
                        HumanoidConnection = LocalPlayer.Character.Humanoid.Died:Connect(function()
                            MarshMallowStep = "Water"
                            HumanoidConnection:Disconnect()
                        end)
                        LocalPlayer.Character.Humanoid:UnequipTools()
                        if not LocalPlayer.Character:FindFirstChild("Gelatin") then
                            LocalPlayer.Character.Humanoid:EquipTool(LocalPlayer.Backpack:FindFirstChild("Gelatin"))
                        end
                        Library:Notification("Steps", "Gelatin", 5)
                        repeat 
                            task.wait(1) 
                            tween_and_prompt(Pot.Attachment.ProximityPrompt) 
                        until Task_Text == "Let the solution cook for 45 seconds."

                        if Config["AutoFarm"]["MovementType"] == "Bike" then
                            bikeWaitAndReturn("Gelatin")
                        end

                        if not (House.Parent.Name == "Apartments") then task.wait(2.5) end
                        MarshMallowStep = "Collect"
                        HumanoidConnection:Disconnect()
                    end

                    if MarshMallowStep == "Collect" then
                        repeat task.wait() until Pot.Timer.TextLabel.Text == "0"
                        local HumanoidConnection
                        HumanoidConnection = LocalPlayer.Character.Humanoid.Died:Connect(function()
                            MarshMallowStep = "Water"
                            HumanoidConnection:Disconnect()
                        end)
                        if not LocalPlayer.Character:FindFirstChild("Empty Bag") then
                            LocalPlayer.Character.Humanoid:EquipTool(LocalPlayer.Backpack:FindFirstChild("Empty Bag"))
                        end
                        Library:Notification("Steps", "Collect", 5)
                        repeat 
                            task.wait(1) 
                            tween_and_prompt(Pot.Attachment.ProximityPrompt) 
                        until LocalPlayer.Character:FindFirstChild("Empty Bag") == nil
                        task.wait(1)
                        LocalPlayer.Character.Humanoid:UnequipTools()
                        if i == Marshmellow_Increment then
                            MarshMallowStep = "Sell"
                        else
                            MarshMallowStep = "Water"
                        end
                        HumanoidConnection:Disconnect()
                    end
                end
            end

            if MarshMallowStep == "Sell" then
                Library:Notification("AutoFarm", "Selling Marshmallows...", 5)
                Teleport(CFrame.new(510, 4, 602))
                repeat task.wait() until Workspace.Folders.NPCs:FindFirstChild("Lamont Bell")
                task.wait(0.5)
                local Tween = TweenService:Create(LocalPlayer.Character.HumanoidRootPart,
                    TweenInfo.new(2.5, Enum.EasingStyle.Linear),
                    { CFrame = CFrame.new(511, 4, 598) }
                )
                Tween:Play()
                Tween.Completed:Wait()
                Tween = nil
                LookDown(15, true)
                if LookDownConnection then LookDownConnection:Disconnect(); LookDownConnection = nil end
                pcall(function()
                    Workspace.Folders.NPCs["Lamont Bell"].UpperTorso.ProximityPrompt.HoldDuration = 0
                    Workspace.Folders.NPCs["Lamont Bell"].UpperTorso.ProximityPrompt.RequiresLineOfSight = false
                end)
                for _, Value in LocalPlayer.Backpack:GetChildren() do
                    if Value:IsA("Tool") then
                        local MarshmallowItem = GetMarshmallowItem(Value.Name)
                        if MarshmallowItem then
                            LocalPlayer.Character.Humanoid:EquipTool(Value)
                            fireProximityPrompt(Workspace.Folders.NPCs["Lamont Bell"].UpperTorso.ProximityPrompt)
                            Config["AutoFarm"]["Marshmallow"]["Status"]["Earned"] = Config["AutoFarm"]["Marshmallow"]["Status"]["Earned"] + MarshmallowSellPrice[MarshmallowItem]
                            Config["AutoFarm"]["Marshmallow"]["Status"]["Total_Sold"] = Config["AutoFarm"]["Marshmallow"]["Status"]["Total_Sold"] + 1
                            Config.AutoFarm.Marshmallow.Status.Sold_Type[MarshmallowItem] = Config.AutoFarm.Marshmallow.Status.Sold_Type[MarshmallowItem] + 1
                            task.wait(0.2)
                        end
                    end
                end
                MarshMallowStep = "Water"
            end
            ::continue::
        end
    end)
end

Stop_MarshmallowFarm = function()
    if not MarshmallowFarm_Thread then return end
    local status = coroutine.status(MarshmallowFarm_Thread)
    if status ~= "dead" then
        SafeModeRunning = false
        local HumanoidRootPart = _SM_Root or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart"))
        pcall(task.cancel, MarshmallowFarm_Thread)
        MarshmallowFarm_Thread = nil
        SafeModeCleanup()
        if LookDownConnection then LookDownConnection:Disconnect(); LookDownConnection = nil end
        if HumanoidRootPart and HumanoidRootPart.Parent then
            local surfacePos = Vector3.new(HumanoidRootPart.Position.X, 3, HumanoidRootPart.Position.Z)
            local Tween_Root = TweenService:Create(HumanoidRootPart,
                TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
                { CFrame = CFrame.new(surfacePos) * CFrame.Angles(0, math.atan2(HumanoidRootPart.CFrame.LookVector.X, HumanoidRootPart.CFrame.LookVector.Z), 0) }
            )
            Tween_Root:Play()
            Tween_Root.Completed:Wait()
        end
    end
end
-- ============ CARD FARM ============
local function cardMove(pos)
    Teleport(CFrame.new(pos))
end

local CardFarmRunning = false
local immCard = {false}

local function pointCamAt(target)
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root or not target then return end
    local targetPos = (typeof(target) == "Instance" and target:IsA("BasePart")) and target.Position or target
    workspace.CurrentCamera.CFrame = CFrame.lookAt(root.Position + Vector3.new(0, 1.5, 0), targetPos)
end

local function AutoPressCardfarmKeys()
    while getgenv().CardFarm do
        if not immCard[1] then
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.W, false, game)
            task.wait(0.1)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.W, false, game)
            task.wait(0.3)
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.A, false, game)
            task.wait(0.1)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.A, false, game)
            task.wait(0.3)
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.S, false, game)
            task.wait(0.1)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.S, false, game)
            task.wait(0.3)
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.D, false, game)
            task.wait(0.1)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.D, false, game)
            task.wait(0.5)
        else
            task.wait(1)
        end
    end
end

local function waitForAlive()
    repeat 
        task.wait(0.5)
        local c = LocalPlayer.Character
        local h = c and c:FindFirstChildOfClass("Humanoid")
        if c and c:FindFirstChild("HumanoidRootPart") and h and h.Health > 0 then return end
    until false
end

local function startCardFarming()
    if CardFarmRunning then return end
    CardFarmRunning = true
    task.spawn(AutoPressCardfarmKeys)
    task.spawn(function()
        while getgenv().CardFarm do
            local c = LocalPlayer.Character
            local hum = c and c:FindFirstChildOfClass("Humanoid")
            if not c or not hum then waitForAlive(); goto continue end
            if hum.Health <= 0 then
                repeat
                    task.wait(1)
                    c = LocalPlayer.Character
                    hum = c and c:FindFirstChildOfClass("Humanoid")
                until c and hum and hum.Health > 0
                task.wait(1)
            end
            pcall(function()
                local player = LocalPlayer
                local character = player.Character or player.CharacterAdded:Wait()
                local h = character:WaitForChild("Humanoid", 10)
                if not h then return end

                cardMove(Vector3.new(216.20, 3.37, -332.39))
                task.wait(0.5)

                local idSellerNPC = workspace.Folders.NPCs:FindFirstChild("FakeIDSeller")
                if not idSellerNPC then return end
                local idAttach = idSellerNPC.UpperTorso:FindFirstChild("Attachment")
                if not idAttach then return end
                local idPrompt = idAttach:FindFirstChildOfClass("ProximityPrompt")
                if not idPrompt then return end

                local idCounter = 0
                repeat
                    if not getgenv().CardFarm then return end
                    pointCamAt(idSellerNPC.UpperTorso)
                    fireProximityPrompt(idPrompt)
                    task.wait(0.2)
                    idCounter = idCounter + 1
                    if idCounter > 40 then return end
                until player.Backpack:FindFirstChild("Fake ID")

                local idTool = player.Backpack:FindFirstChild("Fake ID")
                if idTool then pcall(function() h:EquipTool(idTool) end) end

                for _, pos in ipairs({Vector3.new(216.62, 3.37, -332.63), Vector3.new(-48.74, 6.50, -317.00)}) do
                    if not getgenv().CardFarm then return end
                    cardMove(pos)
                end

                local tellerNPC = workspace.Folders.NPCs:FindFirstChild("Bank Teller")
                if not tellerNPC then return end
                local tellerAttach = tellerNPC.UpperTorso:FindFirstChild("Attachment")
                if not tellerAttach then return end
                local tellerPrompt = tellerAttach:FindFirstChildOfClass("ProximityPrompt")
                if not tellerPrompt then return end

                local waitCounter = 0
                repeat
                    task.wait(0.2)
                    waitCounter = waitCounter + 1
                    if waitCounter > 50 then return end
                until (tellerPrompt.Enabled and tellerPrompt.Parent) or not getgenv().CardFarm

                local applyCounter = 0
                repeat
                    if not getgenv().CardFarm then return end
                    pointCamAt(tellerNPC.UpperTorso)
                    fireProximityPrompt(tellerPrompt)
                    task.wait(0.3)
                    applyCounter = applyCounter + 1
                    if applyCounter > 30 then return end
                until not character:FindFirstChild("Fake ID")

                task.wait(11.5)
                local notif = player.PlayerGui.Main.BasicNotification
                if not notif.Visible or notif.Text ~= "Your application was successful. Please allow 30 seconds for the bank to prepare your card." then
                    return
                end

                task.wait(35)
                cardMove(Vector3.new(-41.77, 3.37, -332.23))

                local cardPickup = workspace:FindFirstChild("CardPickup")
                if not cardPickup then return end
                local cardPickupAtt = cardPickup:FindFirstChild("Attachment")
                if not cardPickupAtt then return end
                local cardPickupPrompt = cardPickupAtt:FindFirstChildOfClass("ProximityPrompt")
                if not cardPickupPrompt then return end

                local pickupCounter = 0
                repeat
                    if not getgenv().CardFarm then return end
                    pointCamAt(cardPickup)
                    fireProximityPrompt(cardPickupPrompt)
                    task.wait(0.3)
                    pickupCounter = pickupCounter + 1
                    if pickupCounter > 80 then return end
                until player.Backpack:FindFirstChild("Card")

                local cardTool = player.Backpack:FindFirstChild("Card")
                if cardTool then pcall(function() h:EquipTool(cardTool) end); task.wait(0.2) end

                local atmsFolder = workspace:FindFirstChild("Map")
                atmsFolder = atmsFolder and atmsFolder:FindFirstChild("ATMS")
                if not atmsFolder then return end

                local closestATM, shortestDist = nil, math.huge
                for _, atm in ipairs(atmsFolder:GetChildren()) do
                    if atm:IsA("BasePart") and atm.Name:match("^ATM%d*$") then
                        local prompt = atm:FindFirstChildWhichIsA("ProximityPrompt", true)
                        if prompt and prompt.Enabled then
                            local root2 = character:FindFirstChild("HumanoidRootPart")
                            if root2 then
                                local dist = (root2.Position - atm.Position).Magnitude
                                if dist < shortestDist then shortestDist = dist; closestATM = atm end
                            end
                        end
                    end
                end
                if not closestATM then return end

                local frontPos = closestATM.Position + (closestATM.CFrame.LookVector * -2.5)
                cardMove(frontPos)
                task.wait(0.5)

                local atmPrompt = closestATM:FindFirstChildWhichIsA("ProximityPrompt", true)
                if not atmPrompt then return end

                local iStart = tick()
                repeat
                    if not getgenv().CardFarm then return end
                    pointCamAt(closestATM)
                    fireProximityPrompt(atmPrompt)
                    task.wait(0.5)
                until player.PlayerGui:FindFirstChild("ATM") or (tick() - iStart > 8)

                if player.PlayerGui:FindFirstChild("ATM") then
                    Config["AutoFarm"]["Card"]["Status"]["Swipes"] = Config["AutoFarm"]["Card"]["Status"]["Swipes"] + 1
                    local gStart = tick()
                    repeat
                        if not getgenv().CardFarm then break end
                        if not player.PlayerGui:FindFirstChild("ATM") then break end
                        pointCamAt(closestATM)
                        local atmFrame = player.PlayerGui.ATM:FindFirstChild("Frame")
                        local swipeBtn = atmFrame and atmFrame:FindFirstChild("Swipe")
                        if swipeBtn then game.GuiService.SelectedObject = swipeBtn end
                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                        task.wait(0.06)
                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
                        task.wait(0.01)
                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.BackSlash, false, game)
                        task.wait(0.06)
                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.BackSlash, false, game)
                        task.wait(0.1)
                    until not player.PlayerGui:FindFirstChild("ATM") or not getgenv().CardFarm or (tick() - gStart > 12)
                end
            end)
            ::continue::
            task.wait(2)
        end
        CardFarmRunning = false
    end)
end
-- ============ CHIP FARM ============
local immChip = {false}
local camConnection = nil
local chipDetectionScreen = nil
local chipDetectionLabel = nil

local function hideChipDetectionScreen()
    if chipDetectionScreen and chipDetectionScreen.Parent then
        chipDetectionScreen:Destroy()
    end
    chipDetectionScreen = nil
    chipDetectionLabel = nil
end

local function showChipDetectionScreen()
    hideChipDetectionScreen()

    local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui")
    local screen = Instance.new("ScreenGui")
    screen.Name = "ChipNPCDetectionScreen"
    screen.ResetOnSpawn = false
    screen.IgnoreGuiInset = true
    screen.DisplayOrder = 1000
    screen.Parent = playerGui

    local frame = Instance.new("Frame")
    frame.Name = "Detector"
    frame.AnchorPoint = Vector2.new(0.5, 0)
    frame.Position = UDim2.new(0.5, 0, 0.08, 0)
    frame.Size = UDim2.fromOffset(320, 64)
    frame.BackgroundColor3 = Color3.fromRGB(17, 19, 19)
    frame.BorderSizePixel = 0
    frame.Parent = screen

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(0, 0, 255)
    stroke.Thickness = 2
    stroke.Parent = frame

    local label = Instance.new("TextLabel")
    label.Name = "Count"
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamSemibold
    label.Text = "Detecting NPCs: 0"
    label.TextColor3 = Color3.fromRGB(221, 223, 222)
    label.TextSize = 18
    label.Parent = frame

    chipDetectionScreen = screen
    chipDetectionLabel = label
end

local function updateChipDetectionScreen(count, finished)
    if chipDetectionLabel then
        chipDetectionLabel.Text = (finished and "NPCs detected: " or "Detecting NPCs: ") .. tostring(count)
    end
end

local function startChipCamLock()
    if camConnection then camConnection:Disconnect() end
    workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
    camConnection = RunService.RenderStepped:Connect(function()
        if chipFarmActive then
            local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if root then
                workspace.CurrentCamera.CFrame = CFrame.new(root.Position + Vector3.new(0, 10, 0), root.Position)
            end
        end
    end)
end

local function stopChipCamLock()
    if camConnection then camConnection:Disconnect() end
    camConnection = nil
    workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
end

local function chipMove(pos)
    if not chipFarmActive then return "Stopped" end
    local result = Teleport(CFrame.new(pos))
    return result
end

local function chipMoveToNPC(npc)
    if not chipFarmActive then return false end
    local targetPos = npc and npc:FindFirstChild("HumanoidRootPart") and npc.HumanoidRootPart.Position
    if not targetPos then return false end
    local result = Teleport(CFrame.new(targetPos))
    task.wait(0.3)
    return chipFarmActive and result ~= "Stopped"
end
local function startChipFarm()
    startChipCamLock()
    task.spawn(function()
        local storeEvent = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("StorePurchase")
        local HomelessStorage = ReplicatedStorage:FindFirstChild("Workspace")
        HomelessStorage = HomelessStorage and HomelessStorage:FindFirstChild("Homeless")
        if not HomelessStorage then
            warn("Chip Farm: HomelessStorage not found.")
            chipFarmActive = false
            hideChipDetectionScreen()
            stopChipCamLock()
            return
        end

        local HomelessLive = workspace.Folders.HomelessPeople
        local wordNumbers = {"One","Two","Three","Four","Five","Six","Seven","Eight","Nine","Ten","Eleven","Twelve","Thirteen","Fourteen","Fifteen"}

        local function getSittingNPCs(folder)
            local sitting = {}
            local c = LocalPlayer.Character
            if not c or not c:FindFirstChild("HumanoidRootPart") then return sitting end
            if not folder or not folder.Parent then return sitting end
            for _, npc in ipairs(folder:GetChildren()) do
                local found = false
                for _, name in ipairs(wordNumbers) do
                    if npc.Name == name then found = true; break end
                end
                if found and npc:GetAttribute("AnimationState") == "Sitting" then
                    table.insert(sitting, npc)
                end
            end
            return sitting
        end

        while chipFarmActive do
            local c = LocalPlayer.Character
            local hum = c and c:FindFirstChildOfClass("Humanoid")
            if not c or not hum or hum.Health <= 0 then waitForAlive(); goto continue end

            local targets = getSittingNPCs(HomelessStorage)
            showChipDetectionScreen()
            updateChipDetectionScreen(#targets, false)

            local ws = 0
            while chipFarmActive and #targets == 0 and ws <= 300 do
                task.wait(1)
                targets = getSittingNPCs(HomelessStorage)
                updateChipDetectionScreen(#targets, false)
                ws = ws + 1
            end

            if not chipFarmActive then
                hideChipDetectionScreen()
                break
            end

            if #targets == 0 then
                hideChipDetectionScreen()
                goto continue
            end

            updateChipDetectionScreen(#targets, true)
            task.wait(1)
            hideChipDetectionScreen()

            if chipMove(Vector3.new(-771, 4, -198)) == "Stopped" then break end
            local buyCounter = 0
            while chipFarmActive and (getItemCount("Potato") < #targets or getItemCount("Flour") < #targets) do
                buyCounter = buyCounter + 1
                if buyCounter > 60 then break end
                if getItemCount("Potato") < #targets then
                    pcall(function() storeEvent:FireServer("Potato") end)
                    task.wait(0.4)
                end
                if chipFarmActive and getItemCount("Flour") < #targets then
                    pcall(function() storeEvent:FireServer("Flour") end)
                    task.wait(0.4)
                end
            end
            if not chipFarmActive then break end

            local processCounter = 0
            repeat
                if not chipFarmActive then break end
                processCounter = processCounter + 1
                if processCounter > 10 then break end

                if chipMove(Vector3.new(-479, 4, -436)) == "Stopped" then break end
                pressE()
                task.wait(1)

                if chipMove(Vector3.new(-463, 4, -469)) == "Stopped" then break end
                safeEquip("Potato")
                local cutterOk, cutterPrompt = pcall(function()
                    return workspace.Map.Locations["The Laboratory"]["Cutting Boards"]["Potato Cutter"].Model.Union.Attachment.ProximityPrompt
                end)
                if cutterOk and cutterPrompt then fireProximityPrompt(cutterPrompt) end
                task.wait(5.7)

                if not chipFarmActive then break end
                if chipMove(Vector3.new(-462, 4, -475)) == "Stopped" then break end
                local bagOk, bagPrompt = pcall(function()
                    return workspace.Map.Locations["The Laboratory"].Prompts["Plastic Bag"].Attachment.ProximityPrompt
                end)
                if bagOk and bagPrompt then fireProximityPrompt(bagPrompt) end
                task.wait(5.7)

                if not chipFarmActive then break end
                if chipMove(Vector3.new(-487, 4, -536)) == "Stopped" then break end
                safeEquip("Flour")
                local bowlOk, bowlPrompt = pcall(function()
                    return workspace.Map.Locations["The Laboratory"].Bowls:GetChildren()[2].ProximityPrompt
                end)
                if bowlOk and bowlPrompt then fireProximityPrompt(bowlPrompt) end
                task.wait(5.7)

                if not chipFarmActive then break end
                if chipMove(Vector3.new(-521, 4, -465)) == "Stopped" then break end
                local potOk, potPrompt = pcall(function()
                    return workspace.Map.Locations["The Laboratory"].Pots:GetChildren()[7].ProximityPrompt
                end)
                if potOk and potPrompt then fireProximityPrompt(potPrompt) end

                local t = 0
                while chipFarmActive and t < 65 do
                    task.wait(1)
                    t = t + 1
                end
                if chipFarmActive then pressE(); task.wait(1) end

            until not chipFarmActive or (getItemCount("Potato") == 0 and getItemCount("Flour") == 0)

            if not chipFarmActive then break end

            if chipMove(Vector3.new(-33, 4, -25)) == "Stopped" then break end
            local poorGuy = workspace.Folders.NPCs:FindFirstChild("Poor Guy")
            if not poorGuy then task.wait(2); goto continue end
            local poorPrompt = poorGuy.UpperTorso:FindFirstChildOfClass("ProximityPrompt")
            if not poorPrompt then task.wait(2); goto continue end
            fireProximityPrompt(poorPrompt)
            task.wait(1.5)

            local deliverSafety = 0
            while chipFarmActive and getItemCount("Hot Chips") > 0 do
                deliverSafety = deliverSafety + 1
                if deliverSafety > 50 then break end
                local allTargets = getSittingNPCs(HomelessStorage)
                local liveTargets = getSittingNPCs(HomelessLive)
                for _, v in ipairs(liveTargets) do table.insert(allTargets, v) end

                if #allTargets == 0 then
                    task.wait(1)
                else
                    for _, npc in ipairs(allTargets) do
                        if not chipFarmActive or getItemCount("Hot Chips") <= 0 then break end
                        if not npc or not npc.Parent then goto continue_npc end
                        if npc:GetAttribute("AnimationState") ~= "Sitting" then goto continue_npc end
                        local c2 = LocalPlayer.Character
                        local hum2 = c2 and c2:FindFirstChildOfClass("Humanoid")
                        if not c2 or not hum2 or hum2.Health <= 0 then waitForAlive(); break end
                        if chipMoveToNPC(npc) then
                            safeEquip("Hot Chips")
                            Config["AutoFarm"]["Chips"]["Status"]["Earned"] = Config["AutoFarm"]["Chips"]["Status"]["Earned"] + 300
                            Config["AutoFarm"]["Chips"]["Status"]["Delivered"] = Config["AutoFarm"]["Chips"]["Status"]["Delivered"] + 1
                            task.wait(0.3)
                            pressE()
                            task.wait(1.5)
                        end
                        ::continue_npc::
                    end
                end
                task.wait(0.5)
            end
            ::continue::
        end

        hideChipDetectionScreen()
        stopChipCamLock()
    end)
end
-- ============ HUMANODEATH HANDLER ============
local Humanoid = LocalPlayer.Character:WaitForChild("Humanoid")
local Died_Counter = 0

Humanoid.Died:Connect(function()
    Died_Counter = Died_Counter + 1
    if Task_Text == "Let the solution cook for 45 seconds." or Task_Text == "Bag the solution into the empty bag." then
        LocalPlayer:Kick("[DEBUG]: Died during empty bag step, autofarm disabled. Please rejoin!")
    end
    if Config["AutoFarm"]["Marshmallow"]["Enabled"] then Stop_MarshmallowFarm() end
end)

LocalPlayer.CharacterAdded:Connect(function(Character)
    Humanoid = Character:WaitForChild("Humanoid")
    if Config["AutoFarm"]["Marshmallow"]["Enabled"] then
        Library:Notification("AutoFarm", "Marshmallow will run in 10s", 5)
        Stop_MarshmallowFarm()
        task.wait(1)
        SpawnBike()
        task.wait(10)
        Start_MarshmallowFarm()
    end
    Humanoid.Died:Connect(function()
        Died_Counter = Died_Counter + 1
        if Task_Text == "Let the solution cook for 45 seconds." or Task_Text == "Bag the solution into the empty bag." then
            LocalPlayer:Kick("[DEBUG]: Died during empty bag step, autofarm disabled. Please rejoin!")
        end
        if Config["AutoFarm"]["Marshmallow"]["Enabled"] then Stop_MarshmallowFarm() end
    end)
end)
-- ============ GUI / LIBRARY ============
do
    -- Muat Library
    local Library
    local success, result = pcall(function()
        Library = loadstring(game:HttpGet("https://pastebin.com/raw/vZYJc3ay"))()
        return Library
    end)
    
    if not success then
        warn("Gagal memuat library: " .. tostring(result))
        return
    end
    
    Library = getgenv().Library

    local notificationGui = nil
    local notificationHolder = nil
    local notificationCounter = 0

    local function ensureNotificationHolder()
        if notificationGui and notificationGui.Parent and notificationHolder then
            return notificationHolder
        end

        local parent = LocalPlayer and (LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 5)) or CoreGui
        if gethui then
            local success, hiddenUi = pcall(gethui)
            if success and hiddenUi then parent = hiddenUi end
        end

        local oldGui = parent and parent:FindFirstChild("EclipseXNotifications")
        if oldGui then oldGui:Destroy() end

        notificationGui = Instance.new("ScreenGui")
        notificationGui.Name = "EclipseXNotifications"
        notificationGui.IgnoreGuiInset = true
        notificationGui.ResetOnSpawn = false
        notificationGui.DisplayOrder = 10000
        notificationGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        notificationGui.Parent = parent

        notificationHolder = Instance.new("Frame")
        notificationHolder.Name = "Holder"
        notificationHolder.AnchorPoint = Vector2.new(1, 0)
        notificationHolder.Position = UDim2.new(1, -18, 0, 18)
        notificationHolder.Size = UDim2.new(0, 310, 1, -36)
        notificationHolder.BackgroundTransparency = 1
        notificationHolder.Parent = notificationGui

        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 5)
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
        layout.VerticalAlignment = Enum.VerticalAlignment.Top
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Parent = notificationHolder

        return notificationHolder
    end

    function Library:Notification(title, description, duration)
        local notificationTitle = tostring(title or "Notification")
        local notificationText = tostring(description or "")
        local notificationDuration = math.max(tonumber(duration) or 3, 0.5)

        local success = pcall(function()
            local holder = ensureNotificationHolder()
            if not holder then error("Notification holder unavailable") end

            notificationCounter = notificationCounter + 1

            local wrapper = Instance.new("Frame")
            wrapper.Name = "NotificationWrapper"
            wrapper.Size = UDim2.fromOffset(304, 70)
            wrapper.BackgroundTransparency = 1
            wrapper.LayoutOrder = -notificationCounter
            wrapper.Parent = holder

            local glow = Instance.new("ImageLabel")
            glow.Name = "Glow"
            glow.Position = UDim2.fromOffset(18, -10)
            glow.Size = UDim2.fromOffset(306, 84)
            glow.BackgroundTransparency = 1
            glow.BorderSizePixel = 0
            glow.Image = "rbxassetid://18245826428"
            glow.ImageColor3 = Color3.fromRGB(151, 0, 255)
            glow.ImageTransparency = 1
            glow.ScaleType = Enum.ScaleType.Slice
            glow.SliceCenter = Rect.new(21, 21, 79, 79)
            glow.ZIndex = 1
            glow.Parent = wrapper

            local card = Instance.new("Frame")
            card.Name = "Notification"
            card.Position = UDim2.fromOffset(320, 4)
            card.Size = UDim2.fromOffset(286, 62)
            card.BackgroundColor3 = Color3.fromRGB(17, 19, 19)
            card.BorderSizePixel = 0
            card.ClipsDescendants = true
            card.ZIndex = 2
            card.Parent = wrapper

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 5)
            corner.Parent = card

            local outerStroke = Instance.new("UIStroke")
            outerStroke.Color = Color3.fromRGB(151, 0, 255)
            outerStroke.Thickness = 1
            outerStroke.Transparency = 0.05
            outerStroke.Parent = card

            local inline = Instance.new("Frame")
            inline.Name = "Inline"
            inline.Position = UDim2.fromOffset(2, 2)
            inline.Size = UDim2.new(1, -4, 1, -4)
            inline.BackgroundColor3 = Color3.fromRGB(24, 24, 26)
            inline.BorderSizePixel = 0
            inline.ZIndex = 3
            inline.Parent = card

            local inlineCorner = Instance.new("UICorner")
            inlineCorner.CornerRadius = UDim.new(0, 4)
            inlineCorner.Parent = inline

            local accent = Instance.new("Frame")
            accent.Name = "Accent"
            accent.Size = UDim2.new(0, 3, 1, 0)
            accent.BackgroundColor3 = Color3.fromRGB(151, 0, 255)
            accent.BorderSizePixel = 0
            accent.ZIndex = 4
            accent.Parent = inline
        local titleLabel = Instance.new("TextLabel")
        titleLabel.Name = "Title"
        titleLabel.Position = UDim2.fromOffset(12, 6)
        titleLabel.Size = UDim2.new(1, -38, 0, 18)
        titleLabel.BackgroundTransparency = 1
        titleLabel.Font = Enum.Font.GothamBold
        titleLabel.Text = notificationTitle
        titleLabel.TextColor3 = Color3.fromRGB(245, 245, 247)
        titleLabel.TextSize = 13
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.TextTruncate = Enum.TextTruncate.AtEnd
        titleLabel.ZIndex = 5
        titleLabel.Parent = inline

        local bodyLabel = Instance.new("TextLabel")
        bodyLabel.Name = "Body"
        bodyLabel.Position = UDim2.fromOffset(12, 25)
        bodyLabel.Size = UDim2.new(1, -24, 0, 24)
        bodyLabel.BackgroundTransparency = 1
        bodyLabel.Font = Enum.Font.Gotham
        bodyLabel.Text = notificationText
        bodyLabel.TextColor3 = Color3.fromRGB(188, 190, 196)
        bodyLabel.TextSize = 11
        bodyLabel.TextWrapped = true
        bodyLabel.TextXAlignment = Enum.TextXAlignment.Left
        bodyLabel.TextYAlignment = Enum.TextYAlignment.Top
        bodyLabel.ZIndex = 5
        bodyLabel.Parent = inline

        local closeButton = Instance.new("TextButton")
        closeButton.Name = "Close"
        closeButton.Position = UDim2.new(1, -25, 0, 4)
        closeButton.Size = UDim2.fromOffset(19, 19)
        closeButton.BackgroundTransparency = 1
        closeButton.Font = Enum.Font.GothamBold
        closeButton.Text = "X"
        closeButton.TextColor3 = Color3.fromRGB(148, 150, 158)
        closeButton.TextSize = 10
        closeButton.ZIndex = 6
        closeButton.Parent = inline

        local progressTrack = Instance.new("Frame")
        progressTrack.Name = "ProgressTrack"
        progressTrack.AnchorPoint = Vector2.new(0, 1)
        progressTrack.Position = UDim2.new(0, 3, 1, 0)
        progressTrack.Size = UDim2.new(1, -3, 0, 2)
        progressTrack.BackgroundColor3 = Color3.fromRGB(38, 38, 42)
        progressTrack.BorderSizePixel = 0
        progressTrack.ZIndex = 4
        progressTrack.Parent = inline

        local progress = Instance.new("Frame")
        progress.Name = "Progress"
        progress.Size = UDim2.fromScale(1, 1)
        progress.BackgroundColor3 = Color3.fromRGB(151, 0, 255)
        progress.BorderSizePixel = 0
        progress.ZIndex = 5
        progress.Parent = progressTrack

        local progressGlow = Instance.new("ImageLabel")
        progressGlow.Name = "ProgressGlow"
        progressGlow.AnchorPoint = Vector2.new(0, 0.5)
        progressGlow.Position = UDim2.new(0, -7, 0.5, 0)
        progressGlow.Size = UDim2.new(1, 14, 0, 18)
        progressGlow.BackgroundTransparency = 1
        progressGlow.Image = "rbxassetid://18245826428"
        progressGlow.ImageColor3 = Color3.fromRGB(151, 0, 255)
        progressGlow.ImageTransparency = 0.3
        progressGlow.ScaleType = Enum.ScaleType.Slice
        progressGlow.SliceCenter = Rect.new(21, 21, 79, 79)
        progressGlow.ZIndex = 4
        progressGlow.Parent = progress

        local progressTween = TweenService:Create(progress,
            TweenInfo.new(notificationDuration, Enum.EasingStyle.Linear),
            { Size = UDim2.new(0, 0, 1, 0) }
        )

        local dismissed = false
        local function dismiss()
            if dismissed then return end
            dismissed = true
            pcall(function() progressTween:Cancel() end)

            local cardOut = TweenService:Create(card,
                TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                { Position = UDim2.fromOffset(320, 4), BackgroundTransparency = 1 }
            )
            local glowOut = TweenService:Create(glow,
                TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                { ImageTransparency = 1 }
            )
            cardOut:Play()
            glowOut:Play()
            cardOut.Completed:Wait()
            if wrapper then wrapper:Destroy() end
        end

        closeButton.MouseButton1Click:Connect(dismiss)

        local cardIn = TweenService:Create(card,
            TweenInfo.new(0.24, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            { Position = UDim2.fromOffset(18, 4) }
        )
        local glowIn = TweenService:Create(glow,
            TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            { ImageTransparency = 0.38 }
        )
        cardIn:Play()
        glowIn:Play()
        progressTween:Play()
        task.delay(notificationDuration, dismiss)
    end)

    if not success then
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = notificationTitle,
                Text = notificationText,
                Duration = notificationDuration,
            })
        end)
    end
end
local Window = Library:Window({
    Prefix = "Volted",
    Suffix = "X",
})

Library:RefreshTheme("accent", Color3.fromRGB(151, 0, 255))
Library:RefreshTheme("background", Color3.fromRGB(17, 19, 19))
Library:RefreshTheme("inline", Color3.fromRGB(27, 27, 27))
Library:RefreshTheme("visible_backgrounds", Color3.fromRGB(18, 18, 18))
Library:RefreshTheme("text_color", Color3.fromRGB(221, 223, 222))
Library:RefreshTheme("glow", Color3.fromRGB(151, 0, 255))
Library:RefreshTheme("deselected", Color3.fromRGB(89, 91, 91))
Library:RefreshTheme("window_outline", Color3.fromRGB(151, 0, 255))
Window.Items.Glow.ImageColor3 = Color3.fromRGB(151, 0, 255)

local function setLabel(label, text)
    if label then
        pcall(function() label:Set(text) end)
    end
end

local function setMarshmallowEnabled(value)
    local wasEnabled = Config["AutoFarm"]["Marshmallow"]["Enabled"]
    Config["AutoFarm"]["Marshmallow"]["Enabled"] = value
    if value then
        Start_MarshmallowFarm()
    elseif wasEnabled then
        Stop_MarshmallowFarm()
    end
end

local function setCardEnabled(value)
    local wasEnabled = getgenv().CardFarm == true or Config["AutoFarm"]["Card"]["Enabled"] == true
    getgenv().CardFarm = value
    Config["AutoFarm"]["Card"]["Enabled"] = value

    if value then
        pcall(function()
            local bankParts = workspace.Map.Locations["Community Bank"]
            if bankParts:GetChildren()[29] then bankParts:GetChildren()[29]:Destroy() end
            if bankParts:GetChildren()[19] then bankParts:GetChildren()[19]:Destroy() end
        end)
        startCardFarming()
    elseif wasEnabled then
        immCard[1] = false
        CardFarmRunning = false
        if not anyFarmRunning() then SafeModeCleanup() end
    end
end

local function setChipEnabled(value)
    local wasEnabled = chipFarmActive == true or Config["AutoFarm"]["Chips"]["Enabled"] == true
    chipFarmActive = value
    Config["AutoFarm"]["Chips"]["Enabled"] = value

    if value then
        startChipFarm()
    elseif wasEnabled then
        hideChipDetectionScreen()
        stopChipCamLock()
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not anyFarmRunning() then SafeModeCleanup() end
        if LookDownConnection then LookDownConnection:Disconnect(); LookDownConnection = nil end
        if root and root.Parent then
            local surfacePos = Vector3.new(root.Position.X, 3, root.Position.Z)
            local tweenUp = TweenService:Create(root,
                TweenInfo.new(1, Enum.EasingStyle.Linear),
                { CFrame = CFrame.new(surfacePos) * CFrame.Angles(0, math.atan2(root.CFrame.LookVector.X, root.CFrame.LookVector.Z), 0) }
            )
            tweenUp:Play()
            tweenUp.Completed:Wait()
        end
        local screen = LocalPlayer.PlayerGui:FindFirstChild("VolcanoWaitScreen")
        if screen then screen:Destroy() end
    end
end
    -- ============ MARSHMALLOW TAB ============
    local MarshmallowTab = Window:Tab({ Name = "Marshmallow" })
    local MarshmallowControls = MarshmallowTab:Section({ Name = "Farm", Side = "Left" })
    local MarshmallowStats = MarshmallowTab:Section({ Name = "Stats", Side = "Right" })

    MarshmallowControls:Dropdown({
        Name = "Movement Type",
        Flag = "Movement_Type",
        Options = {"Safe Mode", "Bike"},
        Default = "Safe Mode",
        Multi = false,
        Callback = function(value)
            Config["AutoFarm"]["MovementType"] = value
        end,
    })

    MarshmallowControls:Button({
        Name = "Buy / Spawn Bike",
        Callback = function() SpawnBike() end,
    })

    MarshmallowControls:Button({
        Name = "Buy Apartment - $250",
        Callback = function() BuyApartment() end,
    })

    MarshmallowControls:Slider({
        Name = "Batch Amount",
        Flag = "Marshmallow_Batch",
        Min = 1,
        Max = 100,
        Default = 1,
        Suffix = "x",
        Decimal = 1,
        Callback = function(value)
            Config["AutoFarm"]["Marshmallow"]["BatchAmount"] = value
        end,
    })

    MarshmallowControls:Toggle({
        Name = "Marshmallow Farm",
        Flag = "Marshmallow_Farm",
        Default = false,
        Callback = setMarshmallowEnabled,
    })

    local MarshmallowStatus = MarshmallowStats:Label({ Name = "Status: Stopped" })
    local MarshmallowStep = MarshmallowStats:Label({ Name = "Situation: Water" })
    local SmallSold = MarshmallowStats:Label({ Name = "Small Sold: 0" })
    local MediumSold = MarshmallowStats:Label({ Name = "Medium Sold: 0" })
    local LargeSold = MarshmallowStats:Label({ Name = "Large Sold: 0" })
    local TotalSold = MarshmallowStats:Label({ Name = "Total Sold: 0" })
    local MarshmallowEarned = MarshmallowStats:Label({ Name = "Earned: $0" })
    local Deaths = MarshmallowStats:Label({ Name = "Deaths: 0" })

    -- ============ CARD TAB ============
    local CardTab = Window:Tab({ Name = "Card" })
    local CardControls = CardTab:Section({ Name = "Farm", Side = "Left" })
    local CardStats = CardTab:Section({ Name = "Stats", Side = "Right" })

    CardControls:Toggle({
        Name = "Card Farm",
        Flag = "Card_Farm",
        Default = false,
        Callback = setCardEnabled,
    })

    local CardStatus = CardStats:Label({ Name = "Status: Stopped" })
    local CardSwipes = CardStats:Label({ Name = "Swipes: 0" })

    -- ============ CHIP TAB ============
    local ChipTab = Window:Tab({ Name = "Chip" })
    local ChipControls = ChipTab:Section({ Name = "Farm", Side = "Left" })
    local ChipStats = ChipTab:Section({ Name = "Stats", Side = "Right" })

    ChipControls:Toggle({
        Name = "Chip Farm",
        Flag = "Chip_Farm",
        Default = false,
        Callback = setChipEnabled,
    })

    local ChipStatus = ChipStats:Label({ Name = "Status: Stopped" })
    local ChipDelivered = ChipStats:Label({ Name = "Delivered: 0" })
    local ChipEarned = ChipStats:Label({ Name = "Earned: $0" })

    -- ============ STATS UPDATER ============
    task.spawn(function()
        while task.wait(1) do
            local marshmallow = Config["AutoFarm"]["Marshmallow"]
            local marshmallowStatus = marshmallow["Status"]
            local card = Config["AutoFarm"]["Card"]
            local chips = Config["AutoFarm"]["Chips"]

            setLabel(MarshmallowStatus, "Status: " .. (marshmallow["Enabled"] and "Running" or "Stopped"))
            setLabel(MarshmallowStep, "Situation: " .. tostring(MarshMallowStep))
            setLabel(SmallSold, "Small Sold: " .. tostring(marshmallowStatus["Sold_Type"]["Small Marshmallow Bag"]))
            setLabel(MediumSold, "Medium Sold: " .. tostring(marshmallowStatus["Sold_Type"]["Medium Marshmallow Bag"]))
            setLabel(LargeSold, "Large Sold: " .. tostring(marshmallowStatus["Sold_Type"]["Large Marshmallow Bag"]))
            setLabel(TotalSold, "Total Sold: " .. tostring(marshmallowStatus["Total_Sold"]))
            setLabel(MarshmallowEarned, "Earned: $" .. tostring(marshmallowStatus["Earned"]))
            setLabel(Deaths, "Deaths: " .. tostring(Died_Counter))

            setLabel(CardStatus, "Status: " .. (card["Enabled"] and "Running" or "Stopped"))
            setLabel(CardSwipes, "Swipes: " .. tostring(card["Status"]["Swipes"]))

            setLabel(ChipStatus, "Status: " .. (chips["Enabled"] and "Running" or "Stopped"))
            setLabel(ChipDelivered, "Delivered: " .. tostring(chips["Status"]["Delivered"]))
            setLabel(ChipEarned, "Earned: $" .. tostring(chips["Status"]["Earned"]))
        end
    end)

    task.wait(0.1)
end
