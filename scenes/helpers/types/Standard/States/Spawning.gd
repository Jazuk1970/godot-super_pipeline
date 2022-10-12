extends State
func enter(_args:Dictionary = {}):
	#_owner.position = _owner.start_pos.snapped(Vector2(1,1))
	_owner.direction = _owner.pf.facingdirection
	_owner.target_pos = globals.getVect(globals.Level_Data.Player_Start_Position) * globals.tile_size
	_owner.anim.play("Walk")
	
func exit(_args:Dictionary = {}):
	pass
	
func logic(_args:Dictionary = {}):
	var _delta = _args["delta"]
	var _dist = _owner.speed * _delta
	move(_dist,_owner.direction)
	if _owner.position.x >= _owner.target_pos.x:
		if _owner.winning:
			emit_signal("StateChange","Winning")
		else:
			emit_signal("StateChange","Idle")
			
func move(_dist,_dir) -> void:
	if abs(_owner.position.x - _owner.target_pos.x) < _dist:
		_owner.position.x = _owner.target_pos.x
	else:
		_owner.position += _dist * _dir
		

