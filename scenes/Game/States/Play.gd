extends State
var complete_done:bool = false

func enter(_args:Dictionary = {}):
	_owner.pipeline.startflow = true
	var _es = _owner.oEnemySpawner.instance()
	globals.level.add_child(_es)
	var _hs = _owner.oHelperSpawner.instance()
	globals.level.add_child(_hs)
	_owner.pipeline.connect("fill_complete",self,"on_Pipeline_Fill_Complete")
	var _bl = _owner.oBarrel.instance()
	_bl.position = _owner.pipeline._waterfall.position
	globals.barrel = _bl
	globals.barrel.fill_level(0)
	globals.level.add_child(_bl)
	complete_done = false
	_owner.player = _owner.oPlayer.instance()
	_owner.player.pf.gridpos = globals.getVect(globals.Level_Data.Player_Start_Position)
	_owner.player.connect("lifelost",self,"on_player_lifeLost")
	globals.players.add_child(_owner.player)
	globals.oCurrent_Player = _owner.player
	#Make the current player flash on the hud
	globals.hud.updatePlayer(globals.Current_Player,"Active")
	_play_level_music()


func exit(_args:Dictionary = {}):
	pass

func logic(_args:Dictionary = {}):
	pass


func on_Pipeline_Fill_Complete():
	if not complete_done:
		emit_signal("StateChange","LevelComplete")
		AudioManager.sfx_stop("HAMMER")
		AudioManager.music_stop()
		complete_done = true

func _play_level_music():
	#First wait until the music player is stopped
	if globals.Level_Data.has("Music"):
		if AudioManager.music_player.is_playing():
			yield(AudioManager.music_player,"finished")
			AudioManager.music_play(globals.Level_Data.Music)
		else:			
			AudioManager.music_play(globals.Level_Data.Music)

func on_player_lifeLost():
	AudioManager.sfx_stop("HAMMER")
	globals.hud.updateLives(globals.Current_Player,1)
	if globals.playerstats[globals.Current_Player].lives <= 0:
		#game over
		emit_signal("StateChange","GameOver")
	else:
		emit_signal("StateChange","LifeLost")
