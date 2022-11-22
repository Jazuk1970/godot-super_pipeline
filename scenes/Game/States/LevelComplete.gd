extends State
var _es:Object
var _win_time:float = 3.5

func enter(_args:Dictionary = {}):
	#Make the current player stop flashing
	globals.hud.updatePlayer(globals.Current_Player,"Inactive")
	#Update the score with the level fill bonus
	globals.hud.updateScore(globals.Current_Player,globals.barrel._fill_level)
	#Turn off enemy respawn
	_es = globals.level.get_node("EnemySpawner")
	_es.EnemyRespawn = false
	
	#Make the player and helper display the winning animation and stop moving
	get_tree().call_group("Players","_winning")
	
	#Kill all on screen enemies
	get_tree().call_group("Enemy","_self_destruct")

	yield(get_tree().create_timer(0.5), "timeout")
	AudioManager.music_play("STAGE_CLEAR")

	yield(get_tree().create_timer(_win_time), "timeout")
	globals.playerstats[globals.Current_Player].level = globals.Level_Data.Next_Level

	emit_signal("StateChange","LevelReset")
	

func exit(_args:Dictionary = {}):
	pass

func logic(_args:Dictionary = {}):
	pass

