extends State
var pipemap

func enter(_args:Dictionary = {}):
	var _pipeline = globals.level.get_node("pipeline")
	pipemap = _pipeline.map
	_owner.position = pipemap.map_to_world(_owner.source_gridpos).snapped(Vector2(1,1))
	_owner.gridpos = _owner.source_gridpos
	_owner.trigger = false
	
func exit(_args:Dictionary = {}):
	_owner.trigger = false
	
func logic(_args:Dictionary = {}):
	if _owner.trigger:
		var _t = _owner.targets.size()
		_owner.target_gridpos = _owner.targets[randi()%_t]
		emit_signal("StateChange","Dropping")	
