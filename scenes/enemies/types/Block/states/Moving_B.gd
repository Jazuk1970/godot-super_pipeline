extends State
var pipeline:Object

func enter(_args:Dictionary = {}):
	_owner.target_pos = _owner.target_gridpos * globals.tile_size
	_owner.direction = Vector2.DOWN

func exit(_args:Dictionary = {}):
	pass

func logic(_args:Dictionary = {}):
	var _delta = _args["delta"]
	var _dist = _owner.speed * _delta
	move(_dist,_owner.direction)
	if _owner.position.y == _owner.target_pos.y:
		emit_signal("StateChange","Moving_A")

func move(_dist,_dir) -> void:
	if _owner.target_pos.y -_owner.position.y  < _dist:
		_owner.position.y = _owner.target_pos.y
	else:
		_owner.position += _dist * _dir
