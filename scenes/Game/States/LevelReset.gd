extends State
func enter(_args:Dictionary = {}):
	if globals.Demo_Mode:
		match globals.Demo_NextState:
			1:
				#Get the next level	play demo
				globals.Demo_NextState = 2
				_owner.Level =  globals.Demo_Level
			2:
				#display hiscore table
				globals.Demo_NextState = 3
			3:
				#reset for title page
				globals.Demo_NextState = 0
				_owner.Level = "00"
			_:
				#Go back to the title level
				_owner.Level = "00"
	else:
		#Get the next level	
		_owner.Level =  globals.playerstats[globals.Current_Player].level
			
	#Free up the existing level objects
	utility.queue_free_children(globals.enemies)
	utility.queue_free_children(globals.helpers)
	utility.queue_free_children(globals.players)
	utility.queue_free_children(globals.level)

	#Load the next level and start again
	if globals.Demo_NextState == 3 and globals.Demo_Mode:
		emit_signal("StateChange","HiScores")
	else:
		emit_signal("StateChange","LoadLevel")
	
func exit(_args:Dictionary = {}):
	pass

func logic(_args:Dictionary = {}):
	pass

