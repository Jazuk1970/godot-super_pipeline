extends Area2D
class_name Mob
signal respawn
signal hit
# warning-ignore:unused_class_variable
onready var parent = get_parent()
# warning-ignore:unused_class_variable
onready var spr = $Sprite
# warning-ignore:unused_class_variable
onready var col = $CollisionShape2D
# warning-ignore:unused_class_variable
onready var anim = $AnimationPlayer
# warning-ignore:unused_class_variable
onready var timer = $Timer
# warning-ignore:unused_class_variable
export var type:String = 'Mob'
export var speed = 250
var fsm:StateMachine = StateMachine.new()
var collisions:Array = []
var Spawner:Object
# warning-ignore:unused_class_variable
var spawn_frequency:float
# warning-ignore:unused_class_variable
var initial_delay:float
var id:String

func _ready():
	set_process(true)
	fsm._owner = self
	add_to_group(type)

func _process(_delta):
	pass

func _move():
	pass


func _on_area_entered(area):
	if not collisions.has(area):
		collisions.append(area)
		_collided(area)


func _on_area_exited(area):
	if collisions.has(area):
		collisions.erase(area)

func _collided(_a):
	#collided function to be overidden in instances
	pass

func _exit_tree():
	pass

func _hit():
	#hit functino to be overidden in instances
	pass
