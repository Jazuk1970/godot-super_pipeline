extends Node
onready var Anim = $AnimationPlayer

func _ready():
	Anim.play("Explode")
	yield(Anim,"animation_finished")
	queue_free()
