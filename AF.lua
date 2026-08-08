local Players = game:GetService("Players")
local Tween = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local UIS = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")

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

--==================================================
-- MAIN UI
--==================================================

local UIEnabled = true

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = PlayerGui
ScreenGui.Name = "AF"
ScreenGui.IgnoreGuiInset = true
ScreenGui.ResetOnSpawn = false

UIS.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	if input.KeyCode == Enum.KeyCode.LeftControl
		or input.KeyCode == Enum.KeyCode.RightControl then

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

TitleText.FontFace = Font.new(
	"rbxasset://fonts/families/Montserrat.json",
	Enum.FontWeight.Bold,
	Enum.FontStyle.Normal
)

TitleText.TextColor3 = Color3.fromRGB(0, 0, 0)
TitleText.Text = "Auto Farm"
TitleText.TextScaled = true
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.TextYAlignment = Enum.TextYAlignment.Center

--==================================================
-- SETTINGS UI
--==================================================

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

--==================================================
-- AUTOFARM
--==================================================

local function GetRoot()
	local char = Player.Character

	if char and char.Parent == CharactersFolder then
		return char:FindFirstChild("HumanoidRootPart")
	end

	return nil
end

--==================================================
-- PRESS E
--==================================================

local function PressE()
	local success, err = pcall(function()
		VirtualInputManager:SendKeyEvent(
			true,
			Enum.KeyCode.E,
			false,
			game
		)

		task.wait(0.15)

		VirtualInputManager:SendKeyEvent(
			false,
			Enum.KeyCode.E,
			false,
			game
		)
	end)

	if not success then
		warn("Erro ao pressionar E:", err)
	end
end

--==================================================
-- POSITION CHECK
--==================================================

local function IsAtPosition(root, targetCFrame, tolerance)
	if not root then
		return false
	end

	if not root.Parent then
		return false
	end

	if not targetCFrame then
		return false
	end

	tolerance = tolerance or 5

	local distance = (
		root.Position - targetCFrame.Position
	).Magnitude

	return distance <= tolerance
end

--==================================================
-- WAIT
--==================================================

local function WaitForSeconds(duration, modeName)
	local startTime = os.clock()

	while TogglesState[modeName] do
		if os.clock() - startTime >= duration then
			return true
		end

		task.wait()
	end

	return false
end

--==================================================
-- AUTOFARM
--==================================================

local function StartAutoFarm(modeName)
	task.spawn(function()
		local data = AUTOFARMS[modeName]

		if not data then
			warn("Modo não encontrado:", modeName)
			return
		end

		print("================================")
		print("AutoFarm iniciado:", modeName)
		print("================================")

		while TogglesState[modeName] do

			--==================================================
			-- GET ROOT
			--==================================================

			local root = GetRoot()

			if not root then
				warn("Root não encontrado")
				task.wait(1)
				continue
			end

			--==================================================
			-- 1. START POS
			--==================================================

			print("[AutoFarm] Teleportando para StartPos")

			root.CFrame = data.StartPos

			-- Pequeno intervalo para garantir que o CFrame
			-- foi aplicado antes da interação.
			task.wait(0.15)

			if not TogglesState[modeName] then
				break
			end

			--==================================================
			-- 2. PRESS E
			--==================================================

			print("[AutoFarm] Pressionando E")

			PressE()

			if not TogglesState[modeName] then
				break
			end

			--==================================================
			-- 3. START CD
			--==================================================

			print(
				"[AutoFarm] Start_CD:",
				data.Start_CD,
				"segundos"
			)

			if not WaitForSeconds(
				data.Start_CD,
				modeName
			) then
				break
			end

			--==================================================
			-- 4. FARM
			--==================================================

			print("[AutoFarm] Iniciando farm")

			local farmStart = os.clock()
			local exitDuration = data.ExitTime * 60

			local positionIndex = 1

			-- Essa variável é MUITO importante.
			--
			-- Enquanto false:
			-- não verificamos StartPos.
			--
			-- Depois do primeiro TP:
			-- passa para true.
			local hasLeftStart = false

			local stoppedEarly = false

			while TogglesState[modeName] do

				--==================================================
				-- EXIT TIME
				--==================================================

				local farmElapsed = os.clock() - farmStart

				if farmElapsed >= exitDuration then
					print("[AutoFarm] ExitTime alcançado")
					break
				end

				--==================================================
				-- GET ROOT
				--==================================================

				root = GetRoot()

				if not root then
					warn("[AutoFarm] Root perdido")

					task.wait(1)
					continue
				end

				--==================================================
				-- TELEPORT POS
				--==================================================

				local cf = data.Pos[positionIndex]

				if cf then
					print(
						"[AutoFarm] TP Pos[" ..
						positionIndex ..
						"]"
					)

					root.CFrame = cf

					-- Agora o player realmente saiu do StartPos.
					hasLeftStart = true
				end

				-- Próxima posição
				positionIndex += 1

				if positionIndex > #data.Pos then
					positionIndex = 1
				end

				--==================================================
				-- TP TIME
				--==================================================

				local tpStart = os.clock()

				while TogglesState[modeName] do

					local tpElapsed = os.clock() - tpStart
					local farmElapsedNow = os.clock() - farmStart

					-- TP_TIME terminou
					if tpElapsed >= data.TP_TIME then
						break
					end

					-- ExitTime terminou
					if farmElapsedNow >= exitDuration then
						break
					end

					root = GetRoot()

					if not root then
						warn("[AutoFarm] Root perdido durante TP_TIME")
						break
					end

					--==================================================
					-- CHECK START POS
					--==================================================

					if hasLeftStart then
						if IsAtPosition(
							root,
							data.StartPos,
							5
						) then

							print(
								"[AutoFarm] Player retornou para StartPos!"
							)

							stoppedEarly = true
							break
						end
					end

					task.wait()
				end

				-- Saiu do TP_TIME porque voltou para StartPos
				if stoppedEarly then
					break
				end

				--==================================================
				-- CHECK EXTRA
				--==================================================

				root = GetRoot()

				if root and hasLeftStart then
					if IsAtPosition(
						root,
						data.StartPos,
						5
					) then

						print(
							"[AutoFarm] Player está no StartPos."
						)

						stoppedEarly = true
						break
					end
				end
			end

			--==================================================
			-- CHECK TOGGLE
			--==================================================

			if not TogglesState[modeName] then
				break
			end

			--==================================================
			-- 5. FARM TERMINOU
			--==================================================

			if stoppedEarly then
				print(
					"[AutoFarm] Farm interrompido: " ..
					"Player voltou para StartPos."
				)
			else
				print(
					"[AutoFarm] Farm terminou normalmente."
				)
			end

			--==================================================
			-- 6. START POS
			--==================================================

			root = GetRoot()

			if root then
				print(
					"[AutoFarm] Voltando para StartPos"
				)

				root.CFrame = data.StartPos
			end

			if not TogglesState[modeName] then
				break
			end

			--==================================================
			-- 7. WAIT REJOIN
			--==================================================

			print(
				"[AutoFarm] Wait_Rejoin:",
				data.Wait_Rejoin,
				"segundos"
			)

			if not WaitForSeconds(
				data.Wait_Rejoin,
				modeName
			) then
				break
			end

			if not TogglesState[modeName] then
				break
			end

			--==================================================
			-- 8. LOOP
			--==================================================
			--
			-- O while volta automaticamente para:
			--
			-- StartPos
			-- Press E
			-- Start_CD
			-- Farm
			-- ExitTime
			-- StartPos
			-- Wait_Rejoin
			-- ...
			--

			print("[AutoFarm] Novo ciclo iniciado")
		end

		print("================================")
		print("AutoFarm finalizado:", modeName)
		print("================================")
	end)
end

--==================================================
-- TOGGLE CREATOR
--==================================================

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

	Title.FontFace = Font.new(
		"rbxasset://fonts/families/Montserrat.json",
		Enum.FontWeight.Bold
	)

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

	Off.FontFace = Font.new(
		"rbxasset://fonts/families/Montserrat.json",
		Enum.FontWeight.Bold
	)

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

	On.FontFace = Font.new(
		"rbxasset://fonts/families/Montserrat.json",
		Enum.FontWeight.Bold
	)

	On.TextColor3 = Color3.fromRGB(255, 255, 255)
	On.Text = "On"
	On.TextScaled = true
	On.ZIndex = 2

	local TweenInfo = TweenInfo.new(
		0.25,
		Enum.EasingStyle.Quad,
		Enum.EasingDirection.Out
	)

	local function Update()
		if Enabled then
			Tween:Create(
				Button,
				TweenInfo,
				{
					Position = ON_POS,
					ImageColor3 = ON
				}
			):Play()

			Tween:Create(
				Toggle,
				TweenInfo,
				{
					ImageColor3 = ON
				}
			):Play()
		else
			Tween:Create(
				Button,
				TweenInfo,
				{
					Position = OFF_POS,
					ImageColor3 = OFF
				}
			):Play()

			Tween:Create(
				Toggle,
				TweenInfo,
				{
					ImageColor3 = OFF
				}
			):Play()
		end
	end

	Toggle.MouseButton1Click:Connect(function()
		Enabled = not Enabled

		local modeName = text
			:gsub("Auto ", "")
			:gsub(" ", "")

		TogglesState[modeName] = Enabled

		Update()

		if Enabled then
			StartAutoFarm(modeName)
		end
	end)

	Update()
end

--==================================================
-- CREATE SETTINGS
--==================================================

CreateToggle("Auto Patrick Gamemode")

--==================================================
-- LOADSTRING
--==================================================

-- loadstring(game:HttpGet(
--     "https://raw.githubusercontent.com/MigsV30/roblox-script/main/AF.lua"
-- ))()
