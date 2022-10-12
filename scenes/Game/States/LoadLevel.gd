extends State

func enter(_args:Dictionary = {}):
	var _fname = "res://level_data/Level_"+ _owner.Level + ".json"
	var _data = file_handling.LoadFile(_fname)
	if _data[0] == 0:
		globals.Level_Data = _data[1].Level
		_data = null
		_owner.pipeline = _owner.oPipeline.instance()
		_owner.pipeline.pipestring = globals.Level_Data.PipeData
		_owner.pipeline.targetfill = globals.Level_Data.Target_Fill
		globals.level.add_child(_owner.pipeline)
		globals.hud._updateLevelName(globals.Level_Data.LevelName)
		if globals.Level_Data.Level_Type == "Pipeline":
			globals.hud.visible = true
			_owner.pipeline.flow_rate = 0.03
		else:
			globals.hud.visible = false
			_owner.pipeline.flow_rate = 0.03
			globals.bgmusic.play()
		
		emit_signal("StateChange","DrawLevel")
		


func exit(_args:Dictionary = {}):
	pass

func logic(_args:Dictionary = {}):
	pass
