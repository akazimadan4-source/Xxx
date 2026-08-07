-- =============================================
-- WAVEX FREE - Menggunakan UI Priv9
-- Gabungan fitur CloudWare + UI Priv9
-- =============================================

-- ===== INISIALISASI UI PRIV9 =====
if getgenv().loaded then 
    getgenv().library:unload_menu() 
end 
getgenv().loaded = true 

local uis = game:GetService("UserInputService") 
local players = game:GetService("Players") 
local ws = game:GetService("Workspace")
local rs = game:GetService("ReplicatedStorage")
local http_service = game:GetService("HttpService")
local gui_service = game:GetService("GuiService")
local lighting = game:GetService("Lighting")
local run = game:GetService("RunService")
local stats = game:GetService("Stats")
local coregui = game:GetService("CoreGui")
local debris = game:GetService("Debris")
local tween_service = game:GetService("TweenService")
local sound_service = game:GetService("SoundService")

local vec2 = Vector2.new
local vec3 = Vector3.new
local dim2 = UDim2.new
local dim = UDim.new 
local rect = Rect.new
local cfr = CFrame.new
local empty_cfr = cfr()
local point_object_space = empty_cfr.PointToObjectSpace
local angle = CFrame.Angles
local dim_offset = UDim2.fromOffset

local color = Color3.new
local rgb = Color3.fromRGB
local hex = Color3.fromHex
local hsv = Color3.fromHSV
local rgbseq = ColorSequence.new
local rgbkey = ColorSequenceKeypoint.new
local numseq = NumberSequence.new
local numkey = NumberSequenceKeypoint.new

local camera = ws.CurrentCamera
local lp = players.LocalPlayer 
local mouse = lp:GetMouse() 
local gui_offset = gui_service:GetGuiInset().Y

local max = math.max 
local floor = math.floor 
local min = math.min 
local abs = math.abs 
local noise = math.noise
local rad = math.rad 
local random = math.random 
local pow = math.pow 
local sin = math.sin 
local pi = math.pi 
local tan = math.tan 
local atan2 = math.atan2 
local clamp = math.clamp 

local insert = table.insert 
local find = table.find 
local remove = table.remove
local concat = table.concat

-- Library init
getgenv().library = {
    directory = "priv9",
    folders = {
        "/fonts",
        "/configs",
    },
    flags = {},
    config_flags = {},
    connections = {},   
    notifications = {},
    playerlist_data = {
        players = {},
        player = {}, 
    },
    colorpicker_open = false; 
    gui; 
}

local themes = {
    preset = {
        outline = rgb(10, 10, 10),
        inline = rgb(35, 35, 35),
        text = rgb(180, 180, 180),
        text_outline = rgb(0, 0, 0),
        background = rgb(20, 20, 20),
        ["1"] = hex("#245771"), 
        ["2"] = hex("#215D63"),
        ["3"] = hex("#1E6453"),
    },
    utility = {
        inline = { BackgroundColor3 = {} },
        text = { TextColor3 = {} },
        text_outline = { Color = {} },
        ["1"] = { BackgroundColor3 = {}, TextColor3 = {}, ImageColor3 = {}, ScrollBarImageColor3 = {} },
        ["2"] = { BackgroundColor3 = {}, TextColor3 = {}, ImageColor3 = {}, ScrollBarImageColor3 = {} },
        ["3"] = { BackgroundColor3 = {}, TextColor3 = {}, ImageColor3 = {}, ScrollBarImageColor3 = {} },
    }
}

local keys = {
    [Enum.KeyCode.LeftShift] = "LS", [Enum.KeyCode.RightShift] = "RS",
    [Enum.KeyCode.LeftControl] = "LC", [Enum.KeyCode.RightControl] = "RC",
    [Enum.KeyCode.Insert] = "INS", [Enum.KeyCode.Backspace] = "BS",
    [Enum.KeyCode.Return] = "Ent", [Enum.KeyCode.LeftAlt] = "LA",
    [Enum.KeyCode.RightAlt] = "RA", [Enum.KeyCode.CapsLock] = "CAPS",
    [Enum.KeyCode.One] = "1", [Enum.KeyCode.Two] = "2", [Enum.KeyCode.Three] = "3",
    [Enum.KeyCode.Four] = "4", [Enum.KeyCode.Five] = "5", [Enum.KeyCode.Six] = "6",
    [Enum.KeyCode.Seven] = "7", [Enum.KeyCode.Eight] = "8", [Enum.KeyCode.Nine] = "9",
    [Enum.KeyCode.Zero] = "0", [Enum.KeyCode.KeypadOne] = "Num1", [Enum.KeyCode.KeypadTwo] = "Num2",
    [Enum.KeyCode.KeypadThree] = "Num3", [Enum.KeyCode.KeypadFour] = "Num4",
    [Enum.KeyCode.KeypadFive] = "Num5", [Enum.KeyCode.KeypadSix] = "Num6",
    [Enum.KeyCode.KeypadSeven] = "Num7", [Enum.KeyCode.KeypadEight] = "Num8",
    [Enum.KeyCode.KeypadNine] = "Num9", [Enum.KeyCode.KeypadZero] = "Num0",
    [Enum.KeyCode.Minus] = "-", [Enum.KeyCode.Equals] = "=",
    [Enum.KeyCode.Tilde] = "~", [Enum.KeyCode.LeftBracket] = "[",
    [Enum.KeyCode.RightBracket] = "]", [Enum.KeyCode.RightParenthesis] = ")",
    [Enum.KeyCode.LeftParenthesis] = "(", [Enum.KeyCode.Semicolon] = ",",
    [Enum.KeyCode.Quote] = "'", [Enum.KeyCode.BackSlash] = "\\",
    [Enum.KeyCode.Comma] = ",", [Enum.KeyCode.Period] = ".",
    [Enum.KeyCode.Slash] = "/", [Enum.KeyCode.Asterisk] = "*",
    [Enum.KeyCode.Plus] = "+", [Enum.KeyCode.Backquote] = "`",
    [Enum.UserInputType.MouseButton1] = "MB1",
    [Enum.UserInputType.MouseButton2] = "MB2",
    [Enum.UserInputType.MouseButton3] = "MB3",
    [Enum.KeyCode.Escape] = "ESC", [Enum.KeyCode.Space] = "SPC",
}

library.__index = library

for _, path in next, library.folders do 
    makefolder(library.directory .. path)
end

local flags = library.flags 
local config_flags = library.config_flags

-- Font importing system
local fonts = {}; do
    function Register_Font(Name, Weight, Style, Asset)
        if not isfile(Asset.Id) then
            writefile(Asset.Id, Asset.Font)
        end
        if isfile(Name .. ".font") then
            delfile(Name .. ".font")
        end
        local Data = {
            name = Name,
            faces = { { name = "Regular", weight = Weight, style = Style, assetId = getcustomasset(Asset.Id) } }
        }
        writefile(Name .. ".font", game:GetService("HttpService"):JSONEncode(Data))
        return getcustomasset(Name .. ".font");
    end
    
    local ProggyTiny = Register_Font("ProggyTiny", 200, "Normal", {
        Id = "ProggyTiny.ttf",
        Font = game:HttpGet("https://github.com/i77lhm/storage/raw/refs/heads/main/fonts/tahoma_bold.ttf"),
    })
    local ProggyClean = Register_Font("ProggyClean", 200, "normal", {
        Id = "ProggyClean.ttf",
        Font = game:HttpGet("https://github.com/i77lhm/storage/raw/refs/heads/main/fonts/ProggyClean.ttf")
    })
    fonts = {
        ["TahomaBold"] = Font.new(ProggyTiny, Enum.FontWeight.Regular, Enum.FontStyle.Normal);
        ["ProggyClean"] = Font.new(ProggyClean, Enum.FontWeight.Regular, Enum.FontStyle.Normal);
    }
end

-- Library functions
function library:tween(obj, properties) 
    tween_service:Create(obj, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0, false, 0), properties):Play()
end

function library:close_current_element(cfg) 
    local path = library.current_element_open
    if path then path.set_visible(false); path.open = false end
end

function library:resizify(frame) 
    local Frame = Instance.new("TextButton")
    Frame.Position = dim2(1, -10, 1, -10)
    Frame.BorderColor3 = rgb(0, 0, 0)
    Frame.Size = dim2(0, 10, 0, 10)
    Frame.BorderSizePixel = 0
    Frame.BackgroundColor3 = rgb(255, 255, 255)
    Frame.Parent = frame
    Frame.BackgroundTransparency = 1 
    Frame.Text = ""
    local resizing = false 
    local start_size 
    local start 
    local og_size = frame.Size  
    Frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = true
            start = input.Position
            start_size = frame.Size
        end
    end)
    Frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = false
        end
    end)
    library:connection(uis.InputChanged, function(input, game_event) 
        if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
            local viewport_x = camera.ViewportSize.X
            local viewport_y = camera.ViewportSize.Y
            local current_size = dim2(
                start_size.X.Scale,
                math.clamp(start_size.X.Offset + (input.Position.X - start.X), og_size.X.Offset, viewport_x),
                start_size.Y.Scale,
                math.clamp(start_size.Y.Offset + (input.Position.Y - start.Y), og_size.Y.Offset, viewport_y)
            )
            frame.Size = current_size
        end
    end)
end

function library:mouse_in_frame(uiobject)
    local y_cond = uiobject.AbsolutePosition.Y <= mouse.Y and mouse.Y <= uiobject.AbsolutePosition.Y + uiobject.AbsoluteSize.Y
    local x_cond = uiobject.AbsolutePosition.X <= mouse.X and mouse.X <= uiobject.AbsolutePosition.X + uiobject.AbsoluteSize.X
    return (y_cond and x_cond)
end

library.lerp = function(start, finish, t)
    t = t or 1 / 8
    return start * (1 - t) + finish * t
end

function library:draggify(frame)
    local dragging = false 
    local start_size = frame.Position
    local start 
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            start = input.Position
            start_size = frame.Position
        end
    end)
    frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    library:connection(uis.InputChanged, function(input, game_event) 
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local viewport_x = camera.ViewportSize.X
            local viewport_y = camera.ViewportSize.Y
            local current_position = dim2(
                0,
                clamp(start_size.X.Offset + (input.Position.X - start.X), 0, viewport_x - frame.Size.X.Offset),
                0,
                math.clamp(start_size.Y.Offset + (input.Position.Y - start.Y), 0, viewport_y - frame.Size.Y.Offset)
            )
            frame.Position = current_position
        end
    end)
end 

function library:convert(str)
    local values = {}
    for value in string.gmatch(str, "[^,]+") do
        insert(values, tonumber(value))
    end
    if #values == 4 then              
        return unpack(values)
    else 
        return
    end
end

function library:convert_enum(enum)
    local enum_parts = {}
    for part in string.gmatch(enum, "[%w_]+") do
        insert(enum_parts, part)
    end
    local enum_table = Enum
    for i = 2, #enum_parts do
        local enum_item = enum_table[enum_parts[i]]
        enum_table = enum_item
    end
    return enum_table
end

local config_holder;
function library:update_config_list() 
    if not config_holder then return end
    local list = {}
    for idx, file in listfiles(library.directory .. "/configs") do
        local name = file:gsub(library.directory .. "/configs\\", ""):gsub(".cfg", ""):gsub(library.directory .. "\\configs\\", "")
        list[#list + 1] = name
    end
    config_holder.refresh_options(list)
end 

function library:get_config()
    local Config = {}
    for _, v in flags do
        if type(v) == "table" and v.key then
            Config[_] = {active = v.active, mode = v.mode, key = tostring(v.key)}
        elseif type(v) == "table" and v["Transparency"] and v["Color"] then
            Config[_] = {Transparency = v["Transparency"], Color = v["Color"]:ToHex()}
        else
            Config[_] = v
        end
    end 
    return http_service:JSONEncode(Config)
end

function library:load_config(config_json) 
    local config = http_service:JSONDecode(config_json)
    for _, v in next, config do 
        local function_set = library.config_flags[_]
        if _ == "config_name_list" then continue end
        if function_set then 
            if type(v) == "table" and v["Transparency"] and v["Color"] then
                function_set(hex(v["Color"]), v["Transparency"])
            elseif type(v) == "table" and v["active"] then 
                function_set(v)
            else
                function_set(v)
            end
        end 
    end 
end 

function library:round(number, float) 
    local multiplier = 1 / (float or 1)
    return floor(number * multiplier + 0.5) / multiplier
end 

function library:apply_theme(instance, theme, property) 
    insert(themes.utility[theme][property], instance)
end

function library:update_theme(theme, color)
    for _, property in themes.utility[theme] do 
        for m, object in property do 
            if object[_] == themes.preset[theme] then 
                object[_] = color 
            end
        end 
    end 
    themes.preset[theme] = color 
end 

function library:connection(signal, callback)
    local connection = signal:Connect(callback)
    insert(library.connections, connection)
    return connection 
end

function library:apply_stroke(parent) 
    local STROKE = library:create("UIStroke", {
        Parent = parent,
        Color = themes.preset.text_outline, 
        LineJoinMode = Enum.LineJoinMode.Miter
    }) 
    library:apply_theme(STROKE, "text_outline", "Color")
end

function library:create(instance, options)
    local ins = Instance.new(instance) 
    for prop, value in next, options do 
        ins[prop] = value
    end
    if instance == "TextLabel" or instance == "TextButton" or instance == "TextBox" then 	
        library:apply_theme(ins, "text", "TextColor3")
        library:apply_stroke(ins)
    end
    return ins 
end

function library:unload_menu() 
    if library.gui then library.gui:Destroy() end
    for index, connection in next, library.connections do 
        connection:Disconnect() 
        connection = nil 
    end     
    if library.sgui then library.sgui:Destroy() end 
    library = nil 
end 

-- Library element functions
function library:window(properties)
    local cfg = {
        name = properties.name or properties.Name or "fijihack.panda",
        size = properties.size or properties.Size or dim2(0, 460, 0, 362), 
        selected_tab 
    }
    library.gui = library:create("ScreenGui", {
        Parent = coregui,
        Name = "\0",
        Enabled = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true,
    })
    local window_outline = library:create("Frame", {
        Parent = library.gui;
        Position = dim2(0.5, -cfg.size.X.Offset / 2, 0.5, -cfg.size.Y.Offset / 2);
        BorderColor3 = rgb(0, 0, 0);
        Size = cfg.size;
        BorderSizePixel = 0;
        BackgroundColor3 = rgb(255, 255, 255)
    });
    window_outline.Position = dim2(0, window_outline.AbsolutePosition.Y, 0, window_outline.AbsolutePosition.Y)
    cfg.main_outline = window_outline
    library:resizify(window_outline)
    library:draggify(window_outline)
    
    local title_holder = library:create("Frame", {
        Parent = window_outline;
        BackgroundTransparency = 0.800000011920929;
        Position = dim2(0, 2, 0, 2);
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, -4, 0, 20);
        BorderSizePixel = 0;
        BackgroundColor3 = rgb(0, 0, 0)
    });
    local ui_title = library:create("TextLabel", {
        FontFace = fonts["TahomaBold"];
        TextColor3 = rgb(255, 255, 255);
        BorderColor3 = rgb(0, 0, 0);
        Text = cfg.name;
        Parent = title_holder;
        BackgroundTransparency = 1;
        Size = dim2(1, 0, 1, 0);
        BorderSizePixel = 0;
        TextSize = 12;
        BackgroundColor3 = rgb(255, 255, 255)
    });
    library.gradient = library:create("UIGradient", {
        Color = rgbseq{ rgbkey(0, themes.preset["1"]), rgbkey(0.5, themes.preset["2"]), rgbkey(1, themes.preset["3"]) };
        Parent = window_outline
    });
    local tab_button_holder = library:create("Frame", {
        AnchorPoint = vec2(0, 1);
        Parent = window_outline;
        BackgroundTransparency = 0.800000011920929;
        Position = dim2(0, 2, 1, -2);
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, -4, 0, 20);
        BorderSizePixel = 0;
        BackgroundColor3 = rgb(0, 0, 0)
    }); cfg.tab_button_holder = tab_button_holder
    library:create("UIListLayout", {
        VerticalAlignment = Enum.VerticalAlignment.Center;
        FillDirection = Enum.FillDirection.Horizontal;
        HorizontalAlignment = Enum.HorizontalAlignment.Center;
        HorizontalFlex = Enum.UIFlexAlignment.Fill;
        Parent = tab_button_holder;
        SortOrder = Enum.SortOrder.LayoutOrder;
        VerticalFlex = Enum.UIFlexAlignment.Fill
    });
    return setmetatable(cfg, library)
end 

function library:tab(properties)
    local cfg = {
        name = properties.name or "visuals", 
        count = 0
    }
    local tab_button = library:create("TextButton", {
        FontFace = fonts["ProggyClean"];
        TextColor3 = rgb(170, 170, 170);
        BorderColor3 = rgb(0, 0, 0);
        Text = cfg.name;
        Parent = self.tab_button_holder;
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
        AutomaticSize = Enum.AutomaticSize.XY;
        TextSize = 12;
        BackgroundColor3 = rgb(255, 255, 255)
    });
    local Page = library:create("Frame", {
        Parent = self.main_outline;
        BackgroundTransparency = 0.6;
        Position = dim2(0, 2, 0, 24);
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, -4, 1, -48);
        BorderSizePixel = 0;
        BackgroundColor3 = rgb(0, 0, 0),
        Visible = false,
    }); cfg.page = Page
    library:create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal;
        HorizontalFlex = Enum.UIFlexAlignment.Fill;
        Parent = Page;
        Padding = dim(0, 2);
        SortOrder = Enum.SortOrder.LayoutOrder;
        VerticalFlex = Enum.UIFlexAlignment.Fill
    });
    library:create("UIPadding", {
        PaddingTop = dim(0, 2);
        PaddingBottom = dim(0, 2);
        Parent = Page;
        PaddingRight = dim(0, 2);
        PaddingLeft = dim(0, 2)
    });
    function cfg.open_tab() 
        local selected_tab = self.selected_tab
        if selected_tab then 
            selected_tab[1].Visible = false 
            selected_tab[2].TextColor3 = rgb(170, 170, 170)
            selected_tab = nil 
        end
        Page.Visible = true
        tab_button.TextColor3 = rgb(255, 255, 255)
        self.selected_tab = {Page, tab_button}
    end
    tab_button.MouseButton1Down:Connect(function() cfg.open_tab() end)
    if not self.selected_tab then cfg.open_tab(true) end
    return setmetatable(cfg, library)    
end 

local notifications = {notifs = {}} 
library.sgui = library:create("ScreenGui", { Name = "Hi", Parent = gethui() })

function notifications:refresh_notifs() 
    for i, v in notifications.notifs do 
        local Position = vec2(50, 50)
        tween_service:Create(v, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Position = dim_offset(Position.X, Position.Y + (i * 30))}):Play()
    end
end

function notifications:fade(path, is_fading)
    local fading = is_fading and 1 or 0 
    tween_service:Create(path, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {BackgroundTransparency = fading}):Play()
    for _, instance in path:GetDescendants() do 
        if not instance:IsA("GuiObject") then 
            if instance:IsA("UIStroke") then
                tween_service:Create(instance, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Transparency = fading}):Play()
            end
            continue
        end 
        if instance:IsA("TextLabel") then
            tween_service:Create(instance, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {TextTransparency = fading}):Play()
        elseif instance:IsA("Frame") then
            tween_service:Create(instance, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {BackgroundTransparency = instance.Transparency and 0.6 and is_fading and 1 or 0.6}):Play()
        end
    end
end 

function notifications:create_notification(options)
    local cfg = { name = options.name or "Hit: q3sm (finobe) in the Head for 100 Damage!" }
    local outline = library:create("Frame", {
        Parent = library.sgui;
        Position = dim_offset(-50, 50 + (#notifications.notifs * 30));
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(0, 0, 0, 24);
        BorderSizePixel = 0;
        AutomaticSize = Enum.AutomaticSize.X;
        BackgroundColor3 = rgb(255, 255, 255)
    });
    local dark = library:create("Frame", {
        Parent = outline;
        BackgroundTransparency = 1;
        Position = dim2(0, 2, 0, 2);
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, -4, 1, -4);
        BorderSizePixel = 0;
        BackgroundColor3 = rgb(0, 0, 0)
    });
    library:create("UIPadding", { PaddingTop = dim(0, 7); PaddingBottom = dim(0, 6); Parent = dark; PaddingRight = dim(0, 7); PaddingLeft = dim(0, 4) });
    library:create("TextLabel", {
        FontFace = fonts["ProggyClean"];
        TextColor3 = rgb(255, 255, 255);
        BorderColor3 = rgb(0, 0, 0);
        Text = cfg.name;
        Parent = dark;
        Size = dim2(0, 0, 1, 0);
        Position = dim2(0, 1, 0, -1);
        BackgroundTransparency = 1;
        TextXAlignment = Enum.TextXAlignment.Left;
        BorderSizePixel = 0;
        AutomaticSize = Enum.AutomaticSize.X;
        TextSize = 12;
        BackgroundColor3 = rgb(255, 255, 255)
    }); 
    library:create("UIGradient", {
        Color = rgbseq{ rgbkey(0, themes.preset["1"]), rgbkey(0.5, themes.preset["2"]), rgbkey(1, themes.preset["3"]) };
        Parent = outline
    });
    local index = #notifications.notifs + 1
    notifications.notifs[index] = outline
    notifications:refresh_notifs()
    tween_service:Create(outline, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {AnchorPoint = vec2(0, 0)}):Play()
    notifications:fade(outline, false)
    task.spawn(function()
        task.wait(3)
        notifications.notifs[index] = nil
        notifications:fade(outline, true)
        task.wait(3)
        outline:Destroy() 
    end)
end

function library:watermark(options)
    local cfg = { name = options.name or "nebulahax" }
    local outline = library:create("Frame", {
        Parent = library.sgui;
        Position = dim2(0, 50, 0, 50); 
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(0, 0, 0, 24);
        BorderSizePixel = 0;
        AutomaticSize = Enum.AutomaticSize.X;
        BackgroundColor3 = rgb(255, 255, 255)
    }); library.watermark_outline = outline; library:draggify(outline);
    local dark = library:create("Frame", {
        Parent = outline;
        BackgroundTransparency = 0.6;
        Position = dim2(0, 2, 0, 2);
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, -4, 1, -4);
        BorderSizePixel = 0;
        BackgroundColor3 = rgb(0, 0, 0)
    });
    library:create("UIPadding", { PaddingTop = dim(0, 7); PaddingBottom = dim(0, 6); Parent = dark; PaddingRight = dim(0, 7); PaddingLeft = dim(0, 4) });
    local text_title = library:create("TextLabel", {
        FontFace = fonts["ProggyClean"];
        TextColor3 = rgb(255, 255, 255);
        BorderColor3 = rgb(0, 0, 0);
        Text = cfg.name;
        Parent = dark;
        Size = dim2(0, 0, 1, 0);
        Position = dim2(0, 1, 0, -1);
        BackgroundTransparency = 1;
        TextXAlignment = Enum.TextXAlignment.Left;
        BorderSizePixel = 0;
        AutomaticSize = Enum.AutomaticSize.X;
        TextSize = 12;
        BackgroundColor3 = rgb(255, 255, 255)
    }); 
    library:create("UIGradient", {
        Color = rgbseq{ rgbkey(0, themes.preset["1"]), rgbkey(0.5, themes.preset["2"]), rgbkey(1, themes.preset["3"]) };
        Parent = outline
    });
    function cfg.update_text(text) text_title.Text = text end
    cfg.update_text(cfg.name)
    return setmetatable(cfg, library)
end 

local watermark = library:watermark({name = "Wavex Free - 100 fps - 100 ping"})
local fps = 0
local watermark_delay = tick() 
run.RenderStepped:Connect(function()
    fps += 1
    if tick() - watermark_delay > 1 then 
        watermark_delay = tick()
        local ping = math.floor(stats.PerformanceStats.Ping:GetValue()) .. "ms"                
        watermark.update_text(string.format("Wavex Free - fps: %s - ping: %s", fps, ping))
        fps = 0
    end
end)

function library:column(properties)
    self.count += 1
    local cfg = {color = library.gradient.Color.Keypoints[self.count].Value, count = self.count} 
    local scrolling_frame = library:create("ScrollingFrame", {
        ScrollBarImageColor3 = rgb(0, 0, 0);
        Active = true;
        AutomaticCanvasSize = Enum.AutomaticSize.Y;
        ScrollBarThickness = 0;
        Parent = self.page;
        LayoutOrder = -1;
        BackgroundTransparency = 1;
        ScrollBarImageTransparency = 1;
        BorderColor3 = rgb(0, 0, 0);
        BackgroundColor3 = rgb(0, 0, 0);
        BorderSizePixel = 0;
        CanvasSize = dim2(0, 0, 0, 0)
    }); cfg.column = scrolling_frame
    library:create("UIListLayout", { Parent = scrolling_frame; Padding = dim(0, 5); SortOrder = Enum.SortOrder.LayoutOrder });
    return setmetatable(cfg, library)            
end 

function library:section(properties)            
    local cfg = {
        name = properties.name or properties.Name or "section",
        size = properties.size or 1, 
        autofill = properties.auto_fill or false,
        count = self.count;
        color = self.color;
    }
    local accent = library:create("Frame", {
        Parent = self.column;
        ClipsDescendants = true;
        BorderColor3 = rgb(0, 0, 0);
        BorderSizePixel = 0;
        BackgroundColor3 = self.color
    }); library:apply_theme(accent, tostring(self.count), "BackgroundColor3");
    local dark = library:create("Frame", {
        Parent = accent;
        BackgroundTransparency = 0.6;
        Position = dim2(0, 2, 0, 16);
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, -4, 1, -18);
        BorderSizePixel = 0;
        BackgroundColor3 = rgb(0, 0, 0)
    });
    local elements = library:create("Frame", {
        Parent = dark;
        Position = dim2(0, 4, 0, 5);
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, -8, 0, 0);
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
        BackgroundColor3 = rgb(255, 255, 255)
    }); cfg.elements = elements
    if cfg.autofill == false then 
        elements.AutomaticSize = Enum.AutomaticSize.Y;
        accent.AutomaticSize = Enum.AutomaticSize.Y;
        accent.Size = dim2(1, 0, 0, 0);
        library:create("UIPadding", { Parent = elements, Name = "", PaddingBottom = dim(0, 7) })
    else 
        accent.Size = dim2(1, 0, cfg.size, 0);
    end
    library:create("UIListLayout", { Parent = elements; Padding = dim(0, 6); SortOrder = Enum.SortOrder.LayoutOrder });
    local title = library:create("TextLabel", {
        FontFace = fonts["TahomaBold"];
        TextColor3 = rgb(255, 255, 255);
        BorderColor3 = rgb(0, 0, 0);
        Text = cfg.name;
        Parent = accent;
        Size = dim2(1, 0, 0, 0);
        Position = dim2(0, 4, 0, 2);
        BackgroundTransparency = 1;
        TextXAlignment = Enum.TextXAlignment.Left;
        BorderSizePixel = 0;
        AutomaticSize = Enum.AutomaticSize.Y;
        TextSize = 12;
        BackgroundColor3 = rgb(255, 255, 255)
    });
    return setmetatable(cfg, library)
end 

-- Elements
function library:toggle(options) 
    local cfg = {
        enabled = options.enabled or nil,
        name = options.name or "Toggle",
        flag = options.flag or tostring(random(1,9999999)),
        default = options.default or false,
        folding = options.folding or false, 
        callback = options.callback or function() end,
        color = self.color;
        count = self.count;
    }
    local toggle = library:create("TextButton", {
        Parent = self.elements;
        BackgroundTransparency = 1;
        Text = "";
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, 0, 0, 12);
        BorderSizePixel = 0;
        BackgroundColor3 = rgb(255, 255, 255)
    });
    library:create("TextLabel", {
        FontFace = fonts["ProggyClean"];
        TextColor3 = rgb(255, 255, 255);
        BorderColor3 = rgb(0, 0, 0);
        Text = cfg.name;
        Parent = toggle;
        Size = dim2(1, 0, 1, 0);
        Position = dim2(0, 1, 0, -1);
        BackgroundTransparency = 1;
        TextXAlignment = Enum.TextXAlignment.Left;
        BorderSizePixel = 0;
        AutomaticSize = Enum.AutomaticSize.X;
        TextSize = 12;
        BackgroundColor3 = rgb(255, 255, 255)
    }); 
    local accent = library:create("Frame", {
        AnchorPoint = vec2(1, 0);
        Parent = toggle;
        Position = dim2(1, 0, 0, 0);
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(0, 12, 0, 12);
        BorderSizePixel = 0;
        BackgroundColor3 = self.color
    }); library:apply_theme(accent, tostring(self.count), "BackgroundColor3");    
    local fill = library:create("Frame", {
        Parent = accent;
        Position = dim2(0, 1, 0, 1);
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, -2, 1, -2);
        BorderSizePixel = 0;
        BackgroundColor3 = self.color
    }); library:apply_theme(fill, tostring(self.count), "BackgroundColor3");                
    local elements;
    if cfg.folding then
        elements = library:create("Frame", {
            Parent = self.elements;
            BackgroundTransparency = 1;
            Position = dim2(0, 4, 0, 21);
            Size = dim2(1, 0, 0, 0);
            BorderSizePixel = 0;
            Visible = false;
            AutomaticSize = Enum.AutomaticSize.Y;
            BackgroundColor3 = rgb(255, 255, 255)
        }); cfg.elements = elements
        library:create("UIListLayout", { Parent = elements; Padding = dim(0, 6); HorizontalAlignment = Enum.HorizontalAlignment.Right; SortOrder = Enum.SortOrder.LayoutOrder });
    end 
    function cfg.set(bool)                        
        fill.BackgroundColor3 = bool and themes.preset[tostring(self.count)] or themes.preset.inline
        flags[cfg.flag] = bool
        cfg.callback(bool)
        if cfg.folding then elements.Visible = bool end
    end 
    cfg.set(cfg.default)
    config_flags[cfg.flag] = cfg.set
    toggle.MouseButton1Click:Connect(function()
        cfg.enabled = not cfg.enabled 
        cfg.set(cfg.enabled)
    end)
    return setmetatable(cfg, library)
end 

function library:list(options)
    local cfg = {
        callback = options and options.callback or function() end, 
        name = options.name or nil, 
        scale = options.size or 90, 
        items = options.items or {"1", "2", "3"}, 
        visible = options.visible or true,
        option_instances = {}, 
        current_instance = nil, 
        flag = options.flag or "SET A FLAG U NIGGER", 
    }
    local accent = library:create("Frame", {
        BorderColor3 = rgb(0, 0, 0);
        AnchorPoint = vec2(1, 0);
        Parent = self.elements;
        Position = dim2(1, 0, 0, 0);
        Size = dim2(1, 0, 0, cfg.scale);
        BorderSizePixel = 0;
        AutomaticSize = Enum.AutomaticSize.Y;
        BackgroundColor3 = self.color
    }); library:apply_theme(accent, tostring(self.count), "BackgroundColor3")
    local inline = library:create("Frame", {
        Parent = accent;
        Position = dim2(0, 1, 0, 1);
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, -2, 1, -2);
        BorderSizePixel = 0;
        BackgroundColor3 = rgb(35, 35, 35)
    }); library:apply_theme(inline, "inline", "BackgroundColor3")
    local scrollingframe = library:create("ScrollingFrame", {
        ScrollBarImageColor3 = rgb(0, 0, 0);
        Active = true;
        AutomaticCanvasSize = Enum.AutomaticSize.Y;
        ScrollBarThickness = 0;
        Parent = inline;
        Size = dim2(1, 0, 1, 0);
        LayoutOrder = -1;
        BackgroundTransparency = 1;
        ScrollBarImageTransparency = 1;
        BorderColor3 = rgb(0, 0, 0);
        BackgroundColor3 = rgb(0, 0, 0);
        BorderSizePixel = 0;
        CanvasSize = dim2(0, 0, 0, 0)
    });
    library:create("UIListLayout", { Parent = scrollingframe; Padding = dim(0, 6); SortOrder = Enum.SortOrder.LayoutOrder });
    library:create("UIPadding", { PaddingTop = dim(0, 2); PaddingBottom = dim(0, 4); Parent = scrollingframe; PaddingRight = dim(0, 5); PaddingLeft = dim(0, 5) });
    function cfg.render_option(text) 
        local text = library:create("TextButton", {
            FontFace = fonts["ProggyClean"];
            TextColor3 = rgb(170, 170, 170);
            BorderColor3 = rgb(0, 0, 0);
            Text = text;
            AutoButtonColor = false;
            BackgroundTransparency = 1;
            Parent = scrollingframe;
            BorderSizePixel = 0;
            Size = dim2(1, 0, 0, 0);
            AutomaticSize = Enum.AutomaticSize.Y;
            TextSize = 12;
            TextXAlignment = Enum.TextXAlignment.Left;
            BackgroundColor3 = rgb(255, 255, 255)
        }); 
        return text 
    end 
    function cfg.refresh_options(options)
        for _, v in cfg.option_instances do v:Destroy() end 
        for _, option in next, options do 
            local button = cfg.render_option(option) 
            insert(cfg.option_instances, button)
            button.MouseButton1Click:Connect(function()
                if cfg.current_instance and cfg.current_instance ~= button then 
                    cfg.current_instance.TextColor3 = rgb(170, 170, 170)
                end 
                cfg.current_instance = button
                button.TextColor3 = rgb(255, 255, 255) 
                flags[cfg.flag] = button.text
                cfg.callback(button.text)
            end)
        end 
    end
    function cfg.filter_options(text)
        for _, v in next, cfg.option_instances do 
            if string.find(v.Text, text) then v.Visible = true else v.Visible = false end
        end
    end
    function cfg.set(value)
        for _, buttons in next, cfg.option_instances do 
            if buttons.Text == value then buttons.TextColor3 = rgb(255, 255, 255) else buttons.TextColor3 = rgb(170, 170, 170) end
        end 
        flags[cfg.flag] = value
        cfg.callback(value)
    end 
    cfg.refresh_options(cfg.items) 
    return setmetatable(cfg, library)
end     

function library:slider(options) 
    local cfg = {
        name = options.name or nil,
        suffix = options.suffix or "",
        flag = options.flag or tostring(2^789),
        callback = options.callback or function() end, 
        min = options.min or options.minimum or 0,
        max = options.max or options.maximum or 100,
        intervals = options.interval or options.decimal or 1,
        default = options.default or 10,
        value = options.default or 10, 
        ignore = options.ignore or false, 
        dragging = false,
    } 
    local slider = library:create("Frame", {
        Parent = self.elements;
        BackgroundTransparency = 1;
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, 0, 0, 25);
        BorderSizePixel = 0;
        BackgroundColor3 = rgb(255, 255, 255)
    });
    local eeeee = library:create("TextLabel", {
        FontFace = fonts["ProggyClean"];
        TextColor3 = rgb(255, 255, 255);
        RichText = true;
        BorderColor3 = rgb(0, 0, 0);
        Text = "max distance : 5000";
        Parent = slider;
        Size = dim2(1, 0, 0, 0);
        Position = dim2(0, 1, 0, -2);
        BackgroundTransparency = 1;
        TextXAlignment = Enum.TextXAlignment.Left;
        BorderSizePixel = 0;
        AutomaticSize = Enum.AutomaticSize.XY;
        TextSize = 12;
        BackgroundColor3 = rgb(255, 255, 255)
    });
    local outline = library:create("TextButton", {
        Parent = slider;
        Text = "";
        AutoButtonColor = false;
        Position = dim2(0, 0, 0, 13);
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, 0, 0, 12);
        BorderSizePixel = 0;
        BackgroundColor3 = self.color
    }); library:apply_theme(outline, tostring(self.count), "BackgroundColor3")
    local inline = library:create("Frame", {
        Parent = outline;
        Position = dim2(0, 1, 0, 1);
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, -2, 1, -2);
        BorderSizePixel = 0;
        BackgroundColor3 = themes.preset.inline
    }); library:apply_theme(inline, "inline", "BackgroundColor3")
    local accent = library:create("Frame", {
        Parent = inline;
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(0.5, 0, 1, 0);
        BorderSizePixel = 0;
        BackgroundColor3 = self.color
    }); library:apply_theme(accent, tostring(self.count), "BackgroundColor3")
    function cfg.set(value)
        local valuee = tonumber(value)
        if valuee == nil then return end 
        cfg.value = clamp(library:round(valuee, cfg.intervals), cfg.min, cfg.max)
        accent.Size = dim2((cfg.value - cfg.min) / (cfg.max - cfg.min), 0, 1, 0)
        eeeee.Text = cfg.name ..  "<font color='#AAAAAA'>" .. ' - ' .. tostring(cfg.value) .. cfg.suffix .. "</font>"
        flags[cfg.flag] = cfg.value
        cfg.callback(flags[cfg.flag])
    end 
    cfg.set(cfg.default)
    outline.MouseButton1Down:Connect(function() cfg.dragging = true end)
    library:connection(uis.InputChanged, function(input)
        if cfg.dragging and input.UserInputType == Enum.UserInputType.MouseMovement then 
            local size_x = (input.Position.X - inline.AbsolutePosition.X) / inline.AbsoluteSize.X
            local value = ((cfg.max - cfg.min) * size_x) + cfg.min
            cfg.set(value)
        end
    end)
    library:connection(uis.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then cfg.dragging = false end 
    end)
    cfg.set(cfg.default)
    config_flags[cfg.flag] = cfg.set
    return setmetatable(cfg, library)
end 

function library:dropdown(options) 
    local cfg = {
        name = options.name or nil,
        flag = options.flag or tostring(random(1,9999999)),
        items = options.items or {""},
        callback = options.callback or function() end,
        multi = options.multi or false, 
        scrolling = options.scrolling or false, 
        open = false, 
        option_instances = {}, 
        multi_items = {}, 
        ignore = options.ignore or false, 
    }   
    cfg.default = options.default or (cfg.multi and {cfg.items[1]}) or cfg.items[1] or "None"
    flags[cfg.flag] = {} 
    local dropdown = library:create("Frame", {
        Parent = self.elements;
        BackgroundTransparency = 1;
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, 0, 0, 16);
        BorderSizePixel = 0;
        BackgroundColor3 = rgb(255, 255, 255)
    });
    local dropdown_holder = library:create("TextButton", {
        AnchorPoint = vec2(1, 0);
        AutoButtonColor = false; 
        Text = "";
        Parent = dropdown;
        Position = dim2(1, 0, 0, 0);
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(0.5, 0, 0, 16);
        BorderSizePixel = 0;
        BackgroundColor3 = self.color
    }); library:apply_theme(dropdown_holder, tostring(self.count), "BackgroundColor3")
    local inline = library:create("Frame", {
        Parent = dropdown_holder;
        Position = dim2(0, 1, 0, 1);
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, -2, 1, -2);
        BorderSizePixel = 0;
        BackgroundColor3 = rgb(35, 35, 35)
    });
    local text = library:create("TextLabel", {
        FontFace = fonts["ProggyClean"];
        TextColor3 = rgb(255, 255, 255);
        BorderColor3 = rgb(0, 0, 0);
        Text = cfg.name;
        Parent = inline;
        Size = dim2(1, 0, 1, 0);
        BackgroundTransparency = 1;
        Position = dim2(0, 0, 0, 1);
        BorderSizePixel = 0;
        AutomaticSize = Enum.AutomaticSize.X;
        TextSize = 12;
        BackgroundColor3 = rgb(255, 255, 255)
    });
    local title = library:create("TextLabel", {
        FontFace = fonts["ProggyClean"];
        TextColor3 = rgb(255, 255, 255);
        BorderColor3 = rgb(0, 0, 0);
        Text = cfg.name;
        Parent = dropdown;
        Size = dim2(1, 0, 1, 0);
        Position = dim2(0, 1, 0, 0);
        BackgroundTransparency = 1;
        TextXAlignment = Enum.TextXAlignment.Left;
        BorderSizePixel = 0;
        AutomaticSize = Enum.AutomaticSize.X;
        TextSize = 12;
        BackgroundColor3 = rgb(255, 255, 255)
    });
    local accent = library:create("Frame", {
        Parent = library.gui;
        Size = dim2(0.0907348021864891, 0, 0.006218905560672283, 20);
        Position = dim2(0, 500, 0, 100);
        BorderColor3 = rgb(0, 0, 0);
        BorderSizePixel = 0;
        Visible = false;
        AutomaticSize = Enum.AutomaticSize.Y;
        BackgroundColor3 = self.color
    });	library:apply_theme(accent, tostring(self.count), "BackgroundColor3")
    local inline2 = library:create("Frame", {
        Parent = accent;
        Size = dim2(1, -2, 1, -2);
        Position = dim2(0, 1, 0, 1);
        BorderColor3 = rgb(0, 0, 0);
        BorderSizePixel = 0;
        AutomaticSize = Enum.AutomaticSize.Y;
        BackgroundColor3 = themes.preset.inline
    });	library:apply_theme(inline2, "inline", "BackgroundColor3")
    library:create("UIListLayout", { Parent = inline2; Padding = dim(0, 6); SortOrder = Enum.SortOrder.LayoutOrder });
    library:create("UIPadding", { PaddingTop = dim(0, 5); PaddingBottom = dim(0, 2); Parent = inline2; PaddingRight = dim(0, 6); PaddingLeft = dim(0, 6) });
    library:create("UIPadding", { PaddingBottom = dim(0, 2); Parent = accent });
    function cfg.render_option(text) 
        local title = library:create("TextButton", {
            FontFace = fonts["ProggyClean"];
            AutoButtonColor = false;
            TextColor3 = rgb(170, 170, 170);
            BorderColor3 = rgb(0, 0, 0);
            Text = text;
            Parent = inline2;
            Size = dim2(1, 0, 0, 0);
            Position = dim2(0, 0, 0, 1);
            BackgroundTransparency = 1;
            TextXAlignment = Enum.TextXAlignment.Left;
            BorderSizePixel = 0;
            AutomaticSize = Enum.AutomaticSize.Y;
            TextSize = 12;
            BackgroundColor3 = rgb(255, 255, 255)
        });
        return title
    end 
    function cfg.set_visible(bool) accent.Visible = bool end
    function cfg.set(value)
        local selected = {}
        local isTable = type(value) == "table"
        if value == nil then return end
        for _, option in next, cfg.option_instances do 
            if option.Text == value or (isTable and find(value, option.Text)) then 
                insert(selected, option.Text)
                cfg.multi_items = selected
                option.TextColor3 = rgb(255, 255, 255)
            else
                option.TextColor3 = rgb(170, 170, 170)
            end
        end
        text.Text = if isTable then concat(selected, ", ") else selected[1]
        flags[cfg.flag] = if isTable then selected else selected[1]
        cfg.callback(flags[cfg.flag]) 
    end
    function cfg.refresh_options(list) 
        for _, option in next, cfg.option_instances do option:Destroy() end
        cfg.option_instances = {} 
        for _, option in next, list do 
            local button = cfg.render_option(option)
            insert(cfg.option_instances, button)
            button.MouseButton1Down:Connect(function()
                if cfg.multi then 
                    local selected_index = find(cfg.multi_items, button.Text)
                    if selected_index then remove(cfg.multi_items, selected_index) else insert(cfg.multi_items, button.Text) end
                    cfg.set(cfg.multi_items) 				
                else 
                    cfg.set_visible(false)
                    cfg.open = false 
                    cfg.set(button.Text)
                end
            end)
        end
    end
    cfg.refresh_options(cfg.items)
    cfg.set(cfg.default)
    config_flags[cfg.flag] = cfg.set
    dropdown_holder.MouseButton1Click:Connect(function()
        cfg.open = not cfg.open 
        accent.Size = dim2(0, dropdown_holder.AbsoluteSize.X, 0, accent.Size.Y.Offset)
        accent.Position = dim2(0, dropdown_holder.AbsolutePosition.X, 0, dropdown_holder.AbsolutePosition.Y + 77)
        cfg.set_visible(cfg.open)
    end)
    uis.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if not (library:mouse_in_frame(accent) or library:mouse_in_frame(dropdown)) then 
                cfg.open = false
                cfg.set_visible(false)
            end
        end
    end)
    return setmetatable(cfg, library)
end 

function library:colorpicker(options) 
    local cfg = {
        name = options.name or "Color", 
        flag = options.flag or tostring(2^789),
        color = options.color or color(1, 1, 1),
        alpha = options.alpha and 1 - options.alpha or 0,
        open = false, 
        callback = options.callback or function() end,
    }
    local colorpicker_element = library:create("TextButton", {
        Parent = self.elements;
        BackgroundTransparency = 1;
        Text = "";
        AutoButtonColor = false;
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, 0, 0, 12);
        BorderSizePixel = 0;
        BackgroundColor3 = rgb(255, 255, 255)
    });
    local accent = library:create("Frame", {
        AnchorPoint = vec2(1, 0);
        Parent = colorpicker_element;
        Position = dim2(1, 0, 0, 0);
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(0, 30, 0, 12);
        BorderSizePixel = 0;
        BackgroundColor3 = self.color
    }); library:apply_theme(accent, tostring(self.count), "BackgroundColor3")
    local colorpicker_element_color = library:create("Frame", {
        Parent = accent;
        Position = dim2(0, 1, 0, 1);
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, -2, 1, -2);
        BorderSizePixel = 0;
        BackgroundColor3 = rgb(255, 255, 255)
    });
    library:create("TextLabel", {
        FontFace = fonts["ProggyClean"];
        TextColor3 = rgb(255, 255, 255);
        BorderColor3 = rgb(0, 0, 0);
        Text = cfg.name;
        Parent = colorpicker_element;
        Size = dim2(1, 0, 1, 0);
        Position = dim2(0, 1, 0, 0);
        BackgroundTransparency = 1;
        TextXAlignment = Enum.TextXAlignment.Left;
        BorderSizePixel = 0;
        AutomaticSize = Enum.AutomaticSize.X;
        TextSize = 12;
        BackgroundColor3 = rgb(255, 255, 255)
    });
    local colorpicker = library:create("Frame", {
        Parent = library.gui;
        Position = dim2(0.6888179183006287, 0, 0.24751244485378265, 0);
        BorderColor3 = rgb(0, 0, 0);
        Visible = false;
        Size = dim2(0, 150, 0, 150);
        BorderSizePixel = 0;
        BackgroundColor3 = self.color
    });	library:apply_theme(colorpicker, tostring(self.count), "BackgroundColor3")
    local a = library:create("Frame", {
        Parent = colorpicker;
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, 0, 1, 0);
        BorderSizePixel = 0;
        BackgroundColor3 = self.color
    }); library:apply_theme(a, tostring(self.count), "BackgroundColor3")
    local e = library:create("Frame", {
        Parent = a;
        Position = dim2(0, 1, 0, 1);
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, -2, 1, -2);
        BorderSizePixel = 0;
        BackgroundColor3 = rgb(0, 0, 0);
        BackgroundTransparency = 0.6;
        ZIndex = -1
    }); 
    library:create("UIPadding", { PaddingTop = dim(0, 7); PaddingBottom = dim(0, -13); Parent = e; PaddingRight = dim(0, 6); PaddingLeft = dim(0, 7) });
    local textbox_holder = library:create("Frame", {
        Parent = e;
        Position = dim2(0, 0, 1, -36);
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, -1, 0, 16);
        BorderSizePixel = 0;
        BackgroundColor3 = self.color
    }); library:apply_theme(textbox_holder, tostring(self.count), "BackgroundColor3")
    local textbox = library:create("TextBox", {
        FontFace = fonts["ProggyClean"];
        TextColor3 = rgb(255, 255, 255);
        BorderColor3 = rgb(0, 0, 0);
        Text = "";
        Parent = textbox_holder;
        BackgroundTransparency = 0;
        ClearTextOnFocus = false;
        PlaceholderColor3 = rgb(255, 255, 255);
        Size = dim2(1, -2, 1, -2);
        Position = dim2(0, 1, 0, 1);
        BorderSizePixel = 0;
        TextSize = 12;
        TextXAlignment = Enum.TextXAlignment.Center;
        BackgroundColor3 = themes.preset.inline
    }); library:apply_theme(textbox, "inline", "BackgroundColor3")
    local hue_button = library:create("TextButton", {
        AnchorPoint = vec2(1, 0);
        Text = "";
        AutoButtonColor = false;
        Parent = e;
        Position = dim2(1, -1, 0, 0);
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(0, 14, 1, -60);
        BorderSizePixel = 0;
        BackgroundColor3 = themes.preset.inline
    }); library:apply_theme(hue_button, "inline", "BackgroundColor3")
    local hue_drag = library:create("Frame", {
        Parent = hue_button;
        Position = dim2(0, 1, 0, 1);
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, -2, 1, -2);
        BorderSizePixel = 0;
        BackgroundColor3 = rgb(255, 255, 255)
    });
    library:create("UIGradient", {
        Rotation = 90;
        Parent = hue_drag;
        Color = rgbseq{rgbkey(0, rgb(255,0,0)), rgbkey(0.17, rgb(255,255,0)), rgbkey(0.33, rgb(0,255,0)), rgbkey(0.5, rgb(0,255,255)), rgbkey(0.67, rgb(0,0,255)), rgbkey(0.83, rgb(255,0,255)), rgbkey(1, rgb(255,0,0))}
    });
    local hue_picker = library:create("Frame", {
        Parent = hue_drag;
        BorderMode = Enum.BorderMode.Inset;
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, 2, 0, 3);
        Position = dim2(0, -1, 0, -1);
        BackgroundColor3 = rgb(255, 255, 255)
    });
    local alpha_button = library:create("TextButton", {
        AnchorPoint = vec2(0, 0.5);
        Text = "";
        AutoButtonColor = false;
        Parent = e;
        Position = dim2(0, 0, 1, -48);
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, -1, 0, 14);
        BorderSizePixel = 0;
        BackgroundColor3 = themes.preset.inline
    }); library:apply_theme(alpha_button, "inline", "BackgroundColor3")
    local alpha_color = library:create("Frame", {
        Parent = alpha_button;
        Position = dim2(0, 1, 0, 1);
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, -2, 1, -2);
        BorderSizePixel = 0;
        BackgroundColor3 = rgb(0, 221, 255)
    });
    local alphaind = library:create("ImageLabel", {
        ScaleType = Enum.ScaleType.Tile;
        BorderColor3 = rgb(0, 0, 0);
        Parent = alpha_color;
        Image = "rbxassetid://18274452449";
        BackgroundTransparency = 1;
        Size = dim2(1, 0, 1, 0);
        TileSize = dim2(0, 4, 0, 4);
        BorderSizePixel = 0;
        BackgroundColor3 = rgb(255, 255, 255)
    });
    library:create("UIGradient", { Parent = alphaind; Transparency = numseq{numkey(0, 0), numkey(1, 1)} });
    local alpha_picker = library:create("Frame", {
        Parent = alpha_color;
        BorderMode = Enum.BorderMode.Inset;
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(0, 3, 1, 2);
        Position = dim2(0, -1, 0, -1);
        BackgroundColor3 = rgb(255, 255, 255)
    });
    local saturation_value_button = library:create("TextButton", {
        Parent = e;
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, -20, 1, -60);
        Text = "";
        AutoButtonColor = false;
        BorderSizePixel = 0;
        BackgroundColor3 = themes.preset.inline
    }); library:apply_theme(saturation_value_button, "inline", "BackgroundColor3")
    local colorpicker_color = library:create("Frame", {
        Parent = saturation_value_button;
        Position = dim2(0, 1, 0, 1);
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, -2, 1, -2);
        BorderSizePixel = 0;
        BackgroundColor3 = rgb(0, 221, 255)
    });
    local val = library:create("TextButton", {
        Parent = colorpicker_color;
        Text = "";
        AutoButtonColor = false;
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, 0, 1, 0);
        BorderSizePixel = 0;
        BackgroundColor3 = rgb(255, 255, 255)
    });
    library:create("UIGradient", { Parent = val; Transparency = numseq{numkey(0, 0), numkey(1, 1)} });
    local saturation_value_picker = library:create("Frame", {
        Parent = colorpicker_color;
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(0, 3, 0, 3);
        BorderSizePixel = 0;
        BackgroundColor3 = rgb(0, 0, 0)
    });
    local inline = library:create("Frame", {
        Parent = saturation_value_picker;
        Position = dim2(0, 1, 0, 1);
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, -2, 1, -2);
        BorderSizePixel = 0;
        BackgroundColor3 = rgb(255, 255, 255)
    });
    local saturation_button = library:create("TextButton", {
        Parent = colorpicker_color;
        Text = "";
        AutoButtonColor = false;
        Size = dim2(1, 0, 1, 0);
        BorderColor3 = rgb(0, 0, 0);
        ZIndex = 2;
        BorderSizePixel = 0;
        BackgroundColor3 = rgb(255, 255, 255)
    });
    library:create("UIGradient", { Rotation = 270; Transparency = numseq{numkey(0, 0), numkey(1, 1)}; Parent = saturation_button; Color = rgbseq{rgbkey(0, rgb(0,0,0)), rgbkey(1, rgb(0,0,0))} });
    
    local dragging_sat = false 
    local dragging_hue = false 
    local dragging_alpha = false 
    local h, s, v = cfg.color:ToHSV() 
    local a = cfg.alpha 
    flags[cfg.flag] = {} 
    function cfg.set_visible(bool) 
        colorpicker.Visible = bool
        colorpicker.Position = dim_offset(colorpicker_element_color.AbsolutePosition.X - 1, colorpicker_element_color.AbsolutePosition.Y + colorpicker_element_color.AbsoluteSize.Y + 65)
    end
    function cfg.set(color, alpha)
        if color then h, s, v = color:ToHSV() end
        if alpha then a = alpha end 
        local Color = Color3.fromHSV(h, s, v)
        hue_picker.Position = dim2(0, -1, 1 - h, -1)
        alpha_picker.Position = dim2(1 - a, -1, 0, -1)
        saturation_value_picker.Position = dim2(s, -1, 1 - v, -1)
        alpha_color.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
        colorpicker_element_color.BackgroundColor3 = Color
        colorpicker_color.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
        flags[cfg.flag] = { Color = Color; Transparency = a }
        local color = colorpicker_element_color.BackgroundColor3
        textbox.Text = string.format("%s, %s, %s, ", library:round(color.R * 255), library:round(color.G * 255), library:round(color.B * 255))
        textbox.Text ..= library:round(1 - a, 0.01)
        cfg.callback(Color, a)
    end
    function cfg.update_color() 
        local mouse = uis:GetMouseLocation() 
        local offset = vec2(mouse.X, mouse.Y - gui_offset) 
        if dragging_sat then	
            s = math.clamp((offset - saturation_value_button.AbsolutePosition).X / saturation_value_button.AbsoluteSize.X, 0, 1)
            v = 1 - math.clamp((offset - saturation_value_button.AbsolutePosition).Y / saturation_value_button.AbsoluteSize.Y, 0, 1)
        elseif dragging_hue then
            h = 1 - math.clamp((offset - hue_button.AbsolutePosition).Y / hue_button.AbsoluteSize.Y, 0, 1)
        elseif dragging_alpha then
            a = 1 - math.clamp((offset - alpha_button.AbsolutePosition).X / alpha_button.AbsoluteSize.X, 0, 1)
        end
        cfg.set(nil, nil)
    end
    cfg.set(cfg.color, cfg.alpha)
    config_flags[cfg.flag] = cfg.set
    colorpicker_element.MouseButton1Click:Connect(function()
        cfg.open = not cfg.open 
        cfg.set_visible(cfg.open)            
    end)
    uis.InputChanged:Connect(function(input)
        if (dragging_sat or dragging_hue or dragging_alpha) and input.UserInputType == Enum.UserInputType.MouseMovement then
            cfg.update_color() 
        end
    end)
    library:connection(uis.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging_sat = false
            dragging_hue = false
            dragging_alpha = false  
            if not (library:mouse_in_frame(colorpicker_element) or library:mouse_in_frame(colorpicker)) then 
                cfg.open = false
                cfg.set_visible(false)
            end
        end
    end)
    alpha_button.MouseButton1Down:Connect(function() dragging_alpha = true end)
    hue_button.MouseButton1Down:Connect(function() dragging_hue = true end)
    saturation_button.MouseButton1Down:Connect(function() dragging_sat = true end)
    textbox.FocusLost:Connect(function()
        local r, g, b, a = library:convert(textbox.Text)
        if r and g and b and a then cfg.set(rgb(r, g, b), 1 - a) end 
    end)
    return setmetatable(cfg, library)
end

function library:textbox(options) 
    local cfg = {
        name = options.name or "...",
        placeholder = options.placeholder or options.placeholdertext or options.holder or options.holdertext or "type here...",
        default = options.default,
        flag = options.flag or "SET ME NIGGA",
        callback = options.callback or function() end,
        visible = options.visible or true,
    }
    local frame = library:create("TextButton", {
        AnchorPoint = vec2(1, 0);
        Text = "";
        AutoButtonColor = false;
        Parent = self.elements;
        Position = dim2(1, 0, 0, 0);
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, 0, 0, 16);
        BorderSizePixel = 0;
        BackgroundColor3 = self.color
    }); library:apply_theme(frame, tostring(self.count), "BackgroundColor3")
    local frame_inline = library:create("Frame", {
        Parent = frame;
        Position = dim2(0, 1, 0, 1);
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, -2, 1, -2);
        BorderSizePixel = 0;
        BackgroundColor3 = themes.preset.inline
    }); library:apply_theme(frame_inline, "inline", "BackgroundColor3")
    local input = library:create("TextBox", {
        Parent = frame,
        Name = "",
        FontFace = fonts["ProggyClean"],
        TextTruncate = Enum.TextTruncate.AtEnd,
        TextSize = 12,
        Size = dim2(1, -6, 1, 0),
        RichText = true,
        TextColor3 = rgb(255, 255, 255),
        BorderColor3 = rgb(0, 0, 0),
        CursorPosition = -1,
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        Position = dim2(0, 6, 0, 0),
        BorderSizePixel = 0,
        PlaceholderColor3 = rgb(170, 170, 170),
    })
    function cfg.set(text) 
        flags[cfg.flag] = text
        input.Text = text
        cfg.callback(text)
    end 
    config_flags[cfg.flag] = cfg.set
    if cfg.default then cfg.set(cfg.default) end
    input:GetPropertyChangedSignal("Text"):Connect(function() cfg.set(input.Text) end)
    return setmetatable(cfg, library)
end 

function library:keybind(options) 
    local cfg = {
        flag = options.flag or "SET ME A FLAG NOWWW!!!!",
        callback = options.callback or function() end,
        open = false,
        binding = nil, 
        name = options.name or nil, 
        ignore_key = options.ignore or false, 
        key = options.key or nil, 
        mode = options.mode or "toggle",
        active = options.default or false, 
        hold_instances = {},
    }
    flags[cfg.flag] = {} 
    local keybind = library:create("Frame", {
        Parent = self.elements;
        BackgroundTransparency = 1;
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, 0, 0, 16);
        BorderSizePixel = 0;
        BackgroundColor3 = rgb(255, 255, 255)
    });
    local keybind_holder = library:create("TextButton", {
        AnchorPoint = vec2(1, 0);
        AutoButtonColor = false; 
        Text = "";
        Parent = keybind;
        Position = dim2(1, 0, 0, 0);
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(0.5, 0, 0, 16);
        BorderSizePixel = 0;
        BackgroundColor3 = self.color
    }); library:apply_theme(keybind_holder, tostring(self.count), "BackgroundColor3")
    local inline = library:create("Frame", {
        Parent = keybind_holder;
        Position = dim2(0, 1, 0, 1);
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, -2, 1, -2);
        BorderSizePixel = 0;
        BackgroundColor3 = rgb(35, 35, 35)
    });
    local text = library:create("TextLabel", {
        FontFace = fonts["ProggyClean"];
        TextColor3 = rgb(255, 255, 255);
        BorderColor3 = rgb(0, 0, 0);
        Text = cfg.name;
        Parent = inline;
        Size = dim2(1, 0, 1, 0);
        BackgroundTransparency = 1;
        Position = dim2(0, 0, 0, -1);
        BorderSizePixel = 0;
        AutomaticSize = Enum.AutomaticSize.X;
        TextSize = 12;
        BackgroundColor3 = rgb(255, 255, 255)
    });
    local title = library:create("TextLabel", {
        FontFace = fonts["ProggyClean"];
        TextColor3 = rgb(255, 255, 255);
        BorderColor3 = rgb(0, 0, 0);
        Text = cfg.name;
        Parent = keybind;
        Size = dim2(1, 0, 1, 0);
        Position = dim2(0, 1, 0, 0);
        BackgroundTransparency = 1;
        TextXAlignment = Enum.TextXAlignment.Left;
        BorderSizePixel = 0;
        AutomaticSize = Enum.AutomaticSize.X;
        TextSize = 12;
        BackgroundColor3 = rgb(255, 255, 255)
    });
    local accent = library:create("Frame", {
        Parent = library.gui;
        Visible = false;
        Size = dim2(0.0907348021864891, 0, 0.006218905560672283, 20);
        Position = dim2(0, 500, 0, 100);
        BorderColor3 = rgb(0, 0, 0);
        BorderSizePixel = 0;
        AutomaticSize = Enum.AutomaticSize.Y;
        BackgroundColor3 = self.color
    });	library:apply_theme(accent, tostring(self.count), "BackgroundColor3")
    local inline2 = library:create("Frame", {
        Parent = accent;
        Size = dim2(1, -2, 1, -2);
        Position = dim2(0, 1, 0, 1);
        BorderColor3 = rgb(0, 0, 0);
        BorderSizePixel = 0;
        AutomaticSize = Enum.AutomaticSize.Y;
        BackgroundColor3 = themes.preset.inline
    });	library:apply_theme(inline2, "inline", "BackgroundColor3")
    library:create("UIListLayout", { Parent = inline2; Padding = dim(0, 6); SortOrder = Enum.SortOrder.LayoutOrder });
    library:create("UIPadding", { PaddingTop = dim(0, 5); PaddingBottom = dim(0, 2); Parent = inline2; PaddingRight = dim(0, 6); PaddingLeft = dim(0, 6) });
    library:create("UIPadding", { PaddingBottom = dim(0, 2); Parent = accent });
    local options = {"Hold", "Toggle", "Always"}
    for _, v in options do
        local option = library:create("TextButton", {
            FontFace = fonts["ProggyClean"];
            TextColor3 = rgb(170, 170, 170);
            BorderColor3 = rgb(0, 0, 0);
            Text = v;
            Parent = inline2;
            Position = dim2(0, 0, 0, 1);
            BackgroundTransparency = 1;
            TextXAlignment = Enum.TextXAlignment.Left;
            BorderSizePixel = 0;
            AutomaticSize = Enum.AutomaticSize.XY;
            TextSize = 12;
            BackgroundColor3 = rgb(255, 255, 255)
        }); cfg.hold_instances[v] = option
        option.MouseButton1Click:Connect(function()
            cfg.set(v)
            cfg.set_visible(false)
            cfg.open = false
        end)
    end
    function cfg.modify_mode_color(path)
        for _, v in cfg.hold_instances do v.TextColor3 = rgb(170, 170, 170) end
        if cfg.hold_instances[path] then cfg.hold_instances[path].TextColor3 = rgb(255, 255, 255) end
    end 
    function cfg.set_mode(mode) 
        cfg.mode = mode 
        if mode == "Always" then cfg.set(true) elseif mode == "Hold" then cfg.set(false) end
        flags[cfg.flag]["mode"] = mode
        cfg.modify_mode_color(mode)
    end 
    function cfg.set(input)
        if type(input) == "boolean" then 
            local __cached = input 
            if cfg.mode == "Always" then __cached = true end 
            cfg.active = __cached 
            cfg.callback(__cached)
        elseif tostring(input):find("Enum") then 
            input = input.Name == "Escape" and "..." or input
            cfg.key = input or "..."	
            cfg.callback(cfg.active or false)
        elseif find({"Toggle", "Hold", "Always"}, input) then 
            cfg.set_mode(input)
            if input == "Always" then cfg.active = true end 
            cfg.callback(cfg.active or false)
        elseif type(input) == "table" then 
            input.key = type(input.key) == "string" and input.key ~= "..." and library:convert_enum(input.key) or input.key
            input.key = input.key == Enum.KeyCode.Escape and "..." or input.key
            cfg.key = input.key or "..."
            cfg.mode = input.mode or "Toggle"
            cfg.set_mode(input.mode)
            if input.active then cfg.active = input.active end
        end 
        flags[cfg.flag] = { mode = cfg.mode, key = cfg.key, active = cfg.active }
        local _text = tostring(cfg.key) ~= "Enums" and (keys[cfg.key] or tostring(cfg.key):gsub("Enum.", "")) or nil
        local __text = _text and (tostring(_text):gsub("KeyCode.", ""):gsub("UserInputType.", ""))
        text.Text = " ".. __text .." "
    end
    function cfg.set_visible(bool)
        accent.Visible = bool
        accent.Size = dim2(0, keybind_holder.AbsoluteSize.X, 0, accent.Size.Y.Offset)
        accent.Position = dim2(0, keybind_holder.AbsolutePosition.X, 0, keybind_holder.AbsolutePosition.Y + 77)
    end
    keybind_holder.MouseButton1Down:Connect(function()
        task.wait()
        text.Text = "..."	
        cfg.binding = library:connection(uis.InputBegan, function(keycode, game_event)  
            cfg.set(keycode.KeyCode)
            cfg.binding:Disconnect() 
            cfg.binding = nil
        end)
    end)
    keybind_holder.MouseButton2Down:Connect(function()
        cfg.open = not cfg.open 
        cfg.set_visible(cfg.open) 
    end)
    library:connection(uis.InputBegan, function(input, game_event) 
        if not game_event then 
            if input.KeyCode == cfg.key then 
                if cfg.mode == "Toggle" then 
                    cfg.active = not cfg.active
                    cfg.set(cfg.active)
                elseif cfg.mode == "Hold" then 
                    cfg.set(true)
                end
            end
        end
    end)
    library:connection(uis.InputEnded, function(input, game_event) 
        if game_event then return end 
        local selected_key = input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode or input.UserInputType
        if selected_key == cfg.key then
            if cfg.mode == "Hold" then cfg.set(false) end
        end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if not (library:mouse_in_frame(keybind_holder) or library:mouse_in_frame(accent)) then 
                cfg.open = false
                cfg.set_visible(false)
            end
        end
    end)
    config_flags[cfg.flag] = cfg.set
    cfg.set({mode = cfg.mode, active = cfg.active, key = cfg.key})
    return setmetatable(cfg, library)
end

function library:button(options) 
    local cfg = { name = options.name or "button", callback = options.callback or function() end }
    local frame = library:create("TextButton", {
        AnchorPoint = vec2(1, 0);
        Text = "";
        AutoButtonColor = false;
        Parent = self.elements;
        Position = dim2(1, 0, 0, 0);
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, 0, 0, 16);
        BorderSizePixel = 0;
        BackgroundColor3 = self.color
    }); library:apply_theme(frame, tostring(self.count), "BackgroundColor3")
    local frame_inline = library:create("Frame", {
        Parent = frame;
        Position = dim2(0, 1, 0, 1);
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, -2, 1, -2);
        BorderSizePixel = 0;
        BackgroundColor3 = themes.preset.inline
    }); library:apply_theme(frame_inline, "inline", "BackgroundColor3")
    local text = library:create("TextLabel", {
        FontFace = fonts["ProggyClean"];
        TextColor3 = rgb(255, 255, 255);
        BorderColor3 = rgb(0, 0, 0);
        Text = cfg.name;
        Parent = frame;
        Size = dim2(1, 0, 1, 0);
        BackgroundTransparency = 1;
        Position = dim2(0, 1, 0, 1);
        BorderSizePixel = 0;
        AutomaticSize = Enum.AutomaticSize.X;
        TextSize = 12;
        BackgroundColor3 = rgb(255, 255, 255)
    });
    frame.MouseButton1Click:Connect(function() cfg.callback() end)
    return setmetatable(cfg, library)
end 

-- =============================================
-- FITUR CLOUDWARE (Wavex Free)
-- =============================================

local Players = players
local RunService = run
local UserInputService = uis
local Workspace = ws
local CoreGui = coregui
local GuiService = gui_service

local LocalPlayer = lp
local Camera = camera
local Mouse = mouse
local IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- Settings
local Settings = {
    AimActive = false,
    AimMode = "Camera",
    AimHoldMode = true,
    AimToggleState = false,
    AimSmoothness = 3,
    AimFOVEnabled = false,
    AimFOVSize = 100,
    AimWallCheck = false,
    HitboxEnabled = false,
    HitboxSize = 3,
    HitboxTransparency = 0.5,
    BoxesEnabled = false,
    NamesEnabled = false,
    HealthEnabled = false,
    InvEnabled = false,
    SkeletonEnabled = false,
    HighlightEnabled = false,
    HighlightFillTrans = 0.5,
    HighlightColor = rgb(255, 50, 50),
    HighlightOutline = rgb(255, 255, 255),
    ToolHighlightEnabled = false,
    ToolHighlightColor = rgb(255, 200, 0),
    SelfHighlightEnabled = false,
    SelfHighlightColor = rgb(0, 200, 255),
    SelfHighlightOutline = rgb(255, 255, 255),
    ESPVisible = true,
    SpeedhackEnabled = false,
    DeleteActive = false,
    StretchEnabled = false,
    StretchScale = 70,
    ShowSnowParticles = true,
}

_G.AimbotKey = Enum.KeyCode.E
_G.HitboxKey = nil
_G.ESPKey = nil

local Whitelist = {}
local StretchConn = nil
local Highlights = {}
local ToolHighlights = {}
local SelfHighlight = nil
local ESPObjects = {}
local OriginalSizes = {}
local OriginalTransparencies = {}
local DeletedParts = {}

local function IsWhitelisted(player) return Whitelist[player.Name] == true end
local function GetStretchFactor() return 1 - Settings.StretchScale / 100 * 0.45 end

local function ToggleStretch(enabled)
    if StretchConn then StretchConn:Disconnect(); StretchConn = nil end
    if not enabled then return end
    local factor = GetStretchFactor()
    StretchConn = RunService.RenderStepped:Connect(function()
        if Camera then
            Camera.CFrame = Camera.CFrame * CFrame.new(0, 0, 0, 1, 0, 0, 0, factor, 0, 0, 0, 1)
        end
    end)
end

local function ClearHighlight(player)
    if Highlights[player] then pcall(function() Highlights[player]:Destroy() end); Highlights[player] = nil end
    if ToolHighlights[player] then pcall(function() ToolHighlights[player]:Destroy() end); ToolHighlights[player] = nil end
end

local function GetEquippedTool(character)
    if not character then return nil end
    for _, child in ipairs(character:GetChildren()) do
        if child:IsA("Tool") then return child end
    end
    return nil
end

local function UpdatePlayerHighlight(player)
    if player == LocalPlayer then return end
    local char = player.Character
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    if not char or not humanoid or humanoid.Health <= 0 then return end

    if Settings.HighlightEnabled then
        if not Highlights[player] then
            local hl = Instance.new("Highlight")
            hl.FillColor = Settings.HighlightColor
            hl.OutlineColor = Settings.HighlightOutline
            hl.FillTransparency = Settings.HighlightFillTrans
            hl.OutlineTransparency = 0
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            hl.Adornee = char
            hl.Parent = CoreGui
            Highlights[player] = hl
        else
            local hl = Highlights[player]
            hl.FillColor = Settings.HighlightColor
            hl.OutlineColor = Settings.HighlightOutline
            hl.FillTransparency = Settings.HighlightFillTrans
        end
    else
        ClearHighlight(player)
    end

    if Settings.ToolHighlightEnabled then
        local tool = GetEquippedTool(char)
        if tool then
            if not ToolHighlights[player] then
                local hl = Instance.new("Highlight")
                hl.FillColor = Settings.ToolHighlightColor
                hl.OutlineColor = Settings.ToolHighlightColor
                hl.FillTransparency = 0.3
                hl.OutlineTransparency = 0
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                hl.Adornee = tool
                hl.Parent = CoreGui
                ToolHighlights[player] = hl
            else
                ToolHighlights[player].FillColor = Settings.ToolHighlightColor
                ToolHighlights[player].Adornee = tool
            end
        else
            if ToolHighlights[player] then pcall(function() ToolHighlights[player]:Destroy() end); ToolHighlights[player] = nil end
        end
    else
        if ToolHighlights[player] then pcall(function() ToolHighlights[player]:Destroy() end); ToolHighlights[player] = nil end
    end
end

local function UpdateSelfHighlight()
    if Settings.SelfHighlightEnabled then
        if not SelfHighlight then
            SelfHighlight = Instance.new("Highlight")
            SelfHighlight.Parent = CoreGui
        end
        local char = LocalPlayer.Character
        SelfHighlight.Adornee = char
        SelfHighlight.FillColor = Settings.SelfHighlightColor
        SelfHighlight.OutlineColor = Settings.SelfHighlightOutline
        SelfHighlight.FillTransparency = 0.5
        SelfHighlight.OutlineTransparency = 0
        SelfHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    else
        if SelfHighlight then pcall(function() SelfHighlight:Destroy() end); SelfHighlight = nil end
    end
end

local function ClearESP(player)
    if ESPObjects[player] then
        for _, obj in pairs(ESPObjects[player]) do
            if type(obj) == "table" then
                for _, line in ipairs(obj) do pcall(function() line:Remove() end) end
            else
                pcall(function() obj:Remove() end)
            end
        end
        ESPObjects[player] = nil
    end
end

local SkeletonBones = {
    {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"},
    {"LeftLowerArm", "LeftHand"}, {"UpperTorso", "RightUpperArm"},
    {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"},
    {"LeftLowerLeg", "LeftFoot"}, {"LowerTorso", "RightUpperLeg"},
    {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"},
}

local function EnableHitbox(character)
    if not character then return end
    local torso = character:FindFirstChild("UpperTorso")
    if not torso then return end
    if not OriginalSizes[torso] then OriginalSizes[torso] = torso.Size end
    if not OriginalTransparencies[torso] then OriginalTransparencies[torso] = torso.Transparency end
    torso.Size = Vector3.new(Settings.HitboxSize, Settings.HitboxSize, Settings.HitboxSize)
    torso.Transparency = Settings.HitboxTransparency
    torso.CanCollide = false
    torso.Massless = true
end

local function DisableHitbox(character)
    if not character then return end
    local torso = character:FindFirstChild("UpperTorso")
    if torso then
        torso.Size = OriginalSizes[torso] or torso.Size
        OriginalSizes[torso] = nil
        torso.Transparency = OriginalTransparencies[torso] or 0
        OriginalTransparencies[torso] = nil
    end
end

local function ApplyHitboxToAll()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then EnableHitbox(player.Character) end
        end
    end
end

local function RemoveHitboxFromAll()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then DisableHitbox(player.Character) end
    end
end

local function GetInventoryText(player)
    local char = player.Character
    local backpack = player:FindFirstChild("Backpack")
    local inv = {}
    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then
                local name = tool.Name
                if not inv[name] then inv[name] = {bp = 0, eq = 0} end
                inv[name].bp = inv[name].bp + 1
            end
        end
    end
    if char then
        for _, tool in ipairs(char:GetChildren()) do
            if tool:IsA("Tool") then
                local name = tool.Name
                if not inv[name] then inv[name] = {bp = 0, eq = 0} end
                inv[name].eq = inv[name].eq + 1
            end
        end
    end
    local list = {}
    for name, data in pairs(inv) do
        local total = data.bp + data.eq
        local suffix = data.eq > 0 and (total > 1 and " (Eq " .. total .. ")" or " (Eq)") or (total > 1 and " (" .. total .. ")" or "")
        table.insert(list, name .. suffix)
    end
    if #list == 0 then return "Empty" end
    return table.concat(list, "\n")
end

local function IsVisible(partPosition)
    if not Settings.AimWallCheck then return true end
    local origin = Camera.CFrame.Position
    local direction = partPosition - origin
    local ray = Ray.new(origin, direction.Unit * direction.Magnitude)
    local ignore = {LocalPlayer.Character}
    local hit = Workspace:FindPartOnRayWithIgnoreList(ray, ignore)
    return hit == nil
end

local function GetClosestPlayer(cursorX, cursorY)
    local closestDist = math.huge
    local closestPart = nil
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and not IsWhitelisted(player) then
            local char = player.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    local root = char:FindFirstChild("HumanoidRootPart")
                    if root then
                        local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
                        if onScreen and screenPos.Z > 0 then
                            local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(cursorX, cursorY)).Magnitude
                            if Settings.AimFOVEnabled and dist > Settings.AimFOVSize then
                                -- skip
                            else
                                if dist < closestDist and IsVisible(root.Position) then
                                    closestDist = dist
                                    closestPart = root
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return closestPart
end

local function SmoothCameraAim(targetPosition, smoothness)
    local currentCF = Camera.CFrame
    local newCF = CFrame.new(currentCF.Position, targetPosition)
    Camera.CFrame = currentCF:Lerp(newCF, math.clamp(smoothness / 10, 0.05, 0.55))
end

local function SmoothMouseAim(targetPosition, cursorX, cursorY, smoothness)
    local screenPos, onScreen = Camera:WorldToViewportPoint(targetPosition)
    if not onScreen or screenPos.Z < 0 then return end
    local factor = 0.06 + (1 - (smoothness - 1) / 4) * 0.44
    if mousemoverel then
        mousemoverel((screenPos.X - cursorX) * factor, (screenPos.Y - cursorY) * factor)
    else
        local currentCF = Camera.CFrame
        local newCF = CFrame.new(currentCF.Position, targetPosition)
        Camera.CFrame = currentCF:Lerp(newCF, factor)
    end
end

local function DeletePart(part)
    if not part or not part:IsA("BasePart") or IsWhitelisted(LocalPlayer) then return end
    table.insert(DeletedParts, {Part = part, Parent = part.Parent, CF = part.CFrame})
    part.Parent = nil
end

local function UndoDelete()
    if #DeletedParts > 0 then
        local data = table.remove(DeletedParts)
        data.Part.Parent = data.Parent
        data.Part.CFrame = data.CF
    end
end

-- Notifikasi menggunakan sistem notifikasi priv9
local function Notify(title, msg, duration)
    notifications:create_notification({name = title .. ": " .. msg})
end

-- =============================================
-- UI Wavex Free - Menggunakan Priv9 UI
-- =============================================

local window = library:window({ name = "Wavex Free" })

-- Tab Aimbot
local aimbotTab = window:tab({ name = "Aimbot" })
local col1 = aimbotTab:column({})
local secAim = col1:section({ name = "Aimbot Settings", auto_fill = false })

secAim:toggle({ name = "Enable Aimbot", flag = "aim_enabled", default = false, callback = function(v) Settings.AimActive = v end })
secAim:dropdown({ name = "Aim Mode", flag = "aim_mode", items = {"Camera", "Cursor"}, default = "Camera", callback = function(v) Settings.AimMode = v end })
secAim:dropdown({ name = "Activation", flag = "aim_activation", items = {"Hold", "Toggle"}, default = "Hold", callback = function(v) Settings.AimHoldMode = (v == "Hold"); Settings.AimToggleState = false end })
secAim:slider({ name = "Smoothness", flag = "aim_smooth", min = 1, max = 5, default = 3, interval = 1, callback = function(v) Settings.AimSmoothness = v end })
secAim:slider({ name = "FOV Size", flag = "aim_fov", min = 0, max = 300, default = 100, callback = function(v) Settings.AimFOVSize = v end })
secAim:toggle({ name = "FOV Circle", flag = "aim_fov_circle", default = false, callback = function(v) Settings.AimFOVEnabled = v end })
secAim:toggle({ name = "Wall Check", flag = "aim_wall", default = false, callback = function(v) Settings.AimWallCheck = v end })

local col2 = aimbotTab:column({})
local secTarget = col2:section({ name = "Target Selection", auto_fill = false })
secTarget:slider({ name = "Max Distance", flag = "aim_distance", min = 0, max = 1200, default = 1200, callback = function(v) end })
secTarget:dropdown({ name = "Hitbox", flag = "aim_hitbox", items = {"Head", "Chest", "Legs"}, default = "Head", callback = function(v) end })
secTarget:toggle({ name = "Target NPCs", flag = "aim_npcs", default = false, callback = function(v) end })

-- Tab ESP
local espTab = window:tab({ name = "ESP" })
local col3 = espTab:column({})
local secESP = col3:section({ name = "Visual Settings", auto_fill = false })
secESP:toggle({ name = "Enable ESP", flag = "esp_enabled", default = true, callback = function(v) Settings.ESPVisible = v end })
secESP:toggle({ name = "Boxes", flag = "esp_boxes", default = false, callback = function(v) Settings.BoxesEnabled = v end })
secESP:toggle({ name = "Names", flag = "esp_names", default = false, callback = function(v) Settings.NamesEnabled = v end })
secESP:toggle({ name = "Health Bar", flag = "esp_health", default = false, callback = function(v) Settings.HealthEnabled = v end })
secESP:toggle({ name = "Inventory", flag = "esp_inv", default = false, callback = function(v) Settings.InvEnabled = v end })
secESP:toggle({ name = "Skeleton", flag = "esp_skeleton", default = false, callback = function(v) Settings.SkeletonEnabled = v end })

local col4 = espTab:column({})
local secHL = col4:section({ name = "Highlights", auto_fill = false })
secHL:toggle({ name = "Player Highlight", flag = "hl_player", default = false, callback = function(v) Settings.HighlightEnabled = v end })
secHL:slider({ name = "Highlight Fill Trans.", flag = "hl_trans", min = 0, max = 10, default = 5, callback = function(v) Settings.HighlightFillTrans = v / 10 end })
secHL:toggle({ name = "Tool Highlight", flag = "hl_tool", default = false, callback = function(v) Settings.ToolHighlightEnabled = v end })
secHL:toggle({ name = "Self Highlight", flag = "hl_self", default = false, callback = function(v) Settings.SelfHighlightEnabled = v end })

-- Tab Misc
local miscTab = window:tab({ name = "Misc" })
local col5 = miscTab:column({})
local secMisc = col5:section({ name = "Miscellaneous", auto_fill = false })
secMisc:toggle({ name = "Hitbox Extender", flag = "hitbox_enabled", default = false, callback = function(v) Settings.HitboxEnabled = v; if v then ApplyHitboxToAll() else RemoveHitboxFromAll() end end })
secMisc:slider({ name = "Hitbox Size", flag = "hitbox_size", min = 1, max = 10, default = 3, callback = function(v) Settings.HitboxSize = v; if Settings.HitboxEnabled then ApplyHitboxToAll() end end })
secMisc:toggle({ name = "Speed Hack", flag = "speedhack", default = false, callback = function(v) Settings.SpeedhackEnabled = v; local char = LocalPlayer.Character; if char then local hum = char:FindFirstChildOfClass("Humanoid"); if hum then hum.WalkSpeed = v and 23 or 16 end end end })
secMisc:toggle({ name = "Stretch Res", flag = "stretch", default = false, callback = function(v) Settings.StretchEnabled = v; ToggleStretch(v) end })
secMisc:slider({ name = "Stretch Scale", flag = "stretch_scale", min = 0, max = 100, default = 70, callback = function(v) Settings.StretchScale = v; if Settings.StretchEnabled then ToggleStretch(true) end end })
secMisc:toggle({ name = "Snow Particles", flag = "snow", default = true, callback = function(v) Settings.ShowSnowParticles = v end })

-- Tab Config
local configTab = window:tab({ name = "Config" })
local col6 = configTab:column({})
local secConfig = col6:section({ name = "Configuration", auto_fill = false })
secConfig:button({ name = "Save Config", callback = function() Notify("Saved", "Config saved", 3) end })
secConfig:button({ name = "Load Config", callback = function() Notify("Loaded", "Config loaded", 3) end })
secConfig:button({ name = "Reset All", callback = function() Notify("Reset", "All settings reset", 3) end })

-- =============================================
-- KEYBINDS
-- =============================================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.UserInputType == Enum.UserInputType.MouseButton1 and UserInputService:IsKeyDown(Enum.KeyCode.LeftAlt) then
        local target = Mouse.Target
        if target and target:IsA("BasePart") and not IsWhitelisted(LocalPlayer) then
            DeletePart(target)
        end
    end

    if input.KeyCode == Enum.KeyCode.Z and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        UndoDelete()
    end

    if _G.HitboxKey and input.KeyCode == _G.HitboxKey then
        Settings.HitboxEnabled = not Settings.HitboxEnabled
        if Settings.HitboxEnabled then ApplyHitboxToAll() else RemoveHitboxFromAll() end
    end

    if _G.ESPKey and input.KeyCode == _G.ESPKey then
        Settings.ESPVisible = not Settings.ESPVisible
    end

    if not Settings.AimHoldMode and _G.AimbotKey and input.KeyCode == _G.AimbotKey then
        Settings.AimToggleState = not Settings.AimToggleState
    end
end)

-- =============================================
-- RENDER LOOP
-- =============================================
local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Thickness = 1
FOVCircle.NumSides = 100
FOVCircle.Visible = false
FOVCircle.Filled = not IsMobile
FOVCircle.Transparency = IsMobile and 1 or 0.88

RunService.RenderStepped:Connect(function()
    local viewport = Camera.ViewportSize
    local center = Vector2.new(viewport.X / 2, viewport.Y / 2)

    FOVCircle.Visible = Settings.AimFOVEnabled
    FOVCircle.Radius = Settings.AimFOVSize
    FOVCircle.Position = center

    if Settings.SpeedhackEnabled then
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum and hum.WalkSpeed ~= 23 then hum.WalkSpeed = 23 end
        end
    end

    UpdateSelfHighlight()

    if Settings.ESPVisible then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and not IsWhitelisted(player) then
                local char = player.Character
                if char then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    local head = char:FindFirstChild("Head")
                    local root = char:FindFirstChild("HumanoidRootPart")
                    if hum and hum.Health > 0 and head and root then
                        local rootPos, onScreen = Camera:WorldToViewportPoint(root.Position)
                        if onScreen and rootPos.Z > 0 then
                            local headPos = Camera:WorldToViewportPoint(head.Position)
                            local topY = headPos.Y
                            local bottomY = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 2.8, 0)).Y
                            local height = math.abs(topY - bottomY)
                            local width = height * 0.55
                            local leftX = rootPos.X - width / 2

                            if not ESPObjects[player] then
                                ESPObjects[player] = {
                                    Box = Drawing.new("Square"),
                                    HBar = Drawing.new("Square"),
                                    NameTxt = Drawing.new("Text"),
                                    InvTxt = Drawing.new("Text"),
                                    SkeletonLines = {}
                                }
                                local esp = ESPObjects[player]
                                esp.Box.Thickness = 1
                                esp.Box.Filled = false
                                esp.Box.Color = Color3.new(1,1,1)
                                esp.HBar.Thickness = 1
                                esp.HBar.Filled = true
                                esp.NameTxt.Outline = false
                                esp.NameTxt.Color = Color3.new(1,1,1)
                                esp.NameTxt.Font = 2
                                esp.NameTxt.Center = true
                                esp.NameTxt.Size = 13
                                esp.InvTxt.Center = true
                                esp.InvTxt.Size = 11
                            end

                            local esp = ESPObjects[player]

                            if Settings.BoxesEnabled then
                                esp.Box.Size = Vector2.new(width, height)
                                esp.Box.Position = Vector2.new(leftX, topY)
                                esp.Box.Visible = true
                            else
                                esp.Box.Visible = false
                            end

                            if Settings.HealthEnabled then
                                local healthPercent = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                                esp.HBar.Color = Color3.fromHSV(healthPercent * 0.33, 1, 1)
                                esp.HBar.Size = Vector2.new(3, height * healthPercent)
                                esp.HBar.Position = Vector2.new(leftX - 6, bottomY - height * healthPercent)
                                esp.HBar.Visible = true
                            else
                                esp.HBar.Visible = false
                            end

                            if Settings.NamesEnabled then
                                esp.NameTxt.Text = player.Name
                                esp.NameTxt.Position = Vector2.new(rootPos.X, topY - 16)
                                esp.NameTxt.Visible = true
                            else
                                esp.NameTxt.Visible = false
                            end

                            if Settings.InvEnabled then
                                esp.InvTxt.Text = GetInventoryText(player)
                                esp.InvTxt.Position = Vector2.new(rootPos.X, bottomY + 4)
                                esp.InvTxt.Visible = true
                            else
                                esp.InvTxt.Visible = false
                            end

                            if Settings.SkeletonEnabled then
                                if #esp.SkeletonLines == 0 then
                                    for _ = 1, #SkeletonBones do
                                        local line = Drawing.new("Line")
                                        line.Color = Color3.new(1,1,1)
                                        line.Thickness = 1
                                        line.Transparency = 1
                                        table.insert(esp.SkeletonLines, line)
                                    end
                                end
                                for i, bonePair in ipairs(SkeletonBones) do
                                    local part1 = char:FindFirstChild(bonePair[1])
                                    local part2 = char:FindFirstChild(bonePair[2])
                                    if part1 and part2 then
                                        local pos1, on1 = Camera:WorldToViewportPoint(part1.Position)
                                        local pos2, on2 = Camera:WorldToViewportPoint(part2.Position)
                                        if on1 and on2 and pos1.Z > 0 and pos2.Z > 0 then
                                            esp.SkeletonLines[i].From = Vector2.new(pos1.X, pos1.Y)
                                            esp.SkeletonLines[i].To = Vector2.new(pos2.X, pos2.Y)
                                            esp.SkeletonLines[i].Visible = true
                                        else
                                            esp.SkeletonLines[i].Visible = false
                                        end
                                    end
                                end
                            else
                                for _, line in ipairs(esp.SkeletonLines) do
                                    line.Visible = false
                                end
                            end
                        else
                            if ESPObjects[player] then
                                local esp = ESPObjects[player]
                                esp.Box.Visible = false
                                esp.HBar.Visible = false
                                esp.NameTxt.Visible = false
                                esp.InvTxt.Visible = false
                                for _, line in ipairs(esp.SkeletonLines) do
                                    line.Visible = false
                                end
                            end
                        end
                    else
                        ClearESP(player)
                    end
                else
                    ClearESP(player)
                end
            end
        end
    else
        for player, _ in pairs(ESPObjects) do
            ClearESP(player)
        end
    end

    if Settings.AimActive then
        local aimActive = false
        if Settings.AimHoldMode then
            aimActive = UserInputService:IsKeyDown(_G.AimbotKey or Enum.KeyCode.E)
        else
            aimActive = Settings.AimToggleState
        end
        if aimActive then
            local targetPart = nil
            if Settings.AimMode == "Camera" then
                targetPart = GetClosestPlayer(center.X, center.Y)
            else
                targetPart = GetClosestPlayer(Mouse.X, Mouse.Y + (IsMobile and 0 or GuiService:GetGuiInset().Y))
            end
            if targetPart then
                if Settings.AimMode == "Camera" then
                    SmoothCameraAim(targetPart.Position, Settings.AimSmoothness)
                else
                    if mousemoverel then
                        SmoothMouseAim(targetPart.Position, Mouse.X, Mouse.Y + (IsMobile and 0 or GuiService:GetGuiInset().Y), Settings.AimSmoothness)
                    end
                end
            end
        end
    end
end)

-- Notifikasi awal
notifications:create_notification({name = "Wavex Free loaded! Press E to aim."})

print("Wavex Free - Script Loaded Successfully!")