-- ============================================================
-- UI ONLY FOR SILENT AIM
-- ============================================================

-- Pastikan library sudah ada (dari script utama)
if not library then
    error("Library tidak ditemukan! Pastikan script utama sudah dijalankan.")
end

-- Buat window baru atau gunakan yang sudah ada? Lebih baik buat window terpisah agar hanya silent aim.
local SilentWindow = library:window({
    name = "Silent",
    suffix = " Aim",
    gameInfo = "Silent Aim Only",
    size = UDim2.new(0, 500, 0, 400)
})

-- Buat tab
local SilentTab = SilentWindow:tab({
    name = "Silent Aim",
    icon = "rbxassetid://6034767608", -- ganti dengan icon sesuai keinginan
    tabs = {"General"} -- hanya satu tab
})

-- Ambil halaman pertama (karena hanya satu tab)
local page = SilentTab[1]  -- atau SilentTab.pages[1]

-- Buat kolom
local column = page:column({})

-- Section General
local generalSection = column:section({
    name = "General Settings",
    side = "left",
    size = 1,
    icon = "rbxassetid://6022668898",
    default = true
})

-- Toggle Enable
generalSection:toggle({
    name = "Enable Silent Aim",
    flag = "Silent_Enable",
    default = false,
    callback = function(state)
        -- Hubungkan ke fungsi pengaturan silent aim (misal: setSilentEnabled)
        if setSilentEnabled then setSilentEnabled(state) end
        -- Atau langsung ubah Config jika ada
        if Config and Config.Silent then Config.Silent.Enabled = state end
    end
})

-- Keybind untuk mengaktifkan targetting (hold/toggle)
generalSection:keybind({
    name = "Aim Key",
    flag = "Silent_Keybind",
    key = Enum.KeyCode.LeftAlt,
    mode = "Hold", -- atau "Toggle"
    default = false,
    callback = function(state)
        if setSilentTargetting then setSilentTargetting(state) end
        if Config and Config.Silent then Config.Silent.Targetting = state end
    end
})

-- Dropdown Target Parts (multi)
local bodyParts = {"Head", "UpperTorso", "LowerTorso", "HumanoidRootPart", "LeftUpperArm", "RightUpperArm", "LeftUpperLeg", "RightUpperLeg"}
generalSection:dropdown({
    name = "Target Parts",
    flag = "Silent_TargetParts",
    items = bodyParts,
    multi = true,
    default = {"Head"},
    callback = function(selected)
        if setSilentTargetParts then setSilentTargetParts(selected) end
        if Config and Config.Silent then Config.Silent.TargetPart = selected end
    end
})

-- Slider Max Distance
generalSection:slider({
    name = "Max Distance",
    flag = "Silent_MaxDistance",
    min = 0,
    max = 3000,
    default = 300,
    suffix = " studs",
    callback = function(val)
        if setSilentMaxDistance then setSilentMaxDistance(val) end
        if Config and Config.Silent then Config.Silent.MaxDistance = val end
    end
})

-- Slider Hit Chance
generalSection:slider({
    name = "Hit Chance",
    flag = "Silent_HitChance",
    min = 0,
    max = 100,
    default = 100,
    suffix = "%",
    callback = function(val)
        if setSilentHitChance then setSilentHitChance(val) end
        if Config and Config.Silent then Config.Silent.HitChance = val end
    end
})

-- Toggle Wall Check
generalSection:toggle({
    name = "Wall Check",
    flag = "Silent_WallCheck",
    default = false,
    callback = function(state)
        if setSilentWallCheck then setSilentWallCheck(state) end
        if Config and Config.Silent then Config.Silent.WallCheck = state end
    end
})

-- Toggle Wall Bang
generalSection:toggle({
    name = "Wall Bang (Penetration)",
    flag = "Silent_WallBang",
    default = false,
    callback = function(state)
        if setSilentWallBang then setSilentWallBang(state) end
        if Config and Config.Silent then Config.Silent.WallBang = state end
    end
})

-- Separator untuk FOV
generalSection:seperator({name = "Field of View"})

-- Toggle FOV Enable
generalSection:toggle({
    name = "Enable FOV",
    flag = "Silent_FOV_Enable",
    default = false,
    callback = function(state)
        if setSilentFOV then setSilentFOV(state) end
        if Config and Config.Silent then Config.Silent.UseFieldOfView = state end
    end
})

-- Toggle Draw FOV Circle
generalSection:toggle({
    name = "Draw FOV Circle",
    flag = "Silent_FOV_Draw",
    default = false,
    callback = function(state)
        if setSilentDrawFOV then setSilentDrawFOV(state) end
        if Config and Config.Silent then Config.Silent.DrawFieldOfView = state end
    end
})

-- Slider FOV Radius
generalSection:slider({
    name = "FOV Radius",
    flag = "Silent_FOV_Radius",
    min = 1,
    max = 500,
    default = 100,
    suffix = "°",
    callback = function(val)
        if setSilentFOVRadius then setSilentFOVRadius(val) end
        if Config and Config.Silent then Config.Silent.Radius = val end
    end
})

-- Slider FOV Sides
generalSection:slider({
    name = "FOV Sides",
    flag = "Silent_FOV_Sides",
    min = 3,
    max = 100,
    default = 100,
    suffix = " sides",
    callback = function(val)
        if setSilentFOVSides then setSilentFOVSides(val) end
        if Config and Config.Silent then Config.Silent.Sides = val end
    end
})

-- Colorpicker FOV Color
generalSection:colorpicker({
    name = "FOV Color",
    flag = "Silent_FOV_Color",
    color = Color3.new(1,1,1),
    alpha = 0.25,
    callback = function(color, alpha)
        if Config and Config.Silent then
            Config.Silent.FieldOfViewColor = color
            Config.Silent.FieldOfViewTransparency = 1 - alpha
        end
    end
})

-- Separator untuk Snapline
generalSection:seperator({name = "Snapline"})

-- Toggle Snapline
generalSection:toggle({
    name = "Enable Snapline",
    flag = "Silent_Snapline_Enable",
    default = false,
    callback = function(state)
        if setSilentSnapline then setSilentSnapline(state) end
        if Config and Config.Silent then Config.Silent.Snapline = state end
    end
})

-- Colorpicker Snapline Color
generalSection:colorpicker({
    name = "Snapline Color",
    flag = "Silent_Snapline_Color",
    color = Color3.new(1,1,1),
    alpha = 1,
    callback = function(color, alpha)
        if Config and Config.Silent then
            Config.Silent.SnaplineColor = color
        end
    end
})

-- Slider Snapline Thickness
generalSection:slider({
    name = "Snapline Thickness",
    flag = "Silent_Snapline_Thickness",
    min = 1,
    max = 5,
    default = 1,
    suffix = "px",
    callback = function(val)
        if setSilentSnaplineThickness then setSilentSnaplineThickness(val) end
        if Config and Config.Silent then Config.Silent.SnaplineThickness = val end
    end
})

-- Optional: Keybind untuk toggle silent aim secara cepat (bisa juga di keybind di atas sudah mencakup)
-- Kita sudah punya keybind untuk targetting, cukup.

print("Silent Aim UI loaded successfully!")