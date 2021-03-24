extends State

func enter(_args:Dictionary = {}):
	#temp add enemy code
	_owner.pipeline.startflow = true
	var _es = _owner.oEnemySpawner.instance()
	globals.level.add_child(_es)
	pass
	
func exit(_args:Dictionary = {}):
	pass
			
func logic(_args:Dictionary = {}):
	emit_signal("StateChange","Quit")
