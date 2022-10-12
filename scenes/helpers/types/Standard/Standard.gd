extends Mob
# warning-ignore:unused_class_variable
var start_pos:Vector2
# warning-ignore:unused_class_variable
var target_pos:Vector2
# warning-ignore:unused_class_variable
var targets:Array = []
# warning-ignore:unused_class_variable
var target:Object
# warning-ignore:unused_class_variable
var health = 100
# warning-ignore:unused_class_variable
var dist:float
# warning-ignore:unused_class_variable
var follow_dist:float
# warning-ignore:unused_class_variable
var work_effeciency:float

# warning-ignore:unused_class_variable
var direction:Vector2
# warning-ignore:unused_class_variable
var pf:PipeFollower = PipeFollower.new()
# warning-ignore:unused_class_variable
var pipemap:TileMap
# warning-ignore:unused_class_variable
var pipeline:Object
var winning:bool = false


func _ready():
	set_process(true)
	fsm._owner = self
	add_to_group(type)
	add_to_group("Helpers")
	Spawner = globals.level.get_node("HelperSpawner")

	if not Spawner.helpers.has(type):
		Spawner.helpers[type] = []
	Spawner.helpers[type].append(name)

	#speed = 400
	pipeline = globals.level.get_node("pipeline")
	pipemap = pipeline.map
	fsm.add_states($States)
	pf.facingdirection = Vector2.RIGHT
	pf.gridpos = Vector2(-2,globals.getVect(globals.Level_Data.Player_Start_Position).y)
	_setposition(pipemap.map_to_world(pf.gridpos) + Vector2(1,1))
	#start_pos = Vector2(-2,14) * globals.tile_size
	fsm._on_state_change("Spawning")

func _process(delta):
	update()
	if fsm.state != null:
		var _args = {"delta":delta}
		fsm.state.logic(_args)
	#Set the sprite facing direction
	if pf.facingdirection.x > 0:
		spr.flip_h = true
	else:
		spr.flip_h = false

func _setposition(_p):
	pf.position = _p
	position = _p.snapped(Vector2(1,1))
	var _newgridpos = pipemap.world_to_map(position)
	if _newgridpos != pf.gridpos:
		pf.supressdirchange = false
	pf.gridpos = _newgridpos

func _collided(_a):
	#Check if we have collided with an enemy
	if _a.is_in_group("Enemy"):
		#Check if the enemy is a plug
		if _a.is_in_group("Plug"):
			#Check if the plug is currently  blocking flow
			if _a.fsm.statename == "Blocking":
				#Set the helper state to repairing
				fsm._on_state_change("Repairing")
				#Set the target plug so we know what to remove when the repair is done
				target = _a
		#If the enemy is not a plug, is the enemy not currently dying
		elif _a.fsm.statename != "Dying":
			#Set the helper state to dying as the enemy has killed him
			fsm._on_state_change("Dying")
			#Set the enemy state to dying also to remove the enemy
			_a.fsm._on_state_change("Dying")
	else:
		#Check if the collision is with the player, and the helper is ready to follow
		if _a.is_in_group("Player") and fsm.statename == "Idle" or fsm.statename == "Spawning":
			#set the target to the player
			target = _a
			#Set the helper state to following
			if fsm.state.name != "Following":
				fsm._on_state_change("Following")

func _on_area_entered(area):
	if not collisions.has(area):
		collisions.append(area)
		_collided(area)

func _on_area_exited(area):
	if collisions.has(area):
		collisions.erase(area)

func _exit_tree():
	if Spawner.helpers.has(type):
		if Spawner.helpers[type].has(name):
			if not Spawner.helpersForRemoval.has(type):
				Spawner.helpersForRemoval[type] = []
				Spawner.helpersForRemoval[type].append(name)
	if spawn_frequency != 0:
		Spawner.add_respawn(type,id,str(spawn_frequency))

func _draw():
	if not globals.DEBUG:
		return
	if target_pos != Vector2.ZERO and target:
		draw_line(Vector2.ZERO,target_pos - position,Color(1.0,0,0))

func _on_Timer_timeout():
	if fsm.state != null:
		#if the current state has a timeout method call it
		if fsm.state.has_method("_on_Timer_timeout"):
			fsm.state._on_Timer_timeout()

func _winning():
	winning = true
	if fsm.state.name == "Following" or fsm.state.name == "Idle" or fsm.state.name == "Repairing":
		fsm._on_state_change("Winning")
