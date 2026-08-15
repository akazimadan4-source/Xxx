    v7 = #v6 == 0;
    a = table.remove(v6, math.random(1, #v6));
    r20[a] = string.char(a - 1);
    a = #v6;
    if a == 0 then
        r21 = {};
        r23 = {};
        r16 = setmetatable({}, {
            ["__index"] = r23,
            ["__metatable"] = nil
        });
        x = game;
        x.GetService(x, "Players");
        r24 = game.Players.LocalPlayer;
        x = game;
        r25 = x.GetService(x, "UserInputService");
        k = game;
        r26 = k.GetService(k, "TweenService");
        v4 = game;
        r27 = v4.GetService(v4, "VirtualInputManager");
        D = game;
        D.GetService(D, "RunService");
        D = game;
        M = D.GetService(D, "ReplicatedStorage");
        D = game;
        D.GetService(D, "ContextActionService");
        D = game;
        r28 = D.GetService(D, "VirtualUser");
        r29 = CFrame.new(729.86, 3.71, 444.46) * CFrame.Angles(-3.14, .01, -3.14);
        (function(...)
            v5 = r24.CharacterAdded;
            v5.Connect(v5, function(arg1_2, ...)
                v1 = arg1_2;
                task.wait(.1);
                y = v1.FindFirstChild(v1, "HumanoidRootPart");
                if y then
                    y.Anchored = true;
                    y.CFrame = r29;
                    task.wait(.05);
                    y.Anchored = false;
                end;
                return; 
            end);
            return; 
        end)();
        a = M.FindFirstChild(M, "RemoteEvents");
        if a then
            f = a.FindFirstChild(a, "StorePurchase");
        end;
        v5 = Q[y];
        r30 = a;
        f = r24.Character;
        task.wait();
        if r24.Character then
            f = r24;
            r31 = CFrame.new(537.71, 4.59, -537.09) * CFrame.Angles(-1.2, -1.56, -1.2);
            r32 = 10;
            r33 = true;
            r34 = 5;
            r35 = false;
            r36 = false;
            r40 = 100;
            local function r41(...)
                v1 = r24.Character;
                if v1 then
                    n = v1.FindFirstChildOfClass(v1, "Humanoid");
                end;
                if not v1 or not v1 then
                    return false;
                end;
                x = v1.SeatPart;
                if x then
                    G = x.FindFirstAncestorOfClass(x, "Model");
                    if G then
                        if G.PrimaryPart or (G.FindFirstChildOfClass(G, "VehicleSeat") or G.FindFirstChildOfClass(G, "BasePart")) then
                            v5 = ipairs;
                            D = v5.GetDescendants;
                            v4 = {
                                D(v5)
                            };
                            k = D[3];
                            v4 = D[1];
                            for k, L in v4, v5(z(v4)) do
                                D = k;
                                r42 = L;
                                v5 = r42;
                                if v5.IsA(v5, "BasePart") then
                                    pcall(function(...)
                                        r42.AssemblyLinearVelocity = Vector3.zero;
                                        r42.AssemblyAngularVelocity = Vector3.zero;
                                        r42.Anchored = true;
                                        return; 
                                    end);
                                end; 
                            end;
                            task.wait(.05);
                            if v5.PrimaryPart then
                                v5.SetPrimaryPartCFrame(v5, Q[B]);
                            else
                                n.CFrame = r31;
                            end;
                            task.wait(.05);
                            v5 = ipairs;
                            L = v5.GetDescendants;
                            k = L[2];
                            v4 = L[3];
                            for v4, L in v5(L(v5)) do
                                D = v4;
                                r43 = L;
                                v5 = r43;
                                if v5.IsA(v5, "BasePart") then
                                    pcall(function(...)
                                        r43.Anchored = false;
                                        r43.AssemblyLinearVelocity = Vector3.zero;
                                        r43.AssemblyAngularVelocity = Vector3.zero;
                                        return; 
                                    end);
                                end; 
                            end;
                        end;
                        return true;
                    end;
                else
                    G = v1.FindFirstChild(v1, "HumanoidRootPart");
                    if G then
                        G.Anchored = true;
                        G.CFrame = r31;
                        task.wait(.05);
                        G.Anchored = false;
                        return true;
                    end;
                    return false;
                end; 
            end;
            local function r44(arg1_3, ...)
                v1 = arg1_3;
                y = r24.Character;
                x = y and y.FindFirstChildOfClass(y, "Humanoid");
                if not y or not x then
                    return false;
                end;
                G = x.SeatPart;
                if G then
                    U = G.FindFirstAncestorOfClass(G, "Model");
                    if U then
                        if U.PrimaryPart or (U.FindFirstChildOfClass(U, "VehicleSeat") or U.FindFirstChildOfClass(U, "BasePart")) then
                            v5 = ipairs;
                            L = v5.GetDescendants;
                            D = {
                                L(v5)
                            };
                            v4 = L[3];
                            D = L[1];
                            for v4, M in D, v5(z(D)) do
                                L = v4;
                                r45 = M;
                                v5 = r45;
                                if v5.IsA(v5, "BasePart") then
                                    pcall(function(...)
                                        r45.AssemblyLinearVelocity = Vector3.zero;
                                        r45.AssemblyAngularVelocity = Vector3.zero;
                                        r45.Anchored = true;
                                        return; 
                                    end);
                                end; 
                            end;
                            task.wait(.05);
                            if v5.PrimaryPart then
                                v5.SetPrimaryPartCFrame(v5, arg1_3);
                            else
                                n.CFrame = arg1_3;
                            end;
                            M = v5.GetDescendants;
                            task.wait(.05);
                            v5 = ipairs;
                            k = M[1];
                            v4 = M[2];
                            for D, M in v5(M(v5)) do
                                L = D;
                                r46 = M;
                                v5 = r46;
                                if v5.IsA(v5, "BasePart") then
                                    pcall(function(...)
                                        r46.Anchored = false;
                                        r46.AssemblyLinearVelocity = Vector3.zero;
                                        r46.AssemblyAngularVelocity = Vector3.zero;
                                        return; 
                                    end);
                                end; 
                            end;
                        end;
                        return true;
                    end;
                else
                    U = y.FindFirstChild(y, "HumanoidRootPart");
                    if U then
                        U.Anchored = true;
                        v2 = arg1_3;
                        U.CFrame = v2;
                        task.wait(.05);
                        U.Anchored = false;
                        return true;
                    end;
                    return false;
                end; 
            end;
            local function Cu(arg1_4, ...)
                v1 = arg1_4;
                r39 = v1.WaitForChild(v1, "Humanoid");
                r40 = r39.Health / r39.MaxHealth * 100;
                r36 = false;
                if r38 then
                    task.cancel(r38);
                end;
                return; 
            end;
            if r24.Character then
                Cu(r24.Character);
            end;
            yu = r24.CharacterAdded;
            yu.Connect(yu, Cu);
            local function r47(...)
                v1 = r24.Character;
                y = v1 and v1.FindFirstChild(v1, "HumanoidRootPart");
                if y then
                    r37 = y.CFrame;
                    return true;
                end;
                return false; 
            end;
            local function r48(...)
                if r37 then
                    r44(r37);
                end;
                r36 = false;
                return; 
            end;
            local function r49(...)
                if r38 then
                    task.cancel(r38);
                end;
                r38 = task.spawn(function(...)
                    task.wait(8);
                    if r36 and r35 then
                        r48();
                    end;
                    return; 
                end);
                return; 
            end;
            local function r50(...)
                if not r35 then
                    return;
                end;
                if not r39 or r39.Parent == nil then
                    v1 = r24.Character;
                    if v1 then
                        r39 = v1.FindFirstChildOfClass(v1, "Humanoid");
                    end;
                    if not r39 then
                        return;
                    end;
                end;
                y = r39.MaxHealth;
                if y > 0 then
                    x = r39.Health / y * 100;
                    v5 = not r35;
                    if r40 - x >= 1 and not r36 then
                        r47();
                        if r41() then
                            r36 = true;
                            r49();
                        end;
                    end;
                    r40 = x;
                end;
                return; 
            end;
            local function r52(...)
                if r35 then
                    return;
                end;
                r35 = true;
                r36 = false;
                if r39 then
                    r40 = r39.Health / r39.MaxHealth * 100;
                else
                    r40 = 100;
                end;
                if r38 then
                    task.cancel(r38);
                end;
                r51 = task.spawn(function(...)
                    while r35 do
                        r50();
                        task.wait(.3); 
                    end;
                    return; 
                end);
                return; 
            end;
            local function r53(...)
                r35 = false;
                if r38 then
                    task.cancel(r38);
                end;
                if r51 then
                    task.cancel(r51);
                end;
                if r36 then
                    r48();
                end;
                r36 = false;
                return; 
            end;
            local function r54(...)
                v1 = r24.Character;
                y = v1 and v1.FindFirstChild(v1, "HumanoidRootPart");
                if y then
                    y.CFrame = y.CFrame + y.CFrame.LookVector * 8;
                end;
                return; 
            end;
            g.BindAction(g, "blink_forward", function(arg1_5, arg2_5, ...)
                v1 = arg1_5;
                if arg2_5 == Enum.UserInputState.Begin and r33 then
                    r54();
                end;
                return; 
            end, false, Enum.KeyCode.v6);
            Su = r24.Idled;
            Su.Connect(Su, function(...)
                v5 = r28;
                v5.CaptureController(v5);
                v5 = r28;
                v5.ClickButton2(v5, Vector2.new());
                return; 
            end);
            local function r55(arg1_6, ...)
                v5 = r27;
                v5.SendKeyEvent(v5, true, "E", false, game);
                v5 = task.wait;
                v5(arg1_6 or .7);
                n = r27;
                n.SendKeyEvent(n, false, "E", false, game);
                return; 
            end;
            local function r56(arg1_7, ...)
                v1 = arg1_7;
                y = r24.Character;
                x = r24.Backpack;
                G = x.FindFirstChild(x, v1);
                if G then
                    x = G;
                    if x then
                        v5 = y.Humanoid;
                        v5.EquipTool(v5, x);
                        task.wait(.3);
                        return true;
                    end;
                    return false;
                else
                    n = y.FindFirstChild(y, v1);
                end; 
            end;
            local function r57(arg1_8, ...)
                v1 = arg1_8;
                U = r24.Backpack;
                G = U[3];
                U = U[1];
                for G, k in U, pairs(U.GetChildren(U)) do
                    v2 = G;
                    if k.Name == v1 then
                        0 = 0 + 1;
                    end; 
                end;
                k = r24.Character;
                v2 = k[3];
                U = k[2];
                for v2, k in pairs(k.GetChildren(k)) do
                    x = v2;
                    v5 = pairs;
                    if k.IsA(k, "Tool") and k.Name == v1 then
                        0 = 0 + 1;
                    end; 
                end;
                return 0; 
            end;
            local function r58(arg1_9, ...)
                v1 = arg1_9;
                y = r24.Character;
                if y then
                    n = y.FindFirstChildOfClass(y, "Humanoid");
                end;
                if not y or not y then
                    return;
                end;
                G = y.SeatPart;
                if G then
                    U = G.FindFirstAncestorOfClass(G, "Model");
                    if U then
                        n = U.PrimaryPart;
                    end;
                    if U then
                        U.SetPrimaryPartCFrame(U, CFrame.new(arg1_9 + Vector3.new(0, 2, 0)));
                    end;
                else
                    U = y.FindFirstChild(y, "HumanoidRootPart");
                    if U then
                        U.Anchored = true;
                        U.CFrame = CFrame.new(arg1_9 + Vector3.new(0, 3, 0));
                        task.wait(.05);
                        U.Anchored = false;
                    end;
                    return;
                end; 
            end;
            r59 = Instance.new("ScreenGui");
            r59.Name = "191_STORE";
            eu = f.WaitForChild(f, "PlayerGui");
            r59.Parent = eu;
            r59.ResetOnSpawn = false;
            r59.ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
            r60 = {
                ["bg"] = Color3.fromRGB(8, 8, 16),
                ["surface"] = Color3.fromRGB(13, 13, 22),
                ["panel"] = Color3.fromRGB(18, 18, 28),
                ["card"] = Color3.fromRGB(22, 22, 36),
                ["sidebar"] = Color3.fromRGB(10, 10, 20),
                ["accent"] = Color3.fromRGB(0, 110, 220),
                ["accentDim"] = Color3.fromRGB(0, 70, 150),
                ["accentGlow"] = Color3.fromRGB(50, 150, 255),
                ["accentSoft"] = Color3.fromRGB(0, 90, 190),
                ["text"] = Color3.fromRGB(230, 235, 255),
                ["textMid"] = Color3.fromRGB(150, 160, 200),
                ["textDim"] = Color3.fromRGB(80, 85, 120),
                ["green"] = Color3.fromRGB(40, 200, 100),
                ["red"] = Color3.fromRGB(220, 60, 70),
                ["border"] = Color3.fromRGB(40, 45, 65)
            };
            r61 = Instance.new("Frame", r59);
            r61.Size = UDim2.new(0, 520, 0, 420);
            r61.Position = UDim2.new(0.5, -260, 0.5, -210);
            r61.BackgroundColor3 = r60.bg;
            r61.Active = true;
            r61.Draggable = true;
            r61.ClipsDescendants = false;
            Instance.new("UICorner", r61).CornerRadius = UDim.new(0, 12);
            Zu = Instance.new("UIStroke", r61);
            Zu.Color = r60.border;
            Zu.Thickness = 1;
            ou = Instance.new("Frame", r61);
            ou.Size = UDim2.new(1, 0, 0, 46);
            ou.BackgroundColor3 = r60.surface;
            ou.ZIndex = 2;
            Instance.new("UICorner", ou).CornerRadius = UDim.new(0, 12);
            su = Instance.new("Frame", ou);
            su.Size = UDim2.new(1, 0, 0, 12);
            su.Position = UDim2.new(0, 0, 1, -12);
            su.BackgroundColor3 = r60.surface;
            su.BorderSizePixel = 0;
            Yu = Instance.new("TextLabel", ou);
            Yu.Position = UDim2.new(0, 28, 0, 0);
            Yu.Size = UDim2.new(0, 160, 1, 0);
            Yu.BackgroundTransparency = 1;
            Yu.Text = "191 STORE";
            Yu.Font = Enum.Font.GothamBlack;
            Yu.TextSize = 15;
            Yu.TextColor3 = r60.text;
            Yu.TextXAlignment = Enum.TextXAlignment.Left;
            Yu.TextStrokeTransparency = 1;
            su = Instance.new("TextButton", ou);
            su.Size = UDim2.new(0, 28, 0, 28);
            su.Position = UDim2.new(1, -38, 0.5, -14);
            su.BackgroundColor3 = Color3.fromRGB(50, 15, 22);
            su.Text = "x";
            su.Font = Enum.Font.GothamBold;
            su.TextSize = 12;
            su.TextColor3 = r60.red;
            su.BorderSizePixel = 0;
            su.TextStrokeTransparency = 1;
            Instance.new("UICorner", su).CornerRadius = UDim.new(0, 6);
            eu = su.MouseButton1Click;
            eu.Connect(eu, function(...)
                v5 = r59;
                v5.Destroy(v5);
                return; 
            end);
            Yu = Instance.new("TextButton", ou);
            Yu.Size = UDim2.new(0, 28, 0, 28);
            Yu.Position = UDim2.new(1, -72, 0.5, -14);
            Yu.BackgroundColor3 = r60.card;
            Yu.Text = "-";
            Yu.Font = Enum.Font.GothamBold;
            Yu.TextSize = 14;
            Yu.TextColor3 = r60.textMid;
            Yu.BorderSizePixel = 0;
            Yu.TextStrokeTransparency = 1;
            Instance.new("UICorner", Yu).CornerRadius = UDim.new(0, 6);
            r62 = Instance.new("Frame", r61);
            r62.Size = UDim2.new(0, 70, 1, -46);
            r62.Position = UDim2.new(0, 0, 0, 46);
            r62.BackgroundColor3 = r60.sidebar;
            r62.ZIndex = 2;
            r62.ClipsDescendants = false;
            Mu = Instance.new("Frame", r61);
            Mu.Size = UDim2.new(0, 1, 1, -46);
            Mu.Position = UDim2.new(0, 69, 0, 46);
            Mu.BackgroundColor3 = r60.border;
            Mu.BorderSizePixel = 0;
            Mu.ZIndex = 3;
            Lu = Instance.new("UIListLayout", r62);
            Lu.Padding = UDim.new(0, 4);
            Lu.HorizontalAlignment = Enum.HorizontalAlignment.Center;
            Lu.VerticalAlignment = Enum.VerticalAlignment.Top;
            Lu.SortOrder = Enum.SortOrder.LayoutOrder;
            Instance.new("UIPadding", r62).PaddingTop = UDim.new(0, 10);
            r63 = Instance.new("Frame", r61);
            r63.Size = UDim2.new(1, -70, 1, -46);
            r63.Position = UDim2.new(0, 70, 0, 46);
            r63.BackgroundColor3 = r60.panel;
            r63.ClipsDescendants = true;
            Instance.new("UICorner", r63).CornerRadius = UDim.new(0, 0);
            r64 = {};
            r65 = {};
            Fu = "label";
            Nu = "label";
            Bu = "SELL";
            du = "order";
            Bu = "label";
            local function r67(arg1_10, ...)
                v1 = arg1_10;
                G = r64;
                x = U[3];
                G = U[1];
                for x, v2 in G, pairs(G) do
                    v2.Visible = x == v1; 
                end;
                G = v2[3];
                for G, v2 in v2[1], pairs(r65) do
                    if G == v1 then
                        v2.BackgroundColor3 = r60.accentDim;
                        v2.BackgroundTransparency = 0;
                        v2.TextColor3 = r60.accentGlow;
                    else
                        v2.BackgroundTransparency = 1;
                        v2.TextColor3 = r60.textDim;
                    end; 
                end;
                r66 = v1;
                return; 
            end;
            tu = Fu[1];
            fu = Fu[2];
            for Au, Fu in ipairs({
                {
                    ["label"] = "AUTO",
                    ["order"] = 1
                },
                {
                    ["label"] = "FULLY",
                    ["order"] = 2
                },
                {
                    ["label"] = "TP",
                    ["order"] = 3
                },
                {
                    ["label"] = "MS POT",
                    ["order"] = 4
                },
                {
                    [Fu] = "BUY",
                    ["order"] = 5
                },
                Fu,
                {
                    [Bu] = "SETTINGS",
                    ["order"] = 7
                }
            }), Bu do
                r68 = Fu;
                lu = Au;
                r69 = Instance.new("TextButton", r62);
                r69.Size = UDim2.new(0, 62, 0, 36);
                r69.BackgroundTransparency = 1;
                r69.Text = r68.label;
                r69.Font = Enum.Font.GothamBold;
                r69.TextSize = 10;
                r69.TextColor3 = r60.textDim;
                r69.BorderSizePixel = 0;
                r69.LayoutOrder = r68.order;
                r69.TextStrokeTransparency = 1;
                Instance.new("UICorner", r69).CornerRadius = UDim.new(0, 7);
                du = Instance.new("Frame", r69);
                du.Size = UDim2.new(0, 2, 0, 18);
                du.Position = UDim2.new(0, 0, 0.5, -9);
                du.BackgroundColor3 = r60.accent;
                du.BorderSizePixel = 0;
                du.Visible = false;
                Instance.new("UICorner", du).CornerRadius = UDim.new(0, 2);
                Iu = Instance.new("ScrollingFrame", r63);
                Iu.Size = UDim2.new(1, 0, 1, 0);
                Iu.BackgroundTransparency = 1;
                Iu.ScrollBarThickness = 3;
                Iu.ScrollBarImageColor3 = r60.accentSoft;
                Iu.Visible = false;
                Iu.BorderSizePixel = 0;
                Hu = Instance.new("UIListLayout", Iu);
                Hu.Padding = UDim.new(0, 6);
                Hu.SortOrder = Enum.SortOrder.LayoutOrder;
                Ru = Instance.new("UIPadding", Iu);
                Ru.PaddingTop = UDim.new(0, 12);
                Ru.PaddingLeft = UDim.new(0, 10);
                Ru.PaddingRight = UDim.new(0, 10);
                Ru.PaddingBottom = UDim.new(0, 12);
                r64[r68.label] = Iu;
                r65[r68.label] = r69;
                Bu = r69.MouseButton1Click;
                Bu.Connect(Bu, function(...)
                    G = r16;
                    r67(r68.label);
                    x = r65;
                    y = G[3];
                    x = G[1];
                    for y, U in x, pairs(x) do
                        G = y;
                        v2 = U.FindFirstChild(U, "Frame");
                        if v2 then
                            v2.Visible = U == r69;
                        end; 
                    end;
                    return; 
                end); 
            end;
            local function lu(arg1_11, arg2_11, arg3_11, ...)
                x = arg3_11;
                y = arg2_11;
                G = Instance.new("Frame", arg1_11);
                G.Size = UDim2.new(1, 0, 0, 22);
                G.BackgroundTransparency = 1;
                v5 = "LayoutOrder";
                G[v5] = x or 0;
                U = Instance.new("TextLabel", G);
                U.Size = UDim2.new(1, 0, 1, 0);
                U.BackgroundTransparency = 1;
                U.Text = y.upper(y);
                U.Font = Enum.Font.GothamBold;
                U.TextSize = 9;
                U.TextColor3 = r60.textDim;
                U.TextXAlignment = Enum.TextXAlignment.Left;
                U.LayoutOrder = x or 0;
                U.TextStrokeTransparency = 1;
                v2 = Instance.new("Frame", G);
                v2.Size = UDim2.new(1, 0, 0, 1);
                v2.Position = UDim2.new(0, 0, 1, -1);
                v2.BackgroundColor3 = r60.border;
                v2.BorderSizePixel = 0;
                return G; 
            end;
            local function Fu(arg1_12, arg2_12, arg3_12, ...)
                G = r70(arg1_12, 30, arg3_12);
                U = Instance.new("TextLabel", G);
                U.Position = UDim2.new(0, 12, 0, 0);
                U.Size = UDim2.new(.6, 0, 1, 0);
                U.BackgroundTransparency = 1;
                n = arg2_12;
                U.Text = n;
                U.Font = Enum.Font.GothamSemibold;
                U.TextSize = 11;
                U.TextColor3 = r60.textMid;
                U.TextXAlignment = Enum.TextXAlignment.Left;
                U.TextStrokeTransparency = 1;
                v2 = Instance.new("TextLabel", G);
                v2.Position = UDim2.new(.6, 0, 0, 0);
                v2.Size = UDim2.new(.4, -10, 1, 0);
                v2.BackgroundTransparency = 1;
                v2.Text = "0";
                v2.Font = Enum.Font.GothamBold;
                v2.TextSize = 12;
                v2.TextColor3 = r60.accentGlow;
                v2.TextXAlignment = Enum.TextXAlignment.Right;
                v2.TextStrokeTransparency = 1;
                return v2; 
            end;
            local function r70(arg1_13, arg2_13, arg3_13, ...)
                G = Instance.new("Frame", arg1_13);
                v5 = "Size";
                G[v5] = UDim2.new(1, 0, 0, arg2_13 or 46);
                G.BackgroundColor3 = r60.card;
                G.BorderSizePixel = 0;
                G.LayoutOrder = arg3_13 or 0;
                Instance.new("UICorner", G).CornerRadius = UDim.new(0, 8);
                return G; 
            end;
            local function Au(arg1_14, arg2_14, arg3_14, arg4_14, arg5_14, arg6_14, arg7_14, ...)
                r71 = arg3_14;
                r72 = arg4_14;
                U = arg5_14;
                r73 = arg7_14;
                v4 = r70(arg1_14, 54, arg6_14);
                D = Instance.new("TextLabel", v4);
                D.Position = UDim2.new(0, 12, 0, 8);
                D.Size = UDim2.new(1, -80, 0, 16);
                D.BackgroundTransparency = 1;
                n = arg2_14;
                D.Text = n;
                D.Font = Enum.Font.GothamSemibold;
                D.TextSize = 11;
                D.TextColor3 = r60.textMid;
                D.TextXAlignment = Enum.TextXAlignment.Left;
                D.TextStrokeTransparency = 1;
                r74 = Instance.new("TextLabel", v4);
                r74.Position = UDim2.new(1, -52, 0, 8);
                r74.Size = UDim2.new(0, 42, 0, 16);
                r74.BackgroundTransparency = 1;
                r74.Text = tostring(U);
                r74.Font = Enum.Font.GothamBold;
                r74.TextSize = 12;
                r74.TextColor3 = r60.accentGlow;
                r74.TextXAlignment = Enum.TextXAlignment.Right;
                r74.TextStrokeTransparency = 1;
                r75 = Instance.new("Frame", v4);
                r75.Position = UDim2.new(0, 12, 0, 34);
                r75.Size = UDim2.new(1, -24, 0, 5);
                r75.BackgroundColor3 = r60.border;
                r75.BorderSizePixel = 0;
                r75.Active = true;
                Instance.new("UICorner", r75).CornerRadius = UDim.new(1, 0);
                r76 = Instance.new("Frame", r75);
                r76.Size = UDim2.new((U - r71) / (r72 - r71), 0, 1, 0);
                r76.BackgroundColor3 = r60.accent;
                r76.BorderSizePixel = 0;
                Instance.new("UICorner", r76).CornerRadius = UDim.new(1, 0);
                r77 = Instance.new("Frame", r75);
                r77.Size = UDim2.new(0, 14, 0, 14);
                r77.Position = UDim2.new((U - r71) / (r72 - r71), -7, 0.5, -7);
                r77.BackgroundColor3 = Color3.new(1, 1, 1);
                r77.BorderSizePixel = 0;
                Instance.new("UICorner", r77).CornerRadius = UDim.new(1, 0);
                a = Instance.new("UIStroke", r77);
                a.Color = r60.accent;
                a.Thickness = 2;
                r78 = false;
                local function r79(arg1_15, ...)
                    y = math.clamp((arg1_15 - r75.AbsolutePosition.X) / r75.AbsoluteSize.X, 0, 1);
                    x = math.floor(r71 + y * (r72 - r71));
                    r77.Position = UDim2.new(y, -7, 0.5, -7);
                    r76.Size = UDim2.new(y, 0, 1, 0);
                    r74.Text = tostring(x);
                    if r73 then
                        r73(x);
                    end;
                    return; 
                end;
                v5 = r75.InputBegan;
                v5.Connect(v5, function(arg1_16, ...)
                    v1 = arg1_16;
                    if v1.UserInputType == Enum.UserInputType.MouseButton1 or v1.UserInputType == Enum.UserInputType.Touch then
                        r78 = true;
                        r79(v1.Position.X);
                    end;
                    return; 
                end);
                v5 = r25.InputChanged;
                v5.Connect(v5, function(arg1_17, ...)
                    v1 = arg1_17;
                    if r78 and v1.UserInputType == Enum.UserInputType.MouseMovement then
                        r79(v1.Position.X);
                    end;
                    return; 
                end);
                v5 = r25.InputEnded;
                v5.Connect(v5, function(arg1_18, ...)
                    v1 = arg1_18;
                    if v1.UserInputType == Enum.UserInputType.MouseButton1 or v1.UserInputType == Enum.UserInputType.Touch then
                        r78 = false;
                    end;
                    return; 
                end);
                return v4, r74; 
            end;
            local function fu(arg1_19, arg2_19, arg3_19, arg4_19, ...)
                r80 = arg3_19;
                r81 = Instance.new("TextButton", arg1_19);
                r81.Size = UDim2.new(1, 0, 0, 36);
                v5 = r81;
                v5.BackgroundColor3 = r80 or r60.accentDim;
                r81.Font = Enum.Font.GothamBold;
                r81.TextSize = 12;
                r81.TextColor3 = r60.text;
                v2 = arg2_19;
                r81.Text = v2;
                r81.BorderSizePixel = 0;
                v5 = r81;
                v5.LayoutOrder = arg4_19 or 0;
                r81.TextStrokeTransparency = 1;
                Instance.new("UICorner", r81).CornerRadius = UDim.new(0, 8);
                n = r81.MouseEnter;
                n.Connect(n, function(...)
                    v5 = r26;
                    n = v5.Create(v5, r81, TweenInfo.new(.12), {
                        ["BackgroundColor3"] = r60.accent
                    });
                    n.Play(n);
                    return; 
                end);
                n = r81.MouseLeave;
                n.Connect(n, function(...)
                    v5 = r26;
                    n = v5.Create(v5, r81, TweenInfo.new(.12), {
                        ["BackgroundColor3"] = r80 or r60.accentDim
                    });
                    n.Play(n);
                    return; 
                end);
                return r81; 
            end;
            Nu = r64.AUTO;
            U7[25] = 13364355979343;
            U7[3] = 3101183411620;
            lu(Nu, "MS LOOP AUTO COOK", 1);
            r82 = Fu(Nu, "Water", 2);
            r83 = Fu(Nu, "Sugar Block Bag", 3);
            r84 = Fu(Nu, "Gelatin", 4);
            U7[16] = 2768875570441;
            U7[14] = 33654540795191;
            r85 = Fu(Nu, "Empty Bag", 5);
            lu(Nu, "CONTROL", 6);
            U7[2] = "E\x87\xe1";
            U7[5] = "\xe5\x00\xd5";
            r86 = Instance.new("TextLabel", r70(Nu, 40, 7));
            U7[8] = 14642866903714;
            r86.Size = UDim2.new(1, -20, 1, 0);
            r86.Position = UDim2.new(0, 12, 0, 0);
            r86.BackgroundTransparency = 1;
            r86.Text = "STOPPED";
            U7[23] = 11945203537338;
            r86.Font = Enum.Font.GothamBold;
            r86.TextSize = 13;
            U7[20] = 32426828577531;
            r86.TextColor3 = r60.red;
            U7[28] = 2175492064245;
            r86.TextXAlignment = Enum.TextXAlignment.Left;
            r86.TextStrokeTransparency = 1;
            r87 = fu(Nu, "START MS LOOP", r60.green, 8);
            U7[13] = "\x97cRxB%X\x15\x92H@\x917?\x8d\x01\x13";
            r88 = false;
            local function r89(...)
                r82.Text = tostring(r57("Water"));
                r83.Text = tostring(r57("Sugar Block Bag"));
                r84.Text = tostring(r57("Gelatin"));
                r85.Text = tostring(r57("Empty Bag"));
                return; 
            end;
            local function r90(...)
                pcall(function(...)
                    local p = {
                        p[1],
                        p[2],
                        p[3],
                        p[4]
                    };
                    Q[p[1]]("Water");
                    Q[p[4]](.7);
                    for c = 20, 1, -1 do
                        U = v1;
                        task.wait(1); 
                    end;
                    Q[p[1]]("Sugar Block Bag");
                    Q[p[4]](.7);
                    task.wait(1);
                    Q[p[1]]("Gelatin");
                    Q[p[4]](.7);
                    task.wait(1);
                    for c = 45, 1, -1 do
                        U = v1;
                        task.wait(1); 
                    end;
                    Q[p[1]]("Empty Bag");
                    Q[p[4]](.7);
                    task.wait(1);
                    return; 
                end);
                return; 
            end;
            local function r91(...)
                while r88 do
                    r89();
                    r86.Text = "COOKING...";
                    r90();
                    r89();
                    task.wait(2); 
                end;
                r86.Text = "STOPPED";
                return; 
            end;
            z7 = r87.MouseButton1Click;
            z7.Connect(z7, function(...)
                if not r88 then
                    r52();
                    r88 = true;
                    r87.Text = "STOP MS LOOP";
                    n = r26;
                    v1 = n.Create(n, r87, TweenInfo.new(.2), {
                        ["BackgroundColor3"] = r60.red
                    });
                    v1.Play(v1);
                    r86.Text = "RUNNING";
                    r86.TextColor3 = r60.green;
                    task.spawn(r91);
                end;
                return; 
            end);
            z7 = fu(Nu, "STOP MS LOOP", r60.red, 9).MouseButton1Click;
            z7.Connect(z7, function(...)
                r53();
                r88 = false;
                r87.Text = "START MS LOOP";
                n = r26;
                v1 = n.Create(n, r87, TweenInfo.new(.2), {
                    ["BackgroundColor3"] = r60.green
                });
                v1.Play(v1);
                r86.Text = "STOPPED";
                r86.TextColor3 = r60.red;
                return; 
            end);
            z7 = r64.FULLY;
            U7[19] = " \xf2\xf0";
            lu(z7, "AUTO FULLY", 1);
            r92 = Fu(z7, "Water", 2);
            r93 = Fu(z7, "Sugar Block Bag", 3);
            U7[6] = 19897162392625;
            r94 = Fu(z7, "Gelatin", 4);
            U7[7] = 29901752235620;
            r95 = Fu(z7, "Empty Bag", 5);
            lu(z7, "SETTING", 6);
            U7[1] = {
                Au(z7, "TARGET FULLY", 1, 50, 5, 7, function(arg1_20, ...)
                    r34 = arg1_20;
                    return; 
                end)
            };
            n7 = U7[1][2];
            C7 = U7[1][1];
            U7[17] = 34511416327878;
            U7[1] = r15(U7[2], U7[3]);
            U7[3] = 21038950426181;
            U7[32] = 25120076164529;
            U7[2] = "\xab\x02\x85\x83\xe2`\x9e\xd1\x9f";
            U7[1] = r15(U7[2], U7[3]);
            U7[2] = "ua\x0c\x03";
            U7[3] = 5843504302753;
            r96 = Instance[r16[U7[1]]](r16[U7[1]], r70(z7, 40, 8));
            U7[26] = 21218901911192;
            U7[1] = r15(U7[2], U7[3]);
            U7[1] = "UDim2";
            U7[2] = r16;
            U7[3] = r15;
            U7[4] = U7[3](U7[5], U7[6]);
            U7[1] = U7[2][U7[4]];
            U7[2] = -20;
            U7[4] = 0;
            U7[3] = 1;
            U7[5] = "]\xfdK";
            U7[1] = 1;
            r96[r16[U7[1]]] = Env[U7[1]][U7[1]](U7[1], U7[2], U7[3], U7[4]);
            U7[2] = "\xbf\x8f\xcf\xdb.\x06\xde\xeb";
            U7[3] = 32916437285855;
            U7[1] = r15(U7[2], U7[3]);
            U7[1] = "UDim2";
            U7[6] = 7025875963079;
            U7[2] = r16;
            U7[3] = r15;
            U7[4] = U7[3](U7[5], U7[6]);
            U7[1] = U7[2][U7[4]];
            U7[3] = 0;
            U7[4] = 0;
            U7[2] = 12;
            U7[1] = 0;
            r96[r16[U7[1]]] = Env[U7[1]][U7[1]](U7[1], U7[2], U7[3], U7[4]);
            U7[3] = 31437757249839;
            U7[2] = "\xe2B\x88\xe0\xe7\xa1NOc;\xa8\x84O\x8a\x16\x9a-/]\x8b\x0e\x90";
            U7[1] = r15(U7[2], U7[3]);
            U7[27] = 3278914536950;
            r96[r16[U7[1]]] = 1;
            U7[3] = 19162846372571;
            U7[2] = "\\\xb9+\x1a";
            U7[6] = "\"I\xe1/";
            U7[1] = r15(U7[2], U7[3]);
            U7[4] = 30719282083808;
            U7[3] = "\xee\xbe!163\xf3";
            U7[1] = r15;
            U7[2] = U7[1](U7[3], U7[4]);
            r96[r16[U7[1]]] = r16[U7[2]];
            U7[2] = "\xb1\xda\xd1\x04";
            U7[3] = 30048206419624;
            U7[22] = 12753095563058;
            U7[1] = r15(U7[2], U7[3]);
            U7[2] = "Enum";
            U7[1] = Env[U7[2]];
            U7[24] = 17219424870226;
            U7[3] = r16;
            U7[4] = r15;
            U7[5] = U7[4](U7[6], U7[7]);
            U7[2] = U7[3][U7[5]];
            U7[5] = "\x9e\x04\xc38(\x06\x8e\xd8\r\xe7";
            U7[2] = r16;
            U7[3] = r15;
            U7[6] = 32414208883446;
            U7[4] = U7[3](U7[5], U7[6]);
            U7[1] = U7[2][U7[4]];
            r96[r16[U7[1]]] = U7[1][U7[2]][U7[1]];
            U7[3] = 6890127494280;
            U7[7] = 11929657972147;
            U7[21] = 17784922529881;
            U7[6] = 27099468132683;
            U7[2] = "2\xe9\x0c\x0fL_\x16\xe8";
            U7[1] = r15(U7[2], U7[3]);
            U7[3] = 15156081351569;
            U7[2] = "\xde\xba\xe7U\xd7M\x86\xee\x12\x90";
            r96[r16[U7[1]]] = 13;
            U7[1] = r15(U7[2], U7[3]);
            U7[5] = "\xab\xa1\x04";
            U7[2] = r16;
            U7[3] = r15;
            U7[4] = U7[3](U7[5], U7[6]);
            U7[1] = U7[2][U7[4]];
            r96[r16[U7[1]]] = r60[U7[1]];
            U7[2] = "n\xa5\xa2zo\x8e'D+\xe6\x04\xc8\x9e\x1a";
            U7[3] = 17925999206555;
            U7[1] = r15(U7[2], U7[3]);
            U7[2] = "Enum";
            U7[6] = "\x12\xc3\xa6\x03\xb2\x9e!4)\xed\x83V\xe4\xed";
            U7[1] = Env[U7[2]];
            U7[3] = r16;
            U7[4] = r15;
            U7[5] = U7[4](U7[6], U7[7]);
            U7[2] = U7[3][U7[5]];
            U7[6] = 31084012140682;
            U7[5] = "\x01\xa4\xfef";
            U7[2] = r16;
            U7[3] = r15;
            U7[4] = U7[3](U7[5], U7[6]);
            U7[1] = U7[2][U7[4]];
            U7[3] = 17586739748861;
            r96[r16[U7[1]]] = U7[1][U7[2]][U7[1]];
            U7[2] = "\xfdq\x1e\xf4.\"\x17\xa4\xf1\xc9T\xb8\x96\x9a\x87[@ju\xb9\xaf\xd6";
            U7[6] = 2749728277760;
            U7[1] = r15(U7[2], U7[3]);
            U7[3] = 30114622142151;
            r96[r16[U7[1]]] = 1;
            U7[2] = "\x82${j\xa7\xf3\x8c\xf3\xe9R(";
            U7[1] = r15(U7[2], U7[3]);
            U7[5] = "\xd8Ebh\n";
            U7[2] = r16;
            U7[3] = r15;
            U7[4] = U7[3](U7[5], U7[6]);
            U7[1] = U7[2][U7[4]];
            U7[7] = 425533128902;
            U7[15] = 28318523110274;
            U7[4] = 146019483715;
            r97 = fu(z7, r16[U7[1]], r60[U7[1]], 9);
            U7[30] = 1022749295068;
            U7[1] = r15;
            U7[3] = "\x86\xdb5\x8co\x04\x93b\xd9\x0e";
            U7[6] = "/\x95~";
            U7[2] = U7[1](U7[3], U7[4]);
            U7[1] = r60;
            U7[3] = r16;
            U7[4] = r15;
            U7[5] = U7[4](U7[6], U7[7]);
            U7[2] = U7[3][U7[5]];
            U7[1] = 10;
            U7[7] = "?7\xec";
            r98 = false;
            U7[3] = "Vector3";
            U7[1] = 85;
            Q[U7[1]] = nil;
            U7[2] = Env[U7[3]];
            U7[4] = r16;
            U7[5] = r15;
            U7[6] = U7[5](U7[7], U7[8]);
            U7[3] = U7[4][U7[6]];
            U7[5] = 600.548;
            U7[3] = 510.061;
            U7[4] = 4.476;
            U7[2] = U7[2][U7[3]](U7[3], U7[4], U7[5]);
            U7[4] = function(arg1_21, arg2_21, ...)
                x = arg1_21;
                r96.Text = x;
                x = arg2_21 and nil;
                x = r60.textMid;
                r96.TextColor3 = x;
                return; 
            end;
            U7[3] = function(...)
                r92.Text = tostring(r57("Water"));
                r93.Text = tostring(r57("Sugar Block Bag"));
                r94.Text = tostring(r57("Gelatin"));
                r95.Text = tostring(r57("Empty Bag"));
                return; 
            end;
            r99 = U7[2];
            U7[2] = 87;
            Q[U7[2]] = U7[3];
            U7[3] = 88;
            U7[5] = function(arg1_22, ...)
                v1 = arg1_22;
                if not r30 then
                    return;
                end;
                U = r16;
                G = U[3];
                U = U[1];
                for G, k in U, ipairs({
                    "Water",
                    "Sugar Block Bag",
                    "Gelatin",
                    "Empty Bag"
                }) do
                    r100 = k;
                    k = 119;
                    v2 = G;
                    if not r98 then
                        break;
                    else
                        Q[U7[3]]("BUYING " .. r100 .. " x" .. v1, Color3.fromRGB(100, 180, 255));
                        for L = 1, v1 do
                            v4 = L;
                            if not r98 then
                                
                            else
                                pcall(function(...)
                                    v5 = r30;
                                    v5.FireServer(v5, r100, 1);
                                    return; 
                                end);
                                task.wait(.4);
                            end; 
                        end;
                        task.wait(0.5);
                    end; 
                end;
                Q[U7[3]]("PURCHASE COMPLETE!", Color3.fromRGB(80, 220, 130));
                task.wait(1);
                return; 
            end;
            Q[U7[3]] = U7[4];
            U7[4] = 89;
            U7[6] = function(...)
                G = r15;
                x = G[3];
                G = G[1];
                for x, v2 in G, ipairs({
                    "Small Marshmallow Bag",
                    "Medium Marshmallow Bag",
                    "Large Marshmallow Bag"
                }) do
                    U = x;
                    r101 = v2;
                    v2 = 1;
                    if not r98 then
                        break;
                    end; 
                end;
                Q[U7[3]]("SELLING COMPLETE!", Color3.fromRGB(52, 210, 110));
                task.wait(1);
                return; 
            end;
            Q[U7[4]] = U7[5];
            U7[5] = 90;
            U7[7] = function(...)
                Q[U7[3]]("TARGET: " .. r34 .. " MS PER LOOP", Color3.fromRGB(100, 180, 255));
                while r98 do
                    Q[U7[3]]("TELEPORT TO NPC", Color3.fromRGB(100, 180, 255));
                    r58(r99);
                    task.wait(1);
                    v1 = r34;
                    Q[U7[4]](v1);
                    if not r98 then
                        break;
                    else
                        if Q[U7[1]] then
                            Q[U7[3]]("RETURN TO APARTMENT", Color3.fromRGB(148, 80, 255));
                            r58(Q[U7[1]]);
                            task.wait(1);
                        end;
                        Q[U7[2]]();
                        v1 = 0;
                        y = r98;
                        n = v1 < r34;
                        while not y do
                            if n then
                                Q[U7[3]]("COOKING MS " .. v1 + 1 .. "/" .. r34, Color3.fromRGB(82, 130, 255));
                                r90();
                                v1 = v1 + 1;
                                Q[U7[2]]();
                                task.wait(0.5);
                            end;
                            if not r98 then
                                break;
                            else
                                Q[U7[3]]("TELEPORT TO NPC FOR SELLING", Color3.fromRGB(52, 210, 110));
                                r58(r99);
                                task.wait(1);
                                Q[U7[5]]();
                                if not r98 then
                                    break;
                                else
                                    Q[U7[3]]("LOOP COMPLETE, RESTARTING...", Color3.fromRGB(100, 180, 255));
                                    task.wait(2);
                                end;
                            end; 
                        end;
                        n = v1 < r34;
                    end; 
                end;
                r98 = false;
                r97.Text = "START FULLY";
                v1 = r26;
                y = v1.Create(v1, r97, TweenInfo.new(.2), {
                    ["BackgroundColor3"] = r60.green
                });
                y.Play(y);
                Q[U7[3]]("STOPPED", r60.red);
                return; 
            end;
            Q[U7[5]] = U7[6];
            U7[6] = 91;
            Q[U7[6]] = U7[7];
            U7[8] = r97;
            U7[10] = r16;
            U7[11] = r15;
            U7[12] = U7[11](U7[13], U7[14]);
            U7[9] = U7[10][U7[12]];
            U7[7] = U7[8][U7[9]];
            U7[8] = "Connect";
            U7[9] = function(...)
                if r98 then
                    return;
                end;
                v1 = r24.Character;
                y = v1 and v1.FindFirstChild(v1, "HumanoidRootPart");
                if not y then
                    Q[U7[3]]("CANNOT GET POSITION!", r60.red);
                    return;
                end;
                Q[U7[1]] = y.Position;
                r98 = true;
                r52();
                r97.Text = "RUNNING...";
                x = r26;
                G = x.Create(x, r97, TweenInfo.new(.2), {
                    ["BackgroundColor3"] = r60.accentDim
                });
                G.Play(G);
                Q[U7[3]]("RUNNING", r60.green);
                task.spawn(Q[U7[6]]);
                return; 
            end;
            U7[8] = U7[7][U7[8]];
            U7[12] = "\xe5\xf0\x13\xc3\xf9\xba\xecD\xde\x0e1\xb4\xe1\x90\xe5\xdf\xcc";
            U7[8] = U7[8](U7[7], U7[9]);
            U7[13] = 8529213853571;
            U7[9] = r16;
            U7[10] = r15;
            U7[11] = U7[10](U7[12], U7[13]);
            U7[8] = U7[9][U7[11]];
            U7[9] = function(...)
                if not r98 then
                    return;
                end;
                r98 = false;
                r53();
                Q[U7[3]]("STOPPING...", r60.orange);
                return; 
            end;
            U7[7] = fu(z7, r16[U7[2]], U7[1][U7[2]], U7[1])[U7[8]];
            U7[14] = 30737165416425;
            U7[8] = "Connect";
            U7[8] = U7[7][U7[8]];
            U7[8] = U7[8](U7[7], U7[9]);
            U7[8] = r64;
            U7[10] = r16;
            U7[11] = r15;
            U7[13] = "\xa9\xa8";
            U7[12] = U7[11](U7[13], U7[14]);
            U7[9] = U7[10][U7[12]];
            U7[29] = 33011659455500;
            U7[14] = "{\x9fv\x1c";
            U7[7] = U7[8][U7[9]];
            U7[11] = r16;
            U7[12] = r15;
            U7[13] = U7[12](U7[14], U7[15]);
            U7[10] = U7[11][U7[13]];
            U7[15] = "\xafia\xb9\xdd\xf5\xeb\xa6\xaf\xba";
            U7[12] = r16;
            U7[13] = r15;
            U7[14] = U7[13](U7[15], U7[16]);
            U7[11] = U7[12][U7[14]];
            U7[13] = r16;
            U7[14] = r15;
            U7[16] = "\xbcx\x18";
            U7[15] = U7[14](U7[16], U7[17]);
            U7[12] = U7[13][U7[15]];
            U7[15] = "Vector3";
            U7[14] = Env[U7[15]];
            U7[16] = r16;
            U7[17] = r15;
            U7[18] = U7[17](U7[19], U7[20]);
            U7[15] = U7[16][U7[18]];
            U7[13] = U7[14][U7[15]];
            U7[17] = 433.75;
            U7[16] = 3.71;
            U7[15] = 770.992;
            U7[14] = U7[13](U7[15], U7[16], U7[17]);
            U7[16] = 32104894937702;
            U7[15] = "G\x96\xd9T";
            U7[17] = 26742094114980;
            U7[9] = {
                [U7[10]] = U7[11],
                [U7[12]] = U7[14]
            };
            U7[12] = r16;
            U7[13] = r15;
            U7[14] = U7[13](U7[15], U7[16]);
            U7[11] = U7[12][U7[14]];
            U7[13] = r16;
            U7[16] = "\xec\xcd\n\xa1C\x07\xadw]E:F8\x0c\x8f";
            U7[14] = r15;
            U7[15] = U7[14](U7[16], U7[17]);
            U7[17] = "\xc7\xa2S";
            U7[18] = 9572040200553;
            U7[12] = U7[13][U7[15]];
            U7[14] = r16;
            U7[15] = r15;
            U7[20] = "0\xe8z";
            U7[16] = U7[15](U7[17], U7[18]);
            U7[13] = U7[14][U7[16]];
            U7[16] = "Vector3";
            U7[15] = Env[U7[16]];
            U7[17] = r16;
            U7[18] = r15;
            U7[19] = U7[18](U7[20], U7[21]);
            U7[21] = "\xe7\xe7\xb9";
            U7[16] = U7[17][U7[19]];
            U7[17] = 4.476;
            U7[14] = U7[15][U7[16]];
            U7[18] = 600.548;
            U7[16] = 510.061;
            U7[15] = U7[14](U7[16], U7[17], U7[18]);
            U7[17] = 25355197984286;
            U7[18] = 6868188040318;
            U7[16] = "\xf1\xe1\xc9.";
            U7[10] = {
                [U7[11]] = U7[12],
                [U7[13]] = U7[15]
            };
            U7[13] = r16;
            U7[14] = r15;
            U7[15] = U7[14](U7[16], U7[17]);
            U7[12] = U7[13][U7[15]];
            U7[19] = 26077342576495;
            U7[14] = r16;
            U7[17] = "u\xdc\x7f\xfc\xa0\x13\xaf";
            U7[15] = r15;
            U7[16] = U7[15](U7[17], U7[18]);
            U7[18] = "\x8f\xc1|";
            U7[13] = U7[14][U7[16]];
            U7[15] = r16;
            U7[16] = r15;
            U7[17] = U7[16](U7[18], U7[19]);
            U7[14] = U7[15][U7[17]];
            U7[17] = "Vector3";
            U7[16] = Env[U7[17]];
            U7[18] = r16;
            U7[19] = r15;
            U7[20] = U7[19](U7[21], U7[22]);
            U7[17] = U7[18][U7[20]];
            U7[15] = U7[16][U7[17]];
            U7[18] = 9.932;
            U7[19] = 449.753;
            U7[17] = 1137.992;
            U7[16] = U7[15](U7[17], U7[18], U7[19]);
            U7[11] = {
                [U7[12]] = U7[13],
                [U7[14]] = U7[16]
            };
            U7[14] = r16;
            U7[17] = "5\xc1\xa9\x9b";
            U7[18] = 19245522133761;
            U7[15] = r15;
            U7[19] = 24547511266470;
            U7[16] = U7[15](U7[17], U7[18]);
            U7[18] = "x\x89\xdd\x1a\x18\xab\xda";
            U7[13] = U7[14][U7[16]];
            U7[15] = r16;
            U7[16] = r15;
            U7[17] = U7[16](U7[18], U7[19]);
            U7[14] = U7[15][U7[17]];
            U7[20] = 24266178456611;
            U7[16] = r16;
            U7[19] = "\xcd\xbf\xb9";
            U7[17] = r15;
            U7[18] = U7[17](U7[19], U7[20]);
            U7[15] = U7[16][U7[18]];
            U7[18] = "Vector3";
            U7[17] = Env[U7[18]];
            U7[22] = "\x08\xf1I";
            U7[19] = r16;
            U7[20] = r15;
            U7[21] = U7[20](U7[22], U7[23]);
            U7[18] = U7[19][U7[21]];
            U7[16] = U7[17][U7[18]];
            U7[18] = 1139.174;
            U7[19] = 9.932;
            U7[20] = 420.556;
            U7[17] = U7[16](U7[18], U7[19], U7[20]);
            U7[12] = {
                [U7[13]] = U7[14],
                [U7[15]] = U7[17]
            };
            U7[19] = 27838295503523;
            U7[23] = "\x14\xda\xdb";
            U7[15] = r16;
            U7[16] = r15;
            U7[18] = "H\xdfH/";
            U7[17] = U7[16](U7[18], U7[19]);
            U7[14] = U7[15][U7[17]];
            U7[20] = 7678378053111;
            U7[16] = r16;
            U7[19] = "\xf7\x01\x0c\xfe\x9c\x82E";
            U7[21] = 6145523616557;
            U7[17] = r15;
            U7[18] = U7[17](U7[19], U7[20]);
            U7[20] = "\xb7\xef:";
            U7[15] = U7[16][U7[18]];
            U7[17] = r16;
            U7[18] = r15;
            U7[19] = U7[18](U7[20], U7[21]);
            U7[16] = U7[17][U7[19]];
            U7[19] = "Vector3";
            U7[18] = Env[U7[19]];
            U7[20] = r16;
            U7[21] = r15;
            U7[22] = U7[21](U7[23], U7[24]);
            U7[19] = U7[20][U7[22]];
            U7[20] = 9.932;
            U7[21] = 247.28;
            U7[17] = U7[18][U7[19]];
            U7[19] = 984.856;
            U7[18] = U7[17](U7[19], U7[20], U7[21]);
            U7[13] = {
                [U7[14]] = U7[15],
                [U7[16]] = U7[18]
            };
            U7[20] = 17779508846679;
            U7[16] = r16;
            U7[19] = "\xee\xd3\\\xa2";
            U7[17] = r15;
            U7[18] = U7[17](U7[19], U7[20]);
            U7[24] = "X\xc8\x90";
            U7[15] = U7[16][U7[18]];
            U7[21] = 4481588594726;
            U7[17] = r16;
            U7[20] = "m\xcb\xff\xc4m6g";
            U7[18] = r15;
            U7[19] = U7[18](U7[20], U7[21]);
            U7[16] = U7[17][U7[19]];
            U7[21] = "\x01`\xe9";
            U7[22] = 23473598327474;
            U7[18] = r16;
            U7[19] = r15;
            U7[20] = U7[19](U7[21], U7[22]);
            U7[17] = U7[18][U7[20]];
            U7[20] = "Vector3";
            U7[19] = Env[U7[20]];
            U7[21] = r16;
            U7[22] = r15;
            U7[23] = U7[22](U7[24], U7[25]);
            U7[20] = U7[21][U7[23]];
            U7[22] = 221.664;
            U7[21] = 9.932;
            U7[18] = U7[19][U7[20]];
            U7[25] = "\x8e\xfb\xf9";
            U7[20] = 988.311;
            U7[19] = U7[18](U7[20], U7[21], U7[22]);
            U7[20] = "\xc0.i\xbd";
            U7[14] = {
                [U7[15]] = U7[16],
                [U7[17]] = U7[19]
            };
            U7[21] = 12689688057621;
            U7[17] = r16;
            U7[18] = r15;
            U7[22] = 28053721084679;
            U7[19] = U7[18](U7[20], U7[21]);
            U7[23] = 29439953139085;
            U7[16] = U7[17][U7[19]];
            U7[21] = "m\xac\xe0\x9e\x1f\xb3K";
            U7[18] = r16;
            U7[19] = r15;
            U7[20] = U7[19](U7[21], U7[22]);
            U7[17] = U7[18][U7[20]];
            U7[19] = r16;
            U7[22] = "\xa5\xcf\xdd";
            U7[20] = r15;
            U7[21] = U7[20](U7[22], U7[23]);
            U7[18] = U7[19][U7[21]];
            U7[21] = "Vector3";
            U7[20] = Env[U7[21]];
            U7[22] = r16;
            U7[23] = r15;
            U7[24] = U7[23](U7[25], U7[26]);
            U7[21] = U7[22][U7[24]];
            U7[22] = 9.932;
            U7[19] = U7[20][U7[21]];
            U7[23] = 42.202;
            U7[21] = 923.954;
            U7[20] = U7[19](U7[21], U7[22], U7[23]);
            U7[22] = 10144763531892;
            U7[15] = {
                [U7[16]] = U7[17],
                [U7[18]] = U7[20]
            };
            U7[18] = r16;
            U7[21] = "CG\xb1\x19";
            U7[19] = r15;
            U7[23] = 2486093644933;
            U7[20] = U7[19](U7[21], U7[22]);
            U7[26] = "\xc3&\xac";
            U7[17] = U7[18][U7[20]];
            U7[19] = r16;
            U7[20] = r15;
            U7[22] = "\xd0\xa2g`Ci\x08";
            U7[21] = U7[20](U7[22], U7[23]);
            U7[18] = U7[19][U7[21]];
            U7[20] = r16;
            U7[21] = r15;
            U7[23] = "\x19\xb9\xc5";
            U7[24] = 16771695222401;
            U7[22] = U7[21](U7[23], U7[24]);
            U7[19] = U7[20][U7[22]];
            U7[22] = "Vector3";
            U7[21] = Env[U7[22]];
            U7[23] = r16;
            U7[24] = r15;
            U7[25] = U7[24](U7[26], U7[27]);
            U7[24] = 41.928;
            U7[22] = U7[23][U7[25]];
            U7[20] = U7[21][U7[22]];
            U7[23] = 9.932;
            U7[22] = 895.721;
            U7[21] = U7[20](U7[22], U7[23], U7[24]);
            U7[16] = {
                [U7[17]] = U7[18],
                [U7[19]] = U7[21]
            };
            U7[23] = 5254969231759;
            U7[19] = r16;
            U7[20] = r15;
            U7[25] = 521371025650;
            U7[22] = "\xe9\xfc\xe7%";
            U7[27] = "\xcf\xac@";
            U7[21] = U7[20](U7[22], U7[23]);
            U7[18] = U7[19][U7[21]];
            U7[20] = r16;
            U7[21] = r15;
            U7[23] = "\xfa\xc1\xc0\xdb\xc5Q";
            U7[24] = 16098739461448;
            U7[22] = U7[21](U7[23], U7[24]);
            U7[19] = U7[20][U7[22]];
            U7[21] = r16;
            U7[22] = r15;
            U7[24] = "\xfcB\xf0";
            U7[23] = U7[22](U7[24], U7[25]);
            U7[31] = 28054819746568;
            U7[20] = U7[21][U7[23]];
            U7[23] = "Vector3";
            U7[22] = Env[U7[23]];
            U7[24] = r16;
            U7[25] = r15;
            U7[26] = U7[25](U7[27], U7[28]);
            U7[23] = U7[24][U7[26]];
            U7[25] = -29.77;
            U7[21] = U7[22][U7[23]];
            U7[23] = 1166.33;
            U7[24] = 3.36;
            U7[22] = U7[21](U7[23], U7[24], U7[25]);
            U7[23] = "E-n0";
            U7[17] = {
                [U7[18]] = U7[19],
                [U7[20]] = U7[22]
            };
            U7[26] = 19960414594126;
            U7[20] = r16;
            U7[21] = r15;
            U7[28] = "\xd4\xe6\x87";
            U7[24] = 7656461471213;
            U7[22] = U7[21](U7[23], U7[24]);
            U7[24] = "\x82T\x19\xb8\x1eJw\xf6";
            U7[25] = 10093411226204;
            U7[19] = U7[20][U7[22]];
            U7[21] = r16;
            U7[22] = r15;
            U7[23] = U7[22](U7[24], U7[25]);
            U7[20] = U7[21][U7[23]];
            U7[22] = r16;
            U7[23] = r15;
            U7[25] = "\xaf\xc2\xc5";
            U7[24] = U7[23](U7[25], U7[26]);
            U7[21] = U7[22][U7[24]];
            U7[24] = "Vector3";
            U7[23] = Env[U7[24]];
            U7[25] = r16;
            U7[26] = r15;
            U7[27] = U7[26](U7[28], U7[29]);
            U7[24] = U7[25][U7[27]];
            U7[25] = 28.47;
            U7[22] = U7[23][U7[24]];
            U7[24] = 1065.19;
            U7[26] = 420.76;
            U7[23] = U7[22](U7[24], U7[25], U7[26]);
            U7[25] = 16961599266522;
            U7[26] = 10853385065406;
            U7[18] = {
                [U7[19]] = U7[20],
                [U7[21]] = U7[23]
            };
            U7[21] = r16;
            U7[22] = r15;
            U7[24] = "\x05\xcb=\xd9";
            U7[23] = U7[22](U7[24], U7[25]);
            U7[20] = U7[21][U7[23]];
            U7[25] = "Q~\x0e\x0be\x08+\x938bw\x84";
            U7[22] = r16;
            U7[23] = r15;
            U7[24] = U7[23](U7[25], U7[26]);
            U7[26] = "\xdbx\xdd";
            U7[27] = 10580382913342;
            U7[21] = U7[22][U7[24]];
            U7[23] = r16;
            U7[24] = r15;
            U7[25] = U7[24](U7[26], U7[27]);
            U7[22] = U7[23][U7[25]];
            U7[25] = "Vector3";
            U7[24] = Env[U7[25]];
            U7[26] = r16;
            U7[27] = r15;
            U7[29] = "'c\xeb";
            U7[28] = U7[27](U7[29], U7[30]);
            U7[27] = -220.91;
            U7[30] = "\xb9+\xd4";
            U7[25] = U7[26][U7[28]];
            U7[23] = U7[24][U7[25]];
            U7[25] = 1202.3;
            U7[26] = 3.71;
            U7[24] = U7[23](U7[25], U7[26], U7[27]);
            U7[19] = {
                [U7[20]] = U7[21],
                [U7[22]] = U7[24]
            };
            U7[25] = "Z\x9e{\x04";
            U7[22] = r16;
            U7[26] = 216524226660;
            U7[27] = 34846561369954;
            U7[23] = r15;
            U7[24] = U7[23](U7[25], U7[26]);
            U7[21] = U7[22][U7[24]];
            U7[23] = r16;
            U7[26] = "\t \x9b\xd7\xffy\xda\x15|!\x14\x85";
            U7[28] = 12967952832406;
            U7[24] = r15;
            U7[25] = U7[24](U7[26], U7[27]);
            U7[22] = U7[23][U7[25]];
            U7[24] = r16;
            U7[27] = "\xa0\x985";
            U7[25] = r15;
            U7[26] = U7[25](U7[27], U7[28]);
            U7[23] = U7[24][U7[26]];
            U7[26] = "Vector3";
            U7[25] = Env[U7[26]];
            U7[27] = r16;
            U7[28] = r15;
            U7[29] = U7[28](U7[30], U7[31]);
            U7[28] = -230.21;
            U7[26] = U7[27][U7[29]];
            U7[29] = 10089872511578;
            U7[27] = 3.71;
            U7[24] = U7[25][U7[26]];
            U7[26] = 1179.72;
            U7[25] = U7[24](U7[26], U7[27], U7[28]);
            U7[20] = {
                [U7[21]] = U7[22],
                [U7[23]] = U7[25]
            };
            U7[23] = r16;
            U7[24] = r15;
            U7[26] = "\xd6\x17)T";
            U7[31] = "\xda-\xb2";
            U7[27] = 7340567317850;
            U7[25] = U7[24](U7[26], U7[27]);
            U7[22] = U7[23][U7[25]];
            U7[28] = 19113476465348;
            U7[24] = r16;
            U7[27] = "<\x93S\xdc\x18F\n7D\xc5$\x8f";
            U7[25] = r15;
            U7[26] = U7[25](U7[27], U7[28]);
            U7[23] = U7[24][U7[26]];
            U7[25] = r16;
            U7[28] = "\x1e m";
            U7[26] = r15;
            U7[27] = U7[26](U7[28], U7[29]);
            U7[24] = U7[25][U7[27]];
            U7[27] = "Vector3";
            U7[26] = Env[U7[27]];
            U7[28] = r16;
            U7[29] = r15;
            U7[30] = U7[29](U7[31], U7[32]);
            U7[27] = U7[28][U7[30]];
            U7[25] = U7[26][U7[27]];
            U7[28] = 3.71;
            U7[27] = 1202.31;
            U7[29] = -182.55;
            U7[26] = U7[25](U7[27], U7[28], U7[29]);
            U7[21] = {
                [U7[22]] = U7[23],
                [U7[24]] = U7[26]
            };
            U7[8] = {
                U7[9],
                U7[10],
                U7[11],
                U7[12],
                U7[13],
                U7[14],
                U7[15],
                U7[16],
                U7[17],
                U7[18],
                U7[19],
                U7[20],
                U7[21]
            };
            U7[10] = "ipairs";
            U7[9] = Env[U7[10]];
            U7[13] = {
                U7[9](U7[8])
            };
            U7[11] = U7[13][2];
            U7[12] = U7[13][3];
            U7[10] = U7[13][1];
            U7[12], U7[13] = U7[10](U7[11], U7[12]);
            while U7[12] do
                U7[23] = 33563470839053;
                U7[9] = U7[12];
                U7[14] = 92;
                Q[U7[14]] = U7[13];
                U7[21] = "\x19C\xdcr";
                U7[22] = 23595065060075;
                U7[13] = U7[14];
                U7[16] = Q[U7[13]];
                U7[18] = r16;
                U7[19] = r15;
                U7[20] = U7[19](U7[21], U7[22]);
                U7[17] = U7[18][U7[20]];
                U7[15] = U7[16][U7[17]];
                U7[17] = r60;
                U7[19] = r16;
                U7[20] = r15;
                U7[22] = "\xb7?\x12\xa3";
                U7[21] = U7[20](U7[22], U7[23]);
                U7[18] = U7[19][U7[21]];
                U7[16] = U7[17][U7[18]];
                U7[21] = 3300060055040;
                U7[14] = fu(U7[7], U7[15], U7[16], U7[9]);
                U7[17] = r16;
                U7[18] = r15;
                U7[20] = "\xcf\xb8(B)\xa6@\xf7`\x8f\xd9>LZ\xfd\xf6\xa7";
                U7[19] = U7[18](U7[20], U7[21]);
                U7[16] = U7[17][U7[19]];
                U7[17] = function(...)
                    r58(Q[U7[13]].pos);
                    return; 
                end;
                U7[15] = U7[14][U7[16]];
                U7[16] = "Connect";
                U7[13] = nil;
                U7[16] = U7[15][U7[16]];
                U7[9] = nil;
                U7[14] = nil;
                U7[16] = U7[16](U7[15], U7[17]); 
            end;
            U7[10] = r64;
            U7[15] = "\xe4(\xcb\xa4C\xf2";
            U7[12] = r16;
            U7[16] = 26432819818516;
            U7[13] = r15;
            U7[14] = U7[13](U7[15], U7[16]);
            U7[19] = 1393211245192;
            U7[11] = U7[12][U7[14]];
            U7[18] = "<\xe7\x88O\x0c\xa9\x9e";
            U7[21] = 20005345518691;
            U7[9] = U7[10][U7[11]];
            U7[16] = 32740013194125;
            U7[12] = r16;
            U7[13] = r15;
            U7[15] = "w\x98\xe7\x80\xc6\x81Q\x9a\xef\x029Q0\xa5\xd0|,k\x1b";
            U7[14] = U7[13](U7[15], U7[16]);
            U7[11] = U7[12][U7[14]];
            U7[12] = 1;
            U7[10] = lu(U7[9], U7[11], U7[12]);
            U7[46] = 15640915254387;
            U7[16] = 22319282923673;
            U7[15] = "-\x10\xfd\xedA";
            U7[12] = r16;
            U7[13] = r15;
            U7[14] = U7[13](U7[15], U7[16]);
            U7[11] = U7[12][U7[14]];
            U7[14] = "Color3";
            U7[13] = Env[U7[14]];
            U7[35] = 7102561783019;
            U7[15] = r16;
            U7[16] = r15;
            U7[17] = U7[16](U7[18], U7[19]);
            U7[14] = U7[15][U7[17]];
            U7[12] = U7[13][U7[14]];
            U7[15] = 20;
            U7[16] = 50;
            U7[14] = 120;
            U7[20] = 3906606057243;
            U7[13] = U7[12](U7[14], U7[15], U7[16]);
            U7[53] = "\xe33l";
            U7[12] = 2;
            U7[10] = fu(U7[9], U7[11], U7[13], U7[12]);
            U7[17] = 41734750227;
            U7[11] = 93;
            Q[U7[11]] = U7[10];
            U7[28] = 444459630798;
            U7[19] = "\x1a\xbd0\x17";
            U7[16] = "<\xc5(z";
            U7[13] = r16;
            U7[14] = r15;
            U7[15] = U7[14](U7[16], U7[17]);
            U7[12] = U7[13][U7[15]];
            U7[14] = r60;
            U7[16] = r16;
            U7[17] = r15;
            U7[18] = U7[17](U7[19], U7[20]);
            U7[15] = U7[16][U7[18]];
            U7[18] = 4672125782143;
            U7[13] = U7[14][U7[15]];
            U7[14] = 3;
            U7[10] = fu(U7[9], U7[12], U7[13], U7[14]);
            U7[14] = r16;
            U7[15] = r15;
            U7[17] = "j\xb4\xf5\xa0\txM\xcc\xe3);";
            U7[16] = U7[15](U7[17], U7[18]);
            U7[18] = 5296703981986;
            U7[17] = "\\\x88Z7b;\xb8WU^R\x054(\xad\xda";
            U7[26] = 23641555118848;
            U7[13] = U7[14][U7[16]];
            U7[14] = 4;
            U7[12] = lu(U7[9], U7[13], U7[14]);
            U7[14] = r16;
            U7[15] = r15;
            U7[16] = U7[15](U7[17], U7[18]);
            U7[13] = U7[14][U7[16]];
            U7[25] = "|\xf6>\x9f\x86]\xa4~\xdf\x8c\xb7\xf4f\xe0\x06\xb3\x93";
            U7[16] = "Color3";
            U7[15] = Env[U7[16]];
            U7[17] = r16;
            U7[18] = r15;
            U7[20] = "\xe0\xf2\xb0\xcfE\xf8q";
            U7[19] = U7[18](U7[20], U7[21]);
            U7[16] = U7[17][U7[19]];
            U7[14] = U7[15][U7[16]];
            U7[16] = 0;
            U7[18] = 80;
            U7[17] = 100;
            U7[15] = U7[14](U7[16], U7[17], U7[18]);
            U7[14] = 5;
            U7[45] = 27731495268977;
            U7[12] = fu(U7[9], U7[13], U7[15], U7[14]);
            U7[13] = 94;
            Q[U7[13]] = U7[12];
            U7[15] = 95;
            U7[14] = 96;
            U7[16] = 97;
            U7[12] = {};
            Q[U7[14]] = U7[12];
            U7[17] = 98;
            U7[12] = {};
            U7[18] = function(arg1_23, ...)
                y = arg1_23.Parent;
                if not y then
                    return nil;
                end;
                if y.IsA(y, "BasePart") then
                    return y.Position;
                end;
                if y.IsA(y, "Attachment") then
                    return y.WorldPosition;
                end;
                v2 = "\x94\xb1\xf1\x81U";
                if y.IsA(y, r16[r15(v2, 25489094356573)]) then
                    if y.PrimaryPart then
                        return v1.Parent.PrimaryPart.Position;
                    end;
                    v2 = y.GetDescendants;
                    U = {
                        v2(y)
                    };
                    G = v2[3];
                    x = v2[2];
                    for G, k in ipairs(z("ipairs")) do
                        v2 = G;
                        if k.IsA(k, "BasePart") then
                            return k.Position;
                        else
                            
                        end; 
                    end;
                    return;
                end;
                x = y.Parent;
                if x then
                    if x.IsA(x, "BasePart") then
                        return x.Position;
                    end;
                    if x.IsA(x, "Model") then
                        if x.PrimaryPart then
                            return x.PrimaryPart.Position;
                        end;
                        v4 = x.GetDescendants;
                        v2 = v4[3];
                        U = v4[2];
                        for v2, v4 in ipairs(v4(x)) do
                            k = v2;
                            if v4.IsA(v4, "BasePart") then
                                return v4.Position;
                            else
                                
                            end; 
                        end;
                    end;
                end;
                return nil; 
            end;
            Q[U7[15]] = U7[12];
            U7[12] = 50;
            Q[U7[16]] = U7[12];
            U7[12] = false;
            Q[U7[17]] = U7[12];
            U7[12] = 99;
            U7[19] = function(...)
                v1 = r24.Character;
                if not (v1 and v1.FindFirstChild(v1, "HumanoidRootPart")) then
                    return;
                end;
                U = Q[U7[15]];
                x = 1123625894411[2];
                G = 1123625894411[3];
                for G, k in pairs(n) do
                    if G then
                        v4 = G.Parent;
                    end;
                    if G then
                        G.MaxActivationDistance = k.maxDist;
                        G.RequiresLineOfSight = k.lineOfSight;
                        G.Enabled = k.enabled;
                        G.HoldDuration = k.holdDuration;
                    end; 
                end;
                Q[U7[15]] = {};
                k = workspace;
                G = k[1];
                U = k[2];
                for v2, k in ipairs(k.GetDescendants(k)) do
                    x = v2;
                    if k.IsA(k, "ProximityPrompt") then
                        D = Q[U7[12]](k);
                        if D then
                            if ((v1 and v1.FindFirstChild(v1, "HumanoidRootPart")).Position - D).Magnitude <= Q[U7[16]] then
                                Q[U7[15]][k] = {
                                    ["maxDist"] = k.MaxActivationDistance,
                                    ["lineOfSight"] = k.RequiresLineOfSight,
                                    ["enabled"] = k.Enabled,
                                    ["holdDuration"] = k.HoldDuration
                                };
                                k.Enabled = true;
                                k.MaxActivationDistance = 20;
                                k.RequiresLineOfSight = false;
                                k.HoldDuration = 0;
                            end;
                        end;
                    end; 
                end;
                return; 
            end;
            Q[U7[12]] = U7[18];
            U7[18] = 100;
            Q[U7[18]] = U7[19];
            U7[20] = Q[U7[13]];
            U7[22] = r16;
            U7[23] = r15;
            U7[24] = U7[23](U7[25], U7[26]);
            U7[21] = U7[22][U7[24]];
            U7[19] = U7[20][U7[21]];
            U7[21] = function(...)
                Q[U7[13]].Text = "CARI...";
                v5 = r26;
                n = v5.Create(v5, Q[U7[13]], TweenInfo.new(.15), {
                    ["BackgroundColor3"] = Color3.fromRGB(0, 60, 50)
                });
                n.Play(n);
                task.spawn(function(...)
                    Q[U7[18]]();
                    task.wait(.3);
                    Q[U7[13]].Text = "CARI TOMBOL AMPE KETEMU";
                    v5 = r26;
                    n = v5.Create(v5, Q[U7[13]], TweenInfo.new(.15), {
                        ["BackgroundColor3"] = Color3.fromRGB(0, 100, 80)
                    });
                    n.Play(n);
                    return; 
                end);
                return; 
            end;
            U7[26] = 12459133736617;
            U7[4] = nil;
            U7[20] = "Connect";
            U7[25] = "\x19r\xe4\xbfL&)\x8bx\x12\xbe\xd7\xe8\xc5\xd3\x8f\x99";
            U7[34] = 8817205268489;
            U7[20] = U7[19][U7[20]];
            U7[20] = U7[20](U7[19], U7[21]);
            U7[20] = Q[U7[11]];
            U7[38] = 4683110353028;
            U7[22] = r16;
            U7[23] = r15;
            U7[24] = U7[23](U7[25], U7[26]);
            U7[21] = U7[22][U7[24]];
            U7[25] = 1343680954993;
            U7[26] = 107287838769;
            U7[19] = U7[20][U7[21]];
            U7[27] = "\xfcV\xb4";
            U7[20] = "Connect";
            U7[20] = U7[19][U7[20]];
            U7[21] = function(...)
                if Q[U7[17]] then
                    return;
                end;
                Q[U7[17]] = true;
                Q[U7[11]].Text = "PROCESSING...";
                n = r26;
                v1 = n.Create(n, Q[U7[11]], TweenInfo.new(.15), {
                    ["BackgroundColor3"] = Color3.fromRGB(60, 0, 30)
                });
                v1.Play(v1);
                G = r15;
                v1 = r24.Character;
                if v1 then
                    n = v1.FindFirstChild(v1, "HumanoidRootPart");
                end;
                if not v1 then
                    Q[U7[17]] = false;
                    Q[U7[11]].Text = "HAPUS";
                    x = r26;
                    G = x.Create(x, Q[U7[11]], TweenInfo.new(.15), {
                        ["BackgroundColor3"] = Color3.fromRGB(120, 20, 50)
                    });
                    G.Play(G);
                    return;
                end;
                v2 = RaycastParams.new();
                v2.FilterDescendantsInstances = {
                    v1
                };
                D = "Exclude";
                v2.FilterType = Enum.RaycastFilterType[D];
                G = workspace;
                k = G.Raycast(G, v1.Position, Vector3.new(0, -15, 0), v2);
                if k then
                    G = k.Instance;
                end;
                v5 = true;
                if k then
                    D = G;
                    G = k.Instance;
                    if G then
                        v4 = G.Parent;
                    end;
                    v5 = G;
                    if G then
                        table.insert(Q[U7[14]], {
                            ["object"] = G.Clone(G),
                            ["parent"] = G.Parent
                        });
                        G.Destroy(G);
                    end;
                end;
                task.wait(.3);
                Q[U7[17]] = false;
                Q[U7[11]].Text = "HAPUS";
                v4 = r26;
                D = v4.Create(v4, Q[U7[11]], TweenInfo.new(.15), {
                    ["BackgroundColor3"] = Color3.fromRGB(120, 20, 50)
                });
                D.Play(D);
                return; 
            end;
            U7[24] = "\x82\xac\x9e\xd7\xa8\x00\x83\x87f\x82\xf7mCY\xc3p\xc9";
            U7[20] = U7[20](U7[19], U7[21]);
            U7[21] = r16;
            U7[22] = r15;
            U7[54] = 26952169304326;
            U7[23] = U7[22](U7[24], U7[25]);
            U7[20] = U7[21][U7[23]];
            U7[25] = "5\xe2!";
            U7[32] = 17435498536887;
            U7[21] = function(...)
                v1 = table.remove(Q[U7[14]]);
                if v1 then
                    n = v1.object;
                end;
                if v1 then
                    v1.object.Parent = v1.parent;
                end;
                return; 
            end;
            U7[19] = U7[10][U7[20]];
            U7[20] = "Connect";
            U7[20] = U7[19][U7[20]];
            U7[20] = U7[20](U7[19], U7[21]);
            U7[20] = r64;
            U7[22] = r16;
            U7[55] = "\xb8\xca\xd5";
            U7[23] = r15;
            U7[24] = U7[23](U7[25], U7[26]);
            U7[21] = U7[22][U7[24]];
            U7[19] = U7[20][U7[21]];
            U7[25] = "\x1b#\xe2\xc8\xa4P\x123\xee\xa7\x7f%j\xa0w\xef\x91\\S\xda";
            U7[22] = r16;
            U7[23] = r15;
            U7[26] = 4809795684543;
            U7[24] = U7[23](U7[25], U7[26]);
            U7[21] = U7[22][U7[24]];
            U7[22] = 1;
            U7[23] = 2;
            U7[20] = lu(U7[19], U7[21], U7[22]);
            U7[22] = 40;
            U7[20] = r70;
            U7[21] = U7[20](U7[19], U7[22], U7[23]);
            U7[23] = "Instance";
            U7[22] = Env[U7[23]];
            U7[24] = r16;
            U7[25] = r15;
            U7[26] = U7[25](U7[27], U7[28]);
            U7[28] = 20636807439753;
            U7[27] = "\xe5\xa6+\xc8B!\xcc^v";
            U7[23] = U7[24][U7[26]];
            U7[30] = "\xcf7\xd5";
            U7[20] = U7[22][U7[23]];
            U7[24] = r16;
            U7[25] = r15;
            U7[26] = U7[25](U7[27], U7[28]);
            U7[23] = U7[24][U7[26]];
            U7[22] = U7[20](U7[23], U7[21]);
            U7[20] = 101;
            U7[31] = 20679640311197;
            Q[U7[20]] = U7[22];
            U7[36] = 29047952651478;
            U7[22] = Q[U7[20]];
            U7[24] = r16;
            U7[25] = r15;
            U7[27] = "\xe5_\xde\x87";
            U7[28] = 13635457505485;
            U7[26] = U7[25](U7[27], U7[28]);
            U7[23] = U7[24][U7[26]];
            U7[26] = "UDim2";
            U7[25] = Env[U7[26]];
            U7[27] = r16;
            U7[28] = r15;
            U7[29] = U7[28](U7[30], U7[31]);
            U7[26] = U7[27][U7[29]];
            U7[27] = -20;
            U7[24] = U7[25][U7[26]];
            U7[29] = 0;
            U7[26] = 1;
            U7[28] = 1;
            U7[25] = U7[24](U7[26], U7[27], U7[28], U7[29]);
            U7[22][U7[23]] = U7[25];
            U7[22] = Q[U7[20]];
            U7[27] = "\x90\x8e\xdc\xe8\xdb\x0c\n\xd1";
            U7[30] = "|?E";
            U7[28] = 20922761881102;
            U7[24] = r16;
            U7[25] = r15;
            U7[26] = U7[25](U7[27], U7[28]);
            U7[23] = U7[24][U7[26]];
            U7[31] = 15934360624380;
            U7[26] = "UDim2";
            U7[25] = Env[U7[26]];
            U7[27] = r16;
            U7[28] = r15;
            U7[29] = U7[28](U7[30], U7[31]);
            U7[26] = U7[27][U7[29]];
            U7[29] = 0;
            U7[27] = 12;
            U7[24] = U7[25][U7[26]];
            U7[28] = 0;
            U7[26] = 0;
            U7[25] = U7[24](U7[26], U7[27], U7[28], U7[29]);
            U7[22][U7[23]] = U7[25];
            U7[27] = "(\xdb\xf0\xb9\xaf\xd8\xd3\xab\xf2\x08\xd2\x8a\x04\x81y\xc1\xb9\xc9\x02\xc1\xfe\x87";
            U7[22] = Q[U7[20]];
            U7[24] = r16;
            U7[25] = r15;
            U7[28] = 12076956210679;
            U7[52] = 15701174131855;
            U7[26] = U7[25](U7[27], U7[28]);
            U7[23] = U7[24][U7[26]];
            U7[24] = 1;
            U7[22][U7[23]] = U7[24];
            U7[22] = Q[U7[20]];
            U7[27] = "\xdf\x02_\x1b";
            U7[24] = r16;
            U7[28] = 8853012926490;
            U7[25] = r15;
            U7[26] = U7[25](U7[27], U7[28]);
            U7[23] = U7[24][U7[26]];
            U7[28] = "\x1f\xc7\x18\x01_\xf4\xbc";
            U7[25] = r16;
            U7[26] = r15;
            U7[29] = 6690446756907;
            U7[27] = U7[26](U7[28], U7[29]);
            U7[24] = U7[25][U7[27]];
            U7[31] = "\x94\xe7=\x1e";
            U7[22][U7[23]] = U7[24];
            U7[22] = Q[U7[20]];
            U7[28] = 16099247430984;
            U7[24] = r16;
            U7[25] = r15;
            U7[27] = "\xad\xd75w";
            U7[26] = U7[25](U7[27], U7[28]);
            U7[27] = "Enum";
            U7[23] = U7[24][U7[26]];
            U7[26] = Env[U7[27]];
            U7[28] = r16;
            U7[29] = r15;
            U7[30] = U7[29](U7[31], U7[32]);
            U7[27] = U7[28][U7[30]];
            U7[25] = U7[26][U7[27]];
            U7[40] = "\xdd9\xe4";
            U7[27] = r16;
            U7[28] = r15;
            U7[31] = 4482722662439;
            U7[30] = "\x9d\xfcVUckP[\xccs";
            U7[29] = U7[28](U7[30], U7[31]);
            U7[26] = U7[27][U7[29]];
            U7[24] = U7[25][U7[26]];
            U7[22][U7[23]] = U7[24];
            U7[22] = Q[U7[20]];
            U7[24] = r16;
            U7[27] = "N\\\x90\xa8)2BU";
            U7[25] = r15;
            U7[41] = 13516504373398;
            U7[28] = 2219708613641;
            U7[26] = U7[25](U7[27], U7[28]);
            U7[23] = U7[24][U7[26]];
            U7[24] = 13;
            U7[22][U7[23]] = U7[24];
            U7[22] = Q[U7[20]];
            U7[28] = 12609472501487;
            U7[24] = r16;
            U7[31] = 28990576145595;
            U7[27] = "\x13\xf5A\xb7\xde\xf1Yv\xdf\xb6";
            U7[25] = r15;
            U7[26] = U7[25](U7[27], U7[28]);
            U7[32] = 28238573892445;
            U7[23] = U7[24][U7[26]];
            U7[30] = "\xea=\xdc";
            U7[25] = r60;
            U7[27] = r16;
            U7[28] = r15;
            U7[29] = U7[28](U7[30], U7[31]);
            U7[26] = U7[27][U7[29]];
            U7[24] = U7[25][U7[26]];
            U7[22][U7[23]] = U7[24];
            U7[27] = "t12:\x06\xfe\xc0\xa5\xfe\x86\xcc\xba;\x86";
            U7[28] = 1528726340295;
            U7[22] = Q[U7[20]];
            U7[24] = r16;
            U7[31] = "\x11\x97yS\xc8ce\x06\xf4\xfe\xf6\xa0\xe4\xea";
            U7[25] = r15;
            U7[26] = U7[25](U7[27], U7[28]);
            U7[23] = U7[24][U7[26]];
            U7[50] = "4$\x80\x0e\xc3\xe3\xcauj8c\x9f]\xfb=Y\xf8";
            U7[27] = "Enum";
            U7[26] = Env[U7[27]];
            U7[28] = r16;
            U7[29] = r15;
            U7[30] = U7[29](U7[31], U7[32]);
            U7[27] = U7[28][U7[30]];
            U7[31] = 16659561569869;
            U7[25] = U7[26][U7[27]];
            U7[30] = "\xaf\xf4\xe4\x0e";
            U7[27] = r16;
            U7[28] = r15;
            U7[29] = U7[28](U7[30], U7[31]);
            U7[26] = U7[27][U7[29]];
            U7[24] = U7[25][U7[26]];
            U7[22][U7[23]] = U7[24];
            U7[22] = Q[U7[20]];
            U7[29] = "\xa9\xbd\xeb";
            U7[32] = "\xce+\xe3";
            U7[24] = r16;
            U7[25] = r15;
            U7[33] = 15489753652268;
            U7[27] = "\xae\xeeq\x00J5\xd4\x9a\xa8S\\P*\x91\xb2\xb0\xd2\xae=\xbe\x93;";
            U7[30] = 27859432370861;
            U7[28] = 11325526316185;
            U7[26] = U7[25](U7[27], U7[28]);
            U7[23] = U7[24][U7[26]];
            U7[24] = 1;
            U7[22][U7[23]] = U7[24];
            U7[22] = r70;
            U7[24] = 30;
            U7[25] = 3;
            U7[23] = U7[22](U7[19], U7[24], U7[25]);
            U7[25] = "Instance";
            U7[24] = Env[U7[25]];
            U7[26] = r16;
            U7[27] = r15;
            U7[28] = U7[27](U7[29], U7[30]);
            U7[25] = U7[26][U7[28]];
            U7[22] = U7[24][U7[25]];
            U7[29] = "\xe9\xfc\xb0|\xdb\x0e/\x8ce";
            U7[26] = r16;
            U7[30] = 13394955737181;
            U7[27] = r15;
            U7[28] = U7[27](U7[29], U7[30]);
            U7[25] = U7[26][U7[28]];
            U7[24] = U7[22](U7[25], U7[23]);
            U7[22] = 102;
            U7[29] = "YT1N";
            Q[U7[22]] = U7[24];
            U7[24] = Q[U7[22]];
            U7[26] = r16;
            U7[27] = r15;
            U7[30] = 33581460012309;
            U7[28] = U7[27](U7[29], U7[30]);
            U7[25] = U7[26][U7[28]];
            U7[28] = "UDim2";
            U7[27] = Env[U7[28]];
            U7[29] = r16;
            U7[30] = r15;
            U7[31] = U7[30](U7[32], U7[33]);
            U7[30] = 1;
            U7[33] = 5092631562563;
            U7[32] = "\xac)\xd6";
            U7[28] = U7[29][U7[31]];
            U7[29] = -20;
            U7[31] = 0;
            U7[26] = U7[27][U7[28]];
            U7[28] = 1;
            U7[27] = U7[26](U7[28], U7[29], U7[30], U7[31]);
            U7[24][U7[25]] = U7[27];
            U7[24] = Q[U7[22]];
            U7[26] = r16;
            U7[29] = "_\xf4\xfeIKo\xa3(";
            U7[27] = r15;
            U7[30] = 14738636692175;
            U7[28] = U7[27](U7[29], U7[30]);
            U7[25] = U7[26][U7[28]];
            U7[28] = "UDim2";
            U7[27] = Env[U7[28]];
            U7[29] = r16;
            U7[30] = r15;
            U7[31] = U7[30](U7[32], U7[33]);
            U7[28] = U7[29][U7[31]];
            U7[29] = 12;
            U7[26] = U7[27][U7[28]];
            U7[28] = 0;
            U7[30] = 0;
            U7[31] = 0;
            U7[27] = U7[26](U7[28], U7[29], U7[30], U7[31]);
            U7[24][U7[25]] = U7[27];
            U7[31] = 18679541506554;
            U7[24] = Q[U7[22]];
            U7[26] = r16;
            U7[30] = 2619439514819;
            U7[29] = "[r9\xe6\xae\xfa\xcb\x8b\xf9\xa7\x16)%oZ-\xb4eThq\xf6";
            U7[27] = r15;
            U7[28] = U7[27](U7[29], U7[30]);
            U7[25] = U7[26][U7[28]];
            U7[26] = 1;
            U7[33] = "\xba\xcb\xf1J";
            U7[30] = 8709917429719;
            U7[24][U7[25]] = U7[26];
            U7[24] = Q[U7[22]];
            U7[26] = r16;
            U7[27] = r15;
            U7[29] = "\t[\x9f\xe5";
            U7[28] = U7[27](U7[29], U7[30]);
            U7[25] = U7[26][U7[28]];
            U7[30] = "\x14\x1b\x98\xa5\xb7\xa3\xd4\xbf\x12\x06\t\xd90}";
            U7[27] = r16;
            U7[28] = r15;
            U7[29] = U7[28](U7[30], U7[31]);
            U7[26] = U7[27][U7[29]];
            U7[24][U7[25]] = U7[26];
            U7[24] = Q[U7[22]];
            U7[30] = 28171002393406;
            U7[26] = r16;
            U7[29] = "r\xe1\xfer";
            U7[27] = r15;
            U7[28] = U7[27](U7[29], U7[30]);
            U7[29] = "Enum";
            U7[57] = 9667246150037;
            U7[25] = U7[26][U7[28]];
            U7[28] = Env[U7[29]];
            U7[30] = r16;
            U7[31] = r15;
            U7[32] = U7[31](U7[33], U7[34]);
            U7[33] = 23489337191098;
            U7[29] = U7[30][U7[32]];
            U7[27] = U7[28][U7[29]];
            U7[7] = nil;
            U7[29] = r16;
            U7[32] = "\xcd\xe7v\xc1'\x96";
            U7[30] = r15;
            U7[31] = U7[30](U7[32], U7[33]);
            U7[34] = 15192402484130;
            U7[28] = U7[29][U7[31]];
            U7[26] = U7[27][U7[28]];
            U7[6] = nil;
            U7[29] = "n\xa5\x1d\xbf\xc1J\xed\x8b";
            U7[24][U7[25]] = U7[26];
            U7[30] = 28615462040589;
            U7[24] = Q[U7[22]];
            U7[26] = r16;
            U7[27] = r15;
            U7[28] = U7[27](U7[29], U7[30]);
            U7[25] = U7[26][U7[28]];
            U7[26] = 11;
            U7[24][U7[25]] = U7[26];
            U7[29] = "\x99\xcaM\xfc\xf4\xd8^0\xa5\x06";
            U7[24] = Q[U7[22]];
            U7[26] = r16;
            U7[27] = r15;
            U7[33] = 1940422591367;
            U7[30] = 29454012708243;
            U7[28] = U7[27](U7[29], U7[30]);
            U7[25] = U7[26][U7[28]];
            U7[27] = r60;
            U7[32] = "C\xae\x8f\x98\xdcq\xff";
            U7[29] = r16;
            U7[30] = r15;
            U7[31] = U7[30](U7[32], U7[33]);
            U7[28] = U7[29][U7[31]];
            U7[59] = 15002339351370;
            U7[26] = U7[27][U7[28]];
            U7[24][U7[25]] = U7[26];
            U7[24] = Q[U7[22]];
            U7[29] = "\xfaDM8qU\x95:\x9b\xda\x9b\xfb\x8a\x0e";
            U7[26] = r16;
            U7[30] = 14110730246570;
            U7[27] = r15;
            U7[28] = U7[27](U7[29], U7[30]);
            U7[29] = "Enum";
            U7[25] = U7[26][U7[28]];
            U7[44] = 28322193585028;
            U7[28] = Env[U7[29]];
            U7[30] = r16;
            U7[33] = "b\xb6W8\xfa\xc4\xe3D\x92'\xc5\x92\x89\xc6";
            U7[31] = r15;
            U7[32] = U7[31](U7[33], U7[34]);
            U7[33] = 17874783215747;
            U7[29] = U7[30][U7[32]];
            U7[27] = U7[28][U7[29]];
            U7[29] = r16;
            U7[17] = nil;
            U7[30] = r15;
            U7[32] = "\xb1\x19@\xc5";
            U7[31] = U7[30](U7[32], U7[33]);
            U7[28] = U7[29][U7[31]];
            U7[26] = U7[27][U7[28]];
            U7[31] = 24045415427005;
            U7[24][U7[25]] = U7[26];
            U7[24] = Q[U7[22]];
            U7[29] = "+^R\x81\x1c\x0f\x0f\xc9\x99\xe9\r\x82n\xbbdXW\xb0\xb49Sq";
            U7[26] = r16;
            U7[30] = 26187686457250;
            U7[27] = r15;
            U7[28] = U7[27](U7[29], U7[30]);
            U7[25] = U7[26][U7[28]];
            U7[26] = 1;
            U7[24][U7[25]] = U7[26];
            U7[27] = r16;
            U7[28] = r15;
            U7[30] = "\x05\xb4K\x86\x9cT\x7f\x08Q\xca\x8bXH^HN\x1eu\x15";
            U7[29] = U7[28](U7[30], U7[31]);
            U7[26] = U7[27][U7[29]];
            U7[30] = 4;
            U7[28] = 50;
            U7[31] = function(arg1_24, ...)
                r32 = arg1_24;
                return; 
            end;
            U7[27] = 1;
            U7[29] = 10;
            U7[32] = {
                Au(U7[19], U7[26], U7[27], U7[28], U7[29], U7[30], U7[31])
            };
            U7[31] = "C\x93{\x10\x00\xf2\x8a\x0b\xd0";
            U7[24] = U7[32][1];
            U7[21] = nil;
            U7[25] = U7[32][2];
            U7[34] = "f\xc2\x99\x9c+";
            U7[28] = r16;
            U7[37] = "\xe7\x19c\x8e\xdc\x92\xabM\x17\x15\xce\x99\xff?\xa9\xf0\x0b";
            U7[32] = 24565229972655;
            U7[29] = r15;
            U7[30] = U7[29](U7[31], U7[32]);
            U7[27] = U7[28][U7[30]];
            U7[29] = r60;
            U7[31] = r16;
            U7[39] = 4415323736072;
            U7[32] = r15;
            U7[33] = U7[32](U7[34], U7[35]);
            U7[30] = U7[31][U7[33]];
            U7[28] = U7[29][U7[30]];
            U7[29] = 5;
            U7[35] = "\xbdA\xf4";
            U7[26] = fu(U7[19], U7[27], U7[28], U7[29]);
            U7[29] = r16;
            U7[30] = r15;
            U7[32] = "j\xf2\x10\xb5\xd8T\xe8S";
            U7[33] = 6296541858676;
            U7[31] = U7[30](U7[32], U7[33]);
            U7[28] = U7[29][U7[31]];
            U7[30] = r60;
            U7[32] = r16;
            U7[33] = r15;
            U7[34] = U7[33](U7[35], U7[36]);
            U7[31] = U7[32][U7[34]];
            U7[29] = U7[30][U7[31]];
            U7[30] = 6;
            U7[27] = fu(U7[19], U7[28], U7[29], U7[30]);
            U7[28] = false;
            U7[29] = 103;
            U7[30] = 104;
            U7[31] = function(...)
                Q[U7[29]] = false;
                Q[U7[20]].Text = "STOPPED";
                Q[U7[20]].TextColor3 = r60.red;
                return; 
            end;
            Q[U7[29]] = U7[28];
            U7[28] = 0;
            Q[U7[30]] = U7[28];
            U7[28] = function(...)
                if Q[U7[29]] then
                    return;
                end;
                if not r30 then
                    Q[U7[20]].Text = "ERROR!";
                    Q[U7[20]].TextColor3 = r60.red;
                    task.wait(2);
                    Q[U7[20]].Text = "STOPPED";
                    return;
                end;
                Q[U7[29]] = true;
                Q[U7[30]] = 0;
                Q[U7[20]].Text = "RUNNING";
                Q[U7[20]].TextColor3 = r60.green;
                Q[U7[22]].Text = "Total: 0 items";
                r102 = {
                    "Water",
                    "Sugar Block Bag",
                    "Gelatin"
                };
                U = r16;
                task.spawn(function(...)
                    v1 = r32;
                    G = r102;
                    y = U[2];
                    G = U[1];
                    for x, v2 in ipairs(G) do
                        U = x;
                        r103 = v2;
                        v2 = 64;
                        if not Q[U7[29]] then
                            
                        end; 
                    end;
                    if Q[U7[29]] then
                        Q[U7[20]].Text = "Complete! " .. Q[U7[30]] .. " items";
                        Q[U7[20]].TextColor3 = r60.green;
                        task.wait(2);
                        if Q[U7[29]] then
                            Q[U7[20]].Text = "STOPPED";
                            Q[U7[20]].TextColor3 = r60.red;
                            Q[U7[29]] = false;
                        end;
                    end;
                    return; 
                end);
                return; 
            end;
            U7[34] = r16;
            U7[35] = r15;
            U7[36] = U7[35](U7[37], U7[38]);
            U7[33] = U7[34][U7[36]];
            U7[32] = U7[26][U7[33]];
            U7[33] = "Connect";
            U7[37] = "\x81j;6X?g\x0e\x92\xc1\xe7\xa8x\x8c\xb6\x13T";
            U7[33] = U7[32][U7[33]];
            U7[33] = U7[33](U7[32], U7[28]);
            U7[34] = r16;
            U7[38] = 7528020446641;
            U7[35] = r15;
            U7[36] = U7[35](U7[37], U7[38]);
            U7[33] = U7[34][U7[36]];
            U7[32] = U7[27][U7[33]];
            U7[38] = "\xd3\xfc&\xed";
            U7[33] = "Connect";
            U7[33] = U7[32][U7[33]];
            U7[33] = U7[33](U7[32], U7[31]);
            U7[33] = r64;
            U7[35] = r16;
            U7[36] = r15;
            U7[37] = U7[36](U7[38], U7[39]);
            U7[34] = U7[35][U7[37]];
            U7[32] = U7[33][U7[34]];
            U7[35] = r16;
            U7[39] = 27427579982307;
            U7[36] = r15;
            U7[38] = "\xf3X\xecq\x8d\xe8\xd8\xb0\xf91-K\xe9\x98i[\xfbX\xef\x95\xe9EuD\xacJ";
            U7[37] = U7[36](U7[38], U7[39]);
            U7[34] = U7[35][U7[37]];
            U7[36] = 2;
            U7[35] = 1;
            U7[33] = lu(U7[32], U7[34], U7[35]);
            U7[35] = 40;
            U7[33] = r70;
            U7[34] = U7[33](U7[32], U7[35], U7[36]);
            U7[36] = "Instance";
            U7[35] = Env[U7[36]];
            U7[37] = r16;
            U7[38] = r15;
            U7[39] = U7[38](U7[40], U7[41]);
            U7[40] = "\xba\x19\x12Iop\x82\x7f\xfb";
            U7[41] = 13576735692978;
            U7[36] = U7[37][U7[39]];
            U7[43] = "\xad(\x8f";
            U7[33] = U7[35][U7[36]];
            U7[37] = r16;
            U7[38] = r15;
            U7[39] = U7[38](U7[40], U7[41]);
            U7[36] = U7[37][U7[39]];
            U7[40] = "\x90\x05{\xf1";
            U7[35] = U7[33](U7[36], U7[34]);
            U7[33] = 105;
            Q[U7[33]] = U7[35];
            U7[35] = Q[U7[33]];
            U7[37] = r16;
            U7[38] = r15;
            U7[41] = 7974307794561;
            U7[39] = U7[38](U7[40], U7[41]);
            U7[36] = U7[37][U7[39]];
            U7[39] = "UDim2";
            U7[38] = Env[U7[39]];
            U7[40] = r16;
            U7[41] = r15;
            U7[42] = U7[41](U7[43], U7[44]);
            U7[39] = U7[40][U7[42]];
            U7[37] = U7[38][U7[39]];
            U7[40] = -20;
            U7[49] = 10930785342434;
            U7[44] = 17136497647403;
            U7[39] = 1;
            U7[43] = "\xec\xfb\xc2";
            U7[41] = 1;
            U7[42] = 0;
            U7[38] = U7[37](U7[39], U7[40], U7[41], U7[42]);
            U7[40] = "\x10\xee\x96\xe3\\\x82\x02\xff";
            U7[35][U7[36]] = U7[38];
            U7[35] = Q[U7[33]];
            U7[37] = r16;
            U7[38] = r15;
            U7[41] = 11043112752150;
            U7[39] = U7[38](U7[40], U7[41]);
            U7[36] = U7[37][U7[39]];
            U7[39] = "UDim2";
            U7[38] = Env[U7[39]];
            U7[40] = r16;
            U7[41] = r15;
            U7[42] = U7[41](U7[43], U7[44]);
            U7[39] = U7[40][U7[42]];
            U7[37] = U7[38][U7[39]];
            U7[42] = 0;
            U7[40] = 12;
            U7[41] = 0;
            U7[39] = 0;
            U7[38] = U7[37](U7[39], U7[40], U7[41], U7[42]);
            U7[44] = "\x1b\xd9\xb0b";
            U7[35][U7[36]] = U7[38];
            U7[41] = 2213151310854;
            U7[35] = Q[U7[33]];
            U7[37] = r16;
            U7[40] = "\xbc\x02\xd5\x829\xb0\x8a\x1b\x18J'N\xaa#\xed\x80\xce\xa8\xb9G\x9a\xd9";
            U7[38] = r15;
            U7[39] = U7[38](U7[40], U7[41]);
            U7[36] = U7[37][U7[39]];
            U7[37] = 1;
            U7[41] = 10449912402690;
            U7[35][U7[36]] = U7[37];
            U7[40] = "\xb4t\x1d\x7f";
            U7[42] = 5225045641601;
            U7[35] = Q[U7[33]];
            U7[37] = r16;
            U7[38] = r15;
            U7[39] = U7[38](U7[40], U7[41]);
            U7[36] = U7[37][U7[39]];
            U7[38] = r16;
            U7[39] = r15;
            U7[41] = "P\x9e\xe1\xf3\xaeq\xab";
            U7[40] = U7[39](U7[41], U7[42]);
            U7[37] = U7[38][U7[40]];
            U7[35][U7[36]] = U7[37];
            U7[35] = Q[U7[33]];
            U7[41] = 26480883626027;
            U7[37] = r16;
            U7[38] = r15;
            U7[40] = "\x80\"I\x15";
            U7[39] = U7[38](U7[40], U7[41]);
            U7[36] = U7[37][U7[39]];
            U7[40] = "Enum";
            U7[39] = Env[U7[40]];
            U7[41] = r16;
            U7[42] = r15;
            U7[43] = U7[42](U7[44], U7[45]);
            U7[44] = 19501280109432;
            U7[40] = U7[41][U7[43]];
            U7[38] = U7[39][U7[40]];
            U7[40] = r16;
            U7[43] = "\xe9\x05B\x9b\x9eW\xa5\x18\xca\x8d";
            U7[41] = r15;
            U7[42] = U7[41](U7[43], U7[44]);
            U7[39] = U7[40][U7[42]];
            U7[43] = "#q\x82";
            U7[41] = 4425287157772;
            U7[37] = U7[38][U7[39]];
            U7[35][U7[36]] = U7[37];
            U7[35] = Q[U7[33]];
            U7[37] = r16;
            U7[40] = "n\xcf\nt\x9f9\xa30";
            U7[44] = 5695704271452;
            U7[38] = r15;
            U7[39] = U7[38](U7[40], U7[41]);
            U7[41] = 34393936019087;
            U7[40] = ",G)1\xeb`(\xce\xfb\x82";
            U7[36] = U7[37][U7[39]];
            U7[37] = 13;
            U7[35][U7[36]] = U7[37];
            U7[35] = Q[U7[33]];
            U7[37] = r16;
            U7[38] = r15;
            U7[39] = U7[38](U7[40], U7[41]);
            U7[36] = U7[37][U7[39]];
            U7[23] = nil;
            U7[38] = r60;
            U7[40] = r16;
            U7[41] = r15;
            U7[42] = U7[41](U7[43], U7[44]);
            U7[39] = U7[40][U7[42]];
            U7[60] = 32059780495953;
            U7[40] = "\xbc\x8cY`}\xf3\x0b\xd8(\xc4\x81\xa0q\xfb";
            U7[45] = 34919957315460;
            U7[37] = U7[38][U7[39]];
            U7[35][U7[36]] = U7[37];
            U7[35] = Q[U7[33]];
            U7[37] = r16;
            U7[41] = 23850604653410;
            U7[38] = r15;
            U7[39] = U7[38](U7[40], U7[41]);
            U7[36] = U7[37][U7[39]];
            U7[40] = "Enum";
            U7[44] = "W\xac\x1e_\x07\x9fxb\xees\x841\x8f\xcc";
            U7[16] = nil;
            U7[39] = Env[U7[40]];
            U7[41] = r16;
            U7[42] = r15;
            U7[43] = U7[42](U7[44], U7[45]);
            U7[40] = U7[41][U7[43]];
            U7[38] = U7[39][U7[40]];
            U7[44] = 1212398830132;
            U7[40] = r16;
            U7[43] = "\x00\xc7\xde\xec";
            U7[41] = r15;
            U7[42] = U7[41](U7[43], U7[44]);
            U7[45] = "Q\xf6\x0f";
            U7[39] = U7[40][U7[42]];
            U7[37] = U7[38][U7[39]];
            U7[40] = "\xa4\x92\x8c\x14\x13\xdc\x04\xae\x0f\x10\\\xba!\xf3\xd6\xfe\x05\x1e\x97\x92\xc4\xf1";
            U7[35][U7[36]] = U7[37];
            U7[35] = Q[U7[33]];
            U7[41] = 26997564420379;
            U7[37] = r16;
            U7[38] = r15;
            U7[63] = 33955128393155;
            U7[39] = U7[38](U7[40], U7[41]);
            U7[36] = U7[37][U7[39]];
            U7[37] = 1;
            U7[35][U7[36]] = U7[37];
            U7[38] = 3;
            U7[42] = "z\xe8\x83";
            U7[35] = r70;
            U7[37] = 30;
            U7[43] = 23115763198476;
            U7[36] = U7[35](U7[32], U7[37], U7[38]);
            U7[38] = "Instance";
            U7[37] = Env[U7[38]];
            U7[39] = r16;
            U7[40] = r15;
            U7[41] = U7[40](U7[42], U7[43]);
            U7[38] = U7[39][U7[41]];
            U7[35] = U7[37][U7[38]];
            U7[39] = r16;
            U7[42] = "\x13\xb0\xa5\x00S.ej\x90";
            U7[40] = r15;
            U7[43] = 7580090158537;
            U7[41] = U7[40](U7[42], U7[43]);
            U7[38] = U7[39][U7[41]];
            U7[37] = U7[35](U7[38], U7[36]);
            U7[43] = 6920368245910;
            U7[42] = ",Q\xce\x9e";
            U7[35] = 106;
            Q[U7[35]] = U7[37];
            U7[37] = Q[U7[35]];
            U7[39] = r16;
            U7[40] = r15;
            U7[41] = U7[40](U7[42], U7[43]);
            U7[38] = U7[39][U7[41]];
            U7[41] = "UDim2";
            U7[40] = Env[U7[41]];
            U7[42] = r16;
            U7[43] = r15;
            U7[44] = U7[43](U7[45], U7[46]);
            U7[41] = U7[42][U7[44]];
            U7[44] = 0;
            U7[39] = U7[40][U7[41]];
            U7[42] = -20;
            U7[43] = 1;
            U7[41] = 1;
            U7[40] = U7[39](U7[41], U7[42], U7[43], U7[44]);
            U7[37][U7[38]] = U7[40];
            U7[42] = "\xbd\xff\xf4?\xa0\xab\xc3\xd1";
            U7[37] = Q[U7[35]];
            U7[43] = 939932467637;
            U7[39] = r16;
            U7[46] = 26662820622463;
            U7[40] = r15;
            U7[41] = U7[40](U7[42], U7[43]);
            U7[38] = U7[39][U7[41]];
            U7[41] = "UDim2";
            U7[40] = Env[U7[41]];
            U7[45] = "\xc1\x8fV";
            U7[42] = r16;
            U7[43] = r15;
            U7[47] = 19288709505814;
            U7[44] = U7[43](U7[45], U7[46]);
            U7[41] = U7[42][U7[44]];
            U7[42] = 12;
            U7[43] = 0;
            U7[39] = U7[40][U7[41]];
            U7[41] = 0;
            U7[44] = 0;
            U7[40] = U7[39](U7[41], U7[42], U7[43], U7[44]);
            U7[37][U7[38]] = U7[40];
            U7[37] = Q[U7[35]];
            U7[39] = r16;
            U7[42] = "\xbaD\x03\xbc\x9e\xc7J]\xbc[\x00\x7f\xce\xae\xfb\xc3\x9c\x1c|\xac\xec\xa7";
            U7[43] = 25890369203992;
            U7[40] = r15;
            U7[41] = U7[40](U7[42], U7[43]);
            U7[43] = 14873385753357;
            U7[58] = 35155313901554;
            U7[38] = U7[39][U7[41]];
            U7[39] = 1;
            U7[37][U7[38]] = U7[39];
            U7[56] = 6697010695214;
            U7[37] = Q[U7[35]];
            U7[42] = "l \xa4\xa0";
            U7[39] = r16;
            U7[40] = r15;
            U7[41] = U7[40](U7[42], U7[43]);
            U7[38] = U7[39][U7[41]];
            U7[40] = r16;
            U7[43] = "5\xc3\x08\xfd\x19\xcf\xde";
            U7[44] = 31345930975492;
            U7[41] = r15;
            U7[42] = U7[41](U7[43], U7[44]);
            U7[39] = U7[40][U7[42]];
            U7[37][U7[38]] = U7[39];
            U7[43] = 33418389650633;
            U7[37] = Q[U7[35]];
            U7[39] = r16;
            U7[40] = r15;
            U7[46] = "\x9e;\x04G";
            U7[42] = "@\x98\xd6\xcb";
            U7[41] = U7[40](U7[42], U7[43]);
            U7[38] = U7[39][U7[41]];
            U7[42] = "Enum";
            U7[41] = Env[U7[42]];
            U7[43] = r16;
            U7[44] = r15;
            U7[45] = U7[44](U7[46], U7[47]);
            U7[42] = U7[43][U7[45]];
            U7[40] = U7[41][U7[42]];
            U7[46] = 23589138852584;
            U7[30] = nil;
            U7[42] = r16;
            U7[45] = "U8!YMO\xb9\xf0&\xde";
            U7[43] = r15;
            U7[44] = U7[43](U7[45], U7[46]);
            U7[41] = U7[42][U7[44]];
            U7[48] = 2823293404450;
            U7[46] = 31563446647145;
            U7[39] = U7[40][U7[41]];
            U7[37][U7[38]] = U7[39];
            U7[42] = "\x83\x84\x86\xce6\xd0C\x99";
            U7[37] = Q[U7[35]];
            U7[45] = "i\x88V\x05|`\x13\x93I\x9e";
            U7[39] = r16;
            U7[40] = r15;
            U7[43] = 11750521918815;
            U7[41] = U7[40](U7[42], U7[43]);
            U7[43] = 32865445198792;
            U7[38] = U7[39][U7[41]];
            U7[39] = 12;
            U7[37][U7[38]] = U7[39];
            U7[37] = Q[U7[35]];
            U7[39] = r16;
            U7[42] = "\xee\x1aH\x1f\xbb\xf3\x8e`]\x99";
            U7[40] = r15;
            U7[41] = U7[40](U7[42], U7[43]);
            U7[38] = U7[39][U7[41]];
            U7[40] = r60;
            U7[51] = 10041589224003;
            U7[42] = r16;
            U7[43] = r15;
            U7[44] = U7[43](U7[45], U7[46]);
            U7[41] = U7[42][U7[44]];
            U7[39] = U7[40][U7[41]];
            U7[37][U7[38]] = U7[39];
            U7[42] = "\xed\xd4\xf8\x8ar1\xc1\xf7\xa6\xa4\x00\xba\x19\xa9";
            U7[37] = Q[U7[35]];
            U7[43] = 4888343415012;
            U7[46] = "5f\x1b\x8a\xab\xf7-i RB\x9f\x80\x1e";
            U7[39] = r16;
            U7[40] = r15;
            U7[41] = U7[40](U7[42], U7[43]);
            U7[42] = "Enum";
            U7[38] = U7[39][U7[41]];
            U7[41] = Env[U7[42]];
            U7[47] = 8724185845726;
            U7[43] = r16;
            U7[44] = r15;
            U7[45] = U7[44](U7[46], U7[47]);
            U7[42] = U7[43][U7[45]];
            U7[40] = U7[41][U7[42]];
            U7[42] = r16;
            U7[43] = r15;
            U7[9] = nil;
            U7[45] = ">\n\xd7\x92";
            U7[46] = 13515572189333;
            U7[44] = U7[43](U7[45], U7[46]);
            U7[41] = U7[42][U7[44]];
            U7[39] = U7[40][U7[41]];
            U7[37][U7[38]] = U7[39];
            U7[37] = Q[U7[35]];
            U7[39] = r16;
            U7[43] = 7101494725866;
            U7[40] = r15;
            U7[42] = "\xba\xdf\x03N\xaf\xe1,\xc1jL\x04[\xbb7Z\xc6)'p\xf3\xc5_";
            U7[41] = U7[40](U7[42], U7[43]);
            U7[38] = U7[39][U7[41]];
            U7[39] = 1;
            U7[43] = 19174098248416;
            U7[37][U7[38]] = U7[39];
            U7[39] = r16;
            U7[40] = r15;
            U7[42] = "\"\xbf9[\xe6f*\xff`O";
            U7[41] = U7[40](U7[42], U7[43]);
            U7[61] = 8621727748014;
            U7[38] = U7[39][U7[41]];
            U7[45] = "m\\\xf2r\xba";
            U7[40] = r60;
            U7[42] = r16;
            U7[43] = r15;
            U7[46] = 18740617847318;
            U7[44] = U7[43](U7[45], U7[46]);
            U7[43] = "]\x02\x06\xc4B\x1d\x83\x84\x03";
            U7[41] = U7[42][U7[44]];
            U7[47] = 11721221428562;
            U7[39] = U7[40][U7[41]];
            U7[44] = 33582378351894;
            U7[46] = "\x05\xfei";
            U7[40] = 4;
            U7[37] = fu(U7[32], U7[38], U7[39], U7[40]);
            U7[40] = r16;
            U7[41] = r15;
            U7[42] = U7[41](U7[43], U7[44]);
            U7[39] = U7[40][U7[42]];
            U7[41] = r60;
            U7[43] = r16;
            U7[44] = r15;
            U7[45] = U7[44](U7[46], U7[47]);
            U7[42] = U7[43][U7[45]];
            U7[40] = U7[41][U7[42]];
            U7[41] = 5;
            U7[38] = fu(U7[32], U7[39], U7[40], U7[41]);
            U7[40] = 107;
            U7[46] = "e\xa2\xbd\x17\x0c\xb4\xfe@]\x86\xda\xaa\xba\x1b\x00\x9d'\xce\x13\xb0p";
            U7[39] = false;
            U7[47] = 3057525851535;
            U7[41] = 108;
            Q[U7[40]] = U7[39];
            U7[39] = 0;
            Q[U7[41]] = U7[39];
            U7[43] = r16;
            U7[44] = r15;
            U7[45] = U7[44](U7[46], U7[47]);
            U7[42] = U7[43][U7[45]];
            U7[44] = r16;
            U7[47] = "\x10\xc4\xae\xd2\x14\xe6\n\xe0\x82\xea\x11\xc9\x92\x0b\x1f\xec\xb9\xe1\xe6d\xea\xba";
            U7[45] = r15;
            U7[46] = U7[45](U7[47], U7[48]);
            U7[43] = U7[44][U7[46]];
            U7[22] = nil;
            U7[48] = "\\\xa1\xca\x07\xf6g\xf4\xae\xa1<\x1d\xc1\xb6\x94\xee\xad>\x8d\xb8\x8e\xbf";
            U7[45] = r16;
            U7[46] = r15;
            U7[47] = U7[46](U7[48], U7[49]);
            U7[44] = U7[45][U7[47]];
            U7[39] = {
                U7[42],
                U7[43],
                U7[44]
            };
            U7[42] = 109;
            U7[43] = function(...)
                G = r15;
                if r24.Character then
                    G = r24.Character;
                    x = G[3];
                    G = G[1];
                    for x, v2 in G, pairs(G.GetChildren(G)) do
                        U = x;
                        if v2.IsA(v2, "Tool") then
                            D = M[3];
                            v4 = M[2];
                            for D, M in ipairs(Q[U7[42]]) do
                                L = D;
                                if v2.Name == M then
                                    table.insert({}, v2);
                                else
                                    
                                end; 
                            end;
                        end; 
                    end;
                end;
                v5 = r24;
                y = v5.FindFirstChild(v5, "Backpack");
                if y then
                    k = y.GetChildren;
                    G = k[2];
                    x = k[1];
                    for U, k in pairs(k(y)) do
                        v2 = U;
                        if k.IsA(k, "Tool") then
                            D = g[2];
                            L = g[3];
                            for L, g in ipairs(Q[U7[42]]) do
                                M = L;
                                if k.Name == g then
                                    table.insert({}, k);
                                else
                                    
                                end; 
                            end;
                        end; 
                    end;
                end;
                return {}; 
            end;
            Q[U7[42]] = U7[39];
            U7[39] = 110;
            Q[U7[39]] = U7[43];
            U7[44] = function(...)
                Q[U7[40]] = false;
                n = r27;
                n.SendKeyEvent(n, false, Enum.KeyCode.E, false, game);
                Q[U7[33]].Text = "STOPPED";
                Q[U7[33]].TextColor3 = r60.red;
                return; 
            end;
            U7[43] = function(...)
                if Q[U7[40]] then
                    return;
                end;
                Q[U7[40]] = true;
                Q[U7[41]] = 0;
                Q[U7[33]].Text = "RUNNING";
                Q[U7[33]].TextColor3 = r60.green;
                task.spawn(function(...)
                    while Q[U7[40]] do
                        v1 = Q[U7[39]]();
                        if #v1 > 0 then
                            y = G[2];
                            x = G[3];
                            G = "ipairs";
                            for x, v2 in ipairs(v1) do
                                U = x;
                                if not Q[U7[40]] then
                                    task.wait(0.5);
                                else
                                    if v2 then
                                        k = v2.Parent;
                                    end;
                                    if v2 then
                                        v4 = r24;
                                        if v2.Parent == v4.FindFirstChild(v4, "Backpack") then
                                            v4 = r24.Character;
                                            if v4 then
                                                v4 = r24.Character;
                                                k = v4.FindFirstChild(v4, "Humanoid");
                                            end;
                                            if v4 then
                                                v4.EquipTool(v4, v2);
                                                task.wait(.3);
                                            end;
                                        end;
                                        Q[U7[33]].Text = "SELLING...";
                                        v5 = r27;
                                        v5.SendKeyEvent(v5, true, Enum.KeyCode.E, false, game);
                                        D = Q[U7[40]];
                                        v4 = D;
                                        while not D do
                                            if D then
                                                task.wait(.1);
                                            end;
                                            v5 = r27;
                                            v5.SendKeyEvent(v5, false, Enum.KeyCode.E, false, game);
                                            Q[U7[41]] = Q[U7[41]] + 1;
                                            Q[U7[35]].Text = "Sold: " .. Q[U7[41]];
                                            Q[U7[33]].Text = "RUNNING";
                                            task.wait(1); 
                                        end;
                                        v4 = tick() - tick() < 2;
                                    end;
                                end; 
                            end;
                        else
                            task.wait(2);
                        end; 
                    end;
                    return; 
                end);
                return; 
            end;
            U7[47] = r16;
            U7[48] = r15;
            U7[49] = U7[48](U7[50], U7[51]);
            U7[46] = U7[47][U7[49]];
            U7[45] = U7[37][U7[46]];
            U7[51] = 23773477727038;
            U7[46] = "Connect";
            U7[46] = U7[45][U7[46]];
            U7[46] = U7[46](U7[45], U7[43]);
            U7[50] = "\x85nj~\xa4\xb7\xad,-\xfa\x05\xfdEO\xab\x1b\xd1";
            U7[47] = r16;
            U7[48] = r15;
            U7[49] = U7[48](U7[50], U7[51]);
            U7[46] = U7[47][U7[49]];
            U7[45] = U7[38][U7[46]];
            U7[46] = "Connect";
            U7[46] = U7[45][U7[46]];
            U7[51] = "D\x18\x18\xcc\x92<\xc4\xc7";
            U7[46] = U7[46](U7[45], U7[44]);
            U7[46] = r64;
            U7[48] = r16;
            U7[49] = r15;
            U7[50] = U7[49](U7[51], U7[52]);
            U7[47] = U7[48][U7[50]];
            U7[45] = U7[46][U7[47]];
            U7[51] = "2\xd8\x9a\x06\n\xa7q\x1f\t\xba\xbcF/v\xed\xe7\xa8";
            U7[48] = r16;
            U7[52] = 23089055263231;
            U7[49] = r15;
            U7[50] = U7[49](U7[51], U7[52]);
            U7[47] = U7[48][U7[50]];
            U7[48] = 1;
            U7[46] = lu(U7[45], U7[47], U7[48]);
            U7[46] = r70;
            U7[48] = 50;
            U7[49] = 2;
            U7[47] = U7[46](U7[45], U7[48], U7[49]);
            U7[49] = "Instance";
            U7[48] = Env[U7[49]];
            U7[31] = nil;
            U7[50] = r16;
            U7[51] = r15;
            U7[52] = U7[51](U7[53], U7[54]);
            U7[49] = U7[50][U7[52]];
            U7[46] = U7[48][U7[49]];
            U7[54] = 33164548897875;
            U7[50] = r16;
            U7[51] = r15;
            U7[38] = nil;
            U7[53] = "\xccX\xaf\r\xc5\xf2*\"\xba";
            U7[52] = U7[51](U7[53], U7[54]);
            U7[49] = U7[50][U7[52]];
            U7[53] = 24541288066211;
            U7[48] = U7[46](U7[49], U7[47]);
            U7[49] = r16;
            U7[52] = "\x0b\xf6\xb9\x0c";
            U7[50] = r15;
            U7[51] = U7[50](U7[52], U7[53]);
            U7[46] = U7[49][U7[51]];
            U7[51] = "UDim2";
            U7[50] = Env[U7[51]];
            U7[52] = r16;
            U7[53] = r15;
            U7[54] = U7[53](U7[55], U7[56]);
            U7[51] = U7[52][U7[54]];
            U7[53] = 1;
            U7[49] = U7[50][U7[51]];
            U7[52] = 0;
            U7[54] = 0;
            U7[51] = .6;
            U7[50] = U7[49](U7[51], U7[52], U7[53], U7[54]);
            U7[33] = nil;
            U7[48][U7[46]] = U7[50];
            U7[49] = r16;
            U7[50] = r15;
            U7[52] = "\x88\xbag\x88>'P\xc5";
            U7[53] = 13124624668639;
            U7[51] = U7[50](U7[52], U7[53]);
            U7[46] = U7[49][U7[51]];
            U7[51] = "UDim2";
            U7[50] = Env[U7[51]];
            U7[55] = "%:\x81";
            U7[56] = 22372595411122;
            U7[52] = r16;
            U7[53] = r15;
            U7[54] = U7[53](U7[55], U7[56]);
            U7[51] = U7[52][U7[54]];
            U7[49] = U7[50][U7[51]];
            U7[53] = 0;
            U7[52] = 12;
            U7[51] = 0;
            U7[54] = 0;
            U7[50] = U7[49](U7[51], U7[52], U7[53], U7[54]);
            U7[48][U7[46]] = U7[50];
            U7[53] = 26514567606330;
            U7[49] = r16;
            U7[50] = r15;
            U7[52] = "\x80\xe4\xc9\x9d\xb8\x88\xfeB\n\x1c\x99\xa1\xeb\xa7\x1c\x18vC@~M0";
            U7[51] = U7[50](U7[52], U7[53]);
            U7[52] = "p)\x9a:";
            U7[53] = 1808886285130;
            U7[46] = U7[49][U7[51]];
            U7[49] = 1;
            U7[48][U7[46]] = U7[49];
            U7[49] = r16;
            U7[54] = 33719474945365;
            U7[50] = r15;
            U7[13] = nil;
            U7[51] = U7[50](U7[52], U7[53]);
            U7[56] = "\xa3\xbd\x0e\x91";
            U7[46] = U7[49][U7[51]];
            U7[50] = r16;
            U7[53] = "f\xe4\xf5N3\rl\x94\xf8{\xb0O\xc2\x9e\x1f\xd1\xe0\xcc\x14<{p\x17\xf4\x8f\xa9";
            U7[51] = r15;
            U7[52] = U7[51](U7[53], U7[54]);
            U7[49] = U7[50][U7[52]];
            U7[48][U7[46]] = U7[49];
            U7[49] = r16;
            U7[52] = "\xd712u";
            U7[50] = r15;
            U7[53] = 18249247138097;
            U7[51] = U7[50](U7[52], U7[53]);
            U7[52] = "Enum";
            U7[46] = U7[49][U7[51]];
            U7[51] = Env[U7[52]];
            U7[53] = r16;
            U7[1] = nil;
            U7[54] = r15;
            U7[55] = U7[54](U7[56], U7[57]);
            U7[52] = U7[53][U7[55]];
            U7[55] = "\x8b\xf9\x01,\xa7?;\x1b\xc2\xe7{\xfa\x14`";
            U7[50] = U7[51][U7[52]];
            U7[52] = r16;
            U7[56] = 28622600238096;
            U7[53] = r15;
            U7[54] = U7[53](U7[55], U7[56]);
            U7[5] = nil;
            U7[55] = "\"\x7f`P";
            U7[51] = U7[52][U7[54]];
            U7[49] = U7[50][U7[51]];
            U7[48][U7[46]] = U7[49];
            U7[49] = r16;
            U7[50] = r15;
            U7[52] = "n\xad\xf2\x8eJ+\x9c\xd0";
            U7[56] = 26583251382362;
            U7[53] = 8381932916543;
            U7[51] = U7[50](U7[52], U7[53]);
            U7[46] = U7[49][U7[51]];
            U7[49] = 12;
            U7[48][U7[46]] = U7[49];
            U7[53] = 29246827459891;
            U7[52] = "\x81\xbe\x932\xc2$\xfd\xe6hE";
            U7[49] = r16;
            U7[50] = r15;
            U7[51] = U7[50](U7[52], U7[53]);
            U7[46] = U7[49][U7[51]];
            U7[50] = r60;
            U7[52] = r16;
            U7[67] = 31974140639785;
            U7[53] = r15;
            U7[54] = U7[53](U7[55], U7[56]);
            U7[51] = U7[52][U7[54]];
            U7[49] = U7[50][U7[51]];
            U7[48][U7[46]] = U7[49];
            U7[49] = r16;
            U7[53] = 1337912099439;
            U7[52] = "B\xe9\xa6\xee\x07\x7f\xf7\x98\x99\x8d\xe6\x1fUx";
            U7[56] = "\xeei\x85c\xa0\x9dt :p/J\x92\xcc";
            U7[50] = r15;
            U7[51] = U7[50](U7[52], U7[53]);
            U7[40] = nil;
            U7[14] = nil;
            U7[46] = U7[49][U7[51]];
            U7[52] = "Enum";
            U7[57] = 24572822006962;
            U7[25] = nil;
            U7[51] = Env[U7[52]];
            U7[53] = r16;
            U7[54] = r15;
            U7[55] = U7[54](U7[56], U7[57]);
            U7[52] = U7[53][U7[55]];
            U7[56] = 33297132649617;
            U7[55] = "|\x14\xa8\x06";
            U7[50] = U7[51][U7[52]];
            U7[52] = r16;
            U7[53] = r15;
            U7[54] = U7[53](U7[55], U7[56]);
            U7[53] = 20967789340195;
            U7[51] = U7[52][U7[54]];
            U7[27] = nil;
            U7[49] = U7[50][U7[51]];
            U7[54] = "DB4";
            U7[52] = "\xcc\xf1A\xdb\xe54\x9c\x8bI\xb0\x0f\xeb\xf7\x90v\x06s9\x8cN\x16\xcc";
            U7[57] = "8\xc0j";
            U7[48][U7[46]] = U7[49];
            U7[49] = r16;
            U7[50] = r15;
            U7[51] = U7[50](U7[52], U7[53]);
            U7[55] = 30565187123097;
            U7[46] = U7[49][U7[51]];
            U7[50] = "Instance";
            U7[49] = 1;
            U7[48][U7[46]] = U7[49];
            U7[49] = Env[U7[50]];
            U7[51] = r16;
            U7[52] = r15;
            U7[53] = U7[52](U7[54], U7[55]);
            U7[50] = U7[51][U7[53]];
            U7[62] = "\xccu&";
            U7[46] = U7[49][U7[50]];
            U7[54] = "\x86\x83\xe1\x8bO\xed\x87k\x8a%";
            U7[51] = r16;
            U7[55] = 14792270797544;
            U7[52] = r15;
            U7[53] = U7[52](U7[54], U7[55]);
            U7[55] = 23900384881529;
            U7[50] = U7[51][U7[53]];
            U7[49] = U7[46](U7[50], U7[47]);
            U7[46] = 111;
            Q[U7[46]] = U7[49];
            U7[49] = Q[U7[46]];
            U7[54] = "\xa11f\xfb";
            U7[51] = r16;
            U7[52] = r15;
            U7[53] = U7[52](U7[54], U7[55]);
            U7[50] = U7[51][U7[53]];
            U7[53] = "UDim2";
            U7[52] = Env[U7[53]];
            U7[54] = r16;
            U7[55] = r15;
            U7[56] = U7[55](U7[57], U7[58]);
            U7[53] = U7[54][U7[56]];
            U7[54] = 80;
            U7[58] = 17056066952966;
            U7[51] = U7[52][U7[53]];
            U7[53] = 0;
            U7[56] = 32;
            U7[57] = "\x13\xcc\x8c";
            U7[55] = 0;
            U7[52] = U7[51](U7[53], U7[54], U7[55], U7[56]);
            U7[49][U7[50]] = U7[52];
            U7[49] = Q[U7[46]];
            U7[55] = 13833128073513;
            U7[11] = nil;
            U7[54] = "\xdf\x05\x01'\x85\x07\xc7\x16";
            U7[51] = r16;
            U7[52] = r15;
            U7[53] = U7[52](U7[54], U7[55]);
            U7[50] = U7[51][U7[53]];
            U7[53] = "UDim2";
            U7[52] = Env[U7[53]];
            U7[54] = r16;
            U7[55] = r15;
            U7[56] = U7[55](U7[57], U7[58]);
            U7[53] = U7[54][U7[56]];
            U7[54] = -92;
            U7[55] = 0.5;
            U7[51] = U7[52][U7[53]];
            U7[56] = -16;
            U7[57] = "f\t\xaa=\xe7";
            U7[53] = 1;
            U7[52] = U7[51](U7[53], U7[54], U7[55], U7[56]);
            U7[49][U7[50]] = U7[52];
            U7[49] = Q[U7[46]];
            U7[55] = 18799745507890;
            U7[51] = r16;
            U7[52] = r15;
            U7[54] = ":h\xc9ZV!\x97q\x95DY\x18\x96\xecy<";
            U7[53] = U7[52](U7[54], U7[55]);
            U7[50] = U7[51][U7[53]];
            U7[52] = r60;
            U7[54] = r16;
            U7[55] = r15;
            U7[58] = 31359636945162;
            U7[56] = U7[55](U7[57], U7[58]);
            U7[53] = U7[54][U7[56]];
            U7[51] = U7[52][U7[53]];
            U7[49][U7[50]] = U7[51];
            U7[55] = 27097656176970;
            U7[49] = Q[U7[46]];
            U7[51] = r16;
            U7[44] = nil;
            U7[52] = r15;
            U7[37] = nil;
            U7[54] = "\xc8\x02 k";
            U7[56] = 7388851146096;
            U7[53] = U7[52](U7[54], U7[55]);
            U7[50] = U7[51][U7[53]];
            U7[55] = "\xd4\xbb";
            U7[58] = "\xc7\xb1\xe3\"";
            U7[52] = r16;
            U7[53] = r15;
            U7[54] = U7[53](U7[55], U7[56]);
            U7[3] = nil;
            U7[51] = U7[52][U7[54]];
            U7[54] = "\r\xcc \x0f";
            U7[49][U7[50]] = U7[51];
            U7[55] = 11876438988186;
            U7[49] = Q[U7[46]];
            U7[51] = r16;
            U7[52] = r15;
            U7[53] = U7[52](U7[54], U7[55]);
            U7[54] = "Enum";
            U7[50] = U7[51][U7[53]];
            U7[53] = Env[U7[54]];
            U7[55] = r16;
            U7[56] = r15;
            U7[57] = U7[56](U7[58], U7[59]);
            U7[58] = 34341020450423;
            U7[54] = U7[55][U7[57]];
            U7[52] = U7[53][U7[54]];
            U7[54] = r16;
            U7[57] = "1s\xf3c\xc7\x87~x~\xac";
            U7[55] = r15;
            U7[56] = U7[55](U7[57], U7[58]);
            U7[55] = 9856615780845;
            U7[53] = U7[54][U7[56]];
            U7[54] = "gZ\\\x1a,\xb9\xa9J";
            U7[51] = U7[52][U7[53]];
            U7[49][U7[50]] = U7[51];
            U7[58] = 5853659040421;
            U7[49] = Q[U7[46]];
            U7[51] = r16;
            U7[52] = r15;
            U7[53] = U7[52](U7[54], U7[55]);
            U7[55] = 4359255312365;
            U7[50] = U7[51][U7[53]];
            U7[54] = "mz\x1b\xe9\xb8[\xfd\x97r\x10";
            U7[51] = 12;
            U7[49][U7[50]] = U7[51];
            U7[49] = Q[U7[46]];
            U7[51] = r16;
            U7[52] = r15;
            U7[57] = "\xe8\x9e\xfc\x99";
            U7[53] = U7[52](U7[54], U7[55]);
            U7[50] = U7[51][U7[53]];
            U7[52] = r60;
            U7[54] = r16;
            U7[55] = r15;
            U7[56] = U7[55](U7[57], U7[58]);
            U7[53] = U7[54][U7[56]];
            U7[51] = U7[52][U7[53]];
            U7[56] = 32368226646752;
            U7[49][U7[50]] = U7[51];
            U7[49] = Q[U7[46]];
            U7[54] = "Y,\xb97\x1b\xfe\xd2\x18\xd5\x86>\x8az\x8a\t";
            U7[51] = r16;
            U7[43] = nil;
            U7[55] = 22981240449485;
            U7[52] = r15;
            U7[53] = U7[52](U7[54], U7[55]);
            U7[50] = U7[51][U7[53]];
            U7[54] = "\x02\xc4\xb0\"6\x13\r\xfe\xb4\xfe\x8f\x9b.\xe7\xfb^\xa1L\xf8\x86/\x80";
            U7[20] = nil;
            U7[55] = 26731850723487;
            U7[51] = 0;
            U7[49][U7[50]] = U7[51];
            U7[49] = Q[U7[46]];
            U7[51] = r16;
            U7[52] = r15;
            U7[53] = U7[52](U7[54], U7[55]);
            U7[50] = U7[51][U7[53]];
            U7[10] = nil;
            U7[51] = 1;
            U7[55] = "\xfbdB";
            U7[49][U7[50]] = U7[51];
            U7[51] = "Instance";
            U7[50] = Env[U7[51]];
            U7[52] = r16;
            U7[53] = r15;
            U7[54] = U7[53](U7[55], U7[56]);
            U7[35] = nil;
            U7[51] = U7[52][U7[54]];
            U7[49] = U7[50][U7[51]];
            U7[52] = r16;
            U7[55] = "\x89\x14=\x01\xe6Ne7";
            U7[53] = r15;
            U7[56] = 24790126734615;
            U7[54] = U7[53](U7[55], U7[56]);
            U7[51] = U7[52][U7[54]];
            U7[52] = Q[U7[46]];
            U7[8] = nil;
            U7[50] = U7[49](U7[51], U7[52]);
            U7[58] = 15433101679634;
            U7[51] = r16;
            U7[54] = "\xb7)&\xcf\xb2\x97\x0b\xbaX\xf2\xa1*";
            U7[57] = "\t\xe5\xc2";
            U7[52] = r15;
            U7[55] = 25266953563637;
            U7[53] = U7[52](U7[54], U7[55]);
            U7[49] = U7[51][U7[53]];
            U7[53] = "UDim";
            U7[52] = Env[U7[53]];
            U7[54] = r16;
            U7[55] = r15;
            U7[56] = U7[55](U7[57], U7[58]);
            U7[53] = U7[54][U7[56]];
            U7[51] = U7[52][U7[53]];
            U7[55] = "\xfb\xd9\xf7KGp\x84\xbf\xe3G\xf3q\xc2*\xb6\xa0\x81";
            U7[53] = 0;
            U7[54] = 6;
            U7[52] = U7[51](U7[53], U7[54]);
            U7[50][U7[49]] = U7[52];
            U7[50] = Q[U7[46]];
            U7[56] = 34457372901037;
            U7[52] = r16;
            U7[53] = r15;
            U7[54] = U7[53](U7[55], U7[56]);
            U7[51] = U7[52][U7[54]];
            U7[49] = U7[50][U7[51]];
            U7[50] = "Connect";
            U7[24] = nil;
            U7[50] = U7[49][U7[50]];
            U7[51] = function(...)
                r33 = not r33;
                if r33 then
                    Q[U7[46]].Text = "ON";
                    Q[U7[46]].BackgroundColor3 = r60.green;
                else
                    Q[U7[46]].Text = "OFF";
                    Q[U7[46]].BackgroundColor3 = r60.red;
                end;
                return; 
            end;
            U7[50] = U7[50](U7[49], U7[51]);
            U7[51] = r16;
            U7[55] = 13289093175340;
            U7[54] = "s\xb6\x1e\x0c\x8a\xe7\x91)\xefO\x82))\xa1!\xc1\\\x14\xb6e\x9c\xec\x11\xa7";
            U7[52] = r15;
            U7[53] = U7[52](U7[54], U7[55]);
            U7[50] = U7[51][U7[53]];
            U7[57] = "\x8a\xffp\xc0\r\xe0\xa6\xe7\x95";
            U7[51] = 3;
            U7[49] = lu(U7[45], U7[50], U7[51]);
            U7[51] = r16;
            U7[55] = 23009092331994;
            U7[58] = 34836748812126;
            U7[52] = r15;
            U7[59] = 1657848300291;
            U7[54] = "\x7f=s\n\x84\xdcv\t\xe5\xf4\xa5\x9f\xc6";
            U7[53] = U7[52](U7[54], U7[55]);
            U7[50] = U7[51][U7[53]];
            U7[52] = r60;
            U7[54] = r16;
            U7[55] = r15;
            U7[56] = U7[55](U7[57], U7[58]);
            U7[53] = U7[54][U7[56]];
            U7[51] = U7[52][U7[53]];
            U7[55] = "^\xaf\x8f\x0b2\xf4\xfa\x8d\x9a#/\xed\xf6\xf6";
            U7[52] = 4;
            U7[49] = fu(U7[45], U7[50], U7[51], U7[52]);
            U7[52] = r16;
            U7[58] = "\xb6.\xa2xAKLZ\xbd";
            U7[53] = r15;
            U7[56] = 13260034971678;
            U7[54] = U7[53](U7[55], U7[56]);
            U7[51] = U7[52][U7[54]];
            U7[53] = r60;
            U7[55] = r16;
            U7[56] = r15;
            U7[57] = U7[56](U7[58], U7[59]);
            U7[54] = U7[55][U7[57]];
            U7[59] = "\x93\xd6\x1a2\x91\x95N\xee\xb7";
            U7[56] = "\x17W\xb7\xe1\xad\x91U\xe1";
            U7[52] = U7[53][U7[54]];
            U7[53] = 5;
            U7[50] = fu(U7[45], U7[51], U7[52], U7[53]);
            U7[57] = 16708443659876;
            U7[53] = r16;
            U7[54] = r15;
            U7[55] = U7[54](U7[56], U7[57]);
            U7[52] = U7[53][U7[55]];
            U7[54] = r60;
            U7[56] = r16;
            U7[57] = r15;
            U7[58] = U7[57](U7[59], U7[60]);
            U7[57] = "\xc9.\x7f\x89\xf8\xef\xd2Z\x12\x05";
            U7[55] = U7[56][U7[58]];
            U7[58] = 33017485245454;
            U7[53] = U7[54][U7[55]];
            U7[54] = 6;
            U7[51] = fu(U7[45], U7[52], U7[53], U7[54]);
            U7[60] = "\xb8\xd8QZ\xfc[!$\xf7";
            U7[54] = r16;
            U7[55] = r15;
            U7[56] = U7[55](U7[57], U7[58]);
            U7[53] = U7[54][U7[56]];
            U7[55] = r60;
            U7[57] = r16;
            U7[58] = r15;
            U7[59] = U7[58](U7[60], U7[61]);
            U7[56] = U7[57][U7[59]];
            U7[59] = 4264259536833;
            U7[58] = "\x0c\x8d&o\xec\x17#\xd32d\xf3\t\x0b\xbd\x050}";
            U7[54] = U7[55][U7[56]];
            U7[55] = 7;
            U7[52] = fu(U7[45], U7[53], U7[54], U7[55]);
            U7[55] = r16;
            U7[56] = r15;
            U7[57] = U7[56](U7[58], U7[59]);
            U7[54] = U7[55][U7[57]];
            U7[53] = U7[49][U7[54]];
            U7[58] = "Y\xea\xe3#\xb2\xedBK\xe8$m\xc2\xf4\x87\xcc\x8bt";
            U7[55] = r54;
            U7[60] = 19566167925655;
            U7[54] = "Connect";
            U7[59] = 9709552128425;
            U7[54] = U7[53][U7[54]];
            U7[54] = U7[54](U7[53], U7[55]);
            U7[55] = r16;
            U7[56] = r15;
            U7[57] = U7[56](U7[58], U7[59]);
            U7[54] = U7[55][U7[57]];
            U7[53] = U7[50][U7[54]];
            U7[54] = "Connect";
            U7[58] = "\x179nw{(\x07\rn\xaap\xb5\xd6\xaa\x92wC";
            U7[29] = nil;
            U7[54] = U7[53][U7[54]];
            U7[59] = 23624067099384;
            U7[12] = nil;
            U7[54] = U7[54](U7[53], function(...)
                v1 = r24.Character;
                y = v1 and v1.FindFirstChild(v1, "HumanoidRootPart");
                if y then
                    y.CFrame = y.CFrame - y.CFrame.LookVector * 8;
                end;
                return; 
            end);
            U7[55] = r16;
            U7[56] = r15;
            U7[57] = U7[56](U7[58], U7[59]);
            U7[59] = 3420907882040;
            U7[58] = "\xf8\xc7\x1d_\x13\x980\xb4*B>\xd5\x8f$N\xe3\x11";
            U7[54] = U7[55][U7[57]];
            U7[53] = U7[51][U7[54]];
            U7[54] = "Connect";
            U7[54] = U7[53][U7[54]];
            U7[54] = U7[54](U7[53], function(...)
                v1 = r24.Character;
                y = v1 and v1.FindFirstChild(v1, "HumanoidRootPart");
                if y then
                    y.CFrame = y.CFrame * CFrame.new(0, 5, 0);
                end;
                return; 
            end);
            U7[55] = r16;
            U7[56] = r15;
            U7[57] = U7[56](U7[58], U7[59]);
            U7[54] = U7[55][U7[57]];
            U7[59] = "Sa\x1a\x9d\r";
            U7[53] = U7[52][U7[54]];
            U7[54] = "Connect";
            U7[55] = "task";
            U7[54] = U7[53][U7[54]];
            U7[54] = U7[54](U7[53], function(...)
                v1 = r24.Character;
                y = v1 and v1.FindFirstChild(v1, "HumanoidRootPart");
                if y then
                    y.CFrame = y.CFrame * CFrame.new(0, -5, 0);
                end; 
            end);
            U7[54] = Env[U7[55]];
            U7[56] = r16;
            U7[57] = r15;
            U7[58] = U7[57](U7[59], U7[60]);
            U7[55] = U7[56][U7[58]];
            U7[60] = 31426163816745;
            U7[48] = nil;
            U7[53] = U7[54][U7[55]];
            U7[55] = function(...)
                v1 = r59;
                n = v1;
                while not v1 do
                    if n then
                        if r64.AUTO and r64.AUTO.Visible then
                            r89();
                        end;
                        if r64.FULLY and r64.FULLY.Visible then
                            Q[U7[2]]();
                        end;
                        task.wait(1);
                    end;
                    return; 
                end;
                n = r59.Parent; 
            end;
            U7[18] = nil;
            U7[54] = U7[53](U7[55]);
            U7[53] = true;
            U7[54] = 112;
            U7[59] = "\xd3\xe1h=Y\xc11\x16\xad\xbf.C\xbc\x9d5\x96c";
            Q[U7[54]] = U7[53];
            U7[56] = r16;
            U7[57] = r15;
            U7[58] = U7[57](U7[59], U7[60]);
            U7[55] = U7[56][U7[58]];
            U7[53] = Yu[U7[55]];
            U7[56] = function(...)
                Q[U7[54]] = not Q[U7[54]];
                r62.Visible = Q[U7[54]];
                v1 = "Visible";
                r63[v1] = Q[U7[54]];
                if Q[U7[54]] then
                    n = r26;
                    v1 = n.Create(n, r61, TweenInfo.new(.22, Enum.EasingStyle.Quint), {
                        ["Size"] = UDim2.new(0, 520, 0, 420)
                    });
                    v1.Play(v1);
                else
                    n = r26;
                    v1 = n.Create(n, r61, TweenInfo.new(.22, Enum.EasingStyle.Quint), {
                        ["Size"] = UDim2.new(0, 520, 0, 46)
                    });
                    v1.Play(v1);
                end;
                return; 
            end;
            U7[55] = "Connect";
            U7[55] = U7[53][U7[55]];
            U7[55] = U7[55](U7[53], U7[56]);
            U7[60] = "\xb8|\xec";
            U7[56] = "Instance";
            U7[61] = 937643131316;
            U7[55] = Env[U7[56]];
            U7[57] = r16;
            U7[58] = r15;
            U7[64] = 28046476342020;
            U7[59] = U7[58](U7[60], U7[61]);
            U7[60] = "_\x8a\x87\x98\xd0s\xf7\x1d\x95\xce";
            U7[56] = U7[57][U7[59]];
            U7[53] = U7[55][U7[56]];
            U7[57] = r16;
            U7[58] = r15;
            U7[61] = 27787944538763;
            U7[59] = U7[58](U7[60], U7[61]);
            U7[56] = U7[57][U7[59]];
            U7[59] = "\x97\x7f\xb3\xdc";
            U7[57] = r59;
            U7[55] = U7[53](U7[56], U7[57]);
            U7[56] = r16;
            U7[57] = r15;
            U7[60] = 30910062557241;
            U7[58] = U7[57](U7[59], U7[60]);
            U7[42] = nil;
            U7[53] = U7[56][U7[58]];
            U7[58] = "UDim2";
            U7[57] = Env[U7[58]];
            U7[59] = r16;
            U7[60] = r15;
            U7[61] = U7[60](U7[62], U7[63]);
            U7[60] = 0;
            U7[58] = U7[59][U7[61]];
            U7[63] = 35174322094075;
            U7[56] = U7[57][U7[58]];
            U7[59] = 42;
            U7[58] = 0;
            U7[66] = "\xb9\xab\x04Bp.\xf0";
            U7[61] = 42;
            U7[62] = "\xbdK\xb1";
            U7[57] = U7[56](U7[58], U7[59], U7[60], U7[61]);
            U7[55][U7[53]] = U7[57];
            U7[56] = r16;
            U7[32] = nil;
            U7[59] = "\"f)\x99S\xfc \xff";
            U7[60] = 1225300181562;
            U7[57] = r15;
            U7[58] = U7[57](U7[59], U7[60]);
            U7[34] = nil;
            U7[53] = U7[56][U7[58]];
            U7[52] = nil;
            U7[58] = "UDim2";
            U7[57] = Env[U7[58]];
            U7[59] = r16;
            U7[60] = r15;
            U7[61] = U7[60](U7[62], U7[63]);
            U7[60] = 0.5;
            U7[58] = U7[59][U7[61]];
            U7[61] = -21;
            U7[56] = U7[57][U7[58]];
            U7[58] = 1;
            U7[59] = -52;
            U7[36] = nil;
            U7[57] = U7[56](U7[58], U7[59], U7[60], U7[61]);
            U7[60] = 8480308416364;
            U7[59] = "\xbd\xbe\xed.";
            U7[55][U7[53]] = U7[57];
            U7[56] = r16;
            U7[61] = 24849367280947;
            U7[57] = r15;
            U7[15] = nil;
            U7[58] = U7[57](U7[59], U7[60]);
            U7[60] = "(w/";
            U7[53] = U7[56][U7[58]];
            U7[57] = r16;
            U7[58] = r15;
            U7[59] = U7[58](U7[60], U7[61]);
            U7[56] = U7[57][U7[59]];
            U7[55][U7[53]] = U7[56];
            U7[56] = r16;
            U7[57] = r15;
            U7[60] = 3410857870900;
            U7[59] = "\x9b\x0c\xc3\xc3";
            U7[58] = U7[57](U7[59], U7[60]);
            U7[59] = "Enum";
            U7[53] = U7[56][U7[58]];
            U7[63] = "\xc2\xe6\x0e}";
            U7[58] = Env[U7[59]];
            U7[60] = r16;
            U7[61] = r15;
            U7[62] = U7[61](U7[63], U7[64]);
            U7[59] = U7[60][U7[62]];
            U7[57] = U7[58][U7[59]];
            U7[59] = r16;
            U7[60] = r15;
            U7[62] = "\x98Y\x1aP\x8a_\x9a9\x02o\xcd";
            U7[63] = 17648317587482;
            U7[61] = U7[60](U7[62], U7[63]);
            U7[58] = U7[59][U7[61]];
            U7[63] = 1994746512288;
            U7[56] = U7[57][U7[58]];
            U7[55][U7[53]] = U7[56];
            U7[60] = 12685424793363;
            U7[56] = r16;
            U7[59] = "\xc0\x87X/\xb1\xfd\xe5\xf6";
            U7[57] = r15;
            U7[58] = U7[57](U7[59], U7[60]);
            U7[50] = nil;
            U7[62] = "\xa0\x9dHT\xf0\x92";
            U7[53] = U7[56][U7[58]];
            U7[56] = 12;
            U7[59] = ",iAmxzR\xf9\xfc\x88\xcf\x8a\xa7D\xeb\xb7";
            U7[60] = 225140523112;
            U7[55][U7[53]] = U7[56];
            U7[56] = r16;
            U7[57] = r15;
            U7[58] = U7[57](U7[59], U7[60]);
            U7[53] = U7[56][U7[58]];
            U7[57] = r60;
            U7[59] = r16;
            U7[60] = r15;
            U7[61] = U7[60](U7[62], U7[63]);
            U7[58] = U7[59][U7[61]];
            U7[60] = 19143846257362;
            U7[56] = U7[57][U7[58]];
            U7[55][U7[53]] = U7[56];
            U7[46] = nil;
            U7[56] = r16;
            U7[41] = nil;
            U7[57] = r15;
            U7[59] = "4B\x1e]\x1ap\xc0L\xd6\xf2";
            U7[58] = U7[57](U7[59], U7[60]);
            U7[53] = U7[56][U7[58]];
            U7[58] = "Color3";
            U7[57] = Env[U7[58]];
            U7[63] = 32378303544037;
            U7[64] = 16863943155372;
            U7[62] = "\n(\x14";
            U7[59] = r16;
            U7[60] = r15;
            U7[61] = U7[60](U7[62], U7[63]);
            U7[58] = U7[59][U7[61]];
            U7[47] = nil;
            U7[62] = 16373182930376;
            U7[56] = U7[57][U7[58]];
            U7[58] = 1;
            U7[60] = 1;
            U7[49] = nil;
            U7[59] = 1;
            U7[57] = U7[56](U7[58], U7[59], U7[60]);
            U7[55][U7[53]] = U7[57];
            U7[60] = 11608129017117;
            U7[56] = r16;
            U7[57] = r15;
            U7[59] = "\x1e\xee\xce\xc5\x08\x1c";
            U7[58] = U7[57](U7[59], U7[60]);
            U7[53] = U7[56][U7[58]];
            U7[56] = true;
            U7[59] = "#\xcb_\xcd\xa2\xc2&\xc6\x96";
            U7[63] = "\x88\xf1b";
            U7[55][U7[53]] = U7[56];
            U7[60] = 5850997295780;
            U7[56] = r16;
            U7[57] = r15;
            U7[58] = U7[57](U7[59], U7[60]);
            U7[61] = "\xd9\x7f\xdb";
            U7[59] = "\xfd\xc5\x9d\xfa\x97\xef\xc5\xf1\xb1\xaa\xcb\xd84\x08\xc2";
            U7[53] = U7[56][U7[58]];
            U7[60] = 28620095255567;
            U7[56] = true;
            U7[55][U7[53]] = U7[56];
            U7[56] = r16;
            U7[57] = r15;
            U7[58] = U7[57](U7[59], U7[60]);
            U7[53] = U7[56][U7[58]];
            U7[56] = 0;
            U7[55][U7[53]] = U7[56];
            U7[56] = r16;
            U7[57] = r15;
            U7[60] = 4742321113248;
            U7[59] = "\x18<\x7f@\xdd\xa8\x99\x1f\x81\x87;\xc6N\x83\x81ot\xa0\xc0\xae.\xfc";
            U7[58] = U7[57](U7[59], U7[60]);
            U7[53] = U7[56][U7[58]];
            U7[56] = 1;
            U7[55][U7[53]] = U7[56];
            U7[57] = "Instance";
            U7[56] = Env[U7[57]];
            U7[58] = r16;
            U7[59] = r15;
            U7[60] = U7[59](U7[61], U7[62]);
            U7[57] = U7[58][U7[60]];
            U7[53] = U7[56][U7[57]];
            U7[58] = r16;
            U7[61] = "\x92\x04\x7f\xfej\xc4}f";
            U7[62] = 18197343117593;
            U7[59] = r15;
            U7[60] = U7[59](U7[61], U7[62]);
            U7[57] = U7[58][U7[60]];
            U7[54] = nil;
            U7[19] = nil;
            U7[61] = 7980574183044;
            U7[56] = U7[53](U7[57], U7[55]);
            U7[60] = "\x85\x8a\xcf\xf1)(\xa5\xed\x07\xc5\x83\xd8";
            U7[57] = r16;
            U7[58] = r15;
            U7[59] = U7[58](U7[60], U7[61]);
            U7[53] = U7[57][U7[59]];
            U7[59] = "UDim";
            U7[58] = Env[U7[59]];
            U7[60] = r16;
            U7[45] = nil;
            U7[61] = r15;
            U7[62] = U7[61](U7[63], U7[64]);
            U7[59] = U7[60][U7[62]];
            U7[57] = U7[58][U7[59]];
            U7[60] = 10;
            U7[59] = 0;
            U7[39] = nil;
            U7[58] = U7[57](U7[59], U7[60]);
            U7[61] = 25682869137079;
            U7[56][U7[53]] = U7[58];
            U7[57] = r16;
            U7[62] = "Enum";
            U7[60] = "Kz\xcb\x9c\x97\xf0a\xe2\x90\xa6y\xa3\x8aU\xd1R9";
            U7[51] = nil;
            U7[58] = r15;
            U7[59] = U7[58](U7[60], U7[61]);
            U7[56] = U7[57][U7[59]];
            U7[2] = nil;
            U7[28] = nil;
            U7[57] = function(...)
                r61.Visible = not r61.Visible;
                return; 
            end;
            U7[53] = U7[55][U7[56]];
            U7[60] = "^\xa9\xd4\xb2f_\x97\x01\x02\x074\xb6";
            U7[56] = "Connect";
            U7[56] = U7[53][U7[56]];
            U7[56] = U7[56](U7[53], U7[57]);
            U7[57] = r16;
            U7[58] = r15;
            U7[61] = 11273116226689;
            U7[55] = nil;
            U7[59] = U7[58](U7[60], U7[61]);
            U7[56] = U7[57][U7[59]];
            U7[26] = nil;
            U7[53] = "BindAction";
            U7[58] = false;
            U7[61] = Env[U7[62]];
            U7[63] = r16;
            U7[57] = function(arg1_25, arg2_25, ...)
                v1 = arg1_25;
                if arg2_25 == Enum.UserInputState.Begin then
                    r61.Visible = not r61.Visible;
                end;
                return; 
            end;
            U7[64] = r15;
            U7[65] = U7[64](U7[66], U7[67]);
            U7[66] = 5849088756387;
            U7[62] = U7[63][U7[65]];
            U7[60] = U7[61][U7[62]];
            U7[65] = "\x8c";
            U7[62] = r16;
            U7[63] = r15;
            U7[64] = U7[63](U7[65], U7[66]);
            U7[61] = U7[62][U7[64]];
            U7[53] = g[U7[53]];
            U7[59] = U7[60][U7[61]];
            U7[62] = 18423843070339;
            U7[53] = U7[53](g, U7[56], U7[57], U7[58], U7[59]);
            U7[53] = r67;
            U7[61] = "\x89\xb7\x07\x8b";
            U7[58] = r16;
            U7[59] = r15;
            U7[60] = U7[59](U7[61], U7[62]);
            U7[57] = U7[58][U7[60]];
            U7[56] = U7[53](U7[57]);
            return;
        end;
    end;
end;
return (function(...)
    while true do
