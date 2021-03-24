extends State
var pipeline:Object

func enter(_args:Dictionary = {}):
	pipeline = globals.level.get_node("pipeline")
	var _i = pipeline.get_pipe(_owner.gridpos)
	if _i != -1:
		var _p = pipeline.pipeline[_i]
		_p.blockreq = true
	
func exit(_args:Dictionary = {}):
	var _i = pipeline.get_pipe(_owner.gridpos)
	if _i != -1:
		var _p = pipeline.pipeline[_i]
		_p.blockreq = false
		_owner.gridpos = _owner.source_gridpos
	_owner.trigger = false
		
func logic(_args:Dictionary = {}):
		if _owner.trigger:
#			emit_signal("StateChange","Waiting")
			_owner.queue_free()
