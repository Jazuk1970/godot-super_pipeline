extends State
var pipemap
func enter(_args:Dictionary = {}):
	var _pipeline = globals.level.get_node("pipeline")
	pipemap = _pipeline.map
func exit(_args:Dictionary = {}):
	pass
		
func logic(_args:Dictionary = {}):
	var _delta = _args["delta"]
	var _dist = _owner.speed * _delta
	move(_dist,_owner.direction)
	if _owner.gridpos == _owner.target_gridpos:
		_owner.Spawner.add_respawn(_owner.type,_owner.id,str(1))
		var _plugs = get_tree().get_nodes_in_group("Plug")
		for _plug in _plugs:
			if _plug.gridpos == _owner.gridpos and _plug.name != _owner.name:
				_owner.queue_free()
				return
		emit_signal("StateChange","Blocking")

func move(_dist,_dir) -> void:
	if _owner.position.distance_to(pipemap.map_to_world(_owner.target_gridpos)) < _dist:
		_setposition(pipemap.map_to_world(_owner.target_gridpos))
	else:
		_setposition(_owner.position + (_dist * _dir))

func _setposition(_p):
	_owner.position = _p.snapped(Vector2(1,1))
	_owner.gridpos = pipemap.world_to_map(_owner.position)
