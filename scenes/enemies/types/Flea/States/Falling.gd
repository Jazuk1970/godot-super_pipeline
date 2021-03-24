extends State
func enter(_args:Dictionary = {}):
	_owner.pf.gridpos = choose_target()
	_owner.target_pos = _owner.pipemap.map_to_world(_owner.pf.gridpos) + Vector2(1,1)
	_owner.direction = Vector2.DOWN
	
func exit(_args:Dictionary = {}):
	pass

func logic(_args:Dictionary = {}):
	var _delta = _args["delta"]
	var _dist = (_owner.speed * 1.5) * _delta
	move(_dist,_owner.direction)
	if _owner.position.y == _owner.target_pos.y:
		_owner.pf.direction = Vector2(-1 if randi()%2 == 0 else 1,0)
		_owner.setposition(_owner.pipemap.map_to_world(_owner.pf.gridpos) + Vector2(1,1))
		emit_signal("StateChange","WalkPipe")
		
func move(_dist,_dir) -> void:
	if _owner.target_pos.y - _owner.position.y < _dist:
		_owner.position.y = _owner.target_pos.y
	else:
		_owner.position += _dist * _dir

func choose_target() -> Object:
	randomize()
	return _owner.target.targets[randi()%_owner.target.targets.size()]
