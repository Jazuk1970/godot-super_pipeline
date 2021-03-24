extends State

func enter(_args:Dictionary = {}):
	pass
	
func exit(_args:Dictionary = {}):
	pass
			
func logic(_args:Dictionary = {}):
	emit_signal("StateChange","LoadLevel")
