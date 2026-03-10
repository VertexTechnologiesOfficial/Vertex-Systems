--[[


██╗   ██╗███████╗██████╗ ████████╗███████╗██╗  ██╗
██║   ██║██╔════╝██╔══██╗╚══██╔══╝██╔════╝╚██╗██╔╝
██║   ██║█████╗  ██████╔╝   ██║   █████╗   ╚███╔╝ 
╚██╗ ██╔╝██╔══╝  ██╔══██╗   ██║   ██╔══╝   ██╔██╗ 
 ╚████╔╝ ███████╗██║  ██║   ██║   ███████╗██╔╝ ██╗
  ╚═══╝  ╚══════╝╚═╝  ╚═╝   ╚═╝   ╚══════╝╚═╝  ╚═╝
                                                     
Vertex UI Library - Modern, Clean, Fast
by Nebula Softworks

]]

local Release = "1.0.0"

local Vertex = { 
	Folder = "Vertex", 
	Options = {}, 
	Theme = {
		Accent = Color3.fromRGB(98, 114, 255),
		Background = Color3.fromRGB(18, 20, 25),
		Surface = Color3.fromRGB(26, 28, 34),
		Border = Color3.fromRGB(42, 45, 52),
		Text = Color3.fromRGB(220, 225, 235),
		TextSecondary = Color3.fromRGB(150, 155, 165),
		Danger = Color3.fromRGB(255, 89, 94),
		Success = Color3.fromRGB(80, 200, 120),
		Warning = Color3.fromRGB(255, 180, 70)
	}
}

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local CoreGui = game:GetService("CoreGui")

local isStudio = RunService:IsStudio()
local TweenInfo_Default = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

-- Utility Functions
local function tween(object, goal, callback)
	local t = TweenService:Create(object, TweenInfo_Default, goal)
	t.Completed:Connect(callback or function() end)
	t:Play()
end

local function Kwargify(defaults, passed)
	for i, v in pairs(defaults) do
		if passed[i] == nil then
			passed[i] = v
		end
	end
	return passed
end

-- Icon Module (Simplified)
local Icons = {
	home = "rbxassetid://6031097225",
	settings = "rbxassetid://6031280882",
	user = "rbxassetid://6034287594",
	discord = "rbxassetid://6034754445",
	close = "rbxassetid://6031094678",
	maximize = "rbxassetid://11036884234",
	minimize = "rbxassetid://10137941941",
	chevron_down = "rbxassetid://6031094687",
	chevron_right = "rbxassetid://6031094680",
	check = "rbxassetid://6031094667",
	sliders = "rbxassetid://6031734877",
	palette = "rbxassetid://6034316009",
	download = "rbxassetid://6031302931",
	upload = "rbxassetid://6031302959",
	refresh = "rbxassetid://6031097226",
	trash = "rbxassetid://6022668885",
	plus = "rbxassetid://6035047377"
}

-- Main UI Container
local VertexUI = isStudio and script.Parent:WaitForChild("Vertex UI") or game:GetObjects("rbxassetid://1234567890")[1] -- Replace with your asset ID

if gethui then
	VertexUI.Parent = gethui()
elseif syn and syn.protect_gui then 
	syn.protect_gui(VertexUI)
	VertexUI.Parent = CoreGui
elseif not isStudio then
	VertexUI.Parent = CoreGui
end

VertexUI.Enabled = false
VertexUI.DisplayOrder = 1000000000

-- Main References
local Main = VertexUI.Main
local Notifications = VertexUI.Notifications
local Dragger = Main.DragArea
local Elements = Main.Elements
local Tabs = Main.Navigation.Tabs
local LoadingScreen = Main.Loading

-- Hide existing instances
for _, v in ipairs(VertexUI:GetDescendants()) do
	if v:IsA("Frame") or v:IsA("TextLabel") or v:IsA("ImageLabel") then
		v.Visible = false
	end
end

-- Notification System
function Vertex:Notify(data)
	task.spawn(function()
		data = Kwargify({
			Title = "Notification",
			Content = "",
			Duration = 3,
			Type = "info" -- info, success, warning, error
		}, data or {})

		local notif = VertexUI.Notifications.Template:Clone()
		notif.Parent = VertexUI.Notifications
		notif.Visible = true
		notif.LayoutOrder = #VertexUI.Notifications:GetChildren()
		
		-- Set colors based on type
		local colors = {
			info = Vertex.Theme.Accent,
			success = Vertex.Theme.Success,
			warning = Vertex.Theme.Warning,
			error = Vertex.Theme.Danger
		}
		
		notif.Icon.BackgroundColor3 = colors[data.Type] or Vertex.Theme.Accent
		notif.Title.Text = data.Title
		notif.Content.Text = data.Content
		
		-- Animation
		notif.Position = UDim2.new(1, 20, 0, 0)
		notif.BackgroundTransparency = 1
		notif.Title.TextTransparency = 1
		notif.Content.TextTransparency = 1
		notif.Icon.ImageTransparency = 1
		
		tween(notif, {Position = UDim2.new(1, -320, 0, 0), BackgroundTransparency = 0})
		tween(notif.Title, {TextTransparency = 0})
		tween(notif.Content, {TextTransparency = 0})
		tween(notif.Icon, {ImageTransparency = 0})
		
		task.wait(data.Duration)
		
		tween(notif, {Position = UDim2.new(1, 20, 0, 0), BackgroundTransparency = 1})
		task.wait(0.25)
		notif:Destroy()
	end)
end

-- Dragging Function
local function MakeDraggable(dragBar, window)
	local dragging = false
	local dragInput, dragStart, startPos
	
	dragBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = window.Position
			
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	
	dragBar.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)
	
	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
end

-- Window Creation
function Vertex:CreateWindow(config)
	config = Kwargify({
		Name = "Vertex UI",
		Subtitle = "",
		Icon = "rbxassetid://6031097225",
		Theme = "Dark",
		KeySystem = false,
		KeySettings = {
			Title = "Vertex | Key System",
			Subtitle = "Enter your key",
			Note = "",
			Keys = {"12345"},
			SaveKey = true
		}
	}, config or {})

	local Window = {
		CurrentTab = nil,
		Visible = true,
		Size = "Normal",
		Bind = Enum.KeyCode.RightShift
	}

	-- Setup UI
	Main.Visible = true
	Main.Title.Text = config.Name
	Main.Subtitle.Text = config.Subtitle
	Main.Icon.Image = config.Icon
	
	-- Apply theme
	Main.BackgroundColor3 = Vertex.Theme.Surface
	Main.BorderStroke.Color = Vertex.Theme.Border
	Main.Navigation.BackgroundColor3 = Vertex.Theme.Background
	
	-- Loading Screen
	if config.LoadingEnabled ~= false then
		LoadingScreen.Visible = true
		LoadingScreen.Title.Text = config.LoadingTitle or "Vertex UI"
		LoadingScreen.Subtitle.Text = config.LoadingSubtitle or "Loading..."
		
		task.wait(1.5)
		tween(LoadingScreen, {BackgroundTransparency = 1})
		task.wait(0.3)
		LoadingScreen.Visible = false
	end

	-- Key System
	if config.KeySystem then
		local KeyFrame = VertexUI.KeySystem
		KeyFrame.Visible = true
		KeyFrame.Title.Text = config.KeySettings.Title
		KeyFrame.Subtitle.Text = config.KeySettings.Subtitle
		KeyFrame.Note.Text = config.KeySettings.Note
		
		local success = false
		local attempts = 3
		
		-- Check saved key
		if isfile and config.KeySettings.SaveKey then
			local path = "Vertex/keys/" .. game.PlaceId .. ".key"
			if isfile(path) then
				local saved = readfile(path)
				for _, key in ipairs(config.KeySettings.Keys) do
					if saved == key then
						success = true
						break
					end
				end
			end
		end
		
		if success then
			KeyFrame.Visible = false
		else
			KeyFrame.Input.InputBox.Focus()
			
			KeyFrame.Submit.MouseButton1Click:Connect(function()
				local input = KeyFrame.Input.InputBox.Text
				local valid = false
				
				for _, key in ipairs(config.KeySettings.Keys) do
					if input == key then
						valid = true
						break
					end
				end
				
				if valid then
					if isfile and config.KeySettings.SaveKey then
						local path = "Vertex/keys/" .. game.PlaceId .. ".key"
						writefile(path, input)
					end
					
					tween(KeyFrame, {BackgroundTransparency = 1})
					task.wait(0.3)
					KeyFrame.Visible = false
				else
					attempts = attempts - 1
					KeyFrame.Input.InputBox.Text = ""
					KeyFrame.Note.Text = "Invalid key! " .. attempts .. " attempts remaining"
					
					if attempts <= 0 then
						Player:Kick("No attempts remaining")
					end
				end
			end)
			
			KeyFrame.Close.MouseButton1Click:Connect(function()
				Vertex:Destroy()
			end)
		end
	end

	-- Dragging
	MakeDraggable(Dragger, Main)

	-- Window Controls
	Main.Controls.Close.MouseButton1Click:Connect(function()
		Window.Visible = false
		Main.Visible = false
		VertexUI.MobileButton.Visible = true
	end)

	Main.Controls.ToggleSize.MouseButton1Click:Connect(function()
		if Window.Size == "Normal" then
			Window.Size = "Minimized"
			Main.Elements.Visible = false
			Main.Navigation.Visible = false
			Main.Size = UDim2.fromOffset(500, 42)
		else
			Window.Size = "Normal"
			Main.Elements.Visible = true
			Main.Navigation.Visible = true
			Main.Size = UDim2.fromOffset(700, 450)
		end
	end)

	-- Mobile Button
	VertexUI.MobileButton.MouseButton1Click:Connect(function()
		Window.Visible = true
		Main.Visible = true
		VertexUI.MobileButton.Visible = false
	end)

	-- Keybind Toggle
	UserInputService.InputBegan:Connect(function(input, gpe)
		if gpe or Window.Visible then return end
		if input.KeyCode == Window.Bind then
			Window.Visible = true
			Main.Visible = true
			VertexUI.MobileButton.Visible = false
		end
	end)

	-- Home Tab
	function Window:CreateHomeTab(settings)
		settings = Kwargify({
			Icon = "home",
			Discord = "",
			Executors = {"Synapse", "ScriptWare", "Krnl"}
		}, settings or {})

		local homeTab = Main.Navigation.Tabs.Home
		homeTab.Visible = true
		homeTab.Icon.Image = Icons.home
		homeTab.Title.Text = "Home"

		local homePage = Main.Elements.Home
		homePage.Visible = true

		-- User Info
		homePage.Avatar.Image = Players:GetUserThumbnailAsync(Player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
		homePage.Welcome.Text = "Welcome back, " .. Player.DisplayName
		homePage.Username.Text = "@" .. Player.Name

		-- Server Info Updates
		coroutine.wrap(function()
			while task.wait(1) do
				homePage.ServerInfo.Players.Text = #Players:GetPlayers() .. " / " .. Players.MaxPlayers
				homePage.ServerInfo.Ping.Text = math.floor(Player:GetNetworkPing() * 1000) .. "ms"
				homePage.ServerInfo.Time.Text = os.date("%H:%M:%S")
			end
		end)()

		-- Discord
		if settings.Discord ~= "" then
			homePage.Discord.MouseButton1Click:Connect(function()
				setclipboard("https://discord.gg/" .. settings.Discord)
				Vertex:Notify({Title = "Discord", Content = "Invite copied to clipboard!"})
			end)
		end

		homeTab.Interact.MouseButton1Click:Connect(function()
			Window:SwitchTab(homeTab, homePage)
		end)

		return homePage
	end

	-- Tab Creation
	function Window:CreateTab(settings)
		settings = Kwargify({
			Name = "Tab",
			Icon = "settings",
			ShowTitle = true
		}, settings or {})

		local Tab = { Elements = {} }

		-- Tab Button
		local tabButton = Main.Navigation.Tabs.Template:Clone()
		tabButton.Name = settings.Name
		tabButton.Title.Text = settings.Name
		tabButton.Icon.Image = Icons[settings.Icon] or Icons.settings
		tabButton.Visible = true
		tabButton.Parent = Main.Navigation.Tabs

		-- Tab Page
		local tabPage = Main.Elements.Template:Clone()
		tabPage.Name = settings.Name
		tabPage.Title.Visible = settings.ShowTitle
		tabPage.Title.Text = settings.Name
		tabPage.Visible = true
		tabPage.Parent = Main.Elements

		-- Clean up templates
		for _, v in ipairs(tabPage:GetChildren()) do
			if v:IsA("Frame") and v.Name ~= "Title" then
				v:Destroy()
			end
		end

		-- Switch Tab
		function Window:SwitchTab(button, page)
			for _, btn in ipairs(Main.Navigation.Tabs:GetChildren()) do
				if btn:IsA("Frame") and btn.Name ~= "Template" then
					tween(btn, {BackgroundTransparency = 1})
					tween(btn.Icon, {ImageColor3 = Vertex.Theme.TextSecondary})
				end
			end
			
			tween(button, {BackgroundTransparency = 0})
			tween(button.Icon, {ImageColor3 = Vertex.Theme.Accent})
			Main.Elements.UIPageLayout:JumpTo(page)
			Window.CurrentTab = settings.Name
		end

		tabButton.Interact.MouseButton1Click:Connect(function()
			Window:SwitchTab(tabButton, tabPage)
		end)

		if not Window.CurrentTab then
			Window:SwitchTab(tabButton, tabPage)
		end

		-- Section Creator
		function Tab:CreateSection(name)
			local section = {}
			
			local sectionLabel = Instance.new("TextLabel")
			sectionLabel.Name = name
			sectionLabel.Text = name
			sectionLabel.Size = UDim2.new(1, -20, 0, 20)
			sectionLabel.Position = UDim2.new(0, 10, 0, 5)
			sectionLabel.BackgroundTransparency = 1
			sectionLabel.TextColor3 = Vertex.Theme.TextSecondary
			sectionLabel.Font = Enum.Font.GothamSemibold
			sectionLabel.TextSize = 14
			sectionLabel.TextXAlignment = Enum.TextXAlignment.Left
			sectionLabel.Parent = tabPage

			local sectionFrame = Instance.new("Frame")
			sectionFrame.Name = name .. "_Content"
			sectionFrame.Size = UDim2.new(1, -20, 1, -30)
			sectionFrame.Position = UDim2.new(0, 10, 0, 30)
			sectionFrame.BackgroundTransparency = 1
			sectionFrame.Parent = tabPage

			-- Button
			function section:CreateButton(settings)
				settings = Kwargify({
					Name = "Button",
					Description = "",
					Callback = function() end
				}, settings or {})

				local btn = VertexUI.Templates.Button:Clone()
				btn.Title.Text = settings.Name
				btn.Desc.Text = settings.Description
				btn.Desc.Visible = settings.Description ~= ""
				btn.Size = UDim2.new(1, 0, 0, settings.Description ~= "" and 55 or 40)
				btn.Parent = sectionFrame

				btn.Interact.MouseButton1Click:Connect(settings.Callback)
				
				btn.MouseEnter:Connect(function()
					tween(btn, {BackgroundColor3 = Vertex.Theme.Background})
				end)
				
				btn.MouseLeave:Connect(function()
					tween(btn, {BackgroundColor3 = Vertex.Theme.Surface})
				end)

				return btn
			end

			-- Toggle
			function section:CreateToggle(settings, flag)
				settings = Kwargify({
					Name = "Toggle",
					Description = "",
					Default = false,
					Callback = function() end
				}, settings or {})

				local toggle = VertexUI.Templates.Toggle:Clone()
				toggle.Title.Text = settings.Name
				toggle.Desc.Text = settings.Description
				toggle.Desc.Visible = settings.Description ~= ""
				toggle.Size = UDim2.new(1, 0, 0, settings.Description ~= "" and 55 or 40)
				toggle.Parent = sectionFrame

				local function setState(state)
					if state then
						tween(toggle.Toggle, {BackgroundColor3 = Vertex.Theme.Accent})
						tween(toggle.Toggle.Knob, {Position = UDim2.new(1, -20, 0.5, 0)})
					else
						tween(toggle.Toggle, {BackgroundColor3 = Vertex.Theme.Border})
						tween(toggle.Toggle.Knob, {Position = UDim2.new(0, 3, 0.5, 0)})
					end
				end

				setState(settings.Default)

				toggle.Interact.MouseButton1Click:Connect(function()
					settings.Default = not settings.Default
					setState(settings.Default)
					settings.Callback(settings.Default)
				end)

				if flag then
					Vertex.Options[flag] = {
						Set = function(state)
							settings.Default = state
							setState(state)
						end,
						Get = function() return settings.Default end
					}
				end

				return toggle
			end

			-- Slider
			function section:CreateSlider(settings, flag)
				settings = Kwargify({
					Name = "Slider",
					Min = 0,
					Max = 100,
					Default = 50,
					Suffix = "",
					Callback = function() end
				}, settings or {})

				local slider = VertexUI.Templates.Slider:Clone()
				slider.Title.Text = settings.Name
				slider.Value.Text = settings.Default .. settings.Suffix
				slider.Parent = sectionFrame

				local dragging = false
				local function updatePosition(input)
					local pos = UDim2.new(math.clamp((input.Position.X - slider.Slider.AbsolutePosition.X) / slider.Slider.AbsoluteSize.X, 0, 1), 0, 0.5, 0)
					slider.Progress.Size = UDim2.new(pos.X.Scale, 0, 1, 0)
					
					local value = settings.Min + (pos.X.Scale * (settings.Max - settings.Min))
					value = math.floor(value * 100) / 100
					slider.Value.Text = value .. settings.Suffix
					settings.Callback(value)
				end

				slider.Slider.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						dragging = true
						updatePosition(input)
					end
				end)

				slider.Slider.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						dragging = false
					end
				end)

				UserInputService.InputChanged:Connect(function(input)
					if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
						updatePosition(input)
					end
				end)

				-- Set default
				local defaultPos = (settings.Default - settings.Min) / (settings.Max - settings.Min)
				slider.Progress.Size = UDim2.new(defaultPos, 0, 1, 0)

				return slider
			end

			-- Dropdown
			function section:CreateDropdown(settings, flag)
				settings = Kwargify({
					Name = "Dropdown",
					Options = {"Option 1", "Option 2"},
					Default = "Option 1",
					Callback = function() end
				}, settings or {})

				local dropdown = VertexUI.Templates.Dropdown:Clone()
				dropdown.Title.Text = settings.Name
				dropdown.Selected.Text = settings.Default
				dropdown.Parent = sectionFrame

				local open = false
				local function toggle()
					open = not open
					tween(dropdown, {Size = UDim2.new(1, 0, 0, open and 200 or 40)})
					tween(dropdown.Icon, {Rotation = open and 180 or 0})
				end

				dropdown.Interact.MouseButton1Click:Connect(toggle)

				for _, option in ipairs(settings.Options) do
					local btn = VertexUI.Templates.DropdownItem:Clone()
					btn.Text = option
					btn.Parent = dropdown.List
					
					btn.MouseButton1Click:Connect(function()
						dropdown.Selected.Text = option
						settings.Callback(option)
						toggle()
					end)
				end

				return dropdown
			end

			-- Input
			function section:CreateInput(settings, flag)
				settings = Kwargify({
					Name = "Input",
					Placeholder = "Enter text...",
					Default = "",
					Numeric = false,
					Callback = function() end
				}, settings or {})

				local input = VertexUI.Templates.Input:Clone()
				input.Title.Text = settings.Name
				input.InputBox.PlaceholderText = settings.Placeholder
				input.InputBox.Text = settings.Default
				input.Parent = sectionFrame

				if settings.Numeric then
					input.InputBox:GetPropertyChangedSignal("Text"):Connect(function()
						input.InputBox.Text = input.InputBox.Text:gsub("%D", "")
					end)
				end

				input.InputBox.FocusLost:Connect(function()
					settings.Callback(input.InputBox.Text)
				end)

				return input
			end

			-- Color Picker
			function section:CreateColorPicker(settings, flag)
				settings = Kwargify({
					Name = "Color",
					Default = Vertex.Theme.Accent,
					Callback = function() end
				}, settings or {})

				local picker = VertexUI.Templates.ColorPicker:Clone()
				picker.Title.Text = settings.Name
				picker.Preview.BackgroundColor3 = settings.Default
				picker.Parent = sectionFrame

				local open = false
				picker.Interact.MouseButton1Click:Connect(function()
					open = not open
					tween(picker, {Size = UDim2.new(1, 0, 0, open and 180 or 40)})
				end)

				-- Color wheel logic would go here
				-- (Simplified for this example)

				return picker
			end

			return section
		end

		return Tab
	end

	VertexUI.Enabled = true
	return Window
end

function Vertex:Destroy()
	VertexUI:Destroy()
end

return Vertex
