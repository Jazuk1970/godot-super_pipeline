extends State
func enter(_args:Dictionary = {}):
	#Get the next level	
	_owner.Level =  globals.Level_Data.Next_Level
	
	if _owner.Level == "END":
		emit_signal("StateChange","Quit")
	else:
		#Free up the existing level objects
		utility.queue_free_children(globals.enemies)
		utility.queue_free_children(globals.helpers)
		utility.queue_free_children(globals.players)
		utility.queue_free_children(globals.level)

		#Load the next level and start again
		emit_signal("StateChange","LoadLevel")

	
func exit(_args:Dictionary = {}):
	pass

func logic(_args:Dictionary = {}):
	pass

