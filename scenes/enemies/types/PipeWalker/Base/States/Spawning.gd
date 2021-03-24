extends State
func enter(_args:Dictionary = {}):
	_owner.setposition(_owner.pipemap.map_to_world(_owner.pf.gridpos))

func exit(_args:Dictionary = {}):
	pass

func logic(_args:Dictionary = {}):
	var _delta = _args["delta"]
#	var _dist = _owner.speed * _delta
	emit_signal("StateChange","Walking")
