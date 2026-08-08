local State = {}

local CurrentState = "Disabled"

function State.Get()
	return CurrentState
end

function State.Set(NewState)
	CurrentState = NewState
end

return State
