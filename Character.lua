local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local Player = Players.LocalPlayer
local CharactersFolder = Workspace:WaitForChild("Characters")

local Character = {}

function Character.GetCharacter()
	local Character = Player.Character

	if not Character then
		return nil
	end

	if Character.Parent ~= CharactersFolder then
		return nil
	end

	return Character
end

function Character.GetRoot()
	local Character = Character.GetCharacter()

	if not Character then
		return nil
	end

	return Character:FindFirstChild("HumanoidRootPart")
end

return Character
