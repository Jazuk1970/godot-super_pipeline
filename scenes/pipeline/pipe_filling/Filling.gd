extends State

func enter(_args:Dictionary = {}):
	pass	

func exit(_args:Dictionary = {}):
	pass
	
func logic(_args:Dictionary = {}):
	var _delta = _args["delta"]
	#Check if we are full
	if _owner.current_state == _owner.full_state:
		emit_signal("StateChange","Full")
	#if we are not full request a flow update
	elif _owner.nextflowupdate == 0:
		_owner.nextflowupdate = 1
