extends State

func enter(_args:Dictionary = {}):
	pass

func exit(_args:Dictionary = {}):
	pass

func logic(_args:Dictionary = {}):
	if _owner.pipeline._draw_idx == 0 and _owner.pipeline.tmr.is_stopped():
		_owner.pipeline.draw_pipeline()
	if not _owner.pipeline._draw_done:
		return
	_owner.player = _owner.oPlayer.instance()
#	_owner.player.pf.gridpos = Vector2(globals.Level_Data.Player_Start_Position.left(2),globals.Level_Data.Player_Start_Position.right(2))
	_owner.player.pf.gridpos = globals.getVect(globals.Level_Data.Player_Start_Position)
	globals.players.add_child(_owner.player)
	emit_signal("StateChange","Play")
