extends State
func enter(_args:Dictionary = {}):
	pass

func exit(_args:Dictionary = {}):
	pass

func logic(_args:Dictionary = {}):
	var _delta = _args["delta"]
	_owner.pf.dist = _owner.speed * _delta
	_owner.pipeline.checkmove(_owner.pf,false)
	if _owner.pf.dist == 0 and globals.Game_State.statename !="Intermission":
		_owner.pf.direction = get_next_direction(_owner.pf)
	move(_owner.pf)
	if abs(_owner.pf.direction.x) > 0:
		_owner.col.disabled = true
		_owner.colV.disabled = false
		_owner.anim.play("Walk")
		_owner.spr.flip_v = false
		if _owner.pf.direction.x > 0:
			_owner.spr.flip_h = true
		else:
			_owner.spr.flip_h = false
	if abs(_owner.pf.direction.y) > 0:
		_owner.col.disabled = false
		_owner.colV.disabled = true
		_owner.anim.play("Climb")
		_owner.spr.flip_h = false
		if _owner.pf.direction.y > 0:
			_owner.spr.flip_v = true
		else:
			_owner.spr.flip_v = false


func move(_pf):
	_pf.moving = true
	_owner.setposition(_pf.position + (_pf.dist * _pf.direction))
	var _axis = _pf.direction.abs()
	if _pf.direction != _pf.prevdirection and _pf.direction:
		if _pf.preprevdirection.abs() != _pf.prevdirection.abs():
			_pf.preprevdirection = _pf.prevdirection
		_pf.prevdirection = _pf.direction
	if _pf.lastmovement != _axis:
		_pf.lastmovement = _axis
		var _pos = _owner.pipemap.map_to_world(_pf.gridpos)
		if _axis == Vector2.RIGHT:
			_pos.y += _owner.pipeline._topHMove
			_pos.x = _pf.position.x
			_owner.setposition(_pos)
		if _axis == Vector2.DOWN:
			_pos.x = _owner.pipemap.map_to_world(_pf.gridpos).x + 16
			_owner.setposition(_pos)

#			match _pf.ti[6]:
#				2,5,6,2003,2008:
#					_pos.x += _owner.pipeline._rightVMove
#					_pos.y = _pf.position.y
#					_owner.setposition(_pos)
#				1002,1005,1006,3008:
#					_pos.x += _owner.pipeline._leftVMove
#					_pos.y = _pf.position.y
#					_owner.setposition(_pos)
	return

func get_next_direction(_pf) -> Vector2:
	if abs(_pf.direction.x):
		#try up/down as the next directions
		var _trydir = Vector2.UP
		if _pf.available_directions[_trydir]:
			return _trydir
		else:
			_trydir = Vector2.DOWN
			if _pf.available_directions[_trydir]:
				return _trydir
			else:
				#must be at an end, reverse direction
				return _pf.direction *  Vector2.LEFT
	else:
		#must be travelling up/down
		#try left/roght as the next directions
		var _trydir = Vector2.LEFT
		if _pf.available_directions[_trydir]:
			return _trydir
		else:
			_trydir = Vector2.RIGHT
			if _pf.available_directions[_trydir]:
				return _trydir
			else:
				#must be at an end, reverse direction
				return _pf.direction * Vector2.UP
# warning-ignore:unreachable_code
	return _pf.direction
