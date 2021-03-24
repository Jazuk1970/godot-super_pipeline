extends State

func enter(_args:Dictionary = {}):
	var _fname = "res://level_data/"+ _owner.Level + ".json"
	var _data = file_handling.LoadFile(_fname)
	if _data[0] == 0:
		globals.Level_Data = _data[1].Level
		_data = null
		_owner.pipeline = _owner.oPipeline.instance()
		_owner.pipeline.pipestring = globals.Level_Data.PipeData
		globals.level.add_child(_owner.pipeline)
		emit_signal("StateChange","DrawLevel")	

func exit(_args:Dictionary = {}):
	pass
			
func logic(_args:Dictionary = {}):
	pass
