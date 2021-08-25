extends Area2D
var bullet_size:Vector2
var speed:int = 1200
var direction = Vector2.ZERO
var collisions:Array = []
var _next_position:Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	bullet_size = $Sprite.get_texture().get_size()
	set_physics_process(true)
	


func _physics_process(_delta):
	_next_position = position + (direction * speed * _delta) #+ (Vector2(bullet_size.x * 0.5,0))
	var space_state = get_world_2d().direct_space_state
	var _result = space_state.intersect_ray(position,_next_position,[self],collision_mask,false,true)
#	if not _result: #_result.size() == 0:
	position += direction * speed * _delta
#	else:
#		var _collider = _result.collider
#		position.x = _result.position.x #- (bullet_size.x/2)
#		_check_collider(_collider)

	if position.x < 0 - bullet_size.x or position.x > globals.screen_size.x + bullet_size.x:
		queue_free()

func _check_collider(_collider):
	var _group = _collider.get_groups()
	if _group.has("Enemy"):
			#_collider.hit = true
			_collider.emit_signal("hit")
			queue_free()


func _on_Bullet_area_entered(area):
	if not collisions.has(area):
		collisions.append(area)


func _on_Bullet_area_exited(area):
	if collisions.has(area):
		collisions.erase(area)

