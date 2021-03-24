extends State
func enter(_args:Dictionary = {}):
	_owner.anim.play("Walk")
	_owner.direction = Vector2.LEFT
	
func exit(_args:Dictionary = {}):
	pass
		
func logic(_args:Dictionary = {}):
	var _delta = _args["delta"]
	var _dist = _owner.speed * _delta
	move(_dist,_owner.direction)
	if _owner.position.x == _owner.target_pos.x:
		emit_signal("StateChange","Falling")

func move(_dist,_dir) -> void:
	if _owner.position.x - _owner.target_pos.x < _dist:
		_owner.position.x = _owner.target_pos.x
	else:
		_owner.position += _dist * _dir
