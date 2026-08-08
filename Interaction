local VirtualInputManager = game:GetService("VirtualInputManager")

local Interaction = {}

function Interaction.Press(Key)
	local KeyCode = Enum.KeyCode[Key]

	if not KeyCode then
		warn("Interaction: tecla inválida:", Key)
		return false
	end

	VirtualInputManager:SendKeyEvent(true, KeyCode, false, game)

	task.wait(0.1)

	VirtualInputManager:SendKeyEvent(false, KeyCode, false, game)

	return true
end

return Interaction
