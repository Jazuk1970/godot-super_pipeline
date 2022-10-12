extends State

func enter(_args:Dictionary = {}):
	pass	

func exit(_args:Dictionary = {}):
	pass
	
func logic(_args:Dictionary = {}):
	var _delta = _args["delta"]
	if not (_owner.flow_in and _owner.flow_in_enable) and _owner.flow_out_enable:
		_owner.nextstate = "Emptying"
		if _owner.type == 3:
			_owner.current_fill = _owner.full_state + 8
		_owner.nextflowupdate = 1
	elif _owner.type == 3:
		_owner.nextflowupdate = 1
