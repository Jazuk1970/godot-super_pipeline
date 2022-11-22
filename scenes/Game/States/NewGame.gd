extends State

func enter(_args:Dictionary = {}):
	globals.hud.visible = false
	globals.hud.initialise()
	globals.Current_Player = 1
	globals.Demo_Mode = false
	globals.Demo_Level = "01"
	globals.Demo_NextState = 0
	_owner.Level = globals.playerstats[1].level
	emit_signal("StateChange","LoadLevel")
	
func exit(_args:Dictionary = {}):
	pass
			
func logic(_args:Dictionary = {}):
	pass
	
	
