-- ============================================================
--  CALISTREETS – UI LENGKAP (HANYA AUTO FARM YANG BERFUNGSI)
--  Dibersihkan dari obfuscation dan kode sampah
-- ============================================================

-- Load Library Obsidian
local LibraryURL = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(LibraryURL .. "Library.lua"))()
loadstring(game:HttpGet(LibraryURL .. "addons/ThemeManager.lua"))()
loadstring(game:HttpGet(LibraryURL .. "addons/SaveManager.lua"))()

-- Service references
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Options & Toggles (untuk UI)
local Options = {}
local Toggles = {}

-- Buat Window utama
local Window = Library.CreateWindow({
    Title = "CaliStreets",
    Footer = "ByXeioa",
    Icon = 95816097006870,
    NotifySide = "Right",
    ShowCustomCursor = true
})

-- Tab definitions (semua tab seperti asli)
local Tabs = {
    Combat   = Window.AddTab("Combat", "swords"),
    Movement = Window.AddTab("Movement", "zap"),
    Farm     = Window.AddTab("Farm", "coins"),
    Shop     = Window.AddTab("Shop", "shopping-cart"),
    Visual   = Window.AddTab("Visual", "eye"),
    Misc     = Window.AddTab("Misc", "sliders"),
    ESP      = Window.AddTab("ESP", "scan"),
    UISettings = Window.AddTab("UI Settings", "settings")
}

-- ============================================================
--  TAB COMBAT (hanya UI, tidak ada fungsi)
-- ============================================================
local CombatMain = Tabs.Combat.AddLeftGroupbox("Aimbot Main")
local CombatSettings = Tabs.Combat.AddRightGroupbox("Aimbot Settings")
local HitboxGroup = Tabs.Combat.AddLeftGroupbox("Hitbox Expander")

CombatMain.AddToggle("EnableAimbot", { Text = "Enable Aimbot", Default = false })
CombatMain.AddDropdown("AimbotMode", {
    Values = {"Always", "Hold Right Click"},
    Default = 1,
    Multi = false,
    Text = "Targeting Mode (PC/Mobile)"
})
CombatMain.AddDropdown("AimPart", {
    Values = {"Head", "HumanoidRootPart"},
    Default = 1,
    Multi = false,
    Text = "Target Part"
})

CombatSettings.AddSlider("AimbotFOV", {
    Text = "FOV Radius",
    Default = 150,
    Min = 30,
    Max = 600,
    Rounding = 0
})
CombatSettings.AddSlider("AimbotSmoothness", {
    Text = "Smoothness",
    Default = 1,
    Min = 1,
    Max = 20,
    Rounding = 1
})
CombatSettings.AddToggle("ShowFOV", { Text = "Show FOV Circle", Default = true })
CombatSettings.AddToggle("AimbotWallCheck", { Text = "Wall Check", Default = true })
CombatSettings.AddToggle("AimbotFriendCheck", { Text = "Friend Check", Default = true })

HitboxGroup.AddToggle("EnableHitbox", { Text = "Enable Hitbox Expander", Default = false })
HitboxGroup.AddSlider("HitboxSize", {
    Text = "Hitbox Size",
    Default = 10,
    Min = 2,
    Max = 50,
    Rounding = 1
})
HitboxGroup.AddSlider("HitboxTransparency", {
    Text = "Hitbox Transparency",
    Default = 0.5,
    Min = 0,
    Max = 1,
    Rounding = 2
})
HitboxGroup.AddDropdown("HitboxPart", {
    Values = {"HumanoidRootPart", "Head"},
    Default = 1,
    Multi = false,
    Text = "Target Part"
})
HitboxGroup.AddToggle("HitboxFriendCheck", { Text = "Friend Check", Default = true })

-- ============================================================
--  TAB MOVEMENT (hanya UI)
-- ============================================================
local MovePlayer = Tabs.Movement.AddLeftGroupbox("Player Movement")
local MoveMods = Tabs.Movement.AddRightGroupbox("Movement Modifiers")

MovePlayer.AddToggle("InfStamina", { Text = "Infinite Stamina", Default = false })
MovePlayer.AddToggle("AntiJumpCooldown", { Text = "Anti Jump Cooldown", Default = false })

MoveMods.AddToggle("EnableSpeed", { Text = "Enable Custom WalkSpeed", Default = false })
MoveMods.AddSlider("WalkSpeedValue", {
    Text = "WalkSpeed",
    Default = 16,
    Min = 16,
    Max = 200,
    Rounding = 0
})
MoveMods.AddToggle("EnableJumpPower", { Text = "Enable Custom JumpPower", Default = false })
MoveMods.AddSlider("JumpPowerValue", {
    Text = "JumpPower",
    Default = 50,
    Min = 50,
    Max = 300,
    Rounding = 0
})
MoveMods.AddToggle("Noclip", { Text = "Noclip", Default = false })
MoveMods.AddToggle("InfiniteJump", { Text = "Infinite Jump", Default = false })

-- ============================================================
--  TAB FARM (SATU-SATUNYA FITUR YANG BERFUNGSI)
-- ============================================================
local FarmGroup = Tabs.Farm.AddLeftGroupbox("Auto Farm")

-- Toggle BoxFarm
local boxFarmEnabled = false
local farmCoroutine = nil
local originalSize = nil
local targetPartRef = nil

-- Fungsi Auto Farm
local function startFarm()
    while boxFarmEnabled do
        task.wait()  -- loop cepat

        local char = LocalPlayer.Character
        if not char then
            char = LocalPlayer.CharacterAdded:Wait()
        end

        local rootPart = char:FindFirstChild("HumanoidRootPart")
        if not rootPart then
            task.wait(0.5)
            goto continue
        end

        local gameStuff = Workspace:FindFirstChild("GameStuff")
        if not gameStuff then
            task.wait(0.5)
            goto continue
        end

        local jobs = gameStuff:FindFirstChild("Jobs")
        if not jobs then
            task.wait(0.5)
            goto continue
        end

        local boxJob = jobs:FindFirstChild("BoxJob")
        if not boxJob then
            task.wait(0.5)
            goto continue
        end

        local getJobPart = boxJob:FindFirstChild("GetJobPart")
        local targetPart = boxJob:FindFirstChild("TargetPart")

        if not getJobPart or not targetPart then
            task.wait(0.5)
            goto continue
        end

        -- Simpan ukuran asli jika belum
        if not originalSize then
            originalSize = targetPart.Size
            targetPartRef = targetPart
        end

        -- Perbesar TargetPart
        targetPart.Size = Vector3.new(999, 999, 999)

        -- Pindahkan pemain ke GetJobPart
        rootPart.CFrame = getJobPart.CFrame

        -- Aktifkan ProximityPrompt
        local prompt = getJobPart:FindFirstChildOfClass("ProximityPrompt")
        if prompt then
            fireproximityprompt(prompt)
        end

        ::continue::
    end

    -- Kembalikan ukuran saat dimatikan
    if targetPartRef and originalSize then
        targetPartRef.Size = originalSize
        targetPartRef = nil
        originalSize = nil
    end
end

-- Toggle BoxFarm
FarmGroup.AddToggle("BoxFarm", {
    Text = "BoxFarm",
    Tooltip = "Extremely OP - Inf Money (Infinite Money Method)",
    Default = false,
    Callback = function(value)
        boxFarmEnabled = value
        if boxFarmEnabled then
            if farmCoroutine then
                task.cancel(farmCoroutine)
            end
            farmCoroutine = task.spawn(startFarm)
        else
            if farmCoroutine then
                task.cancel(farmCoroutine)
                farmCoroutine = nil
            end
            -- Kembalikan ukuran jika ada
            if targetPartRef and originalSize then
                targetPartRef.Size = originalSize
                targetPartRef = nil
                originalSize = nil
            end
        end
    end
})

-- ============================================================
--  TAB SHOP (hanya UI)
-- ============================================================
local ShopGroup = Tabs.Shop.AddLeftGroupbox("Weapon Shop")
ShopGroup.AddDropdown("WeaponSelector", {
    Values = {"None"},  -- biar sederhana
    Default = 1,
    Multi = false,
    Text = "Select Weapon"
})
ShopGroup.AddButton({
    Text = "Buy Weapon",
    Func = function() end  -- dummy
})

-- ============================================================
--  TAB VISUAL (hanya UI)
-- ============================================================
local VisualWorld = Tabs.Visual.AddLeftGroupbox("World Visuals")
local VisualCamera = Tabs.Visual.AddRightGroupbox("Camera Visuals")

VisualCamera.AddToggle("EnableCustomFOV", { Text = "Enable Custom Camera FOV", Default = false })
VisualCamera.AddSlider("CameraFOVValue", {
    Text = "Camera FOV",
    Default = 70,
    Min = 60,
    Max = 120,
    Rounding = 0
})

VisualWorld.AddToggle("Fullbright", { Text = "Fullbright", Default = false })
VisualWorld.AddToggle("NoFog", { Text = "No Fog", Default = false })

-- ============================================================
--  TAB MISC (hanya UI)
-- ============================================================
local MiscGroup = Tabs.Misc.AddLeftGroupbox("Overhead Stats")
MiscGroup.AddInput("CustomNameInput", {
    Default = "",
    Numeric = false,
    Finished = false,
    Text = "Custom Name",
    Placeholder = "Enter Name..."
})
MiscGroup.AddInput("CustomLevelInput", {
    Default = "",
    Numeric = false,
    Finished = false,
    Text = "Custom Level",
    Placeholder = "Enter Level..."
})
MiscGroup.AddToggle("CustomOverheadStats", { Text = "Custom Overhead Stats", Default = false })

-- ============================================================
--  TAB ESP (hanya UI)
-- ============================================================
local ESPGroup = Tabs.ESP.AddLeftGroupbox("ESP Settings")
ESPGroup.AddToggle("EnableESP", { Text = "Enable ESP", Default = false })
ESPGroup.AddToggle("EspBox", { Text = "Show Box", Default = true })
ESPGroup.AddToggle("EspHealth", { Text = "Show Health Bar", Default = true })
ESPGroup.AddToggle("EspName", { Text = "Show Name", Default = true })
ESPGroup.AddToggle("EspDistance", { Text = "Show Distance", Default = true })
ESPGroup.AddToggle("FriendCheck", { Text = "Friend Check (Green Box)", Default = true })

-- ============================================================
--  TAB UI SETTINGS (sama seperti asli)
-- ============================================================
local UIGroup = Tabs.UISettings.AddLeftGroupbox("Menu", "wrench")

UIGroup.AddToggle("KeybindMenuOpen", {
    Default = Library.KeybindFrame.Visible,
    Text = "Open Keybind Menu",
    Callback = function(v)
        Library.KeybindFrame.Visible = v
    end
})

UIGroup.AddToggle("ShowCustomCursor", {
    Text = "Custom Cursor",
    Default = Library.ShowCustomCursor,
    Callback = function(v)
        Library.ShowCustomCursor = v
    end
})

UIGroup.AddDropdown("NotificationSide", {
    Values = {"Left", "Right"},
    Default = "Right",
    Text = "Notification Side",
    Callback = function(v)
        Library.SetNotifySide(v)
    end
})

UIGroup.AddDropdown("DPIDropdown", {
    Values = {"50%", "75%", "100%", "125%", "150%", "175%", "200%"},
    Default = "100%",
    Text = "DPI Scale",
    Callback = function(v)
        local num = tonumber(v:gsub("%%", ""))
        Library.SetDPIScale(num)
    end
})

UIGroup.AddSlider("UICornerSlider", {
    Text = "Corner Radius",
    Default = Library.CornerRadius,
    Min = 0,
    Max = 20,
    Rounding = 0,
    Callback = function(v)
        Window.SetCornerRadius(v)
    end
})

UIGroup.AddDivider()

local label = UIGroup.AddLabel("Menu bind")
label.AddKeyPicker("MenuKeybind", {
    Default = "RightShift",
    NoUI = true,
    Text = "Menu keybind"
})

UIGroup.AddButton("Unload", function()
    Library.Unload()
end)

-- Set keybind untuk membuka/tutup menu
Library.ToggleKeybind = Options.MenuKeybind

-- Setup ThemeManager dan SaveManager
local ThemeManager = loadstring(game:HttpGet(LibraryURL .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(LibraryURL .. "addons/SaveManager.lua"))()

ThemeManager.SetLibrary(Library)
SaveManager.SetLibrary(Library)

SaveManager.IgnoreThemeSettings()
SaveManager.SetIgnoreIndexes({"MenuKeybind"})
ThemeManager.SetFolder("CaliStreetsScript")
SaveManager.SetFolder("CaliStreetsScript/main")
SaveManager.BuildConfigSection(Tabs.UISettings)
ThemeManager.ApplyToTab(Tabs.UISettings)
SaveManager.LoadAutoloadConfig()

print("✅ UI CaliStreets siap! Hanya Auto Farm yang berfungsi.")