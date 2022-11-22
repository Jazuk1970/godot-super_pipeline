extends Enemy
#var pipemap:TileMap
#var pipeline:Object
# warning-ignore:unused_class_variable
var gridpos:Vector2
# warning-ignore:unused_class_variable
var source_gridpos:Vector2
# warning-ignore:unused_class_variable
var target_gridpos:Vector2
# warning-ignore:unused_class_variable
var targets:Array = []
# warning-ignore:unused_class_variable
var health = 1000
# warning-ignore:unused_class_variable
var dist:float
# warning-ignore:unused_class_variable
var direction = Vector2.DOWN
# warning-ignore:unused_class_variable
var trigger:bool

func _ready():
	set_process(true)
	fsm.add_states($States)
	fsm._on_state_change("Waiting")

func _process(delta):
	if fsm.state != null:
		var _args = {"delta":delta}
		fsm.state.logic(_args)
