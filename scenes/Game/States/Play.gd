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
#	_owner.player.pf.gridpos = Vector2(globals.Level_Data.Player_Start_Position.left(2),globals.Level_Data.Player_Start_Position.right(2))
	_owner.player.pf.gridpos = globals.getVect(globals.Level_Data.Player_Start_Position)
	globals.players.add_child(_owner.player)
	#Make the current player flash on the hud
	globals.hud._updatePlayer(globals.Current_Player,"Active")
	$AudioStreamPlayer.play()

	pass

func exit(_args:Dictionary = {}):
	$AudioStreamPlayer.stop()

func logic(_args:Dictionary = {}):
	pass


func on_Pipeline_Fill_Complete():
	if not complete_done:
		emit_signal("StateChange","LevelComplete")
		complete_done = true
