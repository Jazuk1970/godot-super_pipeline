extends Node
# warning-ignore:unused_class_variable
export (PackedScene) var Plug
# warning-ignore:unused_class_variable
export (PackedScene) var Ant
# warning-ignore:unused_class_variable
export (PackedScene) var Flea
# warning-ignore:unused_class_variable
export (PackedScene) var Lobster
# warning-ignore:unused_class_variable
export (PackedScene) var Block

var Enemies:Dictionary = {}
var EnemiesForRemoval:Dictionary = {}
var EnemiesForRespawn:Dictionary = {}
var EnemiesToRemove:int setget remove_enemies
var EnemyRespawn:bool = true

func _ready():
	var _Enemies = globals.Level_Data.Enemies
	for _EnemyType in _Enemies:
		for _Enemy in _Enemies[_EnemyType]:
			if _Enemies[_EnemyType][_Enemy].has("initial_delay"):
				if _Enemies[_EnemyType][_Enemy].initial_delay == "0":
					globals.enemies.add_child(spawn(_EnemyType,_Enemy))
				else:
					add_respawn(_EnemyType,_Enemy,_Enemies[_EnemyType][_Enemy].initial_delay)
			else:
				globals.enemies.add_child(spawn(_EnemyType,_Enemy))

func _process(delta):
	if EnemiesForRemoval.size() > 0:
		self.EnemiesToRemove = EnemiesForRemoval.size()
	if EnemiesForRespawn.size() > 0 and EnemyRespawn:
		for _EnemyType in EnemiesForRespawn:
			for _Enemy in EnemiesForRespawn[_EnemyType]:
				EnemiesForRespawn[_EnemyType][_Enemy].elapsed += delta
				if EnemiesForRespawn[_EnemyType][_Enemy].elapsed > EnemiesForRespawn[_EnemyType][_Enemy].delay.to_float():
					var _new_enemy = spawn(_EnemyType,EnemiesForRespawn[_EnemyType][_Enemy].id)
					_new_enemy.initial_delay = 0.0
					globals.enemies.add_child(_new_enemy)
					EnemiesForRespawn[_EnemyType].erase(EnemiesForRespawn[_EnemyType][_Enemy].id)
					if EnemiesForRespawn[_EnemyType].size() == 0:
						EnemiesForRespawn.erase(_EnemyType)
	return delta

func remove_enemies(_num):
	EnemiesToRemove = _num
	if _num > 0:
		for _type in EnemiesForRemoval:
			if Enemies.has(_type):
				for _idx in EnemiesForRemoval[_type].size():
					if Enemies[_type].has(EnemiesForRemoval[_type][_idx]):
						Enemies[_type].erase(EnemiesForRemoval[_type][_idx])
					EnemiesForRemoval[_type].remove(_idx)
				if Enemies[_type].size() == 0:
					Enemies.erase(_type)
			EnemiesForRemoval.erase(_type)

func add_respawn(_type,_id,_delay):
	if not EnemiesForRespawn.has(_type):
		EnemiesForRespawn[_type] = {}
	var _respawn = {"id":_id,"delay":_delay,"elapsed":0}
	EnemiesForRespawn[_type][_id] = _respawn

func spawn(_type,_id) -> Object:
	var _Enemies = globals.Level_Data.Enemies
	if _Enemies.has(_type):
		if _Enemies[_type].has(_id):
			var _Enemy = _Enemies[_type][_id]
			var _e = getType(_type)
			if _e != null:
				_e.name = _type + "_" + _id
				_e.id = _id
				_e.speed = _Enemy.speed.to_float()
				if _Enemy.has("points"):
					_e.points = _Enemy.points.to_int()
				
				match _type:
					"Plug":
						_e.source_gridpos = globals.getVect(_Enemy.start_position)
						for _t in _Enemy.targets:
							_e.targets.append(globals.getVect(_t))

					"Ant","Flea","Lobster":
						_e.spawn_frequency = _Enemy.spawn_frequency.to_float()
						_e.initial_delay = _Enemy.initial_delay.to_float()
					"Block":
						_e.source_gridpos = globals.getVect(_Enemy.source_gridpos)
						_e.target_gridpos = globals.getVect(_Enemy.target_gridpos)
				return _e
	return null

func getType(_type) -> Object:
	match _type:
		"Plug":
			return Plug.instance()
			#return Plug.new()
		"Ant":
			return Ant.instance()
		"Flea":
			return Flea.instance()
		"Lobster":
			return Lobster.instance()
		"Block":
			return Block.instance()
	return null
