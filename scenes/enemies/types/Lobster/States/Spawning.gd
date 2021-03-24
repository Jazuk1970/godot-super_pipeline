extends State
func enter(_args:Dictionary = {}):
	_owner.target = choose_target()
	_owner.pf.gridpos = _owner.target.grid_position
	_owner.setposition(_owner.pipemap.map_to_world(_owner.pf.gridpos) + Vector2(1,1))
	_owner.direction = Vector2.RIGHT
	_owner.anim.play("Walk")
	emit_signal("StateChange","WalkPipe")
	
func exit(_args:Dictionary = {}):
	pass
	
func logic(_args:Dictionary = {}):
	var _delta = _args["delta"]
	pass

func choose_target() -> Object:
	_owner.targets.append(_owner.pipeline.pipeline.front())
	_owner.targets.append(_owner.pipeline.pipeline.back())
	randomize()
	return _owner.targets[randi()%2]
	
