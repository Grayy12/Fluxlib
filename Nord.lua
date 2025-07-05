local GuiService = game:GetService("GuiService")
-- << Services >> --
local TweenService, Core do
    TweenService = game:GetService("TweenService"); Core = game:GetService("CoreGui");
end

local New = function(Class, Properties)
    local Obj, Properties = Instance.new(Class), Properties or {}
    if Obj:IsA("GuiObject") then Obj["AnchorPoint"] = Vector2.new(0.5, 0.5); Obj["BorderSizePixel"] = 0 end;
    for I, V in pairs(Properties) do if rawequal(I, "Parent") then continue end; Obj[I] = V end
    if Properties["Parent"] then Obj["Parent"] = Properties["Parent"] end; return Obj;
end

local Tween = function(I, T, S, D, G, RT)
    local ObjTween = TweenService:Create(I, TweenInfo.new(T, Enum["EasingStyle"][S], Enum["EasingDirection"][D]), G);
    if RT then return ObjTween
    else
        coroutine.wrap(function()
            ObjTween:Play()
        end)()
    end
end

if Core:FindFirstChild("NordNotifications") then Core:FindFirstChild("NordNotifications"):Destroy() end
local UI = New("ScreenGui", {
    ["IgnoreGuiInset"] = true; ["Name"] = "NordNotifications"; ["ResetOnSpawn"] = false; ["ZIndexBehavior"] = "Global"
});
UI.Parent = Core;

local NotificationHolder = New("Frame", {
    Parent = UI, BackgroundTransparency = 1, Position = UDim2.new(0.924, 0, 0.5, 0), Size = UDim2.new(0.151, 0, 1, 0)
});
New("UIListLayout", {Parent = NotificationHolder, Padding = UDim.new(0, 15), HorizontalAlignment = "Center", VerticalAlignment = "Bottom"});
New("UIPadding", {Parent = NotificationHolder, PaddingBottom = UDim.new(0, 20), PaddingTop = UDim.new(0, 20)});

local Nord = {};

Nord["Config"] = { ["Theme"] = "Dark" }

Nord["Themes"] = {
    ["light"] = {
        ["Frame"] = {
            ["BackgroundColor3"] = Color3.new(0.121568, 0.121568, 0.121568);
        },
        ["TextLabel"] = {
            ["TextColor3"] = Color3.new(0.650980, 0.027450, 0.027450)
        }
    },
    ["dark"] = {
        ["Frame"] = {
            ["BackgroundColor3"] = Color3.fromRGB(70, 70, 73);
        },
        ["TextLabel"] = {
            ["TextColor3"] = Color3.new(1, 1, 1)
        }
    },
    ["discord"] = {
        ["Frame"] = {
            ["BackgroundColor3"] = Color3.fromRGB(44, 47, 51);
        },
        ["TextLabel"] = {
            ["TextColor3"] = Color3.fromRGB(114, 137, 218)
        }
    },
    ["spotify"] = {
        ["Frame"] = {
            ["BackgroundColor3"] = Color3.fromRGB(25, 20, 20);
        },
        ["TextLabel"] = {
            ["TextColor3"] = Color3.fromRGB(30, 215, 96)
        }
    },
	["ocean"] = {
		["Frame"] = {
			["BackgroundColor3"] = Color3.fromRGB(52, 73, 94);
		},
		["TextLabel"] = {
			["TextColor3"] = Color3.fromRGB(174, 214, 241)
		}
	},
	["sunset"] = {
		["Frame"] = {
			["BackgroundColor3"] = Color3.fromRGB(72, 52, 70);
		},
		["TextLabel"] = {
			["TextColor3"] = Color3.fromRGB(255, 193, 122)
		}
	},
	["mint"] = {
		["Frame"] = {
			["BackgroundColor3"] = Color3.fromRGB(46, 64, 54);
		},
		["TextLabel"] = {
			["TextColor3"] = Color3.fromRGB(152, 211, 180)
		}
	},
	["lavender"] = {
		["Frame"] = {
			["BackgroundColor3"] = Color3.fromRGB(67, 56, 75);
		},
		["TextLabel"] = {
			["TextColor3"] = Color3.fromRGB(196, 176, 222)
		}
	},
	["rose"] = {
		["Frame"] = {
			["BackgroundColor3"] = Color3.fromRGB(74, 55, 63);
		},
		["TextLabel"] = {
			["TextColor3"] = Color3.fromRGB(255, 183, 197)
		}
	},
	["sage"] = {
		["Frame"] = {
			["BackgroundColor3"] = Color3.fromRGB(56, 66, 58);
		},
		["TextLabel"] = {
			["TextColor3"] = Color3.fromRGB(185, 206, 168)
		}
	},
	["coral"] = {
		["Frame"] = {
			["BackgroundColor3"] = Color3.fromRGB(73, 59, 56);
		},
		["TextLabel"] = {
			["TextColor3"] = Color3.fromRGB(255, 183, 158)
		}
	},
	["steel"] = {
		["Frame"] = {
			["BackgroundColor3"] = Color3.fromRGB(58, 68, 75);
		},
		["TextLabel"] = {
			["TextColor3"] = Color3.fromRGB(176, 196, 209)
		}
	},
	["neon"] = {
		["Frame"] = {
			["BackgroundColor3"] = Color3.fromRGB(23, 23, 23);
		},
		["TextLabel"] = {
			["TextColor3"] = Color3.fromRGB(0, 255, 127)
		}
	},
	["cyber"] = {
		["Frame"] = {
			["BackgroundColor3"] = Color3.fromRGB(30, 30, 40);
		},
		["TextLabel"] = {
			["TextColor3"] = Color3.fromRGB(255, 0, 255)
		}
	},
	["purple"] = {
		["Frame"] = {
			["BackgroundColor3"] = Color3.fromRGB(66, 46, 84);
		},
		["TextLabel"] = {
			["TextColor3"] = Color3.fromRGB(186, 156, 255)
		}
	}
}

function Nord:TextConstraint(Item)
    New("UITextSizeConstraint", {Parent = Item, MaxTextSize = Item["TextSize"]}); Item["TextScaled"] = true
end

function Nord:ApplyTheme(Theme, Frame)
    local Desc = Frame:GetDescendants()
    if Nord["Themes"][Theme:lower()] then
        for i, v in next, Nord["Themes"][Theme:lower()] do
            for a, b in next, Desc do
                if b["ClassName"] == i and b["Name"] ~= "Line" then
                    for c, d in next, v do
                        b[c] = d
                    end
                elseif i == "Frame" then
                    for c, d in next, v do
                        Frame[c] = d
                    end
                end
            end
        end
    end
end

function Nord:Notify(Title, Message, Type, Duration)
    Nord["Config"] = _G.Config
    local Type2Color = {
        ['error'] = Color3.fromRGB(255, 87, 87), 
        ['warn'] = Color3.fromRGB(255, 255, 127), 
        ['success'] = Color3.fromRGB(85, 255, 127), 
        ['normal'] = Color3.fromRGB(255, 255, 255), 
        ['maxy'] = Color3.fromRGB(255, 1, 1),  
        ['beta'] = Color3.fromRGB(128, 0, 128),
        ['ocean'] = Color3.fromRGB(174, 214, 241),
        ['sunset'] = Color3.fromRGB(255, 193, 122),
        ['mint'] = Color3.fromRGB(152, 211, 180),
        ['lavender'] = Color3.fromRGB(196, 176, 222),
        ['rose'] = Color3.fromRGB(255, 183, 197),
        ['sage'] = Color3.fromRGB(185, 206, 168),
        ['coral'] = Color3.fromRGB(255, 183, 158),
        ['steel'] = Color3.fromRGB(176, 196, 209),
        ['neon'] = Color3.fromRGB(0, 255, 127),
        ['cyber'] = Color3.fromRGB(255, 0, 255),
        ['purple'] = Color3.fromRGB(186, 156, 255)
    }
    
    local Frame = New("Frame", {Name = "MainFrame", Parent = NotificationHolder, BackgroundColor3 = Color3.fromRGB(70, 70, 73),
        Size = UDim2.new(0.9, 0, 0.097, 0), ZIndex = 2, BackgroundTransparency = 1
    });
    
    local Glow = New("ImageLabel", {Parent = Frame, BackgroundTransparency = 1, Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(1.1, 0, 1.2, 0), Image = "rbxassetid://241650934",
        ImageColor3 = Type2Color[Type:lower()], ImageTransparency = 0.85, ZIndex = 1
    });
    
    local DropShadow = New("ImageLabel", {Parent = Frame, BackgroundTransparency = 1, Position = UDim2.new(0.5, 0, 0.512, 0), Size = UDim2.new(1.050, 5, 1.135, 5), Image = "rbxassetid://7912134082",
        ImageColor3 = Type2Color[Type:lower()], ImageTransparency = 1, ScaleType = "Slice", SliceCenter = Rect.new(95, 95, 205, 205)
    });
    
    local Gradient = New("UIGradient", {Parent = Frame, Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Type2Color[Type:lower()])
    }), Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.15),
        NumberSequenceKeypoint.new(1, 0.05)
    }), Rotation = 45});
    
    New("UICorner", {Parent = Frame, CornerRadius = UDim.new(0, 5)});
    New("UICorner", {Parent = DropShadow, CornerRadius = UDim.new(0, 5)});
    
    local Icon = New("ImageLabel", {Parent = Frame, BackgroundTransparency = 1, Position = UDim2.new(0.08, 0, 0.2, 0), Size = UDim2.new(0.12, 0, 0.6, 0), ZIndex = 3,
        Image = Type:lower() == "error" and "rbxassetid://5107152351" or Type:lower() == "warn" and "rbxassetid://5107152198" or Type:lower() == "success" and "rbxassetid://5107152095" or "rbxassetid://5107151952",
        ImageColor3 = Type2Color[Type:lower()]
    });
    
    local Header = New("TextLabel", {Parent = Frame, BackgroundTransparency = 1, Position = UDim2.new(0.237, 0, 0.172, 0), Size = UDim2.new(0.4, 0, 0.358, 0), ZIndex = 2, Font = "GothamMedium",
        Text = Title or "MaxHub", TextSize = 13, TextXAlignment = "Left", TextScaled = true, TextColor3 = Type2Color[Type:lower()] or Color3.new(1, 1, 1)
    });
    Nord:TextConstraint(Header);
    
    local Msg = New("TextLabel", {Parent = Frame, BackgroundTransparency = 1, Position = UDim2.new(0.5, 0, 0.563, 0), Size = UDim2.new(0.927, 0, 0.5, 0), ZIndex = 2, Font = "Gotham",
        Text = Message, TextSize = 12, TextXAlignment = "Left", TextScaled = true, TextColor3 = Type2Color[Type:lower()] or Color3.new(1, 1, 1)
    });
    Nord:TextConstraint(Msg);
    
    local CloseBtn = New("TextButton", {Parent = Frame, BackgroundTransparency = 1, Position = UDim2.new(0.92, 0, 0.15, 0), Size = UDim2.new(0.08, 0, 0.35, 0), ZIndex = 4,
        Text = "×", TextSize = 16, Font = "GothamBold", TextColor3 = Type2Color[Type:lower()], TextTransparency = 0.3
    });
    
    local LineHolder = New("Frame", {Parent = Frame, BackgroundTransparency = 1, Position = UDim2.new(0.5, 0, 0.93, 0), Size = UDim2.new(0.9278, 0, 0, 1), ZIndex = 2})
    New("UIListLayout", {Parent = LineHolder, HorizontalAlignment = "Left", VerticalAlignment = "Center"});
    local Line = New("Frame", {Name = "Line", Parent = LineHolder, BackgroundColor3 = Type2Color[Type:lower()], Size = UDim2.new(0, 0, 1, 0), ZIndex = 2});
    local Hover = New("TextButton", {Parent = Frame, BackgroundTransparency = 1, Text = "", Size = UDim2.new(1, 0, 1, 0), Position = UDim2.new(0.5, 0, 0.5, 0), ZIndex = 3});
    
    Nord:ApplyTheme(Nord["Config"]["Theme"], Frame)
    if Nord["Config"]["Theme"]:lower() == "light" and Type:lower() == "normal" then 
        Line["BackgroundColor3"] = Color3.new(0, 0, 0);
        DropShadow["ImageColor3"] = Color3.new(0, 0, 0)
    end

    local function CloseNotification()
        coroutine.wrap(function()
            Tween(Line, 0.15, "Quad", "Out", {Size = UDim2.new(0, 0, 1, 0)});
            Tween(Msg, 0.15, "Quad", "Out", {TextTransparency = 1});
            Tween(Header, 0.15, "Quint", "Out", {TextTransparency = 1}); 
            Tween(Icon, 0.15, "Quint", "Out", {ImageTransparency = 1});
            Tween(CloseBtn, 0.15, "Quint", "Out", {TextTransparency = 1});
            Tween(Glow, 0.15, "Quint", "Out", {ImageTransparency = 1});
            wait(0.2);
            Tween(DropShadow, 0.15, "Quint", "Out", {ImageTransparency = 1});
            Tween(Frame, 0.15, "Quint", "Out", {BackgroundTransparency = 1}); 
            wait(0.15); 
            Frame:Destroy();
        end)()
    end
    
    CloseBtn.MouseButton1Click:Connect(CloseNotification)

    coroutine.wrap(function()
        Tween(Glow, 0.4, "Sine", "InOut", {ImageTransparency = 0.9});
        Tween(Frame, 0.25, "Back", "Out", {BackgroundTransparency = 0});
        Tween(DropShadow, 0.25, "Quad", "In", {ImageTransparency = 0.5}); wait(0.3);
        Tween(Icon, 0.6, "Bounce", "Out", {ImageTransparency = 0}); wait(0.1);
        Tween(Header, 0.5, "Quad", "Out", {TextTransparency = 0}); wait(0.15);
        Tween(Msg, 0.5, "Quad", "Out", {TextTransparency = 0}); wait(0.1);
        Tween(CloseBtn, 0.3, "Quad", "Out", {TextTransparency = 0.3});

        local MainTween = Tween(Line, Duration, "Sine", "InOut", {Size = UDim2.new(1, 0, 1, 0)}, "true"); MainTween:Play();
        
        Hover["MouseEnter"]:Connect(function()
            if MainTween["PlaybackState"] == Enum["PlaybackState"]["Playing"] then
                MainTween:Pause()
            end
            Tween(Frame, 0.2, "Quad", "Out", {Size = UDim2.new(0.92, 0, 0.1, 0)});
            Tween(Glow, 0.2, "Quad", "Out", {ImageTransparency = 0.75});
        end);
        
        Hover["MouseLeave"]:Connect(function()
            if MainTween["PlaybackState"] == Enum["PlaybackState"]["Paused"] then
                MainTween:Play()
            end
            Tween(Frame, 0.2, "Quad", "Out", {Size = UDim2.new(0.9, 0, 0.097, 0)});
            Tween(Glow, 0.2, "Quad", "Out", {ImageTransparency = 0.85});
        end);
        
        repeat wait() until MainTween["PlaybackState"] == Enum["PlaybackState"]["Completed"]
        CloseNotification()
    end)()
end

return Nord