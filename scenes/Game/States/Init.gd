extends State

func enter(_args:Dictionary = {}):
	globals.hud.visible = false
	globals.hud.initialise()
	globals.getHiscores()
	globals.hud.updateHiScore(globals.hiscores[1].score)	
	globals.Current_Player = 1
	globals.Demo_Mode = false
	globals.Demo_Level = "01"
	globals.Demo_NextState = 0
	globals.cameraanim.play("Play")
	
func exit(_args:Dictionary = {}):
	pass
			
func logic(_args:Dictionary = {}):
	emit_signal("StateChange","LoadLevel")
	
