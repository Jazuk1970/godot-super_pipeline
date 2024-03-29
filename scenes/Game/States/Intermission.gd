extends State
var Lobster:Object
var Helper:Object
var IntermissionState:int = 0
var _delay_time:float = 1.0
var _helper_start_position:int = 60
func enter(_args:Dictionary = {}):
	_owner.player = _owner.oPlayer.instance()
	_owner.player.speed += 125
	_owner.player.pf.gridpos = Vector2(globals.Level_Data.Player_Start_Position.left(2),globals.Level_Data.Player_Start_Position.right(2))
	_owner.player.pf.gridpos = globals.getVect(globals.Level_Data.Player_Start_Position)
	globals.players.add_child(_owner.player)
	IntermissionState = 0
	
	var _hs = _owner.oHelperSpawner.instance()
	globals.level.add_child(_hs)

	var _es = _owner.oEnemySpawner.instance()
	globals.level.add_child(_es)

	pass

func exit(_args:Dictionary = {}):
	pass

func logic(_args:Dictionary = {}):
	match IntermissionState:
		0:
			#Wait for the lobster to be spawned
			if globals.enemies.get_children().size() > 0:
				Lobster = globals.enemies.get_child(0)
				Lobster.speed += 125
				_play_intermission_music()
				NextState()
		1:
			#Wait for the helper to be spawned
			if globals.helpers.get_children().size() > 0:
				Helper = globals.helpers.get_child(0)
				Helper.fsm._on_state_change("Idle")
				Helper.speed += 125
				Helper.pf.gridpos.x = _helper_start_position
				Helper.setpositionfromgrid(Helper.pf.gridpos)
				NextState()
		2:
			#Start the player walking to the right, the helper should follow
			_owner.player.remote_input_direction = Vector2.RIGHT
			if _owner.player.pf.gridpos.x > 58:
				Helper.target = _owner.player
				Helper.fsm._on_state_change("Following")
				if Helper.fsm.statename == "Following":
					NextState()
		3:
			#Start the player walking to the left
			#The helper should follow, the follow distance is reduced to make the helper walk off view
			#and start the lobster walking to the left
			_owner.player.remote_input_direction = Vector2.LEFT
			Lobster.pf.direction = Vector2.LEFT
			if _owner.player.pf.gridpos.x < 30:
				Helper.follow_dist = 5
			if Lobster.pf.gridpos.x <1:
				NextState()
		4:
			#Call the delay function which after a short time will trigger a level reset
			Delay()
			NextState()


func NextState():
	IntermissionState +=1

func Delay():
	yield(get_tree().create_timer(_delay_time), "timeout")
	globals.playerstats[globals.Current_Player].level = globals.Level_Data.Next_Level
	emit_signal("StateChange","LevelReset")
	
func _play_intermission_music():
	if globals.Level_Data.has("Music"):
		AudioManager.music_play(globals.Level_Data.Music)
