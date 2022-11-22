extends State
var max_follow_distance:float = 400.0
var _total_remaining_distance:float = 0.0
var _dist:float = 0.0
var last_player_positions:Array = []
var current_target_position:Vector2 = Vector2.ZERO
var current_target_direction:Vector2 = Vector2.ZERO
var moving_to_position:bool = false
var flashing:bool = false
var flashrate:float = 0.5
var altcol:Color = Color8(255,255,150)

func enter(_args:Dictionary = {}):
	current_target_position = _owner.target.position
	_owner._setposition(_owner.position)
	_owner.anim.play("Idle")
	if not _owner.target.is_connected("directionchange",self,"_player_direction_changed"):
		_owner.target.connect("directionchange",self,"_player_direction_changed")
	moving_to_position = false
	last_player_positions.clear()
	last_player_positions.append([_owner.target.position,clamp_direction(_owner.position.direction_to(current_target_position))])
	if globals.Game_State.statename == "Play":
		flashing = false
		_owner.spr.modulate = Color8(255,255,255)
		_owner.timer.one_shot = true
		_owner.timer.start(flashrate)

func exit(_args:Dictionary = {}):
	_owner.spr.modulate = Color8(255,255,255)


func logic(_args:Dictionary = {}):
	var _delta = _args["delta"]
	var _last_log:Array = []
	_owner.pf.moving = false
	#Check we still have a target object (player)
	if _owner.target:
		var _last_pos:Vector2 = _owner.position
		_total_remaining_distance = 0.0
		for _log in last_player_positions:
			_total_remaining_distance += abs(_last_pos.x - _log[0].x) + abs(_last_pos.y - _log[0].y)
			_last_pos = _log[0]
		_total_remaining_distance += _last_pos.distance_to(_owner.target.position)


		#If the distance to the player becomes too large detach from the player
		_dist = _owner.position.distance_to(_owner.target.position)
		if _dist > max_follow_distance:
			_owner.target = null
			last_player_positions.clear()
			current_target_position = _owner.position
			emit_signal("StateChange","Idle")
			_setanimation(_owner.pf)
			return

		if _total_remaining_distance < _owner.follow_dist :
			_setanimation(_owner.pf)
			return

		#if we have anything in the position list try and move towards the target
		#note: one axis should always match!
		if last_player_positions.size() > 0 and not moving_to_position:
			current_target_position = last_player_positions.front()[0]
			current_target_direction = dir_to(_owner.position,current_target_position)
			_owner.pf.inputdirection = current_target_direction
			moving_to_position = true

		_owner.target_pos = current_target_position
		if _owner.pf.inputdirection:
			_owner.pf.dist = _owner.speed * _delta
			_owner.pf.direction = _owner.pf.inputdirection
			_owner.pf.moving = false
			_owner.pipeline.checkmove(_owner.pf,true)
			if _owner.pf.dist != 0:
				_owner.pf = move(_owner.pf)
			else:
				if _owner.pf.lastmovement:
					_owner.pf.dist = _owner.speed * _delta
					_owner.pf.direction = _owner.pf.lastmovement
					_owner.pf.moving = false
					_owner.pipeline.checkmove(_owner.pf,true)
					if _owner.pf.dist:
						_owner.pf = move(_owner.pf)
		else:
			_owner.pf.moving = false
	var ctp = _grid(current_target_position)
	var op = _grid(_owner.position)
	if moving_to_position and _grid(current_target_position*current_target_direction.abs()) == _grid(_owner.position*current_target_direction.abs()):
		moving_to_position = false
		last_player_positions.pop_front()
		if last_player_positions.size() < 1:
			last_player_positions.append([_owner.target.position,clamp_direction(_owner.position.direction_to(current_target_position))])
	_setanimation(_owner.pf)

func move(_pf) -> PipeFollower:
	_pf.moving = true
	_owner._setposition(_pf.position + (_pf.dist * _pf.direction))
	var _axis = _pf.direction.abs()
	if _pf.direction != _pf.prevdirection and _pf.direction:
		_pf.prevdirection = _pf.direction
	if _pf.lastmovement != _axis:
		_pf.lastmovement = _axis
		var _pos = _owner.pipemap.map_to_world(_pf.gridpos)
		if _axis == Vector2.RIGHT:
			_pos.y += _owner.pipeline._topHMove
			_pos.x = _pf.position.x
			_owner._setposition(_pos)
		if _axis == Vector2.DOWN:
			match _pf.ti[6]:
				2,5,6,2003,2008:
					_pos.x += _owner.pipeline._rightVMove
					_pos.y = _pf.position.y
					_owner._setposition(_pos)
				1002,1005,1006,3008:
					_pos.x += _owner.pipeline._leftVMove
					_pos.y = _pf.position.y
					_owner._setposition(_pos)
	return _pf

func _setanimation(_pf):# -> PipeFollower:
	if _pf.moving:
		if _pf.prevdirection != _pf.fdmemory or not _owner.anim.is_playing():
			_pf.facingdirection = _pf.prevdirection
			_pf.fdmemory = _pf.facingdirection
			match _pf.facingdirection:
				Vector2.RIGHT, Vector2.LEFT:
					_owner.anim.play("Walk")
				Vector2.UP, Vector2.DOWN:
					_owner.anim.play("Climb")
	else:
		if _pf.inputdirection.abs() == Vector2.RIGHT and not _pf.moving:
			_pf.facingdirection = _pf.inputdirection
		if _owner.anim.current_animation in ["Walk","Climb"] or _pf.facingdirection != _pf.fdmemory:
			match _pf.facingdirection:
				Vector2.RIGHT, Vector2.LEFT:
					_owner.anim.play("Idle")
				Vector2.UP, Vector2.DOWN:
					_owner.anim.play("ClimbStop")
				_:
					_owner.anim.play("Idle")
			_pf.fdmemory = Vector2.ZERO
	return #_pf


func clamp_direction(v2:Vector2) -> Vector2:
	v2.x = clamp_val(v2.x)
	v2.y = clamp_val(v2.y)
	return v2

func clamp_val(v:float) -> float:
	if v > 0:
		v = 1
	elif v < -0:
		v = -1
	else:
		v = 0
	return v

func _player_direction_changed(args:Array = []):
	if _owner.target:
		var _last_log:Array = []
		if last_player_positions.size() > 0:
			if _grid(args[0]) != _grid(last_player_positions.back()[0]):
				_last_log.append(args[0]) #GridPosition
				_last_log.append(args[1]) #GridPosition
				last_player_positions.append(_last_log)
		else:
				_last_log.append(args[0]) #GridPosition
				_last_log.append(args[1]) #GridPosition
				last_player_positions.append(_last_log)

func _within_range(sv:Vector2, tv:Vector2,td:Vector2, xr:int = 2, yr:int = 2) -> bool:
	if td == Vector2.LEFT:
		if sv.x <= tv.x  and sv.y >= tv.y -yr and sv.y <= tv.y +yr:
			return true
	if td == Vector2.RIGHT:
		if sv.x >= tv.x  and sv.y >= tv.y -yr and sv.y <= tv.y +yr:
			return true
	if td == Vector2.UP:
		if sv.y <= tv.y  and sv.x >= tv.x -xr and sv.x <= tv.x +xr:
			return true
	if td == Vector2.DOWN:
		if sv.y >= tv.y  and sv.x >= tv.x -xr and sv.x <= tv.x +xr:
			return true
	return false

func dir_to(cpos:Vector2,tpos:Vector2) -> Vector2:
	var cgpos:Vector2 = _grid(cpos)
	var tgpos:Vector2 = _grid(tpos)
	if cgpos.x == tgpos.x:
		#target is vertical direction
		if cpos.y < tpos.y:
			return Vector2.DOWN
		else:
			return Vector2.UP
	else:
		#target is horizontal direction
		if cpos.x < tpos.x:
			return Vector2.RIGHT
		else:
			return Vector2.LEFT

func _grid(pos:Vector2) ->Vector2:
	return _owner.pipemap.world_to_map(pos)

func _on_Timer_timeout():
	if flashing:
		flashing = false
		_owner.spr.modulate = Color8(255,255,255)
	else:
		flashing = true
		_owner.spr.modulate = altcol
	_owner.timer.start(flashrate)
