extends State
var _es:Object
var _win_time:float = 10.0

func enter(_args:Dictionary = {}):
	#Make the current player stop flashing
	globals.hud._updatePlayer(globals.Current_Player,"Inactive")
	#Update the score with the level fill bonus
	globals.hud._updateScore(globals.Current_Player,globals.barrel._fill_level)
	#Turn off enemy respawn
	_es = globals.level.get_node("EnemySpawner")
	_es.EnemyRespawn = false
	
	#Make the player and helper display the winning animation and stop moving
	get_tree().call_group("Players","_winning")
	
	#Kill all on screen enemies
	get_tree().call_group("Enemy","_self_destruct")

	yield(get_tree().create_timer(_win_time), "timeout")
	emit_signal("StateChange","LevelReset")
	

func exit(_args:Dictionary = {}):
	pass

func logic(_args:Dictionary = {}):
	pass

