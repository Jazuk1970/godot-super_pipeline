extends State
var pipeline:Object

func enter(_args:Dictionary = {}):
	pipeline = globals.level.get_node("pipeline")
	var _i = pipeline.get_pipe(_owner.gridpos)
	if _i != -1:
		var _p = pipeline.pipeline[_i]
		_p.blockreq = true
	
func exit(_args:Dictionary = {}):
	pass
		
func logic(_args:Dictionary = {}):
		if _owner.trigger:
			var _i = pipeline.get_pipe(_owner.gridpos)
			if _i != -1:
				var _p = pipeline.pipeline[_i]
				_p.blockreq = false
			_owner.trigger = false
			#Update the score
			globals.hud._updateScore(globals.Current_Player,_owner.points)
			_owner.queue_free()
