extends Area2D
#Preload scenes
var oBullet = preload("res://scenes/player/bullet/bullet.tscn")
signal directionchange
# warning-ignore:unused_class_variable
onready var parent = get_parent()
onready var spr = $Sprite
onready var anim = $AnimationPlayer
onready var scdtimer = $ShootCoolDown
onready var bulletspawn = $Sprite/BulletSpawn
export var speed = 400
var pipemap:TileMap
var pipeline:Object
var pf:PipeFollower = PipeFollower.new()
var canshoot:bool = true
var cooldowntime:float = 0.3
var collisions:Array = []

func _ready():
	set_process(true)
#	var _owner = get_parent()
	var _owner = globals.mainscene
	pipeline = _owner.get_node("level/pipeline")
	pipemap = pipeline.map
	anim.play("StandStill")
	pf.facingdirection = Vector2.RIGHT
	_setposition(pipemap.map_to_world(pf.gridpos) + Vector2(1,1))

func _process(delta):
	pf.inputdirection = get_input_direction()
	var _ld:Vector2
	if pf.inputdirection and canshoot:
		pf.dist = speed * delta
		pf.direction = pf.inputdirection
		pf.moving = false
		if pf.direction.abs() == Vector2.ONE:
			#if both horizontal and vertical movements are requested first try the direction we were last moving in
			pf.direction = pf.inputdirection * pf.lastmovement
#			pf =  pipeline.checkmove(pf)
			pipeline.checkmove(pf)
#			pf.dist = pf.available_directions[pf.direction]
			#if we cannot move in the same direction as last time or we are at a junction, try the other direction
			if pf.dist == 0:# or (pf.ti[6] in [2,1002] and not pf.supressdirchange):
				pf.supressdirchange = true
				if pf.lastmovement == Vector2.RIGHT:
					pf.direction = pf.inputdirection * Vector2.DOWN
#					pf.dist = speed * delta
#					pf =  pipeline.checkmove(pf)
					pf.dist = pf.available_directions[pf.direction]
				else:
					pf.direction = pf.inputdirection * Vector2.RIGHT
#					pf.dist = speed * delta
#					pf =  pipeline.checkmove(pf)
					pf.dist = pf.available_directions[pf.direction]

		else:
#			pf =  pipeline.checkmove(pf)
			pipeline.checkmove(pf)
#			pf.dist = pf.available_directions[pf.direction]
#			pf =  pipeline.checkmove(pf)

		if pf.direction.x > 0 or abs(pf.direction.y) > 0:
			spr.flip_h = true
			bulletspawn.position.x = abs(bulletspawn.position.x)
		else:
			spr.flip_h = false
			bulletspawn.position.x = abs(bulletspawn.position.x) * -1
		if pf.direction.y != 0:
			pf.position.x = pipemap.map_to_world(pf.gridpos).x + 16

		if pf.dist:
			pf = move(pf)
	else:
		pf.moving = false
	if Input.is_action_pressed("fire") and canshoot and not pf.moving and pf.facingdirection.abs() == Vector2.RIGHT:
		_shoot(pf)

#	pf = _setanimation(pf)
	_setanimation(pf)
	var _atm = true if pf.dist else false
	globals.mainscene.PlayerPos.text = str(position, " , pos in tile: ",utility.vect2Int(pf.ti[5]), " , Able to move: ",_atm, " , Moving: ",pf.moving, " , Facing Direction: ",pf.facingdirection)
	globals.mainscene.PlayerGridPos.text = str(pf.gridpos, " , Rel Dist: ",position - pipemap.map_to_world(pf.gridpos))

func get_input_direction():
	var _id = Vector2()
	_id.x = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
	_id.y = int(Input.is_action_pressed("move_down")) - int(Input.is_action_pressed("move_up"))
	return _id

func move(_pf) -> PipeFollower:
	_pf.moving = true
#	emit_signal("directionchange",[_pf.direction,_pf.gridpos,_pf.lastmovement,"update"])
	_setposition(_pf.position + (_pf.dist * _pf.direction))
	var _axis = _pf.direction.abs()
	if _pf.direction != _pf.prevdirection and _pf.direction:
		_pf.prevdirection = _pf.direction
		#emit_signal("directionchange",[_pf.direction,position,"dir change"])
		emit_signal("directionchange",[_pf.position,_pf.direction])

	if _pf.lastmovement != _axis:
		_pf.lastmovement = _axis

		var _pos = pipemap.map_to_world(_pf.gridpos)
		#emit_signal("directionchange",[_pf.direction,_pos,"axis_change"])
		if _axis == Vector2.RIGHT:
			_pos.y += pipeline._topHMove
			_pos.x = _pf.position.x
			_setposition(_pos)
		if _axis == Vector2.DOWN:
			match _pf.ti[6]:
				2,5,6,2003,2008:
					_pos.x += pipeline._rightVMove
					_pos.y = _pf.position.y
					_setposition(_pos)
				1002,1005,1006,3008:
					_pos.x += pipeline._leftVMove
					_pos.y = _pf.position.y
					_setposition(_pos)
	return _pf

func _shoot(_pf):
	var _bullet = oBullet.instance()
	_bullet.position = bulletspawn.global_position
	_bullet.direction = pf.facingdirection
	var _level = globals.mainscene.get_node("level")
	_level.add_child(_bullet)
	anim.play("Shoot")
	scdtimer.start(cooldowntime)
	canshoot = false


func _setposition(_p):
	pf.position = _p
	position = _p.snapped(Vector2(1,1))
	var _newgridpos = pipemap.world_to_map(position)
	if _newgridpos != pf.gridpos:
		pf.supressdirchange = false
	pf.gridpos = _newgridpos

func _setanimation(_pf):# -> PipeFollower:
	if anim.current_animation == "Shoot":
		 return #_pf
	if _pf.moving:
		if _pf.prevdirection != _pf.fdmemory or not anim.is_playing():
			_pf.facingdirection = _pf.prevdirection
			_pf.fdmemory = _pf.facingdirection
			match _pf.facingdirection:
				Vector2.RIGHT, Vector2.LEFT:
					anim.play("Walk")
				Vector2.UP, Vector2.DOWN:
					anim.play("Climb")
	else:
		if _pf.inputdirection.abs() == Vector2.RIGHT and not _pf.moving:
			_pf.facingdirection = _pf.inputdirection
		if anim.current_animation in ["Walk","Climb"] or _pf.facingdirection != _pf.fdmemory:
			match _pf.facingdirection:
				Vector2.RIGHT, Vector2.LEFT:
					anim.play("StandStill")
				Vector2.UP, Vector2.DOWN:
					anim.play("ClimbStop")
				_:
					anim.play("StandStill")
			_pf.fdmemory = Vector2.ZERO
	return #_pf


func _on_ShootCoolDown_timeout():
	canshoot = true
	anim.play("StandStill")


func _on_player_area_entered(area):
	if not collisions.has(area):
		collisions.append(area)


func _on_player_area_exited(area):
	if collisions.has(area):
		collisions.erase(area)

