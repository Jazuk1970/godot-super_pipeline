extends State
func enter(_args:Dictionary = {}):
	_owner.position = _owner.start_pos.snapped(Vector2(1,1))
	_owner.direction = Vector2.UP
	_owner.target = choose_target()
	_owner.target_pos = _owner.target.position + Vector2(-24,-64)
	_owner.anim.play("Climb")
	
func exit(_args:Dictionary = {}):
	pass
	
func logic(_args:Dictionary = {}):
	var _delta = _args["delta"]
	var _dist = _owner.speed * _delta
	move(_dist,_owner.direction)
	if _owner.position.y == _owner.target_pos.y:
		randomize()
		emit_signal("StateChange","Walking")

func move(_dist,_dir) -> void:
	if _owner.position.y - _owner.target_pos.y < _dist:
		_owner.position.y = _owner.target_pos.y
	else:
		_owner.position += _dist * _dir
		
func choose_target() -> Object:
	var _plugs = get_tree().get_nodes_in_group("Plug")
	for _plug in _plugs:
		if _plug.fsm.statename == "Waiting":
			_owner.targets.append(_plug)
	randomize()
	return _owner.targets[randi()%_owner.targets.size()]
