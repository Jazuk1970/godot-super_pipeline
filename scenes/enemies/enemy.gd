extends Mob
class_name Enemy

func _ready():
	set_process(true)
	fsm._owner = self
	add_to_group(type)
	add_to_group("Enemy")
	Spawner = globals.level.get_node("EnemySpawner")
	if not Spawner.Enemies.has(type):
		Spawner.Enemies[type] = []
	Spawner.Enemies[type].append(name)

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

func _exit_tree():
	if Spawner.Enemies.has(type):
		if Spawner.Enemies[type].has(name):
			if not Spawner.EnemiesForRemoval.has(type):
				Spawner.EnemiesForRemoval[type] = []
				Spawner.EnemiesForRemoval[type].append(name)
	if spawn_frequency != 0 and globals.Game_State.statename == "Play":
		Spawner.add_respawn(type,id,str(spawn_frequency))

func _self_destruct():
	if self_destructs:
		self.call_deferred("free")
	
