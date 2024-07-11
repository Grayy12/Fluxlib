local cloneref = cloneref or function(...)
	return ...
end

local function GetService(service)
	return cloneref(game:GetService(service))
end

local SavingSystem = loadstring(game:HttpGet("https://raw.githubusercontent.com/Grayy12/SavingSys-Alpha/main/src.lua", true))()
local SaveFile

local ConnectionHandlerModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/Grayy12/EXT/testing/connections.lua", true))()
local connectionManager

local Flux = { RainbowColorValue = 0, HueSelectionPosition = 0 }
local getgenv = (getgenv and getgenv()) or _G

getgenv.PresetColor = Color3.fromRGB(66, 134, 255)
local UserInputService = GetService("UserInputService")
local TweenService = GetService("TweenService")
local RunService = GetService("RunService")
local LocalPlayer = GetService("Players").LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local oldMouseCuror = UserInputService.MouseIconEnabled

isKeyLeft = true

local FluxLib = Instance.new("ScreenGui")
FluxLib.Name = "FluxLib"
FluxLib.Parent = (gethui and gethui()) or GetService("CoreGui")
FluxLib.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local function sanitizeFileName(fileName)
	fileName = fileName:gsub("%W", "")

	fileName = fileName:gsub("^[%s%.]+", ""):gsub("[%s%.]+$", "")
	return fileName
end

local function _saveState(id, vtype, value, value2)
	local savedData = {
		[id] = {
			["Type"] = vtype,
			["Value"] = value,
		},
	}

	if value2 ~= nil then
		savedData[id]["Value2"] = value2
	end

	SaveFile:Save(savedData)
end

local function _loadState(id, type)
	local storeddata = SaveFile:Load()

	if storeddata[id] ~= nil and storeddata[id]["Type"] == type then
		if storeddata[id]["Value2"] ~= nil then
			return { storeddata[id]["Value"], storeddata[id]["Value2"] }
		end
		return storeddata[id]["Value"] or nil
	end
end

coroutine.wrap(function()
	while wait() do
		Flux.RainbowColorValue = Flux.RainbowColorValue + 1 / 255
		Flux.HueSelectionPosition = Flux.HueSelectionPosition + 1

		if Flux.RainbowColorValue >= 1 then
			Flux.RainbowColorValue = 0
		end

		if Flux.HueSelectionPosition == 80 then
			Flux.HueSelectionPosition = 0
		end
	end
end)()

function Flux:Window(args)
	local ReplaceOld = args["replaceOld"] or false
	local EnableSaving = (args["enableSaving"] and writefile ~= nil) or false
	local text = args["Title"]
	local bottom = args["Description"]
	local mainclr = args["mainclr"] or Color3.fromRGB(66, 134, 255)
	local FolderName = (args["SaveFolder"] and sanitizeFileName(args["SaveFolder"])) or ""
	local FileName = (args["SaveFile"] and sanitizeFileName(args["SaveFile"]))

	if EnableSaving then
		SaveFile = SavingSystem.Init(sanitizeFileName(FolderName), sanitizeFileName(FileName))
	end
	if ReplaceOld then
		if getgenv._FluxLibGui and typeof(getgenv._FluxLibGui) == "Instance" then
			getgenv._FluxLibGui:Destroy()
		end
		getgenv._FluxLibGui = FluxLib
		connectionManager = ConnectionHandlerModule.new("_FluxHub")
	elseif not ReplaceOld then
		connectionManager = ConnectionHandlerModule.new(tostring(math.random(1, 1000000)))
	end

	local function MakeDraggable(topbarobject, object)
		local Dragging = nil
		local DragInput = nil
		local DragStart = nil
		local StartPosition = nil

		local function Update(input)
			local Delta = input.Position - DragStart
			local pos = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + Delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y)
			object.Position = pos
		end

		connectionManager:NewConnection(topbarobject.InputBegan, function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				Dragging = true
				DragStart = input.Position
				StartPosition = object.Position

				connectionManager:NewConnection(input.Changed, function()
					if input.UserInputState == Enum.UserInputState.End then
						Dragging = false
					end
				end)
			end
		end)

		connectionManager:NewConnection(topbarobject.InputChanged, function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				DragInput = input
			end
		end)

		connectionManager:NewConnection(UserInputService.InputChanged, function(input)
			if input == DragInput and Dragging then
				Update(input)
			end
		end)
	end
	getgenv.PresetColor = mainclr
	local fs = false
	local MainFrame = Instance.new("Frame")
	local MainCorner = Instance.new("UICorner")
	local LeftFrame = Instance.new("Frame")
	local LeftCorner = Instance.new("UICorner")
	local GlowTabHolder = Instance.new("ImageLabel")
	local Title = Instance.new("TextLabel")
	local BottomText = Instance.new("TextLabel")
	local TabHold = Instance.new("Frame")
	local TabLayout = Instance.new("UIListLayout")
	local Drag = Instance.new("Frame")
	local ContainerFolder = Instance.new("Folder")

	MainFrame.Name = "MainFrame"
	MainFrame.Parent = FluxLib
	MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	MainFrame.BackgroundColor3 = Color3.fromRGB(50, 53, 59)
	MainFrame.ClipsDescendants = true
	MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
	MainFrame.Size = UDim2.new(0, 0, 0, 0)

	MainCorner.CornerRadius = UDim.new(0, 5)
	MainCorner.Name = "MainCorner"
	MainCorner.Parent = MainFrame

	LeftFrame.Name = "LeftFrame"
	LeftFrame.Parent = MainFrame
	LeftFrame.BackgroundColor3 = Color3.fromRGB(47, 49, 54)
	LeftFrame.Size = UDim2.new(0, 205, 0, 484)

	LeftCorner.CornerRadius = UDim.new(0, 5)
	LeftCorner.Name = "LeftCorner"
	LeftCorner.Parent = LeftFrame

	GlowTabHolder.Name = "GlowTabHolder"
	GlowTabHolder.Parent = LeftFrame
	GlowTabHolder.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	GlowTabHolder.BackgroundTransparency = 1.000
	GlowTabHolder.BorderSizePixel = 0
	GlowTabHolder.Position = UDim2.new(0, -15, 0, -15)
	GlowTabHolder.Size = UDim2.new(1, 30, 1, 30)
	GlowTabHolder.ZIndex = 0
	GlowTabHolder.Image = "rbxassetid://4996891970"
	GlowTabHolder.ImageColor3 = Color3.fromRGB(15, 15, 15)
	GlowTabHolder.ScaleType = Enum.ScaleType.Slice
	GlowTabHolder.SliceCenter = Rect.new(20, 20, 280, 280)

	Title.Name = "Title"
	Title.Parent = LeftFrame
	Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Title.BackgroundTransparency = 1.000
	Title.Position = UDim2.new(0.097560972, 0, 0.0475206636, 0)
	Title.Size = UDim2.new(0, 111, 0, 34)
	Title.Font = Enum.Font.GothamBold
	Title.Text = text
	Title.TextColor3 = Color3.fromRGB(255, 255, 255)
	Title.TextSize = 25.000
	Title.TextXAlignment = Enum.TextXAlignment.Left

	BottomText.Name = "BottomText"
	BottomText.Parent = LeftFrame
	BottomText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	BottomText.BackgroundTransparency = 1.000
	BottomText.Position = UDim2.new(0.097560972, 0, 0.0889999792, 0)
	BottomText.Size = UDim2.new(0, 113, 0, 28)
	BottomText.Font = Enum.Font.Gotham
	BottomText.Text = bottom or ""
	BottomText.TextColor3 = Color3.fromRGB(255, 255, 255)
	BottomText.TextSize = 14.000
	BottomText.TextTransparency = 0.300
	BottomText.TextXAlignment = Enum.TextXAlignment.Left

	TabHold.Name = "TabHold"
	TabHold.Parent = LeftFrame
	TabHold.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	TabHold.BackgroundTransparency = 1.000
	TabHold.Position = UDim2.new(0, 0, 0.167355374, 0)
	TabHold.Size = UDim2.new(0, 205, 0, 403)

	TabLayout.Name = "TabLayout"
	TabLayout.Parent = TabHold
	TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
	TabLayout.Padding = UDim.new(0, 3)

	Drag.Name = "Drag"
	Drag.Parent = MainFrame
	Drag.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Drag.BackgroundTransparency = 1.000
	Drag.Position = UDim2.new(0.290368259, 0, 0, 0)
	Drag.Size = UDim2.new(0, 501, 0, 23)

	ContainerFolder.Name = "ContainerFolder"
	ContainerFolder.Parent = MainFrame

	MakeDraggable(Drag, MainFrame)
	MakeDraggable(LeftFrame, MainFrame)
	MainFrame:TweenSize(UDim2.new(0, 706, 0, 484), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.6, true)

	local uitoggled = false

	function Flux:Notification(desc, buttontitle)
		for i, v in next, MainFrame:GetChildren() do
			if v.Name == "NotificationBase" then
				v:Destroy()
			end
		end
		local NotificationBase = Instance.new("TextButton")
		local NotificationBaseCorner = Instance.new("UICorner")
		local NotificationFrame = Instance.new("Frame")
		local NotificationFrameCorner = Instance.new("UICorner")
		local NotificationFrameGlow = Instance.new("ImageLabel")
		local NotificationTitle = Instance.new("TextLabel")
		local CloseBtn = Instance.new("TextButton")
		local CloseBtnCorner = Instance.new("UICorner")
		local NotificationDesc = Instance.new("TextLabel")

		NotificationBase.Name = "NotificationBase"
		NotificationBase.Parent = MainFrame
		NotificationBase.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		NotificationBase.BackgroundTransparency = 1
		NotificationBase.Size = UDim2.new(0, 706, 0, 484)
		NotificationBase.AutoButtonColor = false
		NotificationBase.Font = Enum.Font.SourceSans
		NotificationBase.Text = ""
		NotificationBase.TextColor3 = Color3.fromRGB(0, 0, 0)
		NotificationBase.TextSize = 14.000
		NotificationBase.Visible = true

		NotificationBaseCorner.CornerRadius = UDim.new(0, 5)
		NotificationBaseCorner.Name = "NotificationBaseCorner"
		NotificationBaseCorner.Parent = NotificationBase

		NotificationFrame.Name = "NotificationFrame"
		NotificationFrame.Parent = NotificationBase
		NotificationFrame.AnchorPoint = Vector2.new(0.5, 0.5)
		NotificationFrame.BackgroundColor3 = Color3.fromRGB(50, 53, 59)
		NotificationFrame.ClipsDescendants = true
		NotificationFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
		NotificationFrame.Size = UDim2.new(0, 0, 0, 0)

		NotificationFrameCorner.CornerRadius = UDim.new(0, 5)
		NotificationFrameCorner.Name = "NotificationFrameCorner"
		NotificationFrameCorner.Parent = NotificationFrame

		NotificationFrameGlow.Name = "NotificationFrameGlow"
		NotificationFrameGlow.Parent = NotificationFrame
		NotificationFrameGlow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		NotificationFrameGlow.BackgroundTransparency = 1.000
		NotificationFrameGlow.BorderSizePixel = 0
		NotificationFrameGlow.Position = UDim2.new(0, -15, 0, -15)
		NotificationFrameGlow.Size = UDim2.new(1, 30, 1, 30)
		NotificationFrameGlow.ZIndex = 0
		NotificationFrameGlow.Image = "rbxassetid://4996891970"
		NotificationFrameGlow.ImageColor3 = Color3.fromRGB(15, 15, 15)
		NotificationFrameGlow.ScaleType = Enum.ScaleType.Slice
		NotificationFrameGlow.SliceCenter = Rect.new(20, 20, 280, 280)

		NotificationTitle.Name = "NotificationTitle"
		NotificationTitle.Parent = NotificationFrame
		NotificationTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		NotificationTitle.BackgroundTransparency = 1.000
		NotificationTitle.Position = UDim2.new(0.0400609747, 0, 0.0761325806, 0)
		NotificationTitle.Size = UDim2.new(0, 111, 0, 34)
		NotificationTitle.Font = Enum.Font.GothamBold
		NotificationTitle.Text = Title.Text .. " | NOTIFICATION"
		NotificationTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
		NotificationTitle.TextSize = 24.000
		NotificationTitle.TextXAlignment = Enum.TextXAlignment.Left
		NotificationTitle.TextTransparency = 1

		CloseBtn.Name = "CloseBtn"
		CloseBtn.Parent = NotificationFrame
		CloseBtn.BackgroundColor3 = Color3.fromRGB(64, 68, 75)
		CloseBtn.ClipsDescendants = true
		CloseBtn.Position = UDim2.new(0.0403124988, 0, 0.720855951, 0)
		CloseBtn.Size = UDim2.new(0, 366, 0, 43)
		CloseBtn.AutoButtonColor = false
		CloseBtn.Font = Enum.Font.Gotham
		CloseBtn.Text = buttontitle
		CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		CloseBtn.TextSize = 15.000
		CloseBtn.TextTransparency = 1
		CloseBtn.BackgroundTransparency = 1

		CloseBtnCorner.CornerRadius = UDim.new(0, 4)
		CloseBtnCorner.Name = "CloseBtnCorner"
		CloseBtnCorner.Parent = CloseBtn

		NotificationDesc.Name = "NotificationDesc"
		NotificationDesc.Parent = NotificationFrame
		NotificationDesc.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		NotificationDesc.BackgroundTransparency = 1.000
		NotificationDesc.Position = UDim2.new(0.112499997, 0, 0.266355127, 0)
		NotificationDesc.Size = UDim2.new(0, 309, 0, 82)
		NotificationDesc.Font = Enum.Font.Gotham
		NotificationDesc.Text = desc
		NotificationDesc.TextColor3 = Color3.fromRGB(255, 255, 255)
		NotificationDesc.TextSize = 15.000
		NotificationDesc.TextWrapped = true
		NotificationDesc.TextTransparency = 1

		connectionManager:NewConnection(CloseBtn.MouseEnter, function()
			TweenService:Create(CloseBtn, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0 }):Play()
		end)

		connectionManager:NewConnection(CloseBtn.MouseLeave, function()
			TweenService:Create(CloseBtn, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0.3 }):Play()
		end)

		connectionManager:NewConnection(CloseBtn.MouseButton1Click, function()
			TweenService:Create(NotificationDesc, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 1 }):Play()
			TweenService:Create(CloseBtn, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 1 }):Play()
			TweenService:Create(NotificationTitle, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 1 }):Play()
			TweenService:Create(CloseBtn, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 1 }):Play()

			wait(0.4)
			CloseBtn.Visible = false
			NotificationFrame:TweenSize(UDim2.new(0, 0, 0, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.6, true)

			wait(0.2)

			TweenService:Create(NotificationBase, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 1 }):Play()

			wait(0.2)

			NotificationBase.Visible = false
		end)

		TweenService:Create(NotificationBase, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 0.550 }):Play()

		wait(0.1)

		NotificationFrame:TweenSize(UDim2.new(0, 400, 0, 214), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.6, true)

		wait(0.4)
		TweenService:Create(NotificationDesc, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0.3 }):Play()
		TweenService:Create(CloseBtn, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0.3 }):Play()
		TweenService:Create(NotificationTitle, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0 }):Play()
		TweenService:Create(CloseBtn, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 0 }):Play()
	end
	local Tabs = {}

	function Tabs:ToggleUI()
		if uitoggled == false then
			MainFrame:TweenSize(UDim2.new(0, 0, 0, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.6, true)
			uitoggled = true
			repeat
				wait()
			until MainFrame.Size.Y.Offset <= 1
			FluxLib.Enabled = false
			UserInputService.MouseIconEnabled = oldMouseCuror
		else
			MainFrame:TweenSize(UDim2.new(0, 706, 0, 484), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.6, true)
			repeat
				wait()
			until MainFrame.Size.Y.Offset > 1
			FluxLib.Enabled = true
			uitoggled = false
			UserInputService.MouseIconEnabled = true
		end
	end

	function Tabs:Tab(text, ico)
		local Tab = Instance.new("TextButton")
		local TabIcon = Instance.new("ImageLabel")
		local TabTitle = Instance.new("TextLabel")

		Tab.Name = "Tab"
		Tab.Parent = TabHold
		Tab.BackgroundColor3 = getgenv.PresetColor
		Tab.BorderSizePixel = 0
		Tab.Size = UDim2.new(0, 205, 0, 40)
		Tab.AutoButtonColor = false
		Tab.Font = Enum.Font.SourceSans
		Tab.Text = ""
		Tab.TextColor3 = Color3.fromRGB(0, 0, 0)
		Tab.TextSize = 14.000
		Tab.BackgroundTransparency = 1
		Tab.Modal = true
		UserInputService.MouseIconEnabled = true

		TabIcon.Name = "TabIcon"
		TabIcon.Parent = Tab
		TabIcon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		TabIcon.BackgroundTransparency = 1.000
		TabIcon.Position = UDim2.new(0.0634146333, 0, 0.25, 0)
		TabIcon.Size = UDim2.new(0, 20, 0, 20)
		TabIcon.Image = ico or ""
		TabIcon.ImageTransparency = 0.3

		TabTitle.Name = "TabTitle"
		TabTitle.Parent = Tab
		TabTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		TabTitle.BackgroundTransparency = 1.000
		TabTitle.Position = UDim2.new(0.1902439, 0, 0.25, 0)
		TabTitle.Size = UDim2.new(0, 113, 0, 19)
		TabTitle.Font = Enum.Font.Gotham
		TabTitle.Text = text
		TabTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
		TabTitle.TextSize = 15.000
		TabTitle.TextXAlignment = Enum.TextXAlignment.Left
		TabTitle.TextTransparency = 0.3

		local Container = Instance.new("ScrollingFrame")
		local ContainerLayout = Instance.new("UIListLayout")

		Container.Name = "Container"
		Container.Parent = ContainerFolder
		Container.Active = true
		Container.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Container.BackgroundTransparency = 1.000
		Container.BorderSizePixel = 0
		Container.Position = UDim2.new(0.321529746, 0, 0.0475206599, 0)
		Container.Size = UDim2.new(0, 470, 0, 438)
		Container.CanvasSize = UDim2.new(0, 0, 0, 0)
		Container.ScrollBarThickness = 5
		Container.Visible = false
		Container.ScrollBarImageColor3 = Color3.fromRGB(71, 76, 84)

		ContainerLayout.Name = "ContainerLayout"
		ContainerLayout.Parent = Container
		ContainerLayout.SortOrder = Enum.SortOrder.LayoutOrder
		ContainerLayout.Padding = UDim.new(0, 15)

		if fs == false then
			fs = true
			TabTitle.TextTransparency = 0
			TabIcon.ImageTransparency = 0
			Tab.BackgroundTransparency = 0
			Container.Visible = true
		end

		connectionManager:NewConnection(Tab.MouseButton1Click, function()
			for i, v in next, ContainerFolder:GetChildren() do
				if v.Name == "Container" then
					v.Visible = false
				end
				Container.Visible = true
			end
			for i, v in next, TabHold:GetChildren() do
				if v.Name == "Tab" then
					TweenService:Create(v, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 1 }):Play()
					TweenService:Create(v.TabIcon, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { ImageTransparency = 0.3 }):Play()
					TweenService:Create(v.TabTitle, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0.3 }):Play()
					TweenService:Create(Tab, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 0 }):Play()
					TweenService:Create(TabIcon, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { ImageTransparency = 0 }):Play()
					TweenService:Create(TabTitle, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0 }):Play()
				end
			end
		end)
		local ContainerContent = {}
		function ContainerContent:Button(text, desc, callback)
			if desc == "" then
				desc = "There is no description for this button."
			end
			local BtnDescToggled = false
			local Button = Instance.new("TextButton")
			local ButtonCorner = Instance.new("UICorner")
			local Title = Instance.new("TextLabel")
			local Circle = Instance.new("Frame")
			local CircleCorner = Instance.new("UICorner")
			local CircleSmall = Instance.new("Frame")
			local CircleSmallCorner = Instance.new("UICorner")
			local Description = Instance.new("TextLabel")
			local ArrowBtn = Instance.new("ImageButton")
			local ArrowIco = Instance.new("ImageLabel")

			Button.Name = "Button"
			Button.Parent = Container
			Button.BackgroundColor3 = Color3.fromRGB(64, 68, 75)
			Button.ClipsDescendants = true
			Button.Position = UDim2.new(0.370312512, 0, 0.552631557, 0)
			Button.Size = UDim2.new(0, 457, 0, 43)
			Button.AutoButtonColor = false
			Button.Font = Enum.Font.SourceSans
			Button.Text = ""
			Button.TextColor3 = Color3.fromRGB(0, 0, 0)
			Button.TextSize = 14.000

			ButtonCorner.CornerRadius = UDim.new(0, 4)
			ButtonCorner.Name = "ButtonCorner"
			ButtonCorner.Parent = Button

			Title.Name = "Title"
			Title.Parent = Button
			Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Title.BackgroundTransparency = 1.000
			Title.Position = UDim2.new(0.0822437406, 0, 0, 0)
			Title.Size = UDim2.new(0, 113, 0, 42)
			Title.Font = Enum.Font.Gotham
			Title.Text = text
			Title.TextColor3 = Color3.fromRGB(255, 255, 255)
			Title.TextSize = 15.000
			Title.TextTransparency = 0.300
			Title.TextXAlignment = Enum.TextXAlignment.Left

			Circle.Name = "Circle"
			Circle.Parent = Title
			Circle.Active = true
			Circle.AnchorPoint = Vector2.new(0.5, 0.5)
			Circle.BackgroundColor3 = Color3.fromRGB(211, 211, 211)
			Circle.Position = UDim2.new(-0.150690272, 0, 0.503000021, 0)
			Circle.Size = UDim2.new(0, 11, 0, 11)

			CircleCorner.CornerRadius = UDim.new(2, 6)
			CircleCorner.Name = "CircleCorner"
			CircleCorner.Parent = Circle

			CircleSmall.Name = "CircleSmall"
			CircleSmall.Parent = Circle
			CircleSmall.Active = true
			CircleSmall.AnchorPoint = Vector2.new(0.5, 0.5)
			CircleSmall.BackgroundColor3 = Color3.fromRGB(64, 68, 75)
			CircleSmall.BackgroundTransparency = 1.000
			CircleSmall.Position = UDim2.new(0.485673368, 0, 0.503000021, 0)
			CircleSmall.Size = UDim2.new(0, 9, 0, 9)

			CircleSmallCorner.CornerRadius = UDim.new(2, 6)
			CircleSmallCorner.Name = "CircleSmallCorner"
			CircleSmallCorner.Parent = CircleSmall

			Description.Name = "Description"
			Description.Parent = Title
			Description.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Description.BackgroundTransparency = 1.000
			Description.Position = UDim2.new(-0.200942323, 0, 0.785714269, 0)
			Description.Size = UDim2.new(0, 432, 0, 31)
			Description.Font = Enum.Font.Gotham
			Description.Text = desc
			Description.TextColor3 = Color3.fromRGB(255, 255, 255)
			Description.TextSize = 15.000
			Description.TextTransparency = 1
			Description.TextWrapped = true
			Description.TextXAlignment = Enum.TextXAlignment.Left

			ArrowBtn.Name = "ArrowBtn"
			ArrowBtn.Parent = Button
			ArrowBtn.BackgroundColor3 = Color3.fromRGB(86, 86, 86)
			ArrowBtn.BackgroundTransparency = 1.000
			ArrowBtn.Position = UDim2.new(0.903719902, 0, 0, 0)
			ArrowBtn.Size = UDim2.new(0, 33, 0, 37)
			ArrowBtn.SliceCenter = Rect.new(30, 30, 30, 30)
			ArrowBtn.SliceScale = 7.000

			ArrowIco.Name = "ArrowIco"
			ArrowIco.Parent = ArrowBtn
			ArrowIco.AnchorPoint = Vector2.new(0.5, 0.5)
			ArrowIco.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			ArrowIco.BackgroundTransparency = 1.000
			ArrowIco.Position = UDim2.new(0.495753437, 0, 0.554054081, 0)
			ArrowIco.Selectable = true
			ArrowIco.Size = UDim2.new(0, 28, 0, 24)
			ArrowIco.Image = "http://www.roblox.com/asset/?id=6034818372"
			ArrowIco.ImageTransparency = 0.3

			connectionManager:NewConnection(Button.MouseEnter, function()
				TweenService:Create(Title, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0 }):Play()
			end)

			connectionManager:NewConnection(Button.MouseLeave, function()
				TweenService:Create(Title, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0.3 }):Play()
			end)

			connectionManager:NewConnection(Button.MouseButton1Click, function()
				pcall(callback)
			end)

			connectionManager:NewConnection(ArrowBtn.MouseButton1Click, function()
				if BtnDescToggled == false then
					getgenv.changeButtonColor = function()
						repeat
							wait()
						until BtnDescToggled == true
						repeat
							wait()
							TweenService:Create(Title, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextColor3 = getgenv.PresetColor }):Play()
							TweenService:Create(ArrowIco, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { ImageColor3 = getgenv.PresetColor }):Play()
							TweenService:Create(Circle, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundColor3 = getgenv.PresetColor }):Play()
						until BtnDescToggled == false
						TweenService:Create(Title, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextColor3 = Color3.fromRGB(255, 255, 255) }):Play()
						TweenService:Create(ArrowIco, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { ImageColor3 = Color3.fromRGB(255, 255, 255) }):Play()
						TweenService:Create(ArrowIco, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { ImageTransparency = 0.3 }):Play()
						TweenService:Create(ArrowIco, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Rotation = 0 }):Play()
						TweenService:Create(Circle, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundColor3 = Color3.fromRGB(211, 211, 211) }):Play()
						TweenService:Create(CircleSmall, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 1 }):Play()
						TweenService:Create(Title, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0.3 }):Play()
						TweenService:Create(Description, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 1 }):Play()
					end
					coroutine.wrap(getgenv.changeButtonColor)()
					Button:TweenSize(UDim2.new(0, 457, 0, 74), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.6, true)
					TweenService:Create(Title, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextColor3 = getgenv.PresetColor }):Play()
					TweenService:Create(ArrowIco, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { ImageColor3 = getgenv.PresetColor }):Play()
					TweenService:Create(ArrowIco, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { ImageTransparency = 0 }):Play()
					TweenService:Create(ArrowIco, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Rotation = 180 }):Play()
					TweenService:Create(Circle, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundColor3 = getgenv.PresetColor }):Play()
					TweenService:Create(CircleSmall, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 0 }):Play()
					TweenService:Create(Title, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0 }):Play()
					TweenService:Create(Description, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0.3 }):Play()
					wait(0.4)
					Container.CanvasSize = UDim2.new(0, 0, 0, ContainerLayout.AbsoluteContentSize.Y)
				else
					Button:TweenSize(UDim2.new(0, 457, 0, 43), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.6, true)
					wait(0.4)
					Container.CanvasSize = UDim2.new(0, 0, 0, ContainerLayout.AbsoluteContentSize.Y)
				end
				BtnDescToggled = not BtnDescToggled
			end)
			Container.CanvasSize = UDim2.new(0, 0, 0, ContainerLayout.AbsoluteContentSize.Y)
		end
		function ContainerContent:Toggle(toggleId, text, desc, default, callback)
			local ToggleFunc = {}
			local ToggleDescToggled = false
			local Toggled = false
			if desc == "" then
				desc = "There is no description for this toggle."
			end
			local Toggle = Instance.new("TextButton")
			local ToggleCorner = Instance.new("UICorner")
			local Title = Instance.new("TextLabel")
			local Circle = Instance.new("Frame")
			local CircleCorner = Instance.new("UICorner")
			local CircleSmall = Instance.new("Frame")
			local CircleSmallCorner = Instance.new("UICorner")
			local ToggleFrame = Instance.new("Frame")
			local ToggleFrameCorner = Instance.new("UICorner")
			local ToggleCircle = Instance.new("Frame")
			local ToggleCircleCorner = Instance.new("UICorner")
			local Description = Instance.new("TextLabel")
			local ArrowBtn = Instance.new("ImageButton")
			local ArrowIco = Instance.new("ImageLabel")

			Toggle.Name = "Toggle"
			Toggle.Parent = Container
			Toggle.BackgroundColor3 = Color3.fromRGB(64, 68, 75)
			Toggle.ClipsDescendants = true
			Toggle.Position = UDim2.new(0.110937506, 0, 0.67653507, 0)
			Toggle.Size = UDim2.new(0, 457, 0, 43)
			Toggle.AutoButtonColor = false
			Toggle.Font = Enum.Font.SourceSans
			Toggle.Text = ""
			Toggle.TextColor3 = Color3.fromRGB(0, 0, 0)
			Toggle.TextSize = 14.000

			ToggleCorner.CornerRadius = UDim.new(0, 4)
			ToggleCorner.Name = "ToggleCorner"
			ToggleCorner.Parent = Toggle

			Title.Name = "Title"
			Title.Parent = Toggle
			Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Title.BackgroundTransparency = 1.000
			Title.Position = UDim2.new(0.0822437406, 0, 0, 0)
			Title.Size = UDim2.new(0, 113, 0, 42)
			Title.Font = Enum.Font.Gotham
			Title.Text = text
			Title.TextColor3 = Color3.fromRGB(255, 255, 255)
			Title.TextSize = 15.000
			Title.TextTransparency = 0.300
			Title.TextXAlignment = Enum.TextXAlignment.Left

			Circle.Name = "Circle"
			Circle.Parent = Title
			Circle.Active = true
			Circle.AnchorPoint = Vector2.new(0.5, 0.5)
			Circle.BackgroundColor3 = Color3.fromRGB(211, 211, 211)
			Circle.Position = UDim2.new(-0.150690272, 0, 0.503000021, 0)
			Circle.Size = UDim2.new(0, 11, 0, 11)

			CircleCorner.CornerRadius = UDim.new(2, 6)
			CircleCorner.Name = "CircleCorner"
			CircleCorner.Parent = Circle

			CircleSmall.Name = "CircleSmall"
			CircleSmall.Parent = Circle
			CircleSmall.Active = true
			CircleSmall.AnchorPoint = Vector2.new(0.5, 0.5)
			CircleSmall.BackgroundColor3 = Color3.fromRGB(64, 68, 75)
			CircleSmall.BackgroundTransparency = 1.000
			CircleSmall.Position = UDim2.new(0.485673368, 0, 0.503000021, 0)
			CircleSmall.Size = UDim2.new(0, 9, 0, 9)

			CircleSmallCorner.CornerRadius = UDim.new(2, 6)
			CircleSmallCorner.Name = "CircleSmallCorner"
			CircleSmallCorner.Parent = CircleSmall

			ToggleFrame.Name = "ToggleFrame"
			ToggleFrame.Parent = Circle
			ToggleFrame.BackgroundColor3 = Color3.fromRGB(226, 227, 227)
			ToggleFrame.Position = UDim2.new(33.0856934, 0, 0, 0)
			ToggleFrame.Size = UDim2.new(0, 27, 0, 11)

			ToggleFrameCorner.Name = "ToggleFrameCorner"
			ToggleFrameCorner.Parent = ToggleFrame

			ToggleCircle.Name = "ToggleCircle"
			ToggleCircle.Parent = ToggleFrame
			ToggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			ToggleCircle.Position = UDim2.new(0, 0, -0.272727281, 0)
			ToggleCircle.Selectable = true
			ToggleCircle.Size = UDim2.new(0, 17, 0, 17)

			ToggleCircleCorner.CornerRadius = UDim.new(2, 8)
			ToggleCircleCorner.Name = "ToggleCircleCorner"
			ToggleCircleCorner.Parent = ToggleCircle

			Description.Name = "Description"
			Description.Parent = Title
			Description.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Description.BackgroundTransparency = 1.000
			Description.Position = UDim2.new(-0.200942323, 0, 0.785714269, 0)
			Description.Size = UDim2.new(0, 432, 0, 31)
			Description.Font = Enum.Font.Gotham
			Description.Text = desc
			Description.TextColor3 = Color3.fromRGB(255, 255, 255)
			Description.TextSize = 15.000
			Description.TextTransparency = 1
			Description.TextWrapped = true
			Description.TextXAlignment = Enum.TextXAlignment.Left

			ArrowBtn.Name = "ArrowBtn"
			ArrowBtn.Parent = Toggle
			ArrowBtn.BackgroundColor3 = Color3.fromRGB(86, 86, 86)
			ArrowBtn.BackgroundTransparency = 1.000
			ArrowBtn.Position = UDim2.new(0.903719902, 0, 0, 0)
			ArrowBtn.Size = UDim2.new(0, 33, 0, 37)
			ArrowBtn.SliceCenter = Rect.new(30, 30, 30, 30)
			ArrowBtn.SliceScale = 7.000

			ArrowIco.Name = "ArrowIco"
			ArrowIco.Parent = ArrowBtn
			ArrowIco.AnchorPoint = Vector2.new(0.5, 0.5)
			ArrowIco.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			ArrowIco.BackgroundTransparency = 1.000
			ArrowIco.Position = UDim2.new(0.495753437, 0, 0.554054081, 0)
			ArrowIco.Selectable = true
			ArrowIco.Size = UDim2.new(0, 28, 0, 24)
			ArrowIco.Image = "http://www.roblox.com/asset/?id=6034818372"
			ArrowIco.ImageTransparency = 0.3

			local function _toggle(bool)
				if bool ~= nil then
					Toggled = bool
				else
					Toggled = not Toggled
				end

				if Toggled then
					getgenv.changeToggleColor = function()
						repeat
							wait()
						until Toggled == true
						repeat
							wait()
							TweenService:Create(ToggleCircle, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundColor3 = getgenv.PresetColor }):Play()
						until Toggled == false
						TweenService:Create(ToggleCircle, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundColor3 = Color3.fromRGB(255, 255, 255) }):Play()
					end
					coroutine.wrap(getgenv.changeToggleColor)()
					ToggleCircle:TweenPosition(UDim2.new(0.37, 0, -0.273, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.3, true)
					TweenService:Create(ToggleCircle, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundColor3 = getgenv.PresetColor }):Play()
					ToggleCircle:TweenPosition(UDim2.new(0.37, 0, -0.273, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.3, true)
				else
					ToggleCircle:TweenPosition(UDim2.new(0, 0, -0.273, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.3, true)
				end

				pcall(callback, Toggled)
			end

			connectionManager:NewConnection(Toggle.MouseEnter, function()
				TweenService:Create(Title, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0 }):Play()
			end)

			connectionManager:NewConnection(Toggle.MouseLeave, function()
				TweenService:Create(Title, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0.3 }):Play()
			end)

			connectionManager:NewConnection(Toggle.MouseButton1Click, function()
				_toggle()
			end)

			connectionManager:NewConnection(ArrowBtn.MouseButton1Click, function()
				if ToggleDescToggled == false then
					getgenv.changeArrowColor = function()
						repeat
							wait()
						until ToggleDescToggled == true
						repeat
							wait()
							TweenService:Create(Title, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextColor3 = getgenv.PresetColor }):Play()
							TweenService:Create(ArrowIco, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { ImageColor3 = getgenv.PresetColor }):Play()
							TweenService:Create(Circle, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundColor3 = getgenv.PresetColor }):Play()
						until ToggleDescToggled == false
						TweenService:Create(Title, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextColor3 = Color3.fromRGB(255, 255, 255) }):Play()
						TweenService:Create(ArrowIco, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { ImageColor3 = Color3.fromRGB(255, 255, 255) }):Play()
						TweenService:Create(ArrowIco, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { ImageTransparency = 0.3 }):Play()
						TweenService:Create(ArrowIco, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Rotation = 0 }):Play()
						TweenService:Create(Circle, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundColor3 = Color3.fromRGB(211, 211, 211) }):Play()
						TweenService:Create(CircleSmall, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 1 }):Play()
						TweenService:Create(Title, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0.3 }):Play()
						TweenService:Create(Description, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 1 }):Play()
					end
					coroutine.wrap(getgenv.changeArrowColor)()
					Toggle:TweenSize(UDim2.new(0, 457, 0, 74), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.6, true)
					TweenService:Create(Title, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextColor3 = getgenv.PresetColor }):Play()
					TweenService:Create(ArrowIco, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { ImageColor3 = getgenv.PresetColor }):Play()
					TweenService:Create(ArrowIco, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { ImageTransparency = 0 }):Play()
					TweenService:Create(ArrowIco, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Rotation = 180 }):Play()
					TweenService:Create(Circle, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundColor3 = getgenv.PresetColor }):Play()
					TweenService:Create(CircleSmall, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 0 }):Play()
					TweenService:Create(Title, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0 }):Play()
					TweenService:Create(Description, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0.3 }):Play()
					wait(0.4)
					Container.CanvasSize = UDim2.new(0, 0, 0, ContainerLayout.AbsoluteContentSize.Y)
				else
					Toggle:TweenSize(UDim2.new(0, 457, 0, 43), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.6, true)
					wait(0.4)
					Container.CanvasSize = UDim2.new(0, 0, 0, ContainerLayout.AbsoluteContentSize.Y)
				end
				ToggleDescToggled = not ToggleDescToggled
			end)
			-- if (default == true and not save) or (save and _loadState(toggleId, 'Toggle')) then
			-- ToggleCircle:TweenPosition(UDim2.new(0.37, 0, -0.273, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, .3, true)
			-- TweenService:Create(ToggleCircle, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundColor3 = getgenv.PresetColor }):Play()
			-- Toggled = not Toggled
			-- pcall(callback, Toggled)
			_toggle((EnableSaving and _loadState(toggleId, "Toggle") ~= nil and _loadState(toggleId, "Toggle")) or (default == true and true) or false)
			-- end
			Container.CanvasSize = UDim2.new(0, 0, 0, ContainerLayout.AbsoluteContentSize.Y)

			function ToggleFunc:Set(bool)
				_toggle(bool)
			end

			function ToggleFunc:Save()
				if EnableSaving then
					_saveState(toggleId, "Toggle", Toggled)
				else
					warn("Saving is not enabled!")
				end
			end

			return ToggleFunc
		end

		function ContainerContent:Slider(sliderId, text, desc, min, max, start, callback)
			local SliderFunc = {}
			local SliderDescToggled = false
			local dragging = false
			if desc == "" then
				desc = "There is no description for this slider."
			end
			local Slider = Instance.new("TextButton")
			local SliderCorner = Instance.new("UICorner")
			local Title = Instance.new("TextLabel")
			local Circle = Instance.new("Frame")
			local CircleCorner = Instance.new("UICorner")
			local CircleSmall = Instance.new("Frame")
			local CircleSmallCorner = Instance.new("UICorner")
			local Description = Instance.new("TextLabel")
			local SlideFrame = Instance.new("Frame")
			local CurrentValueFrame = Instance.new("Frame")
			local SlideCircle = Instance.new("ImageButton")
			local ArrowBtn = Instance.new("ImageButton")
			local ArrowIco = Instance.new("ImageLabel")
			local Value = Instance.new("TextLabel")

			Slider.Name = "Slider"
			Slider.Parent = Container
			Slider.BackgroundColor3 = Color3.fromRGB(64, 68, 75)
			Slider.ClipsDescendants = true
			Slider.Position = UDim2.new(0.189062506, 0, 0.648612201, 0)
			Slider.Size = UDim2.new(0, 457, 0, 60)
			Slider.AutoButtonColor = false
			Slider.Font = Enum.Font.SourceSans
			Slider.Text = ""
			Slider.TextColor3 = Color3.fromRGB(0, 0, 0)
			Slider.TextSize = 14.000

			SliderCorner.CornerRadius = UDim.new(0, 4)
			SliderCorner.Name = "SliderCorner"
			SliderCorner.Parent = Slider

			Title.Name = "Title"
			Title.Parent = Slider
			Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Title.BackgroundTransparency = 1.000
			Title.Position = UDim2.new(0.0822437406, 0, 0, 0)
			Title.Size = UDim2.new(0, 113, 0, 42)
			Title.Font = Enum.Font.Gotham
			Title.Text = text
			Title.TextColor3 = Color3.fromRGB(255, 255, 255)
			Title.TextSize = 15.000
			Title.TextTransparency = 0.300
			Title.TextXAlignment = Enum.TextXAlignment.Left

			Circle.Name = "Circle"
			Circle.Parent = Title
			Circle.Active = true
			Circle.AnchorPoint = Vector2.new(0.5, 0.5)
			Circle.BackgroundColor3 = Color3.fromRGB(211, 211, 211)
			Circle.Position = UDim2.new(-0.150690272, 0, 0.503000021, 0)
			Circle.Size = UDim2.new(0, 11, 0, 11)

			CircleCorner.CornerRadius = UDim.new(2, 6)
			CircleCorner.Name = "CircleCorner"
			CircleCorner.Parent = Circle

			CircleSmall.Name = "CircleSmall"
			CircleSmall.Parent = Circle
			CircleSmall.Active = true
			CircleSmall.AnchorPoint = Vector2.new(0.5, 0.5)
			CircleSmall.BackgroundColor3 = Color3.fromRGB(64, 68, 75)
			CircleSmall.BackgroundTransparency = 1.000
			CircleSmall.Position = UDim2.new(0.485673368, 0, 0.503000021, 0)
			CircleSmall.Size = UDim2.new(0, 9, 0, 9)

			CircleSmallCorner.CornerRadius = UDim.new(2, 6)
			CircleSmallCorner.Name = "CircleSmallCorner"
			CircleSmallCorner.Parent = CircleSmall

			Description.Name = "Description"
			Description.Parent = Title
			Description.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Description.BackgroundTransparency = 1.000
			Description.Position = UDim2.new(-0.201000005, 0, 1.38600004, 0)
			Description.Size = UDim2.new(0, 432, 0, 31)
			Description.Font = Enum.Font.Gotham
			Description.Text = desc
			Description.TextColor3 = Color3.fromRGB(255, 255, 255)
			Description.TextSize = 15.000
			Description.TextTransparency = 0.300
			Description.TextWrapped = true
			Description.TextXAlignment = Enum.TextXAlignment.Left

			SlideFrame.Name = "SlideFrame"
			SlideFrame.Parent = Title
			SlideFrame.BackgroundColor3 = Color3.fromRGB(235, 234, 235)
			SlideFrame.BorderSizePixel = 0
			SlideFrame.Position = UDim2.new(-0.197140202, 0, 0.986091495, 0)
			SlideFrame.Size = UDim2.new(0, 426, 0, 3)

			CurrentValueFrame.Name = "CurrentValueFrame"
			CurrentValueFrame.Parent = SlideFrame
			CurrentValueFrame.BackgroundColor3 = getgenv.PresetColor
			CurrentValueFrame.BorderSizePixel = 0
			CurrentValueFrame.Size = UDim2.new((start or 0) / max, 0, 0, 3)

			SlideCircle.Name = "SlideCircle"
			SlideCircle.Parent = SlideFrame
			SlideCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			SlideCircle.BackgroundTransparency = 1.000
			SlideCircle.Position = UDim2.new((start or 0) / max, -6, -1.30499995, 0)
			SlideCircle.Size = UDim2.new(0, 11, 0, 11)
			SlideCircle.Image = "rbxassetid://3570695787"
			SlideCircle.ImageColor3 = getgenv.PresetColor

			ArrowBtn.Name = "ArrowBtn"
			ArrowBtn.Parent = Slider
			ArrowBtn.BackgroundColor3 = Color3.fromRGB(86, 86, 86)
			ArrowBtn.BackgroundTransparency = 1.000
			ArrowBtn.Position = UDim2.new(0.903719902, 0, 0, 0)
			ArrowBtn.Size = UDim2.new(0, 33, 0, 37)
			ArrowBtn.SliceCenter = Rect.new(30, 30, 30, 30)
			ArrowBtn.SliceScale = 7.000

			ArrowIco.Name = "ArrowIco"
			ArrowIco.Parent = ArrowBtn
			ArrowIco.AnchorPoint = Vector2.new(0.5, 0.5)
			ArrowIco.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			ArrowIco.BackgroundTransparency = 1.000
			ArrowIco.Position = UDim2.new(0.495753437, 0, 0.554054081, 0)
			ArrowIco.Selectable = true
			ArrowIco.Size = UDim2.new(0, 28, 0, 24)
			ArrowIco.Image = "http://www.roblox.com/asset/?id=6034818372"
			ArrowIco.ImageTransparency = 0.3

			Value.Name = "Value"
			Value.Parent = Title
			Value.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Value.BackgroundTransparency = 1.000
			Value.Position = UDim2.new(2.27693367, 0, 0, 0)
			Value.Size = UDim2.new(0, 113, 0, 41)
			Value.Font = Enum.Font.Gotham
			Value.Text = tostring(start and math.floor((start / max) * (max - min) + min) or 0)
			Value.TextColor3 = Color3.fromRGB(255, 255, 255)
			Value.TextSize = 15.000
			Value.TextTransparency = 0.300
			Value.TextXAlignment = Enum.TextXAlignment.Right

			connectionManager:NewConnection(ArrowBtn.MouseButton1Click, function()
				if SliderDescToggled == false then
					getgenv.changeSliderColor = function()
						repeat
							wait()
						until SliderDescToggled == true
						repeat
							wait()
							TweenService:Create(Value, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextColor3 = getgenv.PresetColor }):Play()
							TweenService:Create(ArrowIco, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { ImageColor3 = getgenv.PresetColor }):Play()
							TweenService:Create(Circle, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundColor3 = getgenv.PresetColor }):Play()
						until SliderDescToggled == false
						TweenService:Create(Title, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextColor3 = Color3.fromRGB(255, 255, 255) }):Play()
						TweenService:Create(Value, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextColor3 = Color3.fromRGB(255, 255, 255) }):Play()
						TweenService:Create(ArrowIco, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { ImageColor3 = Color3.fromRGB(255, 255, 255) }):Play()
						TweenService:Create(ArrowIco, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { ImageTransparency = 0.3 }):Play()
						TweenService:Create(ArrowIco, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Rotation = 0 }):Play()
						TweenService:Create(Circle, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundColor3 = Color3.fromRGB(211, 211, 211) }):Play()
						TweenService:Create(CircleSmall, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 1 }):Play()
						TweenService:Create(Title, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0.3 }):Play()
						TweenService:Create(Description, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 1 }):Play()
					end
					coroutine.wrap(getgenv.changeSliderColor)()
					Slider:TweenSize(UDim2.new(0, 457, 0, 101), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.6, true)
					TweenService:Create(Value, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextColor3 = getgenv.PresetColor }):Play()
					TweenService:Create(ArrowIco, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { ImageColor3 = getgenv.PresetColor }):Play()
					TweenService:Create(ArrowIco, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { ImageTransparency = 0 }):Play()
					TweenService:Create(ArrowIco, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Rotation = 180 }):Play()
					TweenService:Create(Circle, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundColor3 = getgenv.PresetColor }):Play()
					TweenService:Create(CircleSmall, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 0 }):Play()
					TweenService:Create(Title, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0 }):Play()
					TweenService:Create(Description, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0.3 }):Play()
					wait(0.4)
					Container.CanvasSize = UDim2.new(0, 0, 0, ContainerLayout.AbsoluteContentSize.Y)
				else
					Slider:TweenSize(UDim2.new(0, 457, 0, 60), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.6, true)
					wait(0.4)
					Container.CanvasSize = UDim2.new(0, 0, 0, ContainerLayout.AbsoluteContentSize.Y)
				end
				SliderDescToggled = not SliderDescToggled
			end)

			local increment = 1
			local function move(input)
				local pos = UDim2.new(math.clamp((input.Position.X - SlideFrame.AbsolutePosition.X) / SlideFrame.AbsoluteSize.X, 0, 1), -6, -1.30499995, 0)
				local pos1 = UDim2.new(math.clamp((input.Position.X - SlideFrame.AbsolutePosition.X) / SlideFrame.AbsoluteSize.X, 0, 1), 0, 0, 3)
				CurrentValueFrame:TweenSize(pos1, "Out", "Sine", 0.1, true)
				SlideCircle:TweenPosition(pos, "Out", "Sine", 0.1, true)
				local value = ((pos.X.Scale * max) / max) * (max - min) + min
				local mult = 10
				if increment % 1 ~= 0 then
					mult = 10 ^ (#tostring(increment) - 3)
				end
				value = math.floor((value * mult + 0.5 * increment * mult) / (increment * mult)) * (increment * mult)
				local realValue = value / mult
				realValue = math.clamp(realValue, min, max)
				if increment % 1 == 0 then
					Value.Text = string.format("%d", realValue)
				else
					Value.Text = string.format("%1.1f", realValue)
				end
				pcall(callback, realValue)
			end
			connectionManager:NewConnection(SlideCircle.InputBegan, function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = true
				end
			end)
			connectionManager:NewConnection(SlideCircle.InputEnded, function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = false
				end
			end)
			connectionManager:NewConnection(GetService("UserInputService").InputChanged, function(input)
				if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
					move(input)
				end
			end)
			Container.CanvasSize = UDim2.new(0, 0, 0, ContainerLayout.AbsoluteContentSize.Y)
			function SliderFunc:Set(tochange)
				CurrentValueFrame.Size = UDim2.new((tochange or 0) / max, 0, 0, 3)
				SlideCircle.Position = UDim2.new((tochange or 0) / max, -6, -1.30499995, 0)
				Value.Text = tostring(tochange and math.floor((tochange / max) * (max - min) + min) or 0)
				pcall(callback, tochange)

				return SliderFunc
			end
			if EnableSaving and _loadState(sliderId, "Slider") then
				SliderFunc:Set(_loadState(sliderId, "Slider"))
			end
			function SliderFunc:Save()
				if EnableSaving then
					_saveState(sliderId, "Slider", tonumber(Value.Text))
				else
					warn("Saving is not enabled!")
				end
				return SliderFunc
			end
			function SliderFunc:SetIncrement(val: number)
				assert(type(val) == "number", "Argument #1 to 'SetIncrement' (number) expected.")
				increment = tonumber(val)
				return SliderFunc
			end
			return SliderFunc
		end
		function ContainerContent:Dropdown(dropdownId, text, list, callback)
			local filter = {}

			for i, v in next, list do
				if not table.find(filter, v) then
					table.insert(filter, v)
				end
			end
			list = filter
			local DropFunc = {}
			local Selected = text
			local FrameSize = 43
			local ItemCount = 0
			local DropToggled = false
			local Dropdown = Instance.new("TextButton")
			local DropdownCorner = Instance.new("UICorner")
			local Title = Instance.new("TextLabel")
			local Circle = Instance.new("Frame")
			local CircleCorner = Instance.new("UICorner")
			local CircleSmall = Instance.new("Frame")
			local CircleSmallCorner = Instance.new("UICorner")
			local ArrowIco = Instance.new("ImageLabel")
			local DropItemHolder = Instance.new("ScrollingFrame")
			local DropLayout = Instance.new("UIListLayout")

			Dropdown.Name = "Dropdown"
			Dropdown.Parent = Container
			Dropdown.BackgroundColor3 = Color3.fromRGB(64, 68, 75)
			Dropdown.ClipsDescendants = true
			Dropdown.Position = UDim2.new(0.110937499, 0, 0.67653507, 0)
			Dropdown.Size = UDim2.new(0, 457, 0, 43)
			Dropdown.AutoButtonColor = false
			Dropdown.Font = Enum.Font.SourceSans
			Dropdown.Text = ""
			Dropdown.TextColor3 = Color3.fromRGB(0, 0, 0)
			Dropdown.TextSize = 14.000

			DropdownCorner.CornerRadius = UDim.new(0, 4)
			DropdownCorner.Name = "DropdownCorner"
			DropdownCorner.Parent = Dropdown

			Title.Name = "Title"
			Title.Parent = Dropdown
			Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Title.BackgroundTransparency = 1.000
			Title.Position = UDim2.new(0.0822437406, 0, 0, 0)
			Title.Size = UDim2.new(0, 113, 0, 42)
			Title.Font = Enum.Font.Gotham
			Title.Text = text
			Title.TextColor3 = Color3.fromRGB(255, 255, 255)
			Title.TextSize = 15.000
			Title.TextTransparency = 0.300
			Title.TextXAlignment = Enum.TextXAlignment.Left

			Circle.Name = "Circle"
			Circle.Parent = Title
			Circle.Active = true
			Circle.AnchorPoint = Vector2.new(0.5, 0.5)
			Circle.BackgroundColor3 = Color3.fromRGB(211, 211, 211)
			Circle.Position = UDim2.new(-0.150690272, 0, 0.503000021, 0)
			Circle.Size = UDim2.new(0, 11, 0, 11)

			CircleCorner.CornerRadius = UDim.new(2, 6)
			CircleCorner.Name = "CircleCorner"
			CircleCorner.Parent = Circle

			CircleSmall.Name = "CircleSmall"
			CircleSmall.Parent = Circle
			CircleSmall.Active = true
			CircleSmall.AnchorPoint = Vector2.new(0.5, 0.5)
			CircleSmall.BackgroundColor3 = Color3.fromRGB(64, 68, 75)
			CircleSmall.BackgroundTransparency = 1.000
			CircleSmall.Position = UDim2.new(0.485673368, 0, 0.503000021, 0)
			CircleSmall.Size = UDim2.new(0, 9, 0, 9)

			CircleSmallCorner.CornerRadius = UDim.new(2, 6)
			CircleSmallCorner.Name = "CircleSmallCorner"
			CircleSmallCorner.Parent = CircleSmall

			ArrowIco.Name = "ArrowIco"
			ArrowIco.Parent = Title
			ArrowIco.AnchorPoint = Vector2.new(0.5, 0.5)
			ArrowIco.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			ArrowIco.BackgroundTransparency = 1.000
			ArrowIco.Position = UDim2.new(3.45979357, 0, 0.508096159, 0)
			ArrowIco.Selectable = true
			ArrowIco.Size = UDim2.new(0, 28, 0, 24)
			ArrowIco.Image = "http://www.roblox.com/asset/?id=6035047377"
			ArrowIco.ImageTransparency = 0.3

			DropItemHolder.Name = "DropItemHolder"
			DropItemHolder.Parent = Title
			DropItemHolder.Active = true
			DropItemHolder.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			DropItemHolder.BackgroundTransparency = 1.000
			DropItemHolder.BorderSizePixel = 0
			DropItemHolder.Position = UDim2.new(-0.203539819, 0, 1.02380955, 0)
			DropItemHolder.Size = UDim2.new(0, 436, 0, 82)
			DropItemHolder.CanvasSize = UDim2.new(0, 0, 0, 0)
			DropItemHolder.ScrollBarThickness = 5
			DropItemHolder.ScrollBarImageColor3 = Color3.fromRGB(41, 42, 48)

			DropLayout.Name = "DropLayout"
			DropLayout.Parent = DropItemHolder
			DropLayout.SortOrder = Enum.SortOrder.LayoutOrder
			DropLayout.Padding = UDim.new(0, 2)

			connectionManager:NewConnection(Dropdown.MouseEnter, function()
				TweenService:Create(Title, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0 }):Play()
			end)

			connectionManager:NewConnection(Dropdown.MouseLeave, function()
				TweenService:Create(Title, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0.3 }):Play()
			end)

			connectionManager:NewConnection(Dropdown.MouseButton1Click, function()
				if DropToggled == false then
					getgenv.changeDropdownColor = function()
						repeat
							wait()
						until DropToggled == true
						repeat
							wait()
							TweenService:Create(Title, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextColor3 = getgenv.PresetColor }):Play()
							TweenService:Create(ArrowIco, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { ImageColor3 = getgenv.PresetColor }):Play()
							TweenService:Create(Circle, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundColor3 = getgenv.PresetColor }):Play()
						until DropToggled == false
						TweenService:Create(Title, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextColor3 = Color3.fromRGB(255, 255, 255) }):Play()
						TweenService:Create(ArrowIco, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { ImageColor3 = Color3.fromRGB(255, 255, 255) }):Play()
						TweenService:Create(ArrowIco, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { ImageTransparency = 0.3 }):Play()
						TweenService:Create(ArrowIco, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Rotation = 0 }):Play()
						TweenService:Create(Circle, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundColor3 = Color3.fromRGB(211, 211, 211) }):Play()
						TweenService:Create(CircleSmall, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 1 }):Play()
						TweenService:Create(Title, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0.3 }):Play()
					end
					coroutine.wrap(getgenv.changeDropdownColor)()
					Title.Text = Selected
					Dropdown:TweenSize(UDim2.new(0, 457, 0, FrameSize), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.6, true)
					TweenService:Create(Title, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextColor3 = getgenv.PresetColor }):Play()
					TweenService:Create(ArrowIco, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { ImageColor3 = getgenv.PresetColor }):Play()
					TweenService:Create(ArrowIco, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { ImageTransparency = 0 }):Play()
					TweenService:Create(ArrowIco, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Rotation = 180 }):Play()
					TweenService:Create(Circle, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundColor3 = getgenv.PresetColor }):Play()
					TweenService:Create(CircleSmall, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 0 }):Play()
					TweenService:Create(Title, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0 }):Play()
					wait(0.4)
					Container.CanvasSize = UDim2.new(0, 0, 0, ContainerLayout.AbsoluteContentSize.Y)
				else
					Title.Text = Selected
					Dropdown:TweenSize(UDim2.new(0, 457, 0, 43), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.6, true)
					wait(0.4)
					Container.CanvasSize = UDim2.new(0, 0, 0, ContainerLayout.AbsoluteContentSize.Y)
				end
				DropToggled = not DropToggled
			end)

			for i, v in next, list do
				ItemCount = ItemCount + 1

				if ItemCount == 1 then
					FrameSize = 78
				elseif ItemCount == 2 then
					FrameSize = 107
				elseif ItemCount >= 3 then
					FrameSize = 133
				end
				local Item = Instance.new("TextButton")
				local ItemCorner = Instance.new("UICorner")

				Item.Name = "Item"
				Item.Parent = DropItemHolder
				Item.BackgroundColor3 = Color3.fromRGB(64, 68, 75)
				Item.ClipsDescendants = true
				Item.Size = UDim2.new(0, 427, 0, 25)
				Item.AutoButtonColor = false
				Item.Font = Enum.Font.Gotham
				Item.Text = v
				Item.TextColor3 = Color3.fromRGB(255, 255, 255)
				Item.TextSize = 15.000
				Item.TextTransparency = 0.300

				ItemCorner.CornerRadius = UDim.new(0, 4)
				ItemCorner.Name = "ItemCorner"
				ItemCorner.Parent = Item
				DropItemHolder.CanvasSize = UDim2.new(0, 0, 0, DropLayout.AbsoluteContentSize.Y)

				connectionManager:NewConnection(Item.MouseEnter, function()
					TweenService:Create(Item, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0 }):Play()
				end)

				connectionManager:NewConnection(Item.MouseLeave, function()
					TweenService:Create(Item, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0.3 }):Play()
				end)

				connectionManager:NewConnection(Item.MouseButton1Click, function()
					Selected = v
					Title.Text = Selected
					pcall(callback, v)
					DropToggled = not DropToggled
					Dropdown:TweenSize(UDim2.new(0, 457, 0, 43), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.6, true)
					TweenService:Create(Title, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextColor3 = Color3.fromRGB(255, 255, 255) }):Play()
					TweenService:Create(ArrowIco, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { ImageColor3 = Color3.fromRGB(255, 255, 255) }):Play()
					TweenService:Create(ArrowIco, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { ImageTransparency = 0.3 }):Play()
					TweenService:Create(ArrowIco, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Rotation = 0 }):Play()
					TweenService:Create(Circle, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundColor3 = Color3.fromRGB(211, 211, 211) }):Play()
					TweenService:Create(CircleSmall, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 1 }):Play()
					TweenService:Create(Title, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0.3 }):Play()
					wait(0.4)
					Container.CanvasSize = UDim2.new(0, 0, 0, ContainerLayout.AbsoluteContentSize.Y)
				end)
			end
			function DropFunc:Add(addtext)
				if table.find(list, addtext) then
					return nil
				end
				table.insert(list, addtext)

				ItemCount = ItemCount + 1

				if ItemCount == 1 then
					FrameSize = 78
				elseif ItemCount == 2 then
					FrameSize = 107
				elseif ItemCount >= 3 then
					FrameSize = 133
				end
				local Item = Instance.new("TextButton")
				local ItemCorner = Instance.new("UICorner")

				Item.Name = "Item"
				Item.Parent = DropItemHolder
				Item.BackgroundColor3 = Color3.fromRGB(64, 68, 75)
				Item.ClipsDescendants = true
				Item.Size = UDim2.new(0, 427, 0, 25)
				Item.AutoButtonColor = false
				Item.Font = Enum.Font.Gotham
				Item.Text = addtext
				Item.TextColor3 = Color3.fromRGB(255, 255, 255)
				Item.TextSize = 15.000
				Item.TextTransparency = 0.300

				ItemCorner.CornerRadius = UDim.new(0, 4)
				ItemCorner.Name = "ItemCorner"
				ItemCorner.Parent = Item
				DropItemHolder.CanvasSize = UDim2.new(0, 0, 0, DropLayout.AbsoluteContentSize.Y)

				connectionManager:NewConnection(Item.MouseEnter, function()
					TweenService:Create(Item, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0 }):Play()
				end)

				connectionManager:NewConnection(Item.MouseLeave, function()
					TweenService:Create(Item, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0.3 }):Play()
				end)

				connectionManager:NewConnection(Item.MouseButton1Click, function()
					Selected = addtext
					Title.Text = Selected
					pcall(callback, addtext)
					DropToggled = not DropToggled
					Dropdown:TweenSize(UDim2.new(0, 457, 0, 43), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.6, true)
					TweenService:Create(Title, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextColor3 = Color3.fromRGB(255, 255, 255) }):Play()
					TweenService:Create(ArrowIco, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { ImageColor3 = Color3.fromRGB(255, 255, 255) }):Play()
					TweenService:Create(ArrowIco, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { ImageTransparency = 0.3 }):Play()
					TweenService:Create(ArrowIco, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Rotation = 0 }):Play()
					TweenService:Create(Circle, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundColor3 = Color3.fromRGB(211, 211, 211) }):Play()
					TweenService:Create(CircleSmall, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 1 }):Play()
					TweenService:Create(Title, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0.3 }):Play()
					wait(0.4)
					Container.CanvasSize = UDim2.new(0, 0, 0, ContainerLayout.AbsoluteContentSize.Y)
				end)
				if DropToggled == true then
					Title.Text = Selected
					Dropdown:TweenSize(UDim2.new(0, 457, 0, 43), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.6, true)
					TweenService:Create(Title, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextColor3 = Color3.fromRGB(255, 255, 255) }):Play()
					TweenService:Create(ArrowIco, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { ImageColor3 = Color3.fromRGB(255, 255, 255) }):Play()
					TweenService:Create(ArrowIco, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { ImageTransparency = 0.3 }):Play()
					TweenService:Create(ArrowIco, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Rotation = 0 }):Play()
					TweenService:Create(Circle, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundColor3 = Color3.fromRGB(211, 211, 211) }):Play()
					TweenService:Create(CircleSmall, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 1 }):Play()
					TweenService:Create(Title, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0.3 }):Play()
					wait(0.4)
					Container.CanvasSize = UDim2.new(0, 0, 0, ContainerLayout.AbsoluteContentSize.Y)
				end
			end
			function DropFunc:Clear()
				Title.Text = text
				FrameSize = 0
				ItemCount = 0
				for i, v in next, DropItemHolder:GetChildren() do
					if v.Name == "Item" then
						v:Destroy()
					end
				end
				if DropToggled == true then
					Title.Text = Selected
					Dropdown:TweenSize(UDim2.new(0, 457, 0, 43), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.6, true)
					TweenService:Create(Title, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextColor3 = Color3.fromRGB(255, 255, 255) }):Play()
					TweenService:Create(ArrowIco, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { ImageColor3 = Color3.fromRGB(255, 255, 255) }):Play()
					TweenService:Create(ArrowIco, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { ImageTransparency = 0.3 }):Play()
					TweenService:Create(ArrowIco, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Rotation = 0 }):Play()
					TweenService:Create(Circle, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundColor3 = Color3.fromRGB(211, 211, 211) }):Play()
					TweenService:Create(CircleSmall, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 1 }):Play()
					TweenService:Create(Title, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0.3 }):Play()
					wait(0.4)
					Container.CanvasSize = UDim2.new(0, 0, 0, ContainerLayout.AbsoluteContentSize.Y)
				end
				list = {}
			end
			function DropFunc:Select(addtext)
				assert(type(addtext) == "string", ("Dropdown:Select(<string>) parameter (%s) is not type: string"):format(typeof(addtext)))

				if not table.find(list, addtext) then
					return nil
				end

				Selected = addtext
				Title.Text = Selected
				pcall(callback, addtext)
			end

			if EnableSaving and _loadState(dropdownId, "Dropdown") then
				DropFunc:Select(_loadState(dropdownId, "Dropdown"))
			end

			function DropFunc:Save()
				if EnableSaving then
					_saveState(dropdownId, "Dropdown", Selected)
				else
					warn("Saving is not enbaled!")
				end
			end

			return DropFunc
		end

		function ContainerContent:MultiDropdown(dropdownId, text, list, callback)
			local filter = {}

			for i, v in next, list do
				if not table.find(filter, v) then
					table.insert(filter, v)
				end
			end
			list = filter
			local DropFunc = {}
			local Selected = {}
			local FrameSize = 43
			local ItemCount = 0
			local DropToggled = false
			local Dropdown = Instance.new("TextButton")
			local DropdownCorner = Instance.new("UICorner")
			local Title = Instance.new("TextLabel")
			local Circle = Instance.new("Frame")
			local CircleCorner = Instance.new("UICorner")
			local CircleSmall = Instance.new("Frame")
			local CircleSmallCorner = Instance.new("UICorner")
			local ArrowIco = Instance.new("ImageLabel")
			local DropItemHolder = Instance.new("ScrollingFrame")
			local DropLayout = Instance.new("UIListLayout")

			Dropdown.Name = "Dropdown"
			Dropdown.Parent = Container
			Dropdown.BackgroundColor3 = Color3.fromRGB(64, 68, 75)
			Dropdown.ClipsDescendants = true
			Dropdown.Position = UDim2.new(0.110937499, 0, 0.67653507, 0)
			Dropdown.Size = UDim2.new(0, 457, 0, 43)
			Dropdown.AutoButtonColor = false
			Dropdown.Font = Enum.Font.SourceSans
			Dropdown.Text = ""
			Dropdown.TextColor3 = Color3.fromRGB(0, 0, 0)
			Dropdown.TextSize = 14.000

			DropdownCorner.CornerRadius = UDim.new(0, 4)
			DropdownCorner.Name = "DropdownCorner"
			DropdownCorner.Parent = Dropdown

			Title.Name = "Title"
			Title.Parent = Dropdown
			Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Title.BackgroundTransparency = 1.000
			Title.Position = UDim2.new(0.0822437406, 0, 0, 0)
			Title.Size = UDim2.new(0, 113, 0, 42)
			Title.Font = Enum.Font.Gotham
			Title.Text = text
			Title.TextColor3 = Color3.fromRGB(255, 255, 255)
			Title.TextSize = 15.000
			Title.TextTransparency = 0.300
			Title.TextXAlignment = Enum.TextXAlignment.Left

			Circle.Name = "Circle"
			Circle.Parent = Title
			Circle.Active = true
			Circle.AnchorPoint = Vector2.new(0.5, 0.5)
			Circle.BackgroundColor3 = Color3.fromRGB(211, 211, 211)
			Circle.Position = UDim2.new(-0.150690272, 0, 0.503000021, 0)
			Circle.Size = UDim2.new(0, 11, 0, 11)

			CircleCorner.CornerRadius = UDim.new(2, 6)
			CircleCorner.Name = "CircleCorner"
			CircleCorner.Parent = Circle

			CircleSmall.Name = "CircleSmall"
			CircleSmall.Parent = Circle
			CircleSmall.Active = true
			CircleSmall.AnchorPoint = Vector2.new(0.5, 0.5)
			CircleSmall.BackgroundColor3 = Color3.fromRGB(64, 68, 75)
			CircleSmall.BackgroundTransparency = 1.000
			CircleSmall.Position = UDim2.new(0.485673368, 0, 0.503000021, 0)
			CircleSmall.Size = UDim2.new(0, 9, 0, 9)

			CircleSmallCorner.CornerRadius = UDim.new(2, 6)
			CircleSmallCorner.Name = "CircleSmallCorner"
			CircleSmallCorner.Parent = CircleSmall

			ArrowIco.Name = "ArrowIco"
			ArrowIco.Parent = Title
			ArrowIco.AnchorPoint = Vector2.new(0.5, 0.5)
			ArrowIco.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			ArrowIco.BackgroundTransparency = 1.000
			ArrowIco.Position = UDim2.new(3.45979357, 0, 0.508096159, 0)
			ArrowIco.Selectable = true
			ArrowIco.Size = UDim2.new(0, 28, 0, 24)
			ArrowIco.Image = "http://www.roblox.com/asset/?id=6035047377"
			ArrowIco.ImageTransparency = 0.3

			DropItemHolder.Name = "DropItemHolder"
			DropItemHolder.Parent = Title
			DropItemHolder.Active = true
			DropItemHolder.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			DropItemHolder.BackgroundTransparency = 1.000
			DropItemHolder.BorderSizePixel = 0
			DropItemHolder.Position = UDim2.new(-0.203539819, 0, 1.02380955, 0)
			DropItemHolder.Size = UDim2.new(0, 436, 0, 82)
			DropItemHolder.CanvasSize = UDim2.new(0, 0, 0, 0)
			DropItemHolder.ScrollBarThickness = 5
			DropItemHolder.ScrollBarImageColor3 = Color3.fromRGB(41, 42, 48)

			DropLayout.Name = "DropLayout"
			DropLayout.Parent = DropItemHolder
			DropLayout.SortOrder = Enum.SortOrder.LayoutOrder
			DropLayout.Padding = UDim.new(0, 2)

			local function SetTitle(tab)
				local strTab = {}

				for _, v in next, tab do
					if type(v) == "string" then
						table.insert(strTab, v)
					end
				end

				Title.Text = #strTab > 0 and table.concat(strTab, ", ") or text
			end

			connectionManager:NewConnection(Dropdown.MouseEnter, function()
				TweenService:Create(Title, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0 }):Play()
			end)

			connectionManager:NewConnection(Dropdown.MouseLeave, function()
				TweenService:Create(Title, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0.3 }):Play()
			end)

			connectionManager:NewConnection(Dropdown.MouseButton1Click, function()
				if DropToggled == false then
					getgenv.changeDropdownColor = function()
						repeat
							wait()
						until DropToggled == true
						repeat
							wait()
							TweenService:Create(Title, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextColor3 = getgenv.PresetColor }):Play()
							TweenService:Create(ArrowIco, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { ImageColor3 = getgenv.PresetColor }):Play()
							TweenService:Create(Circle, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundColor3 = getgenv.PresetColor }):Play()
						until DropToggled == false
						TweenService:Create(Title, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextColor3 = Color3.fromRGB(255, 255, 255) }):Play()
						TweenService:Create(ArrowIco, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { ImageColor3 = Color3.fromRGB(255, 255, 255) }):Play()
						TweenService:Create(ArrowIco, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { ImageTransparency = 0.3 }):Play()
						TweenService:Create(ArrowIco, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Rotation = 0 }):Play()
						TweenService:Create(Circle, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundColor3 = Color3.fromRGB(211, 211, 211) }):Play()
						TweenService:Create(CircleSmall, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 1 }):Play()
						TweenService:Create(Title, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0.3 }):Play()
					end
					coroutine.wrap(getgenv.changeDropdownColor)()
					SetTitle(Selected)
					Dropdown:TweenSize(UDim2.new(0, 457, 0, FrameSize), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.6, true)
					TweenService:Create(Title, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextColor3 = getgenv.PresetColor }):Play()
					TweenService:Create(ArrowIco, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { ImageColor3 = getgenv.PresetColor }):Play()
					TweenService:Create(ArrowIco, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { ImageTransparency = 0 }):Play()
					TweenService:Create(ArrowIco, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Rotation = 180 }):Play()
					TweenService:Create(Circle, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundColor3 = getgenv.PresetColor }):Play()
					TweenService:Create(CircleSmall, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 0 }):Play()
					TweenService:Create(Title, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0 }):Play()
					wait(0.4)
					Container.CanvasSize = UDim2.new(0, 0, 0, ContainerLayout.AbsoluteContentSize.Y)
				else
					SetTitle(Selected)
					Dropdown:TweenSize(UDim2.new(0, 457, 0, 43), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.6, true)
					wait(0.4)
					Container.CanvasSize = UDim2.new(0, 0, 0, ContainerLayout.AbsoluteContentSize.Y)
				end
				DropToggled = not DropToggled
			end)

			for i, v in next, list do
				ItemCount = ItemCount + 1

				if ItemCount == 1 then
					FrameSize = 78
				elseif ItemCount == 2 then
					FrameSize = 107
				elseif ItemCount >= 3 then
					FrameSize = 133
				end
				local Item = Instance.new("TextButton")
				local ItemCorner = Instance.new("UICorner")

				Item.Name = "Item"
				Item.Parent = DropItemHolder
				Item.BackgroundColor3 = Color3.fromRGB(64, 68, 75)
				Item.ClipsDescendants = true
				Item.Size = UDim2.new(0, 427, 0, 25)
				Item.AutoButtonColor = false
				Item.Font = Enum.Font.Gotham
				Item.Text = v
				Item.TextColor3 = Color3.fromRGB(255, 255, 255)
				Item.TextSize = 15.000
				Item.TextTransparency = 0.300

				ItemCorner.CornerRadius = UDim.new(0, 4)
				ItemCorner.Name = "ItemCorner"
				ItemCorner.Parent = Item
				DropItemHolder.CanvasSize = UDim2.new(0, 0, 0, DropLayout.AbsoluteContentSize.Y)

				connectionManager:NewConnection(Item.MouseEnter, function()
					TweenService:Create(Item, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0 }):Play()
				end)

				connectionManager:NewConnection(Item.MouseLeave, function()
					TweenService:Create(Item, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0.3 }):Play()
				end)

				connectionManager:NewConnection(Item.MouseButton1Click, function()
					local intable = table.find(Selected, v)
					if intable then
						table.remove(Selected, intable)
					else
						table.insert(Selected, v)
					end

					SetTitle(Selected)
					pcall(callback, Selected)
					DropToggled = not DropToggled
					Dropdown:TweenSize(UDim2.new(0, 457, 0, 43), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.6, true)
					TweenService:Create(Title, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextColor3 = Color3.fromRGB(255, 255, 255) }):Play()
					TweenService:Create(ArrowIco, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { ImageColor3 = Color3.fromRGB(255, 255, 255) }):Play()
					TweenService:Create(ArrowIco, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { ImageTransparency = 0.3 }):Play()
					TweenService:Create(ArrowIco, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Rotation = 0 }):Play()
					TweenService:Create(Circle, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundColor3 = Color3.fromRGB(211, 211, 211) }):Play()
					TweenService:Create(CircleSmall, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 1 }):Play()
					TweenService:Create(Title, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0.3 }):Play()
					wait(0.4)
					Container.CanvasSize = UDim2.new(0, 0, 0, ContainerLayout.AbsoluteContentSize.Y)
				end)
			end
			function DropFunc:Add(addtable)
				assert(type(addtable) == "table", "MultiDropdown:Add() value wasnt a table")
				for _i, _v in next, addtable do
					if table.find(list, _v) then
						continue
					end
					table.insert(list, _v)
					if type(_v) ~= "string" then
						continue
					end
					ItemCount = ItemCount + 1

					if ItemCount == 1 then
						FrameSize = 78
					elseif ItemCount == 2 then
						FrameSize = 107
					elseif ItemCount >= 3 then
						FrameSize = 133
					end
					local Item = Instance.new("TextButton")
					local ItemCorner = Instance.new("UICorner")

					Item.Name = "Item"
					Item.Parent = DropItemHolder
					Item.BackgroundColor3 = Color3.fromRGB(64, 68, 75)
					Item.ClipsDescendants = true
					Item.Size = UDim2.new(0, 427, 0, 25)
					Item.AutoButtonColor = false
					Item.Font = Enum.Font.Gotham
					Item.Text = _v
					Item.TextColor3 = Color3.fromRGB(255, 255, 255)
					Item.TextSize = 15.000
					Item.TextTransparency = 0.300

					ItemCorner.CornerRadius = UDim.new(0, 4)
					ItemCorner.Name = "ItemCorner"
					ItemCorner.Parent = Item
					DropItemHolder.CanvasSize = UDim2.new(0, 0, 0, DropLayout.AbsoluteContentSize.Y)

					connectionManager:NewConnection(Item.MouseEnter, function()
						TweenService:Create(Item, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0 }):Play()
					end)

					connectionManager:NewConnection(Item.MouseLeave, function()
						TweenService:Create(Item, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0.3 }):Play()
					end)

					connectionManager:NewConnection(Item.MouseButton1Click, function()
						-- Selected = addtext
						-- SetTitle(Selected)
						-- pcall(callback, addtext)
						local intable = table.find(Selected, _v)
						if intable then
							table.remove(Selected, intable)
						else
							table.insert(Selected, _v)
						end

						SetTitle(Selected)
						pcall(callback, Selected)
						DropToggled = not DropToggled
						Dropdown:TweenSize(UDim2.new(0, 457, 0, 43), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.6, true)
						TweenService:Create(Title, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextColor3 = Color3.fromRGB(255, 255, 255) }):Play()
						TweenService:Create(ArrowIco, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { ImageColor3 = Color3.fromRGB(255, 255, 255) }):Play()
						TweenService:Create(ArrowIco, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { ImageTransparency = 0.3 }):Play()
						TweenService:Create(ArrowIco, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Rotation = 0 }):Play()
						TweenService:Create(Circle, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundColor3 = Color3.fromRGB(211, 211, 211) }):Play()
						TweenService:Create(CircleSmall, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 1 }):Play()
						TweenService:Create(Title, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0.3 }):Play()
						wait(0.4)
						Container.CanvasSize = UDim2.new(0, 0, 0, ContainerLayout.AbsoluteContentSize.Y)
					end)
					if DropToggled == true then
						SetTitle(Selected)
						Dropdown:TweenSize(UDim2.new(0, 457, 0, 43), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.6, true)
						TweenService:Create(Title, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextColor3 = Color3.fromRGB(255, 255, 255) }):Play()
						TweenService:Create(ArrowIco, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { ImageColor3 = Color3.fromRGB(255, 255, 255) }):Play()
						TweenService:Create(ArrowIco, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { ImageTransparency = 0.3 }):Play()
						TweenService:Create(ArrowIco, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Rotation = 0 }):Play()
						TweenService:Create(Circle, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundColor3 = Color3.fromRGB(211, 211, 211) }):Play()
						TweenService:Create(CircleSmall, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 1 }):Play()
						TweenService:Create(Title, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0.3 }):Play()
						wait(0.4)
						Container.CanvasSize = UDim2.new(0, 0, 0, ContainerLayout.AbsoluteContentSize.Y)
					end
				end
			end
			function DropFunc:Clear()
				Selected = {}
				Title.Text = text
				FrameSize = 0
				ItemCount = 0
				for i, v in next, DropItemHolder:GetChildren() do
					if v.Name == "Item" then
						v:Destroy()
					end
				end
				if DropToggled == true then
					SetTitle(Selected)
					Dropdown:TweenSize(UDim2.new(0, 457, 0, 43), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.6, true)
					TweenService:Create(Title, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextColor3 = Color3.fromRGB(255, 255, 255) }):Play()
					TweenService:Create(ArrowIco, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { ImageColor3 = Color3.fromRGB(255, 255, 255) }):Play()
					TweenService:Create(ArrowIco, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { ImageTransparency = 0.3 }):Play()
					TweenService:Create(ArrowIco, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Rotation = 0 }):Play()
					TweenService:Create(Circle, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundColor3 = Color3.fromRGB(211, 211, 211) }):Play()
					TweenService:Create(CircleSmall, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 1 }):Play()
					TweenService:Create(Title, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0.3 }):Play()
					wait(0.4)
					Container.CanvasSize = UDim2.new(0, 0, 0, ContainerLayout.AbsoluteContentSize.Y)
				end
				list = {}
			end

			function DropFunc:Select(tab)
				assert(type(tab) == "table", ("MultiDropdown:Select(<table>) parameter (%s) is not type: table"):format(typeof(tab)))
				for i = #tab, 1, -1 do
					if not table.find(list, tab[i]) then
						table.remove(tab, i)
					end
				end
				Selected = #tab > 0 and tab or Selected
				SetTitle(Selected)
				pcall(callback, Selected)
			end
			if EnableSaving and _loadState(dropdownId, "Dropdown") then
				DropFunc:Select(_loadState(dropdownId, "Dropdown"))
			end

			function DropFunc:Save()
				if EnableSaving then
					_saveState(dropdownId, "Dropdown", Selected)
				else
					warn("Saving is not enabled!")
				end
			end
			return DropFunc
		end

		function ContainerContent:Colorpicker(colorpickid, text, preset, callback)
			local ColorFunc = {}
			local ColorPickerToggled = false
			local OldToggleColor = Color3.fromRGB(0, 0, 0)
			local OldColor = Color3.fromRGB(0, 0, 0)
			local OldColorSelectionPosition = nil
			local OldHueSelectionPosition = nil
			local ColorH, ColorS, ColorV = 1, 1, 1
			local RainbowColorPicker = false
			local ColorPickerInput = nil
			local ColorInput = nil
			local HueInput = nil

			local Colorpicker = Instance.new("Frame")
			local ColorpickerCorner = Instance.new("UICorner")
			local Title = Instance.new("TextLabel")
			local Circle = Instance.new("Frame")
			local CircleCorner = Instance.new("UICorner")
			local CircleSmall = Instance.new("Frame")
			local CircleSmallCorner = Instance.new("UICorner")
			local Hue = Instance.new("ImageLabel")
			local HueCorner = Instance.new("UICorner")
			local HueGradient = Instance.new("UIGradient")
			local HueSelection = Instance.new("ImageLabel")
			local Color = Instance.new("ImageLabel")
			local ColorCorner = Instance.new("UICorner")
			local ColorSelection = Instance.new("ImageLabel")
			local Toggle = Instance.new("TextLabel")
			local ToggleFrame = Instance.new("Frame")
			local ToggleFrameCorner = Instance.new("UICorner")
			local ToggleCircle = Instance.new("Frame")
			local ToggleCircleCorner = Instance.new("UICorner")
			local Confirm = Instance.new("TextButton")
			local ConfirmCorner = Instance.new("UICorner")
			local ConfirmTitle = Instance.new("TextLabel")
			local BoxColor = Instance.new("Frame")
			local BoxColorCorner = Instance.new("UICorner")
			local ColorpickerBtn = Instance.new("TextButton")
			local ToggleBtn = Instance.new("TextButton")

			Colorpicker.Name = "Colorpicker"
			Colorpicker.Parent = Container
			Colorpicker.BackgroundColor3 = Color3.fromRGB(64, 68, 75)
			Colorpicker.ClipsDescendants = true
			Colorpicker.Position = UDim2.new(0.110937499, 0, 0.67653507, 0)
			Colorpicker.Size = UDim2.new(0, 457, 0, 43)

			ColorpickerCorner.CornerRadius = UDim.new(0, 4)
			ColorpickerCorner.Name = "ColorpickerCorner"
			ColorpickerCorner.Parent = Colorpicker

			Title.Name = "Title"
			Title.Parent = Colorpicker
			Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Title.BackgroundTransparency = 1.000
			Title.Position = UDim2.new(0.0822437406, 0, 0, 0)
			Title.Size = UDim2.new(0, 113, 0, 42)
			Title.Font = Enum.Font.Gotham
			Title.Text = text
			Title.TextColor3 = Color3.fromRGB(255, 255, 255)
			Title.TextSize = 15.000
			Title.TextTransparency = 0.300
			Title.TextXAlignment = Enum.TextXAlignment.Left

			ColorpickerBtn.Name = "ColorpickerBtn"
			ColorpickerBtn.Parent = Title
			ColorpickerBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			ColorpickerBtn.BackgroundTransparency = 1.000
			ColorpickerBtn.Position = UDim2.new(-0.336283177, 0, 0, 0)
			ColorpickerBtn.Size = UDim2.new(0, 457, 0, 42)
			ColorpickerBtn.Font = Enum.Font.SourceSans
			ColorpickerBtn.Text = ""
			ColorpickerBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
			ColorpickerBtn.TextSize = 14.000

			Circle.Name = "Circle"
			Circle.Parent = Title
			Circle.Active = true
			Circle.AnchorPoint = Vector2.new(0.5, 0.5)
			Circle.BackgroundColor3 = Color3.fromRGB(211, 211, 211)
			Circle.Position = UDim2.new(-0.150690272, 0, 0.503000021, 0)
			Circle.Size = UDim2.new(0, 11, 0, 11)

			CircleCorner.CornerRadius = UDim.new(2, 6)
			CircleCorner.Name = "CircleCorner"
			CircleCorner.Parent = Circle

			CircleSmall.Name = "CircleSmall"
			CircleSmall.Parent = Circle
			CircleSmall.Active = true
			CircleSmall.AnchorPoint = Vector2.new(0.5, 0.5)
			CircleSmall.BackgroundColor3 = Color3.fromRGB(64, 68, 75)
			CircleSmall.BackgroundTransparency = 1.000
			CircleSmall.Position = UDim2.new(0.485673368, 0, 0.503000021, 0)
			CircleSmall.Size = UDim2.new(0, 9, 0, 9)

			CircleSmallCorner.CornerRadius = UDim.new(2, 6)
			CircleSmallCorner.Name = "CircleSmallCorner"
			CircleSmallCorner.Parent = CircleSmall

			Hue.Name = "Hue"
			Hue.Parent = Title
			Hue.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Hue.Position = UDim2.new(0, 229, 0, 46)
			Hue.Size = UDim2.new(0, 25, 0, 80)

			HueCorner.CornerRadius = UDim.new(0, 3)
			HueCorner.Name = "HueCorner"
			HueCorner.Parent = Hue

			HueGradient.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 4)), ColorSequenceKeypoint.new(0.20, Color3.fromRGB(234, 255, 0)), ColorSequenceKeypoint.new(0.40, Color3.fromRGB(21, 255, 0)), ColorSequenceKeypoint.new(0.60, Color3.fromRGB(0, 255, 255)), ColorSequenceKeypoint.new(0.80, Color3.fromRGB(0, 17, 255)), ColorSequenceKeypoint.new(0.90, Color3.fromRGB(255, 0, 251)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 4)) })
			HueGradient.Rotation = 270
			HueGradient.Name = "HueGradient"
			HueGradient.Parent = Hue

			HueSelection.Name = "HueSelection"
			HueSelection.Parent = Hue
			HueSelection.AnchorPoint = Vector2.new(0.5, 0.5)
			HueSelection.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			HueSelection.BackgroundTransparency = 1.000
			HueSelection.Position = UDim2.new(0.48, 0, 1 - select(1, Color3.toHSV(preset)))
			HueSelection.Size = UDim2.new(0, 18, 0, 18)
			HueSelection.Image = "http://www.roblox.com/asset/?id=4805639000"
			HueSelection.Visible = false

			Color.Name = "Color"
			Color.Parent = Title
			Color.BackgroundColor3 = Color3.fromRGB(255, 0, 4)
			Color.Position = UDim2.new(0, -23, 0, 46)
			Color.Size = UDim2.new(0, 246, 0, 80)
			Color.ZIndex = 10
			Color.Image = "rbxassetid://4155801252"

			ColorCorner.CornerRadius = UDim.new(0, 3)
			ColorCorner.Name = "ColorCorner"
			ColorCorner.Parent = Color

			ColorSelection.Name = "ColorSelection"
			ColorSelection.Parent = Color
			ColorSelection.AnchorPoint = Vector2.new(0.5, 0.5)
			ColorSelection.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			ColorSelection.BackgroundTransparency = 1.000
			ColorSelection.Position = UDim2.new(preset and select(3, Color3.toHSV(preset)))
			ColorSelection.Size = UDim2.new(0, 18, 0, 18)
			ColorSelection.Image = "http://www.roblox.com/asset/?id=4805639000"
			ColorSelection.ScaleType = Enum.ScaleType.Fit
			ColorSelection.Visible = false

			Toggle.Name = "Toggle"
			Toggle.Parent = Title
			Toggle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Toggle.BackgroundTransparency = 1.000
			Toggle.Position = UDim2.new(2.37430048, 0, 1.07157099, 0)
			Toggle.Size = UDim2.new(0, 137, 0, 38)
			Toggle.Font = Enum.Font.Gotham
			Toggle.Text = "Rainbow"
			Toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
			Toggle.TextSize = 15.000
			Toggle.TextTransparency = 0.300
			Toggle.TextXAlignment = Enum.TextXAlignment.Left

			ToggleFrame.Name = "ToggleFrame"
			ToggleFrame.Parent = Toggle
			ToggleFrame.BackgroundColor3 = Color3.fromRGB(226, 227, 227)
			ToggleFrame.Position = UDim2.new(0.778387249, 0, 0.357142866, 0)
			ToggleFrame.Size = UDim2.new(0, 27, 0, 11)

			ToggleFrameCorner.Name = "ToggleFrameCorner"
			ToggleFrameCorner.Parent = ToggleFrame

			ToggleCircle.Name = "ToggleCircle"
			ToggleCircle.Parent = ToggleFrame
			ToggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			ToggleCircle.Position = UDim2.new(0, 0, -0.273000002, 0)
			ToggleCircle.Selectable = true
			ToggleCircle.Size = UDim2.new(0, 17, 0, 17)

			ToggleCircleCorner.CornerRadius = UDim.new(2, 8)
			ToggleCircleCorner.Name = "ToggleCircleCorner"
			ToggleCircleCorner.Parent = ToggleCircle

			Confirm.Name = "Confirm"
			Confirm.Parent = Title
			Confirm.BackgroundColor3 = Color3.fromRGB(64, 68, 75)
			Confirm.ClipsDescendants = true
			Confirm.Position = UDim2.new(2.3791616, 0, 1.97633278, 0)
			Confirm.Size = UDim2.new(0, 144, 0, 42)
			Confirm.AutoButtonColor = false
			Confirm.Font = Enum.Font.SourceSans
			Confirm.Text = ""
			Confirm.TextColor3 = Color3.fromRGB(0, 0, 0)
			Confirm.TextSize = 14.000

			ConfirmCorner.CornerRadius = UDim.new(0, 4)
			ConfirmCorner.Name = "ConfirmCorner"
			ConfirmCorner.Parent = Confirm

			ConfirmTitle.Name = "ConfirmTitle"
			ConfirmTitle.Parent = Confirm
			ConfirmTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			ConfirmTitle.BackgroundTransparency = 1.000
			ConfirmTitle.Size = UDim2.new(0, 116, 0, 40)
			ConfirmTitle.Font = Enum.Font.Gotham
			ConfirmTitle.Text = "Confirm"
			ConfirmTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
			ConfirmTitle.TextSize = 15.000
			ConfirmTitle.TextTransparency = 0.300
			ConfirmTitle.TextXAlignment = Enum.TextXAlignment.Left

			BoxColor.Name = "BoxColor"
			BoxColor.Parent = Title
			BoxColor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			BoxColor.Position = UDim2.new(3.26915574, 0, 0.261904776, 0)
			BoxColor.Size = UDim2.new(0, 35, 0, 19)

			BoxColorCorner.CornerRadius = UDim.new(0, 4)
			BoxColorCorner.Name = "BoxColorCorner"
			BoxColorCorner.Parent = BoxColor

			ToggleBtn.Name = "ToggleBtn"
			ToggleBtn.Parent = Toggle
			ToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			ToggleBtn.BackgroundTransparency = 1.000
			ToggleBtn.Size = UDim2.new(0, 137, 0, 38)
			ToggleBtn.Font = Enum.Font.SourceSans
			ToggleBtn.Text = ""
			ToggleBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
			ToggleBtn.TextSize = 14.000

			connectionManager:NewConnection(ColorpickerBtn.MouseEnter, function()
				TweenService:Create(Title, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0 }):Play()
			end)

			connectionManager:NewConnection(ColorpickerBtn.MouseLeave, function()
				TweenService:Create(Title, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0.3 }):Play()
			end)

			connectionManager:NewConnection(ColorpickerBtn.MouseButton1Click, function()
				if ColorPickerToggled == false then
					local function changePickerColor()
						repeat
							wait()
						until ColorPickerToggled == true
						repeat
							wait()
							TweenService:Create(Title, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextColor3 = getgenv.PresetColor }):Play()
							TweenService:Create(Circle, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundColor3 = getgenv.PresetColor }):Play()
						until ColorPickerToggled == false
						TweenService:Create(Title, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextColor3 = Color3.fromRGB(255, 255, 255) }):Play()
						TweenService:Create(Circle, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundColor3 = Color3.fromRGB(211, 211, 211) }):Play()
						TweenService:Create(CircleSmall, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 1 }):Play()
						TweenService:Create(Title, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0.3 }):Play()
					end
					coroutine.wrap(changePickerColor)()
					ColorSelection.Visible = true
					HueSelection.Visible = true
					Colorpicker:TweenSize(UDim2.new(0, 457, 0, 138), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.6, true)
					TweenService:Create(Title, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextColor3 = getgenv.PresetColor }):Play()
					TweenService:Create(Circle, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundColor3 = getgenv.PresetColor }):Play()
					TweenService:Create(CircleSmall, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 0 }):Play()
					TweenService:Create(Title, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0 }):Play()
					wait(0.4)
					Container.CanvasSize = UDim2.new(0, 0, 0, ContainerLayout.AbsoluteContentSize.Y)
				else
					ColorSelection.Visible = false
					HueSelection.Visible = false
					Colorpicker:TweenSize(UDim2.new(0, 457, 0, 43), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.6, true)
					wait(0.4)
					Container.CanvasSize = UDim2.new(0, 0, 0, ContainerLayout.AbsoluteContentSize.Y)
				end
				ColorPickerToggled = not ColorPickerToggled
			end)

			local function UpdateColorPicker(nope)
				BoxColor.BackgroundColor3 = Color3.fromHSV(ColorH, ColorS, ColorV)
				Color.BackgroundColor3 = Color3.fromHSV(ColorH, 1, 1)

				pcall(callback, BoxColor.BackgroundColor3)
			end

			ColorH = 1 - (math.clamp(HueSelection.AbsolutePosition.Y - Hue.AbsolutePosition.Y, 0, Hue.AbsoluteSize.Y) / Hue.AbsoluteSize.Y)
			ColorS = (math.clamp(ColorSelection.AbsolutePosition.X - Color.AbsolutePosition.X, 0, Color.AbsoluteSize.X) / Color.AbsoluteSize.X)
			ColorV = 1 - (math.clamp(ColorSelection.AbsolutePosition.Y - Color.AbsolutePosition.Y, 0, Color.AbsoluteSize.Y) / Color.AbsoluteSize.Y)

			BoxColor.BackgroundColor3 = preset
			Color.BackgroundColor3 = preset
			pcall(callback, BoxColor.BackgroundColor3)

			connectionManager:NewConnection(Color.InputBegan, function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					if RainbowColorPicker then
						return
					end

					if ColorInput then
						ColorInput:Disable()
					end

					ColorInput = connectionManager:NewConnection(RunService.RenderStepped, function()
						local ColorX = (math.clamp(Mouse.X - Color.AbsolutePosition.X, 0, Color.AbsoluteSize.X) / Color.AbsoluteSize.X)
						local ColorY = (math.clamp(Mouse.Y - Color.AbsolutePosition.Y, 0, Color.AbsoluteSize.Y) / Color.AbsoluteSize.Y)

						ColorSelection.Position = UDim2.new(ColorX, 0, ColorY, 0)
						ColorS = ColorX
						ColorV = 1 - ColorY

						UpdateColorPicker(true)
					end)
				end
			end)

			connectionManager:NewConnection(Color.InputEnded, function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					if ColorInput then
						ColorInput:Disable()
					end
				end
			end)

			connectionManager:NewConnection(Hue.InputBegan, function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					if RainbowColorPicker then
						return
					end

					if HueInput then
						HueInput:Disable()
					end

					HueInput = connectionManager:NewConnection(RunService.RenderStepped, function()
						local HueY = (math.clamp(Mouse.Y - Hue.AbsolutePosition.Y, 0, Hue.AbsoluteSize.Y) / Hue.AbsoluteSize.Y)

						HueSelection.Position = UDim2.new(0.48, 0, HueY, 0)
						ColorH = 1 - HueY

						UpdateColorPicker(true)
					end)
				end
			end)

			connectionManager:NewConnection(Hue.InputEnded, function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					if HueInput then
						HueInput:Disable()
					end
				end
			end)

			local function rainbowfunc()
				RainbowColorPicker = not RainbowColorPicker

				if ColorInput then
					ColorInput:Disable()
				end

				if HueInput then
					HueInput:Disable()
				end

				if RainbowColorPicker then
					local function changeRainbowColor()
						repeat
							wait()
							TweenService:Create(ToggleCircle, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundColor3 = getgenv.PresetColor }):Play()
						until RainbowColorPicker == false
						TweenService:Create(ToggleCircle, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundColor3 = Color3.fromRGB(255, 255, 255) }):Play()
					end
					coroutine.wrap(changeRainbowColor)()
					ToggleCircle:TweenPosition(UDim2.new(0.37, 0, -0.273, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.3, true)
					TweenService:Create(ToggleCircle, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundColor3 = getgenv.PresetColor }):Play()

					OldToggleColor = BoxColor.BackgroundColor3
					OldColor = Color.BackgroundColor3
					OldColorSelectionPosition = ColorSelection.Position
					OldHueSelectionPosition = HueSelection.Position

					while RainbowColorPicker do
						BoxColor.BackgroundColor3 = Color3.fromHSV(Flux.RainbowColorValue, 1, 1)
						Color.BackgroundColor3 = Color3.fromHSV(Flux.RainbowColorValue, 1, 1)

						ColorSelection.Position = UDim2.new(1, 0, 0, 0)
						HueSelection.Position = UDim2.new(0.48, 0, 0, Flux.HueSelectionPosition)

						pcall(callback, BoxColor.BackgroundColor3)
						wait()
					end
				elseif not RainbowColorPicker then
					ToggleCircle:TweenPosition(UDim2.new(0, 0, -0.273, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.3, true)

					BoxColor.BackgroundColor3 = OldToggleColor
					Color.BackgroundColor3 = OldColor

					ColorSelection.Position = OldColorSelectionPosition
					HueSelection.Position = OldHueSelectionPosition

					pcall(callback, BoxColor.BackgroundColor3)
				end
			end

			connectionManager:NewConnection(ToggleBtn.MouseButton1Down, rainbowfunc)

			connectionManager:NewConnection(Confirm.MouseButton1Click, function()
				ColorPickerToggled = not ColorPickerToggled
				ColorSelection.Visible = false
				HueSelection.Visible = false
				Colorpicker:TweenSize(UDim2.new(0, 457, 0, 43), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.6, true)
				TweenService:Create(Title, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextColor3 = Color3.fromRGB(255, 255, 255) }):Play()
				TweenService:Create(Circle, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundColor3 = Color3.fromRGB(211, 211, 211) }):Play()
				TweenService:Create(CircleSmall, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 1 }):Play()
				TweenService:Create(Title, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0.3 }):Play()
				wait(0.4)
				Container.CanvasSize = UDim2.new(0, 0, 0, ContainerLayout.AbsoluteContentSize.Y)
			end)

			function ColorFunc:Set(color)
				local H, S, V = color:ToHSV()
				ColorH, ColorS, ColorV = H, S, V
				HueSelection.Position = UDim2.new(0.48, 0, 1 - ColorH, 0)
				ColorSelection.Position = UDim2.new(ColorS, 0, 1 - ColorV, 0)
				UpdateColorPicker()
			end

			function ColorFunc:Save()
				if EnableSaving then
					local tc = BoxColor.BackgroundColor3
					_saveState(colorpickid, "ColorPicker", { tc.R, tc.G, tc.B }, RainbowColorPicker)
				else
					warn("Saving is not enabled!")
				end
			end

			if EnableSaving then
				local loadvalue = _loadState(colorpickid, "ColorPicker")
				if loadvalue then
					local h, s, v = unpack(loadvalue[1])
					ColorFunc:Set(Color3.fromRGB(h * 255, s * 255, v * 255))
					if loadvalue[2] == true then
						rainbowfunc()
					end
				end
			end

			return ColorFunc
		end

		function ContainerContent:Line()
			local Line = Instance.new("TextButton")
			local LineCorner = Instance.new("UICorner")

			Line.Name = "Line"
			Line.Parent = Container
			Line.BackgroundColor3 = Color3.fromRGB(64, 68, 75)
			Line.ClipsDescendants = true
			Line.Position = UDim2.new(0, 0, 0.70091325, 0)
			Line.Size = UDim2.new(0, 457, 0, 4)
			Line.AutoButtonColor = false
			Line.Font = Enum.Font.SourceSans
			Line.Text = ""
			Line.TextColor3 = Color3.fromRGB(0, 0, 0)
			Line.TextSize = 14.000

			LineCorner.CornerRadius = UDim.new(0, 4)
			LineCorner.Name = "LineCorner"
			LineCorner.Parent = Line

			Container.CanvasSize = UDim2.new(0, 0, 0, ContainerLayout.AbsoluteContentSize.Y)
		end
		function ContainerContent:Label(text)
			local LabelFunc = {}
			local Label = Instance.new("TextButton")
			local LabelCorner = Instance.new("UICorner")
			local Title = Instance.new("TextLabel")

			Label.Name = "Label"
			Label.Parent = Container
			Label.BackgroundColor3 = Color3.fromRGB(64, 68, 75)
			Label.ClipsDescendants = true
			Label.Position = UDim2.new(0.370312512, 0, 0.552631557, 0)
			Label.Size = UDim2.new(0, 457, 0, 43)
			Label.AutoButtonColor = false
			Label.Font = Enum.Font.SourceSans
			Label.Text = ""
			Label.TextColor3 = Color3.fromRGB(0, 0, 0)
			Label.TextSize = 14.000

			LabelCorner.CornerRadius = UDim.new(0, 4)
			LabelCorner.Name = "LabelCorner"
			LabelCorner.Parent = Label

			Title.Name = "Title"
			Title.Parent = Label
			Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Title.BackgroundTransparency = 1.000
			Title.Position = UDim2.new(0.038480062, 0, 0, 0)
			Title.Size = UDim2.new(0, 113, 0, 42)
			Title.Font = Enum.Font.Gotham
			Title.Text = text
			Title.TextColor3 = Color3.fromRGB(255, 255, 255)
			Title.TextSize = 15.000
			Title.TextTransparency = 0.300
			Title.TextXAlignment = Enum.TextXAlignment.Left

			Container.CanvasSize = UDim2.new(0, 0, 0, ContainerLayout.AbsoluteContentSize.Y)

			function LabelFunc:Set(msg)
				Title.Text = msg
			end

			return LabelFunc
		end
		function ContainerContent:Textbox(textboxId, text, desc, disapper, callback)
			if desc == "" then
				desc = "There is no description for this textbox."
			end
			local TextboxFunc = {}
			local TextboxDescToggled = false
			local Textbox = Instance.new("TextButton")
			local TextboxCorner = Instance.new("UICorner")
			local Title = Instance.new("TextLabel")
			local Circle = Instance.new("Frame")
			local CircleCorner = Instance.new("UICorner")
			local CircleSmall = Instance.new("Frame")
			local CircleSmallCorner = Instance.new("UICorner")
			local Description = Instance.new("TextLabel")
			local TextboxFrame = Instance.new("Frame")
			local TextboxFrameCorner = Instance.new("UICorner")
			local TextBox = Instance.new("TextBox")
			local ArrowBtn = Instance.new("ImageButton")
			local ArrowIco = Instance.new("ImageLabel")

			Textbox.Name = "Textbox"
			Textbox.Parent = Container
			Textbox.BackgroundColor3 = Color3.fromRGB(64, 68, 75)
			Textbox.ClipsDescendants = true
			Textbox.Position = UDim2.new(0.0459499061, 0, 0.734449744, 0)
			Textbox.Size = UDim2.new(0, 457, 0, 43)
			Textbox.AutoButtonColor = false
			Textbox.Font = Enum.Font.SourceSans
			Textbox.Text = ""
			Textbox.TextColor3 = Color3.fromRGB(0, 0, 0)
			Textbox.TextSize = 14.000

			TextboxCorner.CornerRadius = UDim.new(0, 4)
			TextboxCorner.Name = "TextboxCorner"
			TextboxCorner.Parent = Textbox

			Title.Name = "Title"
			Title.Parent = Textbox
			Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Title.BackgroundTransparency = 1.000
			Title.Position = UDim2.new(0.0822437406, 0, 0, 0)
			Title.Size = UDim2.new(0, 113, 0, 42)
			Title.Font = Enum.Font.Gotham
			Title.Text = text
			Title.TextColor3 = Color3.fromRGB(255, 255, 255)
			Title.TextSize = 15.000
			Title.TextTransparency = 0.300
			Title.TextXAlignment = Enum.TextXAlignment.Left

			Circle.Name = "Circle"
			Circle.Parent = Title
			Circle.Active = true
			Circle.AnchorPoint = Vector2.new(0.5, 0.5)
			Circle.BackgroundColor3 = Color3.fromRGB(211, 211, 211)
			Circle.Position = UDim2.new(-0.150690272, 0, 0.503000021, 0)
			Circle.Size = UDim2.new(0, 11, 0, 11)

			CircleCorner.CornerRadius = UDim.new(2, 6)
			CircleCorner.Name = "CircleCorner"
			CircleCorner.Parent = Circle

			CircleSmall.Name = "CircleSmall"
			CircleSmall.Parent = Circle
			CircleSmall.Active = true
			CircleSmall.AnchorPoint = Vector2.new(0.5, 0.5)
			CircleSmall.BackgroundColor3 = Color3.fromRGB(64, 68, 75)
			CircleSmall.BackgroundTransparency = 1.000
			CircleSmall.Position = UDim2.new(0.485673368, 0, 0.503000021, 0)
			CircleSmall.Size = UDim2.new(0, 9, 0, 9)

			CircleSmallCorner.CornerRadius = UDim.new(2, 6)
			CircleSmallCorner.Name = "CircleSmallCorner"
			CircleSmallCorner.Parent = CircleSmall

			Description.Name = "Description"
			Description.Parent = Title
			Description.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Description.BackgroundTransparency = 1.000
			Description.Position = UDim2.new(-0.200942323, 0, 0.985714269, 0)
			Description.Size = UDim2.new(0, 432, 0, 31)
			Description.Font = Enum.Font.Gotham
			Description.Text = desc
			Description.TextColor3 = Color3.fromRGB(255, 255, 255)
			Description.TextSize = 15.000
			Description.TextTransparency = 1
			Description.TextWrapped = true
			Description.TextXAlignment = Enum.TextXAlignment.Left

			TextboxFrame.Name = "TextboxFrame"
			TextboxFrame.Parent = Title
			TextboxFrame.BackgroundColor3 = Color3.fromRGB(50, 53, 59)
			TextboxFrame.Position = UDim2.new(1.82300889, 0, 0.202380955, 0)
			TextboxFrame.Size = UDim2.new(0, 161, 0, 26)

			TextboxFrameCorner.CornerRadius = UDim.new(0, 4)
			TextboxFrameCorner.Name = "TextboxFrameCorner"
			TextboxFrameCorner.Parent = TextboxFrame

			TextBox.Parent = TextboxFrame
			TextBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			TextBox.BackgroundTransparency = 1.000
			TextBox.Size = UDim2.new(0, 161, 0, 26)
			TextBox.Font = Enum.Font.Gotham
			TextBox.Text = ""
			TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
			TextBox.TextSize = 15.000
			TextBox.TextTransparency = 0.300

			ArrowBtn.Name = "ArrowBtn"
			ArrowBtn.Parent = Textbox
			ArrowBtn.BackgroundColor3 = Color3.fromRGB(86, 86, 86)
			ArrowBtn.BackgroundTransparency = 1.000
			ArrowBtn.Position = UDim2.new(0.903719902, 0, 0, 0)
			ArrowBtn.Size = UDim2.new(0, 33, 0, 37)
			ArrowBtn.SliceCenter = Rect.new(30, 30, 30, 30)
			ArrowBtn.SliceScale = 7.000

			ArrowIco.Name = "ArrowIco"
			ArrowIco.Parent = ArrowBtn
			ArrowIco.AnchorPoint = Vector2.new(0.5, 0.5)
			ArrowIco.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			ArrowIco.BackgroundTransparency = 1.000
			ArrowIco.Position = UDim2.new(0.495753437, 0, 0.554054081, 0)
			ArrowIco.Selectable = true
			ArrowIco.Size = UDim2.new(0, 28, 0, 24)
			ArrowIco.Image = "http://www.roblox.com/asset/?id=6034818372"

			if EnableSaving and _loadState(textboxId, "TextBox") then
				TextBox.Text = _loadState(textboxId, "TextBox")
				if #TextBox.Text > 0 then
					pcall(callback, TextBox.Text)
					if disapper then
						TextBox.Text = ""
					end
				end
			end

			connectionManager:NewConnection(TextBox.FocusLost, function(ep)
				if ep then
					if #TextBox.Text > 0 then
						pcall(callback, TextBox.Text)
						if disapper then
							TextBox.Text = ""
						end
					end
				end
			end)

			connectionManager:NewConnection(ArrowBtn.MouseButton1Click, function()
				if TextboxDescToggled == false then
					getgenv.changeTextboxColor = function()
						repeat
							wait()
						until TextboxDescToggled == true
						repeat
							wait()
							TweenService:Create(Title, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextColor3 = getgenv.PresetColor }):Play()
							TweenService:Create(ArrowIco, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { ImageColor3 = getgenv.PresetColor }):Play()
							TweenService:Create(Circle, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundColor3 = getgenv.PresetColor }):Play()
						until TextboxDescToggled == false
						TweenService:Create(Title, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextColor3 = Color3.fromRGB(255, 255, 255) }):Play()
						TweenService:Create(ArrowIco, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { ImageColor3 = Color3.fromRGB(255, 255, 255) }):Play()
						TweenService:Create(ArrowIco, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { ImageTransparency = 0.3 }):Play()
						TweenService:Create(ArrowIco, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Rotation = 0 }):Play()
						TweenService:Create(Circle, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundColor3 = Color3.fromRGB(211, 211, 211) }):Play()
						TweenService:Create(CircleSmall, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 1 }):Play()
						TweenService:Create(Title, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0.3 }):Play()
						TweenService:Create(Description, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 1 }):Play()
					end
					coroutine.wrap(getgenv.changeTextboxColor)()
					Textbox:TweenSize(UDim2.new(0, 457, 0, 81), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.6, true)
					TweenService:Create(Title, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextColor3 = getgenv.PresetColor }):Play()
					TweenService:Create(ArrowIco, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { ImageColor3 = getgenv.PresetColor }):Play()
					TweenService:Create(ArrowIco, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { ImageTransparency = 0 }):Play()
					TweenService:Create(ArrowIco, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Rotation = 180 }):Play()
					TweenService:Create(Circle, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundColor3 = getgenv.PresetColor }):Play()
					TweenService:Create(CircleSmall, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 0 }):Play()
					TweenService:Create(Title, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0 }):Play()
					TweenService:Create(Description, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0.3 }):Play()
					wait(0.4)
					Container.CanvasSize = UDim2.new(0, 0, 0, ContainerLayout.AbsoluteContentSize.Y)
				else
					Textbox:TweenSize(UDim2.new(0, 457, 0, 43), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.6, true)
					wait(0.4)
					Container.CanvasSize = UDim2.new(0, 0, 0, ContainerLayout.AbsoluteContentSize.Y)
				end
				TextboxDescToggled = not TextboxDescToggled
			end)
			Container.CanvasSize = UDim2.new(0, 0, 0, ContainerLayout.AbsoluteContentSize.Y)

			function TextboxFunc:Save()
				if EnableSaving then
					_saveState(textboxId, "TextBox", TextBox.Text)
				else
					warn("Saving is not enabled!")
				end
			end

			function TextboxFunc:Set(val)
				TextBox.Text = tostring(val)
				pcall(callback, val)
				return TextboxFunc
			end

			return TextboxFunc
		end
		function ContainerContent:Bind(bindId, text, presetbind, callback)
			local BindFunc = {}
			local Key = presetbind.Name

			if EnableSaving and _loadState(bindId, "Bind") then
				Key = _loadState(bindId, "Bind")
			end

			local Bind = Instance.new("TextButton")
			local BindCorner = Instance.new("UICorner")
			local Title = Instance.new("TextLabel")
			local Circle = Instance.new("Frame")
			local CircleCorner = Instance.new("UICorner")
			local CircleSmall = Instance.new("Frame")
			local CircleSmallCorner = Instance.new("UICorner")
			local BindLabel = Instance.new("TextLabel")

			Bind.Name = "Bind"
			Bind.Parent = Container
			Bind.BackgroundColor3 = Color3.fromRGB(64, 68, 75)
			Bind.ClipsDescendants = true
			Bind.Position = UDim2.new(0.40625, 0, 0.828947306, 0)
			Bind.Size = UDim2.new(0, 457, 0, 43)
			Bind.AutoButtonColor = false
			Bind.Font = Enum.Font.SourceSans
			Bind.Text = ""
			Bind.TextColor3 = Color3.fromRGB(0, 0, 0)
			Bind.TextSize = 14.000

			BindCorner.CornerRadius = UDim.new(0, 4)
			BindCorner.Name = "BindCorner"
			BindCorner.Parent = Bind

			Title.Name = "Title"
			Title.Parent = Bind
			Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Title.BackgroundTransparency = 1.000
			Title.Position = UDim2.new(0.0822437406, 0, 0, 0)
			Title.Size = UDim2.new(0, 113, 0, 42)
			Title.Font = Enum.Font.Gotham
			Title.Text = text
			Title.TextColor3 = Color3.fromRGB(255, 255, 255)
			Title.TextSize = 15.000
			Title.TextTransparency = 0.300
			Title.TextXAlignment = Enum.TextXAlignment.Left

			Circle.Name = "Circle"
			Circle.Parent = Title
			Circle.Active = true
			Circle.AnchorPoint = Vector2.new(0.5, 0.5)
			Circle.BackgroundColor3 = Color3.fromRGB(211, 211, 211)
			Circle.Position = UDim2.new(-0.150690272, 0, 0.503000021, 0)
			Circle.Size = UDim2.new(0, 11, 0, 11)

			CircleCorner.CornerRadius = UDim.new(2, 6)
			CircleCorner.Name = "CircleCorner"
			CircleCorner.Parent = Circle

			CircleSmall.Name = "CircleSmall"
			CircleSmall.Parent = Circle
			CircleSmall.Active = true
			CircleSmall.AnchorPoint = Vector2.new(0.5, 0.5)
			CircleSmall.BackgroundColor3 = Color3.fromRGB(64, 68, 75)
			CircleSmall.BackgroundTransparency = 1.000
			CircleSmall.Position = UDim2.new(0.485673368, 0, 0.503000021, 0)
			CircleSmall.Size = UDim2.new(0, 9, 0, 9)

			CircleSmallCorner.CornerRadius = UDim.new(2, 6)
			CircleSmallCorner.Name = "CircleSmallCorner"
			CircleSmallCorner.Parent = CircleSmall

			BindLabel.Name = "BindLabel"
			BindLabel.Parent = Title
			BindLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			BindLabel.BackgroundTransparency = 1.000
			BindLabel.Position = UDim2.new(2.56011987, 0, 0, 0)
			BindLabel.Size = UDim2.new(0, 113, 0, 42)
			BindLabel.Font = Enum.Font.Gotham
			BindLabel.Text = Key
			BindLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
			BindLabel.TextSize = 15.000
			BindLabel.TextTransparency = 0.300
			BindLabel.TextXAlignment = Enum.TextXAlignment.Right

			connectionManager:NewConnection(Bind.MouseEnter, function()
				TweenService:Create(Title, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0 }):Play()
			end)

			connectionManager:NewConnection(Bind.MouseLeave, function()
				TweenService:Create(Title, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0.3 }):Play()
			end)

			connectionManager:NewConnection(Bind.MouseButton1Click, function()
				hasInputBegan = false
				getgenv.changeBindColor = function()
					repeat
						wait()
						TweenService:Create(Title, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextColor3 = getgenv.PresetColor }):Play()
						TweenService:Create(BindLabel, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextColor3 = getgenv.PresetColor }):Play()
						TweenService:Create(Circle, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundColor3 = getgenv.PresetColor }):Play()
						connectionManager:NewConnection(GetService("UserInputService").InputBegan, function()
							hasInputBegan = true
						end)
					until hasInputBegan == true
					TweenService:Create(Title, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextColor3 = Color3.fromRGB(255, 255, 255) }):Play()
					TweenService:Create(BindLabel, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextColor3 = Color3.fromRGB(255, 255, 255) }):Play()
					TweenService:Create(Circle, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundColor3 = Color3.fromRGB(211, 211, 211) }):Play()
					TweenService:Create(CircleSmall, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 1 }):Play()
					TweenService:Create(Title, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0.3 }):Play()
					TweenService:Create(BindLabel, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0.3 }):Play()
				end
				coroutine.wrap(getgenv.changeBindColor)()
				TweenService:Create(Title, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextColor3 = getgenv.PresetColor }):Play()
				TweenService:Create(BindLabel, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextColor3 = getgenv.PresetColor }):Play()
				TweenService:Create(Circle, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundColor3 = getgenv.PresetColor }):Play()
				TweenService:Create(CircleSmall, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 0 }):Play()
				TweenService:Create(Title, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0 }):Play()
				TweenService:Create(BindLabel, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0 }):Play()
				BindLabel.Text = "..."
				local inputwait = GetService("UserInputService").InputBegan:wait()
				if inputwait.KeyCode.Name ~= "Unknown" then
					BindLabel.Text = inputwait.KeyCode.Name
					Key = inputwait.KeyCode.Name
					isKeyLeft = false
				end
				GetService("UserInputService").InputEnded:wait()
				isKeyLeft = true
			end)

			connectionManager:NewConnection(GetService("UserInputService").InputBegan, function(current, pressed)
				if isKeyLeft == true then
					if not pressed then
						if current.KeyCode.Name == Key then
							pcall(callback)
						end
					end
				end
			end)

			Container.CanvasSize = UDim2.new(0, 0, 0, ContainerLayout.AbsoluteContentSize.Y)

			function BindFunc:Save()
				if EnableSaving then
					_saveState(bindId, "Bind", BindLabel.Text ~= "..." and BindLabel.Text or presetbind.Name)
				else
					warn("Saving is not enabled!")
				end
			end

			return BindFunc
		end
		return ContainerContent
	end

	function Tabs:Remove()
		FluxLib:Destroy()
		for i, v in next, connectionManager:GetAllConnections() do
			if typeof(v) ~= "RBXScriptConnection" and v.Connected == false then
				continue
			end

			v:Disable()
			v = nil
		end
	end

	function Tabs:ChangeColor(color)
		for i, v in pairs(FluxLib:GetDescendants()) do
			if v.Name == "Tab" and v.Parent.Name == "TabHold" then
				v.BackgroundColor3 = color
			elseif v.Name == "CurrentValueFrame" and v.Parent.Name == "SlideFrame" then
				v.BackgroundColor3 = color
			elseif v.Name == "SlideCircle" and v.Parent.Name == "SlideFrame" then
				v.ImageColor3 = color
			end
		end
	end

	return Tabs
end

return Flux

-- local window = Flux:Window({
-- 	["replaceOld"] = true, -- optional default: false  |  Replaces old Flux Window
-- 	["enableSaving"] = true, -- optional default: false  |  Allows for config saving
-- 	["Title"] = "Flux Hub", -- required
-- 	["Description"] = "Fluxlib", -- required
-- 	["mainclr"] = Color3.fromRGB(66, 134, 255), -- optional default: Color3.fromRGB(66, 134, 255)  |  Main color for the gui
-- 	["SaveFolder"] = "", -- optional default: '' aka no folder  |  Name for the folder where save file is located
-- 	["SaveFile"] = "FluxHub", -- required (ONLY IF "enableSaving" IS TRUE)  |  Name for the save file
-- })

-- local tab = window:Tab("Test")

-- local slider = tab:Slider("Test", "Test", "Test", 0, 100, 0, function(t)
-- 	print(t)
-- end):SetIncrement(10)

-- local color = tab:Colorpicker("Test", "Test", Color3.fromRGB(255, 0, 0), function(t)
--     print(t)
-- end)

-- local toggle = tab:Toggle("Test", "Test",'test', false, function(t)
--     print(t)
-- end)

-- local button = tab:Button("Test",'test', function()
--     print("Test")
-- end)

-- local textbox = tab:Textbox("Test", "Test", 'test', function(t)
--     print(t)
-- end)