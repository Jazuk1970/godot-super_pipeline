extends State
func enter(_args:Dictionary = {}):
	_owner.emit_signal("lifelost")
#		globals.playerstats[globals.Current_Player].lives -= 1
#		if globals.playerstats[globals.Current_Player].lives == 0:
#			#game over
#			pass
#		else:
#			#spawn life lost gamestate
#			pass
		
	
func exit(_args:Dictionary = {}):
	pass

func logic(_args:Dictionary = {}):
	var _delta = _args["delta"]
	
