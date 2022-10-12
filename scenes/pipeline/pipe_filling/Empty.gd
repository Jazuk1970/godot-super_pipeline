extends State

func enter(_args:Dictionary = {}):
	pass	

func exit(_args:Dictionary = {}):
	pass
	
func logic(_args:Dictionary = {}):
	var _delta = _args["delta"]
	if _owner.flow_in and _owner.flow_in_enable: #and not _owner.blocked:
		_owner.nextstate = "Filling"
		_owner.nextflowupdate = 1
