local Controller = {}

local Config = require(script.Parent.Config)
local Character = require(script.Parent.Character)
local State = require(script.Parent.State)
local Interaction = require(script.Parent.Interaction)

local Running = {}

local function IsRunning(ModeName)
	return Running[ModeName] == true
end

local function Wait(Time, ModeName)
	local StartTime = os.clock()

	while os.clock() - StartTime < Time do
		if not IsRunning(ModeName) then
			return false
		end

		task.wait()
	end

	return true
end

local function Teleport(Root, Position, ModeName)
	if not IsRunning(ModeName) then
		return false
	end

	Root.CFrame = Position

	return true
end

local function RunFarm(ModeName)
	local Data = Config[ModeName]

	if not Data then
		warn("AutoFarm: configuração não encontrada:", ModeName)
		Running[ModeName] = nil
		State.Set("Disabled")
		return
	end

	while IsRunning(ModeName) do
		--// STARTING
		State.Set("Starting")

		local Root = Character.GetRoot()

		if not Root then
			warn("AutoFarm: HumanoidRootPart não encontrado.")

			if not Wait(1, ModeName) then
				break
			end

			continue
		end

		--// TELEPORT TO START
		Teleport(Root, Data.Start, ModeName)

		if not IsRunning(ModeName) then
			break
		end

		--// INTERACT WITH NPC
		if not Interaction.Press(Data.InteractKey) then
			warn("AutoFarm: não foi possível interagir.")

			if not Wait(1, ModeName) then
				break
			end

			continue
		end

		--// WAIT FOR GAMEMODE TO START
		State.Set("Waiting")

		if not Wait(Data.StartCD, ModeName) then
			break
		end

		--// FARMING
		State.Set("Farming")

		local FarmStartTime = os.clock()
		local FarmDuration = Data.ExitTime * 60

		while IsRunning(ModeName) and os.clock() - FarmStartTime < FarmDuration do
			Root = Character.GetRoot()

			if not Root then
				warn("AutoFarm: personagem não encontrado.")

				if not Wait(1, ModeName) then
					break
				end

				continue
			end

			for _, Position in ipairs(Data.FarmPos) do
				if not IsRunning(ModeName) then
					break
				end

				Root = Character.GetRoot()

				if not Root then
					break
				end

				Teleport(Root, Position, ModeName)

				if not Wait(Data.TP_Time, ModeName) then
					break
				end
			end
		end

		if not IsRunning(ModeName) then
			break
		end

		--// RETURN TO START
		State.Set("Returning")

		Root = Character.GetRoot()

		if Root then
			Teleport(Root, Data.Start, ModeName)
		end

		if not IsRunning(ModeName) then
			break
		end

		--// WAIT BEFORE NEXT CYCLE
		State.Set("Waiting")

		if not Wait(Data.RejointWait, ModeName) then
			break
		end
	end

	Running[ModeName] = nil
	State.Set("Disabled")
end

function Controller.Start(ModeName)
	if IsRunning(ModeName) then
		return
	end

	if not Config[ModeName] then
		warn("AutoFarm: modo não encontrado:", ModeName)
		return
	end

	Running[ModeName] = true

	task.spawn(function()
		RunFarm(ModeName)
	end)
end

function Controller.Stop(ModeName)
	if not IsRunning(ModeName) then
		return
	end

	Running[ModeName] = nil
	State.Set("Disabled")
end

function Controller.IsRunning(ModeName)
	return IsRunning(ModeName)
end

return Controller
