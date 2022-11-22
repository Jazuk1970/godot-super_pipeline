extends Area2D
onready var spr = $Sprite
var oBoom = preload("res://scenes/player/boom/boom.tscn")
var bullet_size:Vector2
var speed:int = 1200
var direction = Vector2.ZERO
var collisions:Array = []
var _next_position:Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	bullet_size = spr.get_texture().get_size()
	set_physics_process(true)
	


func _physics_process(_delta):
	_next_position = position + (direction * (speed * _delta)) #+ (Vector2(bullet_size.x * 0.5,0))
	var space_state = get_world_2d().direct_space_state
	var _result = space_state.intersect_ray(position,_next_position,[self],collision_mask,false,true)
	if not _result: #_result.size() == 0:
		position += direction * (speed * _delta)
	else:
		var _collider = _result.collider
		var _collider_width = ((_collider.spr.texture.get_width() / _collider.spr.hframes) / 2) + 2 # Two pixels inside the collider
#		position.x = _result.position.x + (_collider_width * (direction.x * -1))  #- (bullet_size.x/2)
		position.x = _collider.position.x + _collider.col.position.x 
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

func boom(_position):
	var _boom = oBoom.instance()
	_boom.position = _position
	globals.enemies.add_child(_boom)
