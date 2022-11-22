extends State

func enter(_args:Dictionary = {}):
	pass	

func exit(_args:Dictionary = {}):
	pass
	
func logic(_args:Dictionary = {}):
	var _delta = _args["delta"]
	#Check if we are empty
	if _owner.current_state == _owner.empty_state:
		emit_signal("StateChange","Empty")
	#if we are not empty request a flow update
	elif _owner.nextflowupdate == 0:
		_owner.nextflowupdate = 1
