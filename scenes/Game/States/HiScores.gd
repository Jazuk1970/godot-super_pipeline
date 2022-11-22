extends State
# warning-ignore:unused_class_variable
export (PackedScene) var oHiScores
var time:float = 8.0

func enter(_args:Dictionary = {}):
	globals.hud.visible = false
	globals.hud.initialise()
	var _hiscoretable = oHiScores.instance()
	globals.level.add_child(_hiscoretable)
	yield(get_tree().create_timer(time), "timeout")
	if _owner.fsm.statename == "HiScores":
		#Set the next level to the title screen
		globals.Level_Data.Next_Level = "00"
		globals.Demo_Mode = true

		utility.queue_free_children(globals.level)
		emit_signal("StateChange","LevelReset")
			
func exit(_args:Dictionary = {}):
	pass
			
func logic(_args:Dictionary = {}):
	pass
	
	
