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
	pf.gridpos = Vector2(-2,14)
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
	if _a.is_in_group("Enemy"):
		if _a.is_in_group("Plug"): 
			if _a.fsm.statename == "Blocking":
				fsm._on_state_change("Repairing")
				target = _a
		elif _a.fsm.statename != "Dying":
			fsm._on_state_change("Dying")
	else:
		if _a.is_in_group("Player") and fsm.statename == "Idle" or fsm.statename == "Spawning":
			#set the target to the player
			target = _a
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
	if target_pos != Vector2.ZERO and target:
		draw_line(Vector2.ZERO,target_pos - position,Color(1.0,0,0))
