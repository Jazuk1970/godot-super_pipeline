extends Node2D
signal areaEntered(area)
signal atTarget
export (Vector2) var initialPos = Vector2.ZERO
export (float) var speed = 5.0
var targetPos:Vector2
var direction:Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	position = initialPos
	targetPos = initialPos
	set_process(true)

func _process(delta):
	if position.x != targetPos.x or position.y !=targetPos.y:
		direction = position.direction_to(targetPos)
		var velocity = speed * delta
		var movement = velocity * direction
		if abs(position.distance_to(targetPos)) <= velocity:
			position = targetPos
		else:
			position += movement
	else:
		emit_signal("atTarget")

func _on_Area2D_area_entered(area):
	emit_signal("areaEntered",area)

func _PlayAnim(anim):
	if anim == "STOP":
		$AnimationPlayer.stop()
	else:
		$AnimationPlayer.play(anim)

