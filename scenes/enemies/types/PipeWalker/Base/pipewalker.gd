extends Enemy
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
var direction:Vector2
# warning-ignore:unused_class_variable
var pf:PipeFollower = PipeFollower.new()
# warning-ignore:unused_class_variable
var pipemap:TileMap
# warning-ignore:unused_class_variable
var pipeline:Object

func _ready():
	speed = 150
	pipeline = globals.level.get_node("pipeline")
	pipemap = pipeline.map
	fsm.add_states($States)
	fsm._on_state_change("Spawning")

func _process(delta):
	if fsm.state != null:
		var _args = {"delta":delta}
		fsm.state.logic(_args)


func setposition(_p):
	pf.position = _p
	position = _p.snapped(Vector2(1,1))
	var _newgridpos = pipemap.world_to_map(position)
	if _newgridpos != pf.gridpos:
		pf.supressdirchange = false
	pf.gridpos = _newgridpos
