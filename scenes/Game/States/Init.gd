extends State

func enter(_args:Dictionary = {}):
	globals.hud.visible = false
	globals.hud._initialise()
	globals.Current_Player = 1
	
func exit(_args:Dictionary = {}):
	pass
			
func logic(_args:Dictionary = {}):
	emit_signal("StateChange","LoadLevel")
	
