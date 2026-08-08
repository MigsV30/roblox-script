local Players = game:GetService("Players")
local Tween = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local UIS = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local PlayerGui = Player.PlayerGui

local CharactersFolder = Workspace:WaitForChild("Characters")

local TogglesState = {}

local AUTOFARMS = {
	PatrickGamemode = {
		StartPos = CFrame.new(6481, 14, -11725),
		Pos = {
			[1] = CFrame.new(9873, 16, -11164),
			[2] = CFrame.new(9983, 16, -11164),
			[3] = CFrame.new(10022, 16, -11097),
			[4] = CFrame.new(9950, 16, -10980),
			[5] = CFrame.new(9847, 16, -11097)
		},
		Start_CD = 20, -- Seconds
		TP_TIME = 1.5, -- Seconds
		ExitTime = 15, -- Minutes
		Wait_Rejoin = 5 -- Seconds
	}
}

local ON = Color3.fromRGB(0, 255, 45)
local OFF = Color3.fromRGB(208, 0, 0)

local ON_POS = UDim2.new(0.714, 0, 0.493, 0)
local OFF_POS = UDim2.new(0.295, 0, 0.493, 0)

------ MAIN UI ------
local UIEnabled = true

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = PlayerGui
ScreenGui.Name = "AF"
ScreenGui.IgnoreGuiInset = true
ScreenGui.ResetOnSpawn = false

UIS.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.RightControl then
		UIEnabled = not UIEnabled
		ScreenGui.Enabled = UIEnabled
	end
end)

local MainFrame = Instance.new("ImageLabel")
MainFrame.Parent = ScreenGui
MainFrame.Name = "MainFrame"
MainFrame.BackgroundTransparency = 1
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.Size = UDim2.new(0.309, 0, 0.275, 0)
MainFrame.Image = "rbxassetid://6328845323"
MainFrame.ScaleType = Enum.ScaleType.Fit

local UIAspectRatioConstraint1 = Instance.new("UIAspectRatioConstraint")
UIAspectRatioConstraint1.Parent = MainFrame
UIAspectRatioConstraint1.AspectRatio = 1.994
UIAspectRatioConstraint1.AspectType = Enum.AspectType.FitWithinMaxSize
UIAspectRatioConstraint1.DominantAxis = Enum.DominantAxis.Width

local UIScale1 = Instance.new("UIScale")
UIScale1.Parent = MainFrame
UIScale1.Scale = 1.5

local TitleBG = Instance.new("ImageLabel")
TitleBG.Parent = MainFrame
TitleBG.Name = "TitleBG"
TitleBG.BackgroundTransparency = 1
TitleBG.Position = UDim2.new(-0.031, 0, -0.088, 0)
TitleBG.Size = UDim2.new(0.882, 0, 0.302, 0)
TitleBG.Image = "rbxassetid://6328843440"
TitleBG.ScaleType = Enum.ScaleType.Fit

local TitleText = Instance.new("TextLabel")
TitleText.Parent = TitleBG
TitleText.Name = "Title"
TitleText.BackgroundTransparency = 1
TitleText.AnchorPoint = Vector2.new(0, 0.5)
TitleText.Position = UDim2.new(0.068, 0, 0.46, 0)
TitleText.Size = UDim2.new(0.5, 0, 0.35, 0)

TitleText.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)

TitleText.TextColor3 = Color3.fromRGB(0, 0, 0)
TitleText.Text = "Auto Farm"
TitleText.TextScaled = true
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.TextYAlignment = Enum.TextYAlignment.Center

------ SETTINGS UI ------

local SettingsFrame = Instance.new("ScrollingFrame")
SettingsFrame.Parent = MainFrame
SettingsFrame.Name = "Settings"
SettingsFrame.BackgroundTransparency = 1
SettingsFrame.AnchorPoint = Vector2.new(0.5, 0.5)
SettingsFrame.Position = UDim2.new(0.524, 0, 0.5, 0)
SettingsFrame.Size = UDim2.new(0.848, 0, 0.596, 0)
SettingsFrame.ClipsDescendants = true
SettingsFrame.ScrollBarImageTransparency = 1
SettingsFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
SettingsFrame.ScrollingDirection = Enum.ScrollingDirection.Y
SettingsFrame.CanvasSize = UDim2.new(0, 0, 0, 0)

local UIGridLayout = Instance.new("UIGridLayout")
UIGridLayout.Parent = SettingsFrame
UIGridLayout.CellSize = UDim2.new(0.98, -12, 0.145, 0)
UIGridLayout.CellPadding = UDim2.new(0, 0, 0.01, 0)
UIGridLayout.FillDirection = Enum.FillDirection.Horizontal
UIGridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
UIGridLayout.VerticalAlignment = Enum.VerticalAlignment.Top

------ AUTOFARM ------

local function GetRoot()
	local char = Player.Character
	if char and char.Parent == CharactersFolder then
		return char:FindFirstChild("HumanoidRootPart")
	end
end

local function PressE()
	print("Pressionando E")
	game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.E, false, game)
	task.wait(0.1)
	game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.E, false, game)
end

local function StartAutoFarm(modeName)
	task.spawn(function()
		local data = AUTOFARMS[modeName]

		if not data then
			warn("Modo não encontrado:", modeName)
			return
		end

		print("AutoFarm iniciado:", modeName)

		while TogglesState[modeName] do
			local root = GetRoot()

			if not root then
				warn("Root não encontrado")
				task.wait(1)
				continue
			end

			--==================================================
			-- 1. TELEPORTA PARA O START
			--==================================================

			print("Teleportando para StartPos...")
			root.CFrame = data.StartPos

			-- Espera o Start_CD
			print("Esperando Start_CD:", data.Start_CD, "segundos")

			local startWait = os.clock()

			while os.clock() - startWait < data.Start_CD do
				if not TogglesState[modeName] then
					break
				end

				task.wait()
			end

			if not TogglesState[modeName] then
				break
			end

			--==================================================
			-- 2. INICIA O FARM
			--==================================================

			print("Iniciando AutoFarm")

			local farmStart = os.clock()
			local exitTime = data.ExitTime * 60

			local positionIndex = 1

			while TogglesState[modeName] and (os.clock() - farmStart) < exitTime do
				local cf = data.Pos[positionIndex]

				if cf then
					root.CFrame = cf

					print(
						"TP:",
						positionIndex,
						"| Tempo restante:",
						math.max(0, math.floor(exitTime - (os.clock() - farmStart))),
						"segundos"
					)
				end

				positionIndex += 1

				-- Volta para a primeira posição
				if positionIndex > #data.Pos then
					positionIndex = 1
				end

				-- Espera o TP_TIME sem ultrapassar o ExitTime
				local tpWait = os.clock()

				while os.clock() - tpWait < data.TP_TIME do
					if not TogglesState[modeName] then
						break
					end

					-- Se o ExitTime acabou, não precisa continuar esperando
					if os.clock() - farmStart >= exitTime then
						break
					end

					task.wait()
				end
			end

			if not TogglesState[modeName] then
				break
			end

			--==================================================
			-- 3. FINALIZOU O EXIT TIME
			--==================================================

			print("ExitTime finalizado.")

			-- Volta para StartPos
			print("Voltando para StartPos...")
			root.CFrame = data.StartPos

			--==================================================
			-- 4. ESPERA WAIT_REJOIN
			--==================================================

			print("Esperando Wait_Rejoin:", data.Wait_Rejoin, "segundos")

			local rejoinWait = os.clock()

			while os.clock() - rejoinWait < data.Wait_Rejoin do
				if not TogglesState[modeName] then
					break
				end

				task.wait()
			end

			if not TogglesState[modeName] then
				break
			end

			-- Depois do Wait_Rejoin,
			-- volta automaticamente para o ciclo de farm.
			print("Reiniciando ciclo...")
		end

		print("AutoFarm finalizado:", modeName)
	end)
end

------ TOGGLE CREATOR ------

local function CreateToggle(text)
	local Enabled = false

	local Holder = Instance.new("Frame")
	Holder.Name = text
	Holder.Parent = SettingsFrame
	Holder.BackgroundTransparency = 1

	local Title = Instance.new("TextLabel")
	Title.Parent = Holder
	Title.Name = "Title"
	Title.BackgroundTransparency = 1
	Title.AnchorPoint = Vector2.new(0, 0.5)
	Title.Position = UDim2.new(0, 0, 0.5, 0)
	Title.Size = UDim2.new(0.521, 0, 0.685, 0)
	Title.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Bold)
	Title.TextColor3 = Color3.fromRGB(255, 255, 255)
	Title.Text = text
	Title.TextScaled = true
	Title.TextXAlignment = Enum.TextXAlignment.Left
	Title.TextStrokeColor3 = Color3.fromRGB(57, 57, 57)
	Title.TextStrokeTransparency = 0

	local Toggle = Instance.new("ImageButton")
	Toggle.Parent = Holder
	Toggle.Name = "Toggle"
	Toggle.AnchorPoint = Vector2.new(1, 0.5)
	Toggle.BackgroundTransparency = 1
	Toggle.Position = UDim2.new(1, 0, 0.5, 0)
	Toggle.Size = UDim2.new(0.222, 0, 0.855, 0)
	Toggle.Image = "http://www.roblox.com/asset/?id=6328983912"
	Toggle.ImageColor3 = OFF
	
	local UIAspectRatioConstraint2 = Instance.new("UIAspectRatioConstraint")
	UIAspectRatioConstraint2.Parent = Toggle
	UIAspectRatioConstraint2.AspectRatio = 2.873
	UIAspectRatioConstraint2.AspectType = Enum.AspectType.FitWithinMaxSize
	UIAspectRatioConstraint2.DominantAxis = Enum.DominantAxis.Width

	local BG = Instance.new("ImageLabel")
	BG.Parent = Toggle
	BG.Name = "Main"
	BG.BackgroundTransparency = 1
	BG.AnchorPoint = Vector2.new(0.5, 0.5)
	BG.Position = UDim2.new(0.5, 0, 0.5, 0)
	BG.Size = UDim2.new(0.94, 0, 0.88, 0)
	BG.Image = Toggle.Image
	BG.ImageColor3 = Color3.fromRGB(41, 41, 41)

	local Button = Instance.new("ImageLabel")
	Button.Name = "Button"
	Button.BackgroundTransparency = 1
	Button.Parent = BG
	Button.AnchorPoint = Vector2.new(0.5, 0.5)
	Button.Position = OFF_POS
	Button.Size = UDim2.new(0.456, 0, 0.755, 0)
	Button.Image = Toggle.Image
	Button.ImageColor3 = OFF
	Button.ZIndex = 3
	
	local Off = Instance.new("TextLabel")
	Off.Parent = BG
	Off.Name = "Off"
	Off.BackgroundTransparency = 1
	Off.AnchorPoint = Vector2.new(0.5, 0.5)
	Off.Position = UDim2.new(0.736, 0, 0.472, 0)
	Off.Size = UDim2.new(0.4, 0, 0.6, 0)
	Off.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Bold)
	Off.TextColor3 = Color3.fromRGB(255, 255, 255)
	Off.Text = "Off"
	Off.TextScaled = true
	Off.ZIndex = 2
	
	local On = Instance.new("TextLabel")
	On.Parent = BG
	On.Name = "On"
	On.BackgroundTransparency = 1
	On.AnchorPoint = Vector2.new(0.5, 0.5)
	On.Position = UDim2.new(0.264, 0, 0.472, 0)
	On.Size = UDim2.new(0.4, 0, 0.6, 0)
	On.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Bold)
	On.TextColor3 = Color3.fromRGB(255, 255, 255)
	On.Text = "On"
	On.TextScaled = true
	On.ZIndex = 2
	
	local TweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	local function Update()
		if Enabled then
			Tween:Create(Button, TweenInfo, {Position = ON_POS, ImageColor3 = ON}):Play()
			Tween:Create(Toggle, TweenInfo, {ImageColor3 = ON}):Play()
		else
			Tween:Create(Button, TweenInfo, {Position = OFF_POS, ImageColor3 = OFF}):Play()
			Tween:Create(Toggle, TweenInfo, {ImageColor3 = OFF}):Play()
		end
	end

	Toggle.MouseButton1Click:Connect(function()
		Enabled = not Enabled
		TogglesState[text:gsub("Auto ", ""):gsub(" ", "")] = Enabled

		Update()

		if Enabled then
			StartAutoFarm(text:gsub("Auto ", ""):gsub(" ", ""))
		end
	end)

	Update()
end

------ CREATE YOUR SETTINGS ------

CreateToggle("Auto Patrick Gamemode")
