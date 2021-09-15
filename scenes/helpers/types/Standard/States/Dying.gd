extends State
func enter(_args:Dictionary = {}):
	_owner.target_pos = Vector2(0,35) * globals.tile_size
	_owner.direction = Vector2.DOWN
	_owner.anim.play("Dying")
	
func exit(_args:Dictionary = {}):
	pass

func logic(_args:Dictionary = {}):
	var _delta = _args["delta"]
	var _dist = (_owner.speed * 1.5) * _delta
	move(_dist,_owner.direction)
	if _owner.position.y >= _owner.target_pos.y:
		_owner.queue_free()

func move(_dist,_dir) -> void:
	if _owner.target_pos.y - _owner.position.y < _dist:
		_owner.position.y = _owner.target_pos.y
	else:
		_owner.position += _dist * _dir
