extends Enemy
#var pipemap:TileMap
#var pipeline:Object
# warning-ignore:unused_class_variable
var gridpos:Vector2
# warning-ignore:unused_class_variable
var source_gridpos:Vector2 = Vector2(42,12)
# warning-ignore:unused_class_variable
var target_gridpos:Vector2 = Vector2(42,20)
# warning-ignore:unused_class_variable
var targets:Array
# warning-ignore:unused_class_variable
var health = 100
# warning-ignore:unused_class_variable
var dist:float
# warning-ignore:unused_class_variable
var direction = Vector2.DOWN
# warning-ignore:unused_class_variable
var trigger:bool
var target_pos:Vector2

func _ready():
	set_process(true)
	position = source_gridpos * globals.tile_size
	fsm.add_states($States)
	fsm._on_state_change("Moving_B")

func _process(delta):
	if fsm.state != null:
		var _args = {"delta":delta}
		fsm.state.logic(_args)
	
func _collided(_a):
	if _a.is_in_group("Bullet"):
		#score modifier required
		_a.queue_free()
