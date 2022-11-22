extends State
var _es:Object
var _win_time:float = 3.5

func enter(_args:Dictionary = {}):
	#Make the current player stop flashing
	globals.hud.updatePlayer(globals.Current_Player,"Inactive")
	#Turn off enemy respawn
	_es = globals.level.get_node("EnemySpawner")
	_es.EnemyRespawn = false
	#stop the player from moving
	globals.oCurrent_Player.moveenabled = false
	get_tree().call_group("Pipeline","master_flow_enable",false)
	
	#Kill all on screen enemies
	get_tree().call_group("Enemy","_self_destruct")
	utility.queue_free_children(globals.enemies)
	AudioManager.sfx_stop("HAMMER")
	#Play the life lost jingle
	AudioManager.music_play("MISS")
	#Scroll the screen out
	_owner.anim.play("ScreenOut")
	#Wait for the scroll complete
	yield(_owner.anim,"animation_finished")
	#Remove the player and helper
	utility.queue_free_children(globals.helpers)
	utility.queue_free_children(globals.players)
	_owner.anim.play("ScreenIn")
	yield(_owner.anim,"animation_finished")
	camera_animation_finished()

func exit(_args:Dictionary = {}):
	pass

func logic(_args:Dictionary = {}):
	pass

func camera_animation_finished():
	globals.Level_Data.Next_Level = _owner.Level
	if globals.Players > 1:
			if (globals.Current_Player == 1 and globals.playerstats[2].lives > 0) or (globals.Current_Player == 2 and globals.playerstats[1].lives == 0):
				globals.Current_Player =2
			else:
				globals.Current_Player =1
			_owner.Level = globals.playerstats[globals.Current_Player].level
	emit_signal("StateChange","LevelReset")
