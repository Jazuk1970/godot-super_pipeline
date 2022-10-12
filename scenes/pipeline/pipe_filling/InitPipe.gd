extends State

func enter(_args:Dictionary = {}):
	_owner.init_pipe()
	emit_signal("StateChange","Empty")

func exit(_args:Dictionary = {}):
	pass
	
func logic(_args:Dictionary = {}):
	var _delta = _args["delta"]
	pass

