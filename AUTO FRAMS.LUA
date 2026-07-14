if LPH_OBFUSCATED == nil then
    local assert, type, G = assert, type, getgenv()
    local function encnum(a,...) assert(type(a)=="number" and #{...}==0) return a end
    local function encstr(a,...) assert(type(a)=="string" and #{...}==0) return a end
    local function jit(f,...) assert(type(f)=="function" and #{...}==0) return f end
    local function novirt(f,...) return jit(f,...) end
    local function noupv(f,...) return jit(f,...) end
    local function crash(...) assert(#{...}==0) game:Shutdown() while true do end end
    rawset(G,"LPH_ENCNUM",encnum); rawset(G,"LPH_NUMENC",encnum)
    rawset(G,"LPH_ENCSTR",encstr); rawset(G,"LPH_STRENC",encstr)
    rawset(G,"LPH_JIT",jit); rawset(G,"LPH_JIT_MAX",jit)
    rawset(G,"LPH_NO_VIRTUALIZE",novirt); rawset(G,"LPH_NO_UPVALUES",noupv)
    rawset(G,"LPH_CRASH",crash)
end

local LoadStart = os.clock()
local ok, val = pcall(function() return loadstring(game:HttpGet("https://raw.githubusercontent.com/k7gi/poopo/refs/heads/main/thegoat.lua"))() end)
if not ok or val ~= "ImKindaGay" then return end

repeat task.wait() until game:IsLoaded()
local Player = game:GetService("Players").LocalPlayer
if not Player.Character then Player.CharacterAdded:Wait() end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")
local RPC = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("RPC")
local PlayerGui = Player:WaitForChild("PlayerGui")
local Character = Player.Character
local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
local Random = Random.new()

local function GetHumanoid() local c=Player.Character return c and c:FindFirstChildOfClass("Humanoid") end
local function EquipTool(t) local h=GetHumanoid() if h and t then h:EquipTool(t) end end
local function UnequipTools() local h=GetHumanoid() if h then h:UnequipTools() end end

if getgenv().AutoRejoinerEnabled then
    task.spawn(function()
        local IntroUI = PlayerGui:WaitForChild("IntroUI", 30) if not IntroUI then return end
        local PlayButton = IntroUI:FindFirstChild("SurfaceGui") and IntroUI.SurfaceGui:FindFirstChild("Frame") and IntroUI.SurfaceGui.Frame:FindFirstChild("Play")
        if not PlayButton then return end
        task.wait(15)
        repeat pcall(function() getconnections(PlayButton.MouseButton1Click)[1]:Fire() end) task.wait(0.25)
        until not PlayerGui:FindFirstChild("IntroUI")
    end)
end

loadstring(game:HttpGet("https://pastefy.app/jTuFzdnC/raw"))()
repeat task.wait() until HyphonReady == true
local Library = loadstring(game:HttpGet("https://pastefy.app/LtJ06OXK/raw"))()
Library.MenuKeybind = nil
local Configuration = {
    Main_Settings = {Autofarming=false, ["Auto Rob Casino"]=true, ["Auto Anti Death"]=true, ["Auto Rejoiner"]=true, ["Performance Saver"]=false},
    Statistics = {["Times Rejoined"]=0, Runtime=0, ["Cash Made"]=0, ["Casino Robbed"]=0, ["Chips Fed"]=0, ["Cards Swiped"]=0, ["Marshmallows Sold"]=0},
    Goal_Settings = {Enabled=false, ["Target Amount"]=250000},
    Webhook_Settings = {["Send Webhooks"]=false, ["Webhook Intervals"]=5, ["Webhook Url"]=""},
    State = {Status="Idle", BikeSitting=false, BikeSpawned=false, IsHealing=false, Apartment=nil},
}

local Locations = {
    SafeZone=Vector3.new(-478.84,24,389.2), HotChipsMan=Vector3.new(-41,3,-25), FakeID=Vector3.new(214.96,1.857,-332.33),
    BuyMarsh=Vector3.new(512.82,4,595.58), BuyPotato=Vector3.new(-759.92,-0.025,-195.87),
    ApplyForCard=Vector3.new(-49.21,4,-310.81), CollectCard=Vector3.new(-39.09,5.392,-329.7),
    SkiMask=Vector3.new(-366.98,0.528,-320.63), Healing=Vector3.new(-769,6,654),
    Clipboard=Vector3.new(-479.23,5.342,-433.27), PotatoCutter=Vector3.new(-456.32,1.87,-466.84),
    PlasticBagLab=Vector3.new(-456.28,1.654,-472.67), FlourBowl=Vector3.new(-494.64,1.579,-518.58),
}
local Labatory = workspace.Map.Locations["The Laboratory"]
local Stove, CookPrompt, StoveTimer, AvailablePot, PotPrompt, PotTimer

for _, v in pairs(getgc(true)) do
    if typeof(v)=="table" and typeof(rawget(v,"Homeless"))=="table" and rawget(v.Homeless,"MaxDistance") then
        v.Homeless.MaxDistance = 9e9
    end
end

local function GetCommaValue(n) local s=tostring(math.floor(n)) while true do local r,c=s:gsub("^(-?%d+)(%d%d%d)","%1,%2") s=r if c==0 then break end end return s end
local function FormatRuntime(s) return string.format("%02d:%02d:%02d",math.floor(s/3600),math.floor((s%3600)/60),s%60) end
local function GetCurrentCash() local n=GetCurrentCashAmount() return n>0 and "$"..GetCommaValue(n) or "N/A" end
local function GetCurrentCashAmount() local ok,n=pcall(function() return tonumber((PlayerGui.Main.Money.Amount.Text:gsub("%D+",""))) or 0 end) return (ok and n) or 0 end
local function GetCharName() local ok,r=pcall(function() return Player.Character.Head:WaitForChild("NameTag",5).MainFrame.NameLabel.Text end) return (ok and r) or "N/A" end
local function GetETA()
    if not Configuration.Goal_Settings.Enabled then return "N/A" end
    local rt, cm = Configuration.Statistics.Runtime, Configuration.Statistics["Cash Made"]
    if rt<=0 or cm<=0 then return "N/A" end
    local rem = Configuration.Goal_Settings["Target Amount"] - GetCurrentCashAmount()
    if rem<=0 then return "Goal Reached" end
    return FormatRuntime(math.floor(rem/(cm/rt)))
end

local function WaitForReady() repeat task.wait() until Configuration.Main_Settings.Autofarming end

local function DoRejoin()
    if not Configuration.Main_Settings["Auto Rejoiner"] then return end
    Configuration.Main_Settings.Autofarming = false
    Configuration.Statistics["Times Rejoined"] = Configuration.Statistics["Times Rejoined"] + 1
    pcall(function() queue_on_teleport([[queue_on_teleport("task.wait(15)\ngetgenv().AutoRejoinerEnabled=true\nloadstring(game:HttpGet('https://pastefy.app/TkULlr1E/raw'))()")]]) end)
    TeleportService:Teleport(10179538382)
end

local function ScavengeInventory()
    UnequipTools()
    local bp = Player:WaitForChild("Backpack")
    local p,f,w,g,sb = 0,0,0,0,0
    for _,o in next, bp:GetChildren() do
        if o.Name=="Potato" then p=p+1 elseif o.Name=="Flour" then f=f+1 elseif o.Name=="Water" then w=w+1
        elseif o.Name=="Gelatin" then g=g+1 elseif o.Name=="Sugar Block Bag" then sb=sb+1 end
    end
    return p,f,w,g,sb
end

local function FindAvailableApartments()
    local avail, owned = {}, {}
    local apts = {"WH1","BH3","BH2","BH4","BH1","LT1"}
    local casino = {"Home 1","Home 2","Home 3","Home 4"}
    for _,o in next, workspace:WaitForChild("Map").APTS:GetChildren() do
        if o:IsA("Model") and (table.find(apts,tostring(o)) or table.find(casino,tostring(o))) then
            local b = o:FindFirstChild("Board",true)
            if b then
                local txt = b.name.SurfaceGui.TextLabel.Text
                if txt=="VACANT" then table.insert(avail,o) elseif txt==Player.Name then table.insert(owned,o) end
            end
        end
    end
    return #owned>=1 and owned or avail, #owned>=1 and "Owned" or "Not Owned"
end

local function FindAvailableATMs()
    for _,atm in next, workspace:WaitForChild("Map").ATMS:GetChildren() do
        if atm:FindFirstChild("ATMScreen").Transparency==0 then return atm end
    end
end

local function FindAvailableHomeless()
    local avail={}
    for _,o in next, workspace.Folders.HomelessPeople:GetChildren() do
        if o:IsA("Model") then
            local leg = o:FindFirstChild("RightLowerLeg")
            if leg and math.floor(leg.Rotation.X)==90 then table.insert(avail,o) end
        end
    end
    return avail
end
local function SpawnAndSitOnBike()
    local name = string.format("%s's Car", Player.Name)
    local exist = Workspace:FindFirstChild(name)
    if exist and exist:FindFirstChild("DriveSeat") and exist.DriveSeat.Occupant then
        Configuration.State.Status = "[ BIKE ] : Already on bike"
        Configuration.State.BikeSitting = true; Configuration.State.BikeSpawned = true
        return true
    end
    Configuration.State.Status = "[ BIKE ] : Spawning bike..."
    local bike = Workspace:FindFirstChild(name)
    if not bike then
        RPC:FireServer(buffer.fromstring("\001"), "Spawn", "DirtBike")
        local t=os.clock() repeat task.wait(0.1) until Workspace:FindFirstChild(name) or os.clock()-t>4
        bike = Workspace:FindFirstChild(name)
    end
    if not bike then Configuration.State.Status="[ BIKE ] : Bike not found!" return false end
    local seat = bike:WaitForChild("DriveSeat")
    UnequipTools()
    Configuration.State.RespawnPending = true
    HumanoidRootPart.CFrame = CFrame.new(67^2, 10^10, 67^2)
    Player.CharacterAdded:Wait()
    Character = Player.Character; HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
    local target = seat.CFrame * CFrame.new(3,1,0)
    task.wait(2)
    for _=1,5 do HumanoidRootPart.CFrame = target task.wait(0.05) end
    task.wait(2.5)
    if (HumanoidRootPart.Position - bike:FindFirstChildWhichIsA("Part",true).Position).Magnitude > 25 then
        Configuration.State.RespawnPending = false
        Configuration.State.Status = "[ BIKE ] : Failed to teleport!"
        return false
    end
    local prompt = seat:FindFirstChildWhichIsA("ProximityPrompt",true)
    if not prompt then local att=seat:FindFirstChild("Attachment") if att then prompt=att:FindFirstChild("ProximityPrompt") end end
    if prompt then prompt.HoldDuration=0; prompt.RequiresLineOfSight=false; prompt.MaxActivationDistance=9e9; fireproximityprompt(prompt) end
    task.wait(1)
    Configuration.State.RespawnPending = false
    Configuration.State.Status = "[ BIKE ] : Sitting!"
    Configuration.State.BikeSitting = true; Configuration.State.BikeSpawned = true
    return true
end

local function DirtBikeTeleport(pos)
    local c=Player.Character if not c then return false end
    local h=c:FindFirstChild("Humanoid") if not h then return false end
    if not h.SeatPart then
        Configuration.State.Status="[ BIKE ] : Re-sitting..."
        if not SpawnAndSitOnBike() then return false end
        task.wait(0.3)
    end
    local seat = h.SeatPart if not seat or seat.Name~="DriveSeat" then return false end
    local vehicle = seat.Parent if not vehicle then return false end
    vehicle:PivotTo(CFrame.new(pos))
    for _,o in pairs(vehicle:GetDescendants()) do if o:IsA("BasePart") then o.Anchored=false end end
    task.wait(0.51)
    for _,o in pairs(vehicle:GetDescendants()) do if o:IsA("BasePart") then o.Anchored=true end end
    return true
end

local function StartMarshmallowFarm()
    WaitForReady()
    Configuration.State.Status = "[ APARTMENTS ] : Finding..."
    local apts, own = FindAvailableApartments()
    if #apts==0 then Configuration.State.Status="[ APARTMENTS ] : None." return false end
    local apt = own=="Owned" and apts[1] or apts[Random:NextInteger(1,#apts)]
    local isHome = tostring(apt):match("Home")
    Configuration.State.Apartment = isHome and workspace.Map.Locations.Apartments:FindFirstChild(tostring(apt)) or workspace.Map.Houses:FindFirstChild(tostring(apt))
    if own=="Not Owned" then
        local board = apt:FindFirstChild("Board",true)
        local prompt = board.backboard.ProximityPrompt
        prompt.MaxActivationDistance = 9e9
        WaitForReady()
        DirtBikeTeleport(board.backboard.Position)
        Configuration.State.Status = "[ APARTMENTS ] : Buying..."
        fireproximityprompt(prompt)
        task.wait(2)
        if board.name.SurfaceGui.TextLabel.Text ~= tostring(Player) then return StartMarshmallowFarm() end
    end
    local lock = apt.Door.DoorLock
    local knob = apt.Door.Interact.Attachment.ProximityPrompt
    if math.abs(lock.Part.Rotation.Y) > 5 and math.abs(lock.Part.Rotation.Y - 90) > 5 then
        WaitForReady()
        knob.MaxActivationDistance = 9e9
        DirtBikeTeleport(lock.Part.Position)
        Configuration.State.Status = "[ APARTMENTS ] : Closing door."
        task.wait(0.5)
        local tries=0
        repeat fireproximityprompt(knob); task.wait(1); tries=tries+1 until math.abs(lock.Part.Rotation.Y)<5 or tries>=10
        task.wait(0.5)
    end
    if lock.Part.Rotation.X ~= 90 then
        WaitForReady()
        local lp = lock.Part.ProximityPrompt; lp.MaxActivationDistance=9e9
        DirtBikeTeleport(lock.Part.Position)
        Configuration.State.Status = "[ APARTMENTS ] : Locking."
        task.wait(0.5)
        local tries=0
        repeat fireproximityprompt(lp); task.wait(0.5); tries=tries+1 until lock.Part.Rotation.X==90 or tries>=10
        if lock.Part.Rotation.X ~= 90 then return StartMarshmallowFarm() end
    end
    Configuration.State.Status = "[ APARTMENTS ] : Secured."
    return true
end

local function PurchaseMarshmallowIngredients()
    WaitForReady()
    local _,_,w,g,sb = ScavengeInventory()
    if w>=1 and g>=1 and sb>=1 then return true end
    local mr = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("StorePurchase")
    DirtBikeTeleport(Locations.BuyMarsh)
    Configuration.State.Status = "[ MARSHMALLOW ] : Buying ingredients."
    task.wait(0.5)
    if w<1 then mr:FireServer("Water") task.wait(0.5) end
    if g<1 then mr:FireServer("Gelatin") task.wait(0.5) end
    if sb<1 then mr:FireServer("Sugar Block Bag") task.wait(0.5) end
    return true
end

local function PourWater()
    WaitForReady()
    local apt = Configuration.State.Apartment
    Stove = tostring(apt):match("Home") and apt:FindFirstChild("Cooking Pot") or apt:WaitForChild("Interior"):FindFirstChild("Cooking Pot")
    CookPrompt = Stove:FindFirstChild("Attachment").ProximityPrompt
    StoveTimer = Stove:FindFirstChild("Timer").TextLabel
    DirtBikeTeleport(Stove.Position)
    Configuration.State.Status = "[ MARSHMALLOW ] : Pouring water."
    local safety=0
    repeat
        WaitForReady()
        EquipTool(Player:WaitForChild("Backpack"):FindFirstChild("Water"))
        DirtBikeTeleport(Stove.Position)
        fireproximityprompt(CookPrompt)
        task.wait(1); UnequipTools(); safety=safety+1
    until not Player:WaitForChild("Backpack"):FindFirstChild("Water") or PlayerGui:WaitForChild("Main").BasicNotification.TextTransparency==0 or safety>=10
    if PlayerGui:WaitForChild("Main").BasicNotification.Text == "You do not have permission to cook in this apartment." then return false end
    return true
end

local function AddSugarAndGelatin()
    WaitForReady()
    Configuration.State.Status = "[ MARSHMALLOW ] : Adding sugar."
    local safety=0
    repeat
        WaitForReady()
        EquipTool(Player:WaitForChild("Backpack"):FindFirstChild("Sugar Block Bag"))

        DirtBikeTeleport(Stove.Position); fireproximityprompt(CookPrompt); task.wait(1); UnequipTools(); safety=safety+1
    until not Player:WaitForChild("Backpack"):FindFirstChild("Sugar Block Bag") or Player:WaitForChild("Backpack"):FindFirstChild("Empty Bag") or safety>=5
    Configuration.State.Status = "[ MARSHMALLOW ] : Adding gelatin."
    safety=0
    repeat
        WaitForReady()
        EquipTool(Player:WaitForChild("Backpack"):FindFirstChild("Gelatin"))
        DirtBikeTeleport(Stove.Position); fireproximityprompt(CookPrompt); task.wait(1); UnequipTools(); safety=safety+1
    until not Player:WaitForChild("Backpack"):FindFirstChild("Gelatin") or PlayerGui:WaitForChild("Main").TaskUpdate.TextLabel.Text:match("Let") or safety>=5
end
local function BagMarshmallowAndSell()
    WaitForReady()
    Configuration.State.Status = "[ WAITING ] : Marshmallow..."
    DirtBikeTeleport(Locations.SafeZone)
    repeat task.wait() until StoveTimer and StoveTimer.Text=="0"
    DirtBikeTeleport(Stove.Position)
    Configuration.State.Status = "[ MARSHMALLOW ] : Bagging."
    repeat
        EquipTool(Player:WaitForChild("Backpack"):FindFirstChild("Empty Bag"))
        task.wait(0.5); fireproximityprompt(CookPrompt); task.wait(0.5); UnequipTools(); task.wait(0.25)
    until Player:WaitForChild("Backpack"):FindFirstChild("Small Marshmallow Bag") or Player:WaitForChild("Backpack"):FindFirstChild("Medium Marshmallow Bag") or Player:WaitForChild("Backpack"):FindFirstChild("Large Marshmallow Bag")
    repeat WaitForReady() DirtBikeTeleport(Locations.BuyMarsh) task.wait(0.05) until workspace:WaitForChild("Folders").NPCs:FindFirstChild("Lamont Bell")
    Configuration.State.Status = "[ MARSHMALLOW ] : Selling."
    local bell = workspace:WaitForChild("Folders").NPCs:FindFirstChild("Lamont Bell")
    local prompt = bell.UpperTorso.ProximityPrompt
    UnequipTools()
    for _,o in next, Player:WaitForChild("Backpack"):GetChildren() do
        if tostring(o):find("Marshmallow") then
            WaitForReady()
            DirtBikeTeleport(Locations.BuyMarsh)
            EquipTool(Player:WaitForChild("Backpack"):FindFirstChild(tostring(o)))
            task.wait(0.5); fireproximityprompt(prompt); task.wait(0.5)
        end
    end
    Configuration.Statistics["Marshmallows Sold"] = Configuration.Statistics["Marshmallows Sold"] + 1
end

local function BuySkiMask()
    WaitForReady()
    local cc = Player.Character if not cc then return end
    if cc:FindFirstChild("White Ski Mask") then return end
    if not Player:WaitForChild("Backpack"):FindFirstChild("White Ski Mask") then
        Configuration.State.Status = "[ SETUP ] : Buying ski mask."
        local sr = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("StorePurchase")
        DirtBikeTeleport(Locations.SkiMask); task.wait(0.5)
        repeat sr:FireServer("White Ski Mask"); task.wait(0.5) until Player:WaitForChild("Backpack"):FindFirstChild("White Ski Mask")
    end
    EquipTool(Player:WaitForChild("Backpack"):FindFirstChild("White Ski Mask"))
    task.wait(0.05)
    RPC:FireServer(buffer.fromstring("\005"), Player.Character:WaitForChild("White Ski Mask"))
    task.wait(0.05); UnequipTools()
end

local function PurchasePotatoIngredients()
    WaitForReady()
    local p,f = ScavengeInventory()
    if p>=1 and f>=1 then return true end
    local pr = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("StorePurchase")
    Configuration.State.Status = "[ POTATO CHIPS ] : Buying ingredients."
    DirtBikeTeleport(Locations.BuyPotato); task.wait(0.5)
    if f<1 then pr:FireServer("Flour") task.wait(0.5) end
    if p<1 then pr:FireServer("Potato") task.wait(0.5) end
    return true
end

local function StartPotatoJob()
    WaitForReady()
    local clip = Labatory.Prompts.Clipboard
    local prompt = clip.ProximityPrompt; prompt.MaxActivationDistance=9e9
    DirtBikeTeleport(Locations.Clipboard)
    Configuration.State.Status = "[ POTATO CHIPS ] : Claiming task."
    task.wait(0.5)
    local tries=0
    repeat
        WaitForReady(); DirtBikeTeleport(Locations.Clipboard); task.wait(0.25)
        fireproximityprompt(prompt); task.wait(0.5); tries=tries+1
    until PlayerGui:WaitForChild("Main").TaskUpdate.TextLabel.Text:match("Task:") or PlayerGui:WaitForChild("Main").BasicNotification.Text=="You have already began your task."
end

local function CutPotato()
    WaitForReady()
    local cutter = Labatory["Cutting Boards"]:FindFirstChild("Potato Cutter").Model.Union
    local prompt = cutter.Attachment.ProximityPrompt; prompt.MaxActivationDistance=9e9
    Configuration.State.Status = "[ POTATO CHIPS ] : Cutting."
    local safety=0
    repeat
        WaitForReady()
        DirtBikeTeleport(Locations.PotatoCutter)
        EquipTool(Player:WaitForChild("Backpack"):FindFirstChild("Potato"))
        task.wait(0.25); fireproximityprompt(prompt); task.wait(0.5); UnequipTools(); task.wait(0.25)
        local notif = PlayerGui:WaitForChild("Main").BasicNotification.Text
        safety=safety+1
    until not Player:WaitForChild("Backpack"):FindFirstChild("Potato") or notif=="You are at the wrong step." or safety>=20
end

local function BagPotato()
    WaitForReady()
    local bag = Labatory.Prompts["Plastic Bag"]
    local prompt = bag.Attachment.ProximityPrompt; prompt.MaxActivationDistance=9e9
    Configuration.State.Status = "[ POTATO CHIPS ] : Bagging."
    if Player:WaitForChild("Backpack"):FindFirstChild("Potato") then return end
    local safety=0
    repeat
        WaitForReady()
        DirtBikeTeleport(Locations.PlasticBagLab)
        task.wait(0.25); fireproximityprompt(prompt); task.wait(0.5); safety=safety+1
        if safety>=15 then break end
    until PlayerGui:WaitForChild("Main").TaskUpdate.TextLabel.Text:match("Head")
end

local function MixFlourAndPotato()
    WaitForReady()
    local bowl = Labatory.Bowls:FindFirstChildOfClass("UnionOperation")
    local prompt = bowl.ProximityPrompt; prompt.MaxActivationDistance=9e9
    Configuration.State.Status = "[ POTATO CHIPS ] : Mixing."
    local safety=0
    repeat
        WaitForReady()
        DirtBikeTeleport(Locations.FlourBowl)
        task.wait(0.25)
        EquipTool(Player:WaitForChild("Backpack"):FindFirstChild("Flour"))
        task.wait(0.25); fireproximityprompt(prompt); task.wait(0.5); UnequipTools(); safety=safety+1
        if safety>=15 then break end
    until not Player:WaitForChild("Backpack"):FindFirstChild("Flour") or safety>=15
    task.wait(3.5)
end

local function CookPotatoChips()
    WaitForReady()
    Configuration.State.Status = "[ POTATO CHIPS ] : Starting cook."
    AvailablePot = nil
    for _,o in next, Labatory.Pots:GetChildren() do
        if AvailablePot then break end
        if o:IsA("UnionOperation") then
            local safety=0
            repeat
                WaitForReady(); DirtBikeTeleport(o.Position); fireproximityprompt(o.ProximityPrompt); task.wait(0.05); safety=safety+1
            until PlayerGui:WaitForChild("Main").BasicNotification.TextTransparency==0 or safety>=120
            local notif = PlayerGui:WaitForChild("Main").BasicNotification.Text
            if notif=="This pot is in use." then
                repeat task.wait() until PlayerGui:WaitForChild("Main").BasicNotification.TextTransparency==1
            elseif notif=="You have 120 seconds to retrieve your product out of the pot when its done." then
                AvailablePot = o; PotTimer = o.Timer.TextLabel; PotPrompt = o.ProximityPrompt
            end
        end
    end
    return AvailablePot ~= nil
end

local function ClaimPotatoChipsAndSell()
    WaitForReady()
    Configuration.State.Status = "[ WAITING ] : Potato chips..."
    DirtBikeTeleport(Locations.SafeZone)
    repeat task.wait() until PotTimer and PotTimer.Text=="0"
    Configuration.State.Status = "[ POTATO CHIPS ] : Claiming."
    repeat
        WaitForReady(); DirtBikeTeleport(AvailablePot.Position); fireproximityprompt(PotPrompt); task.wait(0.5)
    until Player:WaitForChild("Backpack"):FindFirstChild("Potato Chips")
    Configuration.State.Status = "[ POTATO CHIPS ] : Converting."
    repeat WaitForReady() DirtBikeTeleport(Locations.HotChipsMan) task.wait(0.05) until workspace:WaitForChild("Folders").NPCs:FindFirstChild("Poor Guy")
    local poor = workspace:WaitForChild("Folders").NPCs:FindFirstChild("Poor Guy")
    local pp = poor.UpperTorso.ProximityPrompt
    repeat
        WaitForReady(); DirtBikeTeleport(Locations.HotChipsMan); fireproximityprompt(pp); UnequipTools(); task.wait(0.05)
    until Player:WaitForChild("Backpack"):FindFirstChild("Hot Chips")
    task.wait(3)
    Configuration.State.Status = "[ POTATO CHIPS ] : Giving to homeless."
    local homeless = FindAvailableHomeless()
    if #homeless==0 then return false end
    for _,h in next, homeless do
        if not Player:WaitForChild("Backpack"):FindFirstChild("Hot Chips") then break end
        local name = tostring(h)
        repeat WaitForReady() DirtBikeTeleport(h:FindFirstChild("UpperTorso").Position) task.wait(0.05) until workspace:WaitForChild("Folders").HomelessPeople:FindFirstChild(name)
        local hh = workspace:WaitForChild("Folders").HomelessPeople:FindFirstChild(name)
        local ut = hh:FindFirstChild("UpperTorso")
        EquipTool(Player:WaitForChild("Backpack"):FindFirstChild("Hot Chips"))
        task.wait(0.25); fireproximityprompt(ut.ProximityPrompt); task.wait(0.5); UnequipTools()
    end
    Configuration.Statistics["Chips Fed"] = Configuration.Statistics["Chips Fed"] + 1
    return true
end
local function PurchaseFakeID()
    WaitForReady()
    Configuration.State.Status = "[ CARDS ] : Buying fake ID."
    repeat WaitForReady() DirtBikeTeleport(Locations.FakeID) task.wait(0.05) until workspace:WaitForChild("Folders").NPCs:FindFirstChild("FakeIDSeller")
    local seller = workspace:WaitForChild("Folders").NPCs:FindFirstChild("FakeIDSeller")
    local prompt = seller.UpperTorso.Attachment.ProximityPrompt
    repeat
        WaitForReady()
        repeat DirtBikeTeleport(Locations.FakeID) task.wait(0.05) until workspace:WaitForChild("Folders").NPCs:FindFirstChild("FakeIDSeller")
        seller = workspace:WaitForChild("Folders").NPCs:FindFirstChild("FakeIDSeller")
        prompt = seller.UpperTorso.Attachment.ProximityPrompt
        DirtBikeTeleport(Locations.FakeID)
        local mask = Player.Character and Player.Character:FindFirstChild("White Ski Mask") or Player:WaitForChild("Backpack"):FindFirstChild("White Ski Mask")
        if mask then EquipTool(mask); task.wait(0.25) end
        fireproximityprompt(prompt); UnequipTools(); task.wait(4)
    until Player:WaitForChild("Backpack"):FindFirstChild("Fake ID")
end

local function ApplyForCard()
    WaitForReady()
    Configuration.State.Status = "[ CARDS ] : Applying."
    repeat DirtBikeTeleport(Locations.ApplyForCard) task.wait(0.05) until workspace:WaitForChild("Folders").NPCs:FindFirstChild("Bank Teller")
    local teller = workspace:WaitForChild("Folders").NPCs:FindFirstChild("Bank Teller")
    local prompt = teller.UpperTorso.Attachment.ProximityPrompt
    local safety=0
    repeat
        WaitForReady()
        DirtBikeTeleport(Locations.ApplyForCard)
        EquipTool(Player:WaitForChild("Backpack"):FindFirstChild("Fake ID"))
        task.wait(0.5); fireproximityprompt(prompt); task.wait(0.5); UnequipTools(); safety=safety+1
    until not Player:WaitForChild("Backpack"):FindFirstChild("Fake ID") or safety>=15
    if safety>=15 then
        WaitForReady()
        Configuration.State.Status = "[ CARDS ] : Claiming early."
        local card = workspace:WaitForChild("CardPickup")
        local cp = card.Attachment.ProximityPrompt
        for _=1,10 do DirtBikeTeleport(card.Position); fireproximityprompt(cp); task.wait(0.05); UnequipTools() end
    end
end

local function ClaimAndUseCard()
    WaitForReady()
    local function HasCard() return (Player:FindFirstChild("Backpack") and Player.Backpack:FindFirstChild("Card")) or (Player.Character and Player.Character:FindFirstChild("Card")) end
    if HasCard() then
        Configuration.State.Status = "[ CARDS ] : Card owned, going to ATM."
    else
        Configuration.State.Status = "[ CARDS ] : Claiming card."
        local card = workspace:WaitForChild("CardPickup")
        local safety=0
        repeat
            WaitForReady()
            DirtBikeTeleport(card.Position)
            local cp = card.Attachment.ProximityPrompt
            fireproximityprompt(cp); task.wait(0.5); safety=safety+1
        until HasCard() or PlayerGui:WaitForChild("Main").BasicNotification.Text=="You are not on the wait list for a card." or safety>=10
        if not HasCard() and PlayerGui:WaitForChild("Main").BasicNotification.Text=="You are not on the wait list for a card." then return false end
    end
    repeat
        local atm = FindAvailableATMs()
        if not atm then return false end
        local ap = atm.Attachment.ProximityPrompt
        WaitForReady()
        Configuration.State.Status = "[ CARDS ] : Using ATM."
        local old = PlayerGui:FindFirstChild("ATM"); if old then old:Destroy() end
        repeat
            WaitForReady(); DirtBikeTeleport(atm.Position); fireproximityprompt(ap); task.wait(0.05)
        until PlayerGui:FindFirstChild("ATM")
        EquipTool(Player:FindFirstChild("Backpack"):FindFirstChild("Card"))
        task.wait(0.5)
        local btn = PlayerGui:WaitForChild("ATM").Frame.Swipe
        if btn then pcall(function() btn:Click() end) end
        Configuration.State.Status = "[ CARDS ] : Swiping."
        task.wait(0.5); UnequipTools()
    until not HasCard()
    Configuration.Statistics["Cards Swiped"] = Configuration.Statistics["Cards Swiped"] + 1
end

local AutofarmRunning = false
local function MainAutofarmController()
    if AutofarmRunning then return end
    AutofarmRunning = true
    while Configuration.Main_Settings.Autofarming do
        WaitForReady()
        BuySkiMask()
        local ok = StartMarshmallowFarm()
        if not ok then task.wait(5) continue end
        PurchaseMarshmallowIngredients()
        local wok = PourWater()
        if not wok then repeat StartMarshmallowFarm(); wok=PourWater() until wok end
        PurchasePotatoIngredients()
        StartPotatoJob(); CutPotato(); BagPotato(); MixFlourAndPotato(); CookPotatoChips()
        PurchaseFakeID(); ApplyForCard()
        AddSugarAndGelatin()
        DirtBikeTeleport(Locations.SafeZone)
        Configuration.State.Status = "[ WAITING ] : Card result."
        repeat task.wait() until PlayerGui:WaitForChild("Main").BasicNotification.TextTransparency==0 or PlayerGui:WaitForChild("Main").TaskUpdate.TextLabel.Text:match("Bag")
        if PlayerGui:WaitForChild("Main").BasicNotification.Text:match("successful") then
            Configuration.State.Status = "[ WAITING ] : Card approved, 35s..."
            task.wait(35); ClaimAndUseCard()
        end
        BagMarshmallowAndSell(); ClaimPotatoChipsAndSell()
        AvailablePot=nil; PotPrompt=nil; PotTimer=nil; Stove=nil; CookPrompt=nil; StoveTimer=nil
    end
    AutofarmRunning = false
end
local function SendWebhook()
    if Configuration.Webhook_Settings["Webhook Url"] == "" then return end
    local payload = HttpService:JSONEncode({
        username="Autofarm Webhook",
        embeds={{title="Autofarm Webhook : ||"..Player.Name.."|| : "..GetCharName(), color=65280,
        fields={
            {name="[ ♠️ ] Casino Robbed", value=GetCommaValue(Configuration.Statistics["Casino Robbed"]), inline=true},
            {name="[ 💳 ] Cards Swiped", value=GetCommaValue(Configuration.Statistics["Cards Swiped"]), inline=true},
            {name="[ 🍟 ] Chips Fed", value=GetCommaValue(Configuration.Statistics["Chips Fed"]), inline=true},
            {name="[ 🧂 ] Marshmallows Sold", value=GetCommaValue(Configuration.Statistics["Marshmallows Sold"]), inline=true},
            {name="[ 💰 ] Cash Made", value=GetCommaValue(Configuration.Statistics["Cash Made"]), inline=true},
            {name="[ 💸 ] Current Cash", value=GetCurrentCash(), inline=true},
            {name="[ 🕐 ] Runtime", value=FormatRuntime(Configuration.Statistics.Runtime), inline=true},
            {name="[ ⌛ ] ETA", value=GetETA(), inline=true},
            {name="[ 🔄️ ] Rejoined", value=GetCommaValue(Configuration.Statistics["Times Rejoined"]), inline=true},
        }}}
    })
    local req = syn and syn.request or http and http.request or request
    pcall(req, {Url=Configuration.Webhook_Settings["Webhook Url"], Method="POST", Headers={["Content-Type"]="application/json"}, Body=payload})
end

local Watermark = Library:Watermark("Multifarm")
local KeybindList = Library:KeybindList()
local Window = Library:Window({Name="Multifarm - South Bronx: The Trenches"})
local MainPage = Window:Page({Name="Main", Icon="rbxassetid://109841253338329", Columns=2})

local MainSettingsSection = MainPage:Section({Name="Main Settings", Side=1})
MainSettingsSection:Toggle({Name="Autofarming", Flag="Autofarming", Default=Configuration.Main_Settings.Autofarming,
    Callback=function(v)
        Configuration.Main_Settings.Autofarming = v
        if v then task.spawn(function() repeat task.wait(0.5) until SpawnAndSitOnBike() or not Configuration.Main_Settings.Autofarming if Configuration.Main_Settings.Autofarming then MainAutofarmController() end end) end
    end
})
MainSettingsSection:Toggle({Name="Auto Rob Casino", Flag="Auto Rob Casino", Default=Configuration.Main_Settings["Auto Rob Casino"], Callback=function(v) Configuration.Main_Settings["Auto Rob Casino"]=v end})
MainSettingsSection:Toggle({Name="Auto Anti Death", Flag="Auto Anti Death", Default=Configuration.Main_Settings["Auto Anti Death"], Callback=function(v) Configuration.Main_Settings["Auto Anti Death"]=v end})
MainSettingsSection:Toggle({Name="Auto Rejoiner", Flag="Auto Rejoiner", Default=Configuration.Main_Settings["Auto Rejoiner"], Callback=function(v) Configuration.Main_Settings["Auto Rejoiner"]=v end})
MainSettingsSection:Toggle({Name="Performance Saver", Flag="Performance Saver", Default=Configuration.Main_Settings["Performance Saver"],
    Callback=function(v) Configuration.Main_Settings["Performance Saver"]=v; pcall(function() setfpscap(v and 15 or 1000) end); pcall(function() RunService:Set3dRenderingEnabled(not v) end) end
})
local bikeBtn = MainSettingsSection:Button(); bikeBtn:Add("Purchase DirtBike ($35000)", function() RPC:FireServer(buffer.fromstring("\001"), "Purchase", "DirtBike") end)

local GoalSettingsSection = MainPage:Section({Name="Goal Settings", Side=1})
GoalSettingsSection:Label("Make target amount > kick client.")
GoalSettingsSection:Toggle({Name="Enabled", Flag="Goal Enabled", Default=Configuration.Goal_Settings.Enabled, Callback=function(v) Configuration.Goal_Settings.Enabled=v end})
local targetSlider = GoalSettingsSection:Slider({Name="Target Amount", Flag="Target Amount", Min=0, Max=1750000, Default=Configuration.Goal_Settings["Target Amount"], Decimals=1, Suffix=" dollars", Callback=function(v) Configuration.Goal_Settings["Target Amount"]=v end})
GoalSettingsSection:Textbox({Name="Target Amount", Flag="Target Amount Input", Default=tostring(Configuration.Goal_Settings["Target Amount"]), Placeholder="250000", Callback=function(v) local n=tonumber(v) if n then Configuration.Goal_Settings["Target Amount"]=n; targetSlider:Set(n) end end})

local StatisticsSection = MainPage:Section({Name="Statistics", Side=2})
local lblRejoin = StatisticsSection:Label("[🔄️] Times Rejoined: 0")
local lblRuntime = StatisticsSection:Label("[⏰] Runtime: 00:00:00")
local lblCash = StatisticsSection:Label("[💸] Cash Made: 0")
local lblCasino = StatisticsSection:Label("[♠️] Casino Robbed: 0")
local lblChips = StatisticsSection:Label("[🍟] Chips Fed: 0")
local lblCards = StatisticsSection:Label("[💳] Cards Swiped: 0")
local lblMarsh = StatisticsSection:Label("[🧂] Marshmallows Sold: 0")

local WebhookSettingsSection = MainPage:Section({Name="Webhook Settings", Side=2})
WebhookSettingsSection:Toggle({Name="Send Webhooks", Flag="Send Webhooks", Default=Configuration.Webhook_Settings["Send Webhooks"], Callback=function(v) Configuration.Webhook_Settings["Send Webhooks"]=v end})
WebhookSettingsSection:Slider({Name="Webhook Intervals", Flag="Webhook Intervals", Min=1, Max=10, Default=Configuration.Webhook_Settings["Webhook Intervals"], Decimals=1, Suffix="m", Callback=function(v) Configuration.Webhook_Settings["Webhook Intervals"]=v end})
WebhookSettingsSection:Textbox({Name="Webhook Url", Flag="Webhook Url", Default=Configuration.Webhook_Settings["Webhook Url"], Placeholder="...", Callback=function(v) Configuration.Webhook_Settings["Webhook Url"]=v end})
local webBtn = WebhookSettingsSection:Button(); webBtn:Add("Send Test Webhook", function() SendWebhook() end)

Library:CreateSettingsPage(Window, Watermark, KeybindList)
Library:Notification("Multifarm", string.format("Loaded in %.4fs.", os.clock()-LoadStart), 5)

if getgenv().AutoRejoinerEnabled then
    getgenv().AutoRejoinerEnabled = nil
    Configuration.Statistics["Times Rejoined"] = Configuration.Statistics["Times Rejoined"] + 1
    Configuration.Main_Settings.Autofarming = true
    task.spawn(function()
        repeat task.wait(0.5) until not PlayerGui:FindFirstChild("IntroUI")
        task.wait(2)
        repeat task.wait(0.5) until SpawnAndSitOnBike() or not Configuration.Main_Settings.Autofarming
        if Configuration.Main_Settings.Autofarming then MainAutofarmController() end
    end)
end

task.spawn(function()
    local lastCash, lastStatus, lastCashTime, lastStatusTime = 0, "", os.clock(), os.clock()
    task.wait(60); lastCash = GetCurrentCashAmount(); lastStatus = Configuration.State.Status
    while task.wait(30) do
        if not Configuration.Main_Settings.Autofarming then
            lastCashTime=os.clock(); lastStatusTime=os.clock(); lastCash=GetCurrentCashAmount(); lastStatus=Configuration.State.Status; continue
        end
        local now, curCash = os.clock(), GetCurrentCashAmount()
        if curCash ~= lastCash then lastCash=curCash; lastCashTime=now end
        if Configuration.State.Status ~= lastStatus then lastStatus=Configuration.State.Status; lastStatusTime=now end
        if (now-lastCashTime)>=300 or (now-lastStatusTime)>=300 then DoRejoin(); return end
    end
end)

local function ConnectDeathHandler(char)
    local hum = char:WaitForChild("Humanoid",5)
    if hum then hum.Died:Connect(function()
        if Configuration.State.RespawnPending then return end
        if Configuration.Main_Settings.Autofarming and Configuration.Main_Settings["Auto Rejoiner"] then task.wait(3); DoRejoin() end
    end) end
end
ConnectDeathHandler(Player.Character)
Player.CharacterAdded:Connect(ConnectDeathHandler)

task.spawn(function()
    local startTime, startCash = os.clock(), GetCurrentCashAmount()
    task.wait(2)
    while task.wait(1) do
        local el = math.floor(os.clock()-startTime)
        Configuration.Statistics.Runtime = el
        Configuration.Statistics["Cash Made"] = GetCurrentCashAmount() - startCash
        lblRejoin:SetText(string.format("[🔄️] Times Rejoined: %d", Configuration.Statistics["Times Rejoined"]))
        lblRuntime:SetText(string.format("[⏰] Runtime: %02d:%02d:%02d", math.floor(el/3600), math.floor((el%3600)/60), el%60))
        local cm = Configuration.Statistics["Cash Made"]
        lblCash:SetText("[💸] Cash Made: " .. (cm<0 and "-" or "") .. GetCommaValue(math.abs(cm)))
        lblCasino:SetText(string.format("[♠️] Casino Robbed: %d", Configuration.Statistics["Casino Robbed"]))
        lblChips:SetText(string.format("[🍟] Chips Fed: %d", Configuration.Statistics["Chips Fed"]))
        lblCards:SetText(string.format("[💳] Cards Swiped: %d", Configuration.Statistics["Cards Swiped"]))
        lblMarsh:SetText(string.format("[🧂] Marshmallows Sold: %d", Configuration.Statistics["Marshmallows Sold"]))
    end
end)

task.spawn(function()
    while true do
        task.wait(Configuration.Webhook_Settings["Webhook Intervals"] * 60)
        if Configuration.Webhook_Settings["Send Webhooks"] then SendWebhook() end
    end
end)

Player.Idled:Connect(function()
    if Configuration.Main_Settings.Autofarming then
        local vu = game:GetService("VirtualUser")
        pcall(function() vu:CaptureController(); vu:ClickButton2(Vector2.new()) end)
    end
end)
