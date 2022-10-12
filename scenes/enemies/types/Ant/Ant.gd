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

func _ready():
	fsm.add_states($States)
	start_pos = Vector2(44,35) * globals.tile_size
	position = start_pos
	speed = 150
	timer.start(initial_delay)
	self_destructs = true
#	fsm._on_state_change("Climbing")

func _process(delta):
	if fsm.state != null:
		var _args = {"delta":delta}
		fsm.state.logic(_args)


func _collided(_a):
	if _a.is_in_group("Bullet"):
		#score modifier required
		globals.hud._updateScore(globals.Current_Player,points)
		_a.queue_free()
		fsm._on_state_change("Dying")


func _on_Timer_timeout():
	fsm._on_state_change("Climbing")

func _hit():
	if fsm.state.name != "Dying":
		fsm._on_state_change("Dying")
