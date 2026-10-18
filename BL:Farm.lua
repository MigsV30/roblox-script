local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")

-- Remotes de Variant; os remotes de Item foram removidos.
local VariantSpawnRemote = Remotes:WaitForChild("VariantTokenSpawned")
local VariantCollectedRemote = Remotes:WaitForChild("VariantTokenFound")

local Player = Players.LocalPlayer
local PlayerGui = Player.PlayerGui

local obbyRewardPos = {
	["Easy"] = {
		CFrame.new(-1799, 390, 141);
		CD = 300;
		Gradient = "Green"
	};
	["Medium"] = {
		CFrame.new(-1913, 368, 12);
		CD = 600;
		Gradient = "Orange"
	};
	["Hard"] = {
		CFrame.new(-1795, 406, -132);
		CD = 900;
		Gradient = "Red"
	};
}

local itemsSpawn = {
	[1] = {
		CFrame.new(-1724, 8, 6.5)
	};
	[2] = {
		CFrame.new(-1858, 8, 265)
	};
	[3] = {
		CFrame.new(-1860, 8, -257)
	};
	[4] = {
		CFrame.new(-1769, 8, -198)
	};
	[5] = {
		CFrame.new(-1866.5, 8, 14.5)
	};
	[6] = {
		CFrame.new(-1743, 8, 274)
	};
	[7] = {
		CFrame.new(-1811.5, 8, 75.5)
	};
}

local variantsSpawn = {
	[1] = {
		CFrame.new(-1843, 8, -248)
	};
	[2] = {
		CFrame.new(-1821, 8, 208)	
	};
	[3] = {
		CFrame.new(-1833, 8, 269.5)	
	};
	[4] = {
		CFrame.new(-1729, 8, 276)	
	};
	[5] = {
		CFrame.new(-1824.5, 8, -123.5)	
	};
	[6] = {
		CFrame.new(-1936, 8, 17)	
	};
	[7] = {
		CFrame.new(-1671.5, 8, 17)	
	};
	[8] = {
		CFrame.new(-1777, 8, -176)	
	};
	[9] = {
		CFrame.new(-1984, 8, -240)	
	};
	[10] = {
		CFrame.new(-1623, 6.5, -250)	
	};
	[11] = {
		CFrame.new(-1604, 6.5, 20)	
	};
	[12] = {
		CFrame.new(-1610, 6.5, 271.5)	
	};
	[13] = {
		CFrame.new(-1980, 6.5, 273.5)	
	}
}

local housesDoor = {}

local gradients = {
	["Red"] = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 88, 88));
		ColorSequenceKeypoint.new(1, Color3.fromRGB(204, 0, 0))
	};
	["Blue"] = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 147, 255));
		ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 122, 204))
	};
	["Green"] = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(150, 255, 46));
		ColorSequenceKeypoint.new(1, Color3.fromRGB(53, 204, 0))
	};
	["White"] = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255));
		ColorSequenceKeypoint.new(1, Color3.fromRGB(145, 145, 145))
	};
	["Orange"] = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 150, 44));
		ColorSequenceKeypoint.new(1, Color3.fromRGB(204, 85, 0))
	};
}

local gradientTranparency = NumberSequence.new{
	NumberSequenceKeypoint.new(0, 0.5);
	NumberSequenceKeypoint.new(1, 0)
}

local gradientsRotation = 90

local Autos = {
	["AutoObby"] = {
		Name = "Auto Obby";
		Desc = "Skip Obby Parkour and Claim Reward";
		Active = false;
		Difficulty = {};
		DifficultyCD = {}
	};
	["AutoItems"] = {
		Name = "Auto Items";
		Desc = "Auto Collect Items";
		Active = false;
	};
	["AutoVariants"] = {
		Name = "Auto Variants";
		Desc = "Auto Collect Variants";
		Active = false;
	};
}

local TP_CD = 0.5
local interactKeybind = "E"

local function Teleport(Position: CFrame)
    local Character = Player.Character
    if not Character then return false end
    Character:PivotTo(Position)
    return true
end

-- Os farms executam somente quando o Active correspondente estiver ligado.
local itemIndex, variantIndex = 1, 1

local function RunAutoObby()
    local AutoObby = Autos.AutoObby
    if not AutoObby.Active then return end
    local currentTime = os.time()
    for Difficulty, Config in pairs(obbyRewardPos) do
        if AutoObby.Active and AutoObby.Difficulty[Difficulty] then
            local cooldownEnd = AutoObby.DifficultyCD[Difficulty]
            if not cooldownEnd or currentTime >= cooldownEnd then
                if Teleport(Config[1]) then
                    AutoObby.DifficultyCD[Difficulty] = currentTime + Config.CD
                    return -- apenas uma dificuldade por ciclo
                end
            end
        end
    end
end

local function RunAutoItems()
    if not Autos.AutoItems.Active or #itemsSpawn == 0 then return end
    local config = itemsSpawn[itemIndex]
    if config then Teleport(config[1]) end
    itemIndex = (itemIndex % #itemsSpawn) + 1
end

local function RunAutoVariants()
    if not Autos.AutoVariants.Active or #variantsSpawn == 0 then return end
    local config = variantsSpawn[variantIndex]
    if config then Teleport(config[1]) end
    variantIndex = (variantIndex % #variantsSpawn) + 1
end

task.spawn(function()
    local lastItems, lastVariants = 0, 0
    while true do
        local now = os.clock()
        if Autos.AutoObby.Active then RunAutoObby() end
        if Autos.AutoItems.Active and now - lastItems >= TP_CD then
            RunAutoItems()
            lastItems = now
        end
        if Autos.AutoVariants.Active and now - lastVariants >= TP_CD then
            RunAutoVariants()
            lastVariants = now
        end
        task.wait(0.1)
    end
end)

-- // Create UI \\ --

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = PlayerGui
ScreenGui.Name = "BL: Farm"
ScreenGui.IgnoreGuiInset = true
ScreenGui.ResetOnSpawn = false

-- Main Frame

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MainFrame.BackgroundTransparency = 0.5
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.Size = UDim2.new(0.45, 0, 0.5, 0)

local MainUICorner = Instance.new("UICorner")
MainUICorner.Parent = MainFrame
MainUICorner.CornerRadius = UDim.new(0.05, 0)

local MainUIStroke = Instance.new("UIStroke")
MainUIStroke.Parent = MainFrame
MainUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
MainUIStroke.BorderOffset = UDim.new(-0.005, 0)
MainUIStroke.BorderStrokePosition = Enum.BorderStrokePosition.Inner
MainUIStroke.Color = Color3.fromRGB(115, 105, 255)
MainUIStroke.StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize
MainUIStroke.Thickness = 0.006
MainUIStroke.Transparency = 0.2

-- Top Frame

local TopFrame = Instance.new("Frame")
TopFrame.Parent = MainFrame
TopFrame.Name = "Top"
TopFrame.AnchorPoint = Vector2.new(0.5, 0.0)
TopFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
TopFrame.BackgroundTransparency = 0.4
TopFrame.Position = UDim2.new(0.5, 0, 0.018, 0)
TopFrame.Size = UDim2.new(0.98, 0, 0.127, 0)

local TopUICorner = Instance.new("UICorner")
TopUICorner.Parent = TopFrame
TopUICorner.TopLeftRadius = UDim.new(0.225, 0)
TopUICorner.TopRightRadius = UDim.new(0.225, 0)
TopUICorner.BottomLeftRadius = UDim.new(0, 0)
TopUICorner.BottomRightRadius = UDim.new(0, 0)

local TopUIStroke = Instance.new("UIStroke")
TopUIStroke.Parent = TopFrame
TopUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
TopUIStroke.BorderStrokePosition = Enum.BorderStrokePosition.Outer
TopUIStroke.Color = Color3.fromRGB(0, 0, 0)
TopUIStroke.StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize
TopUIStroke.Thickness = 0.03

local Title = Instance.new("TextLabel")
Title.Parent = TopFrame
Title.Name = "Title"
Title.AnchorPoint = Vector2.new(0.0, 0.5)
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0.015, 0, 0.321, 0)
Title.Size = UDim2.new(0.394, 0, 0.401, 0)
Title.ZIndex = 2
Title.Font = Enum.Font.FredokaOne
Title.Text = "BL: Farm"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextScaled = true
Title.TextSize = 14
Title.TextWrapped = true
Title.TextXAlignment = Enum.TextXAlignment.Left

local TitleStroke = Instance.new("UIStroke")
TitleStroke.Parent = Title
TitleStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
TitleStroke.Color = Color3.fromRGB(0, 0, 0)
TitleStroke.StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize
TitleStroke.Thickness = 0.06

local Subtitle = Instance.new("TextLabel")
Subtitle.Parent = TopFrame
Subtitle.Name = "Subtitle"
Subtitle.AnchorPoint = Vector2.new(0.0, 0.5)
Subtitle.BackgroundTransparency = 1
Subtitle.Position = UDim2.new(0.015, 0, 0.7, 0)
Subtitle.Size = UDim2.new(0.209, 0, 0.3, 0)
Subtitle.ZIndex = 2
Subtitle.Font = Enum.Font.FredokaOne
Subtitle.Text = "GrindX Scripts"
Subtitle.TextColor3 = Color3.fromRGB(255, 255, 255)
Subtitle.TextScaled = true
Subtitle.TextSize = 14
Subtitle.TextTransparency = 0.5
Subtitle.TextWrapped = true
Subtitle.TextXAlignment = Enum.TextXAlignment.Left

local SubtitleStroke = Instance.new("UIStroke")
SubtitleStroke.Parent = Subtitle
SubtitleStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
SubtitleStroke.Color = Color3.fromRGB(0, 0, 0)
SubtitleStroke.StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize
SubtitleStroke.Thickness = 0.06

-- Bottom Frame

local BottomFrame = Instance.new("Frame")
BottomFrame.Parent = MainFrame
BottomFrame.Name = "Bottom"
BottomFrame.AnchorPoint = Vector2.new(0.5, 1)
BottomFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
BottomFrame.BackgroundTransparency = 0.4
BottomFrame.Position = UDim2.new(0.5, 0, 0.985, 0)
BottomFrame.Size = UDim2.new(0.98, 0, 0.127, 0)

local BottomUICorner = Instance.new("UICorner")
BottomUICorner.Parent = BottomFrame
BottomUICorner.TopLeftRadius = UDim.new(0, 0)
BottomUICorner.TopRightRadius = UDim.new(0, 0)
BottomUICorner.BottomLeftRadius = UDim.new(0.225, 0)
BottomUICorner.BottomRightRadius = UDim.new(0.225, 0)

local BottomUIStroke = Instance.new("UIStroke")
BottomUIStroke.Parent = BottomFrame
BottomUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
BottomUIStroke.BorderStrokePosition = Enum.BorderStrokePosition.Outer
BottomUIStroke.Color = Color3.fromRGB(0, 0, 0)
BottomUIStroke.StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize
BottomUIStroke.Thickness = 0.03

local SelectScroll = Instance.new("ScrollingFrame")
SelectScroll.Parent = BottomFrame
SelectScroll.AnchorPoint = Vector2.new(0.5, 0.5)
SelectScroll.BackgroundTransparency = 1
SelectScroll.Position = UDim2.new(0.5, 0, 0.5, 0)
SelectScroll.Size = UDim2.new(0.975, 0, 0.865, 0)
SelectScroll.ZIndex = 2
SelectScroll.AutomaticCanvasSize = Enum.AutomaticSize.X
SelectScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
SelectScroll.ElasticBehavior = Enum.ElasticBehavior.WhenScrollable
SelectScroll.HorizontalScrollBarInset = Enum.ScrollBarInset.Always
SelectScroll.ScrollBarImageColor3 = Color3.fromRGB(115, 105, 255)
SelectScroll.ScrollBarThickness = 3
SelectScroll.Visible = false
SelectScroll.Visible = false

local SelectUIListLayout = Instance.new("UIListLayout")
SelectUIListLayout.Parent = SelectScroll
SelectUIListLayout.Padding = UDim.new(0.025, 0)
SelectUIListLayout.FillDirection = Enum.FillDirection.Horizontal
SelectUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

local SpaceSelectFrame = Instance.new("Frame")
SpaceSelectFrame.Parent = SelectScroll
SpaceSelectFrame.Name = "Space"
SpaceSelectFrame.BackgroundTransparency = 1
SpaceSelectFrame.LayoutOrder = 999999999
SpaceSelectFrame.Size = UDim2.new(0.01, 0, 0.9, 0)

-- // Main Container

local MainContainer = Instance.new("ScrollingFrame")
MainContainer.Parent = MainFrame
MainContainer.Name = "Container"
MainContainer.AnchorPoint = Vector2.new(0.5, 0.5)
MainContainer.BackgroundTransparency = 1
MainContainer.Position = UDim2.new(0.499, 0, 0.5, 0)
MainContainer.Size = UDim2.new(0.977, 0, 0.662, 0)
MainContainer.ZIndex = 2
MainContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
MainContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
MainContainer.ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0)
MainContainer.ScrollBarThickness = 4
MainContainer.ScrollingDirection = Enum.ScrollingDirection.Y

local MainContainerUIListLayout = Instance.new("UIListLayout")
MainContainerUIListLayout.Parent = MainContainer
MainContainerUIListLayout.Padding = UDim.new(0.05, 0)
MainContainerUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
MainContainerUIListLayout.FillDirection = Enum.FillDirection.Vertical
MainContainerUIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local MainContainerUIPadding = Instance.new("UIPadding")
MainContainerUIPadding.Parent = MainContainer
MainContainerUIPadding.PaddingTop = UDim.new(0, 2)

local MainContainerSpace = Instance.new("Frame")
MainContainerSpace.Parent = MainContainer
MainContainerSpace.Name = "Space"
MainContainerSpace.BackgroundTransparency = 1
MainContainerSpace.Size = UDim2.new(0.956, 0, 0.1, 0)
MainContainerSpace.LayoutOrder = 999999999

-- // Create Container Items

local function CreateContainerItem(ItemName, ItemDesc, HasSelection, SelectText, OnToggleChanged)
	HasSelection = HasSelection or false
	SelectText = SelectText or "Select"

	-- // Container

	local ContainerItem = Instance.new("Frame")
	ContainerItem.Name = ItemName
	ContainerItem.Parent = MainContainer
	ContainerItem.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	ContainerItem.BackgroundTransparency = 0.5
	ContainerItem.Size = UDim2.new(0.956, 0, 0.174, 0)

	local UICorner = Instance.new("UICorner")
	UICorner.Parent = ContainerItem
	UICorner.CornerRadius = UDim.new(0.1, 0)

	local InnerStroke = Instance.new("UIStroke")
	InnerStroke.Parent = ContainerItem
	InnerStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	InnerStroke.BorderStrokePosition = Enum.BorderStrokePosition.Inner
	InnerStroke.Color = Color3.fromRGB(255, 255, 255)
	InnerStroke.StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize
	InnerStroke.Thickness = 0.04
	InnerStroke.Transparency = 0.88

	local OuterStroke = Instance.new("UIStroke")
	OuterStroke.Parent = ContainerItem
	OuterStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	OuterStroke.BorderStrokePosition = Enum.BorderStrokePosition.Outer
	OuterStroke.Color = Color3.fromRGB(0, 0, 0)
	OuterStroke.StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize
	OuterStroke.Thickness = 0.04

	-- // Name

	local NameLabel = Instance.new("TextLabel")
	NameLabel.Name = "Name"
	NameLabel.Parent = ContainerItem
	NameLabel.AnchorPoint = Vector2.new(0, 0.5)
	NameLabel.BackgroundTransparency = 1
	NameLabel.Position = UDim2.new(0.015, 0, 0.321, 0)
	NameLabel.Size = UDim2.new(0.394, 0, 0.401, 0)
	NameLabel.ZIndex = 2
	NameLabel.Font = Enum.Font.FredokaOne
	NameLabel.Text = ItemName
	NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	NameLabel.TextScaled = true
	NameLabel.TextWrapped = true
	NameLabel.TextXAlignment = Enum.TextXAlignment.Left

	local NameStroke = Instance.new("UIStroke")
	NameStroke.Parent = NameLabel
	NameStroke.Color = Color3.fromRGB(0, 0, 0)
	NameStroke.Thickness = 0.06

	-- // Description

	local Desc = Instance.new("TextLabel")
	Desc.Name = "Desc"
	Desc.Parent = ContainerItem
	Desc.AnchorPoint = Vector2.new(0, 0.5)
	Desc.BackgroundTransparency = 1
	Desc.Position = UDim2.new(0.015, 0, 0.7, 0)
	Desc.Size = UDim2.new(0.54, 0, 0.3, 0)
	Desc.ZIndex = 2
	Desc.Font = Enum.Font.FredokaOne
	Desc.Text = ItemDesc
	Desc.TextColor3 = Color3.fromRGB(255, 255, 255)
	Desc.TextScaled = true
	Desc.TextTransparency = 0.5
	Desc.TextWrapped = true
	Desc.TextXAlignment = Enum.TextXAlignment.Left

	local DescStroke = Instance.new("UIStroke")
	DescStroke.Parent = Desc
	DescStroke.Color = Color3.fromRGB(0, 0, 0)
	DescStroke.Thickness = 0.06


	-- // Button Factory

	local function CreateButton(Name, Text, Position, ColorName)
		local Button = Instance.new("TextButton")
		Button.Name = Name
		Button.Parent = ContainerItem
		Button.AnchorPoint = Vector2.new(1, 0.5)
		Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Button.Position = Position
		Button.Size = UDim2.new(0.19, 0, 0.649, 0)
		Button.Text = ""
		Button.AutoButtonColor = false
		Button.ZIndex = 1

		local Corner = Instance.new("UICorner")
		Corner.Parent = Button
		Corner.CornerRadius = UDim.new(0.1, 0)

		local Gradient = Instance.new("UIGradient")
		Gradient.Name = "Gradient"
		Gradient.Parent = Button
		Gradient.Color = gradients[ColorName]
		Gradient.Rotation = gradientsRotation

		local Shadow = Instance.new("Frame")
		Shadow.Name = "ColorShadow"
		Shadow.Parent = Button
		Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
		Shadow.BackgroundColor3 = Color3.fromRGB(178, 178, 178)
		Shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
		Shadow.Size = UDim2.new(0.965, 0, 0.85, 0)
		Shadow.ZIndex = 2

		local ShadowCorner = Instance.new("UICorner")
		ShadowCorner.Parent = Shadow
		ShadowCorner.CornerRadius = UDim.new(0.1, 0)

		local ShadowGradient = Instance.new("UIGradient")
		ShadowGradient.Name = "Gradient"
		ShadowGradient.Parent = Shadow
		ShadowGradient.Color = gradients[ColorName]
		ShadowGradient.Rotation = gradientsRotation
		ShadowGradient.Transparency = gradientTranparency

		-- // Button Text

		local TextLabel = Instance.new("TextLabel")
		TextLabel.Name = "Label"
		TextLabel.Parent = Shadow
		TextLabel.AnchorPoint = Vector2.new(0.5, 0.5)
		TextLabel.BackgroundTransparency = 1
		TextLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
		TextLabel.Size = UDim2.new(1, 0, 0.57, 0)
		TextLabel.ZIndex = 3
		TextLabel.Font = Enum.Font.FredokaOne
		TextLabel.Text = Text
		TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		TextLabel.TextScaled = true
		TextLabel.TextWrapped = true

		local TextLabelStroke = Instance.new("UIStroke")
		TextLabelStroke.Parent = TextLabel
		TextLabelStroke.Color = Color3.fromRGB(0, 0, 0)
		TextLabelStroke.Thickness = 0.06
		TextLabelStroke.StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize

		return Button, TextLabel
	end

	-- // Toggle Button

	local ToggleButton, ToggleLabel = CreateButton(
		"Toggle",
		"OFF",
		HasSelection and UDim2.new(0.765, 0, 0.5, 0) or UDim2.new(0.985, 0, 0.5, 0),
		"Red"
	)

	-- // Selection Button

	local SelectButton

	if HasSelection then
		SelectButton = CreateButton(
			"Select",
			SelectText,
			UDim2.new(0.985, 0, 0.5, 0),
			"Blue"
		)
	end

	-- // Toggle Logic

	local Enabled = false

	local function SetEnabled(Value)
		Enabled = Value

		local ColorName = Enabled and "Green" or "Red"
		ToggleLabel.Text = Enabled and "ON" or "OFF"

		ToggleButton.Gradient.Color = gradients[ColorName]
		ToggleButton.ColorShadow.Gradient.Color = gradients[ColorName]
	end

	ToggleButton.Activated:Connect(function()
		SetEnabled(not Enabled)
		if OnToggleChanged then
			OnToggleChanged(Enabled)
		end
	end)

	-- // Return References

	return {
		Container = ContainerItem,
		ToggleButton = ToggleButton,
		SelectButton = SelectButton,

		IsEnabled = function()
			return Enabled
		end,

		SetEnabled = SetEnabled,
	}
end

-- // Create Select Button

local function CreateSelectButton(Name, ColorName, OnSelectionChanged)
	local Button = Instance.new("TextButton")
	Button.Name = Name
	Button.Size = UDim2.new(0.25, 0, 0.9, 0)
	Button.Text = ""
	Button.AutoButtonColor = false
	Button.Parent = SelectScroll

	local ButtonCorner = Instance.new("UICorner")
	ButtonCorner.Parent = Button
	ButtonCorner.CornerRadius = UDim.new(0.1, 0)

	local ButtonGradient = Instance.new("UIGradient")
	ButtonGradient.Name = "Gradient"
	ButtonGradient.Parent = Button
	ButtonGradient.Color = gradients.White
	ButtonGradient.Rotation = gradientsRotation

	local Shadow = Instance.new("Frame")
	Shadow.Name = "ColorShadow"
	Shadow.Parent = Button
	Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
	Shadow.BackgroundColor3 = Color3.fromRGB(178, 178, 178)
	Shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
	Shadow.Size = UDim2.new(0.976, 0, 0.85, 0)
	Shadow.ZIndex = 2

	local ShadowCorner = Instance.new("UICorner")
	ShadowCorner.Parent = Shadow
	ShadowCorner.CornerRadius = UDim.new(0.1, 0)

	local ShadowGradient = Instance.new("UIGradient")
	ShadowGradient.Name = "Gradient"
	ShadowGradient.Parent = Shadow
	ShadowGradient.Color = gradients.White
	ShadowGradient.Rotation = gradientsRotation
	ShadowGradient.Transparency = gradientTranparency

	-- // Button Text

	local TextLabel = Instance.new("TextLabel")
	TextLabel.Name = "Label"
	TextLabel.Parent = Shadow
	TextLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	TextLabel.BackgroundTransparency = 1
	TextLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
	TextLabel.Size = UDim2.new(1, 0, 0.57, 0)
	TextLabel.ZIndex = 3
	TextLabel.Font = Enum.Font.FredokaOne
	TextLabel.Text = Name
	TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	TextLabel.TextScaled = true
	TextLabel.TextWrapped = true

	local TextLabelStroke = Instance.new("UIStroke")
	TextLabelStroke.Parent = TextLabel
	TextLabelStroke.Color = Color3.fromRGB(0, 0, 0)
	TextLabelStroke.Thickness = 0.06
	TextLabelStroke.StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize

	-- // Selected Icon

	local Selected = Instance.new("ImageLabel")
	Selected.Name = "Selected"
	Selected.Parent = Shadow
	Selected.BackgroundTransparency = 1
	Selected.AnchorPoint = Vector2.new(0.5, 0.5)
	Selected.Position = UDim2.new(0.9, 0, 0.5, 0)
	Selected.Size = UDim2.new(0.155, 0, 0.685, 0)
	Selected.Image = "rbxassetid://15540208282"
	Selected.ScaleType = Enum.ScaleType.Fit
	Selected.Visible = false
	Selected.ZIndex = 4

	-- // Selection Logic

	local IsSelected = false

	local function SetSelected(Value)
		IsSelected = Value
		local SelectedColor = IsSelected and ColorName or "White"

		ButtonGradient.Color = gradients[SelectedColor]
		ShadowGradient.Color = gradients[SelectedColor]
		Selected.Visible = IsSelected
	end

	Button.Activated:Connect(function()
		SetSelected(not IsSelected)
		if OnSelectionChanged then
			OnSelectionChanged(IsSelected)
		end
	end)

	return {
		Button = Button,
		Selected = Selected,
		IsSelected = function()
			return IsSelected
		end,
		SetSelected = SetSelected,
	}
end

-- // Request Functions

local AutoObbyUI = CreateContainerItem(
	Autos.AutoObby.Name,
	Autos.AutoObby.Desc,
	true,
	"Select Difficulty",
	function(Enabled)
		Autos.AutoObby.Active = Enabled
	end
)

local AutoItemsUI = CreateContainerItem(
	Autos.AutoItems.Name,
	Autos.AutoItems.Desc,
	false,
	nil,
	function(Enabled)
		Autos.AutoItems.Active = Enabled
	end
)

local AutoVariantsUI = CreateContainerItem(
	Autos.AutoVariants.Name,
	Autos.AutoVariants.Desc,
	false,
	nil,
	function(Enabled)
		Autos.AutoVariants.Active = Enabled
	end
)

-- // Difficulty Selector
-- The selected difficulties live in Autos.AutoObby.Difficulty,
-- so destroying the UI buttons will not erase the player's choices.

local DifficultyButtons = {}

local DifficultyButtonConfig = {
	{ Name = "Easy", Color = "Green" },
	{ Name = "Medium", Color = "Orange" },
	{ Name = "Hard", Color = "Red" },
}

local function CloseDifficultySelector()
	SelectScroll.Visible = false

	for Difficulty, ButtonData in pairs(DifficultyButtons) do
		if ButtonData.Button then
			ButtonData.Button:Destroy()
		end
		DifficultyButtons[Difficulty] = nil
	end
end

local function OpenDifficultySelector()
	-- Avoid creating duplicate buttons if the selector is already open.
	if SelectScroll.Visible then
		CloseDifficultySelector()
		return
	end

	SelectScroll.Visible = true

	for _, Config in ipairs(DifficultyButtonConfig) do
		local Difficulty = Config.Name
		local IsSavedSelected = Autos.AutoObby.Difficulty[Difficulty] == true

		local ButtonData = CreateSelectButton(Difficulty, Config.Color, function(IsSelected)
			Autos.AutoObby.Difficulty[Difficulty] = IsSelected
		end)

		DifficultyButtons[Difficulty] = ButtonData
		ButtonData.SetSelected(IsSavedSelected)
	end
end

AutoObbyUI.SelectButton.Activated:Connect(OpenDifficultySelector)

-- // Remote Connections

-- Conexoes de Variant ficam sem handlers aqui porque VariantsCollect e
-- StopVariantsCollect nao existem neste script original. Evita erros de runtime.
-- VariantSpawnRemote envia o nome da Variant (ex.: "Shadow", "Predator",
-- "Flow State" ou "Unknown"). VariantCollectedRemote envia PlayerName e Variant.

-- Ctrl alterna a visibilidade da interface sem destruir o ScreenGui.
UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then return end
    if input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.RightControl then
        ScreenGui.Enabled = not ScreenGui.Enabled
    end
end)
