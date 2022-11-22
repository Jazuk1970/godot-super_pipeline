extends State
export (PackedScene) var oGameOver

func enter(_args:Dictionary = {}):
	#Make the current player stop flashing
	globals.hud.updatePlayer(globals.Current_Player,"Inactive")
	#Turn off enemy respawn
	var _es = globals.level.get_node("EnemySpawner")
	_es.EnemyRespawn = false
	#stop the player from moving
	globals.oCurrent_Player.moveenabled = false
	globals.oCurrent_Player.stop()
	get_tree().call_group("Pipeline","master_flow_enable",false)
	
	#Kill all on screen enemies
	get_tree().call_group("Enemy","_self_destruct")
	utility.queue_free_children(globals.enemies)	
	AudioManager.sfx_stop("HAMMER")
	globals.Demo_Level = "01"

	#Instance the game over message
	var _go = oGameOver.instance()
	globals.level.add_child(_go)
	AudioManager.music_play("GAME_OVER")
	AudioManager.connect("MusicFinished",self,"on_Music_Finished")
	if !globals.InGameMusic:
		on_Music_Finished()

func exit(_args:Dictionary = {}):
	pass

func logic(_args:Dictionary = {}):
	pass

func on_Music_Finished():
	AudioManager.disconnect("MusicFinished",self,"on_Music_Finished")
	if globals.getRank(globals.playerstats[globals.Current_Player].score) > 0:
		_owner.ResetAndStateChange("NewHiScore")
	else:
		if globals.Players > 1:
			if globals.playerstats[1].lives == 0 and globals.playerstats[2].lives == 0:
				#All players dead - show high scores
				_owner.ResetAndStateChange("HiScores")
			else:
				#if the current player is 1 (and its game over) the next player in multiplay must be 2
				if globals.Current_Player == 1:
					globals.Current_Player =2
				else:
					#otherwise the next player must be 1
					globals.Current_Player =1
				_owner.Level = globals.playerstats[globals.Current_Player].level
				_owner.ResetAndStateChange("LevelReset")
