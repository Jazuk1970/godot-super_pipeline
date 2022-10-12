extends State
# warning-ignore:unused_class_variable
export (PackedScene) var oRocket
# warning-ignore:unused_class_variable
export (PackedScene) var oTaskSet
# warning-ignore:unused_class_variable
export (PackedScene) var oLobster
# warning-ignore:unused_class_variable
export (PackedScene) var oTitleText

var Lobster:Object
var Rocket:Object
var Taskset:Object
var TitleText:Object
var TitleState:int = 0
var _delay_time:float = 1.0
var _helper_start_position:int = 60
var meetingPos:int = 650
func enter(_args:Dictionary = {}):
	pass

func exit(_args:Dictionary = {}):
	pass

func logic(_args:Dictionary = {}):
	match TitleState:
		0:
			#Spawn the lobster
			Lobster = oLobster.instance()
			Lobster._PlayAnim("Walk")
			globals.enemies.add_child(Lobster)

			#Spawn the Rocket and connect the signal to advance to the next step
			Rocket = oRocket.instance()
			Rocket.connect("areaEntered",self,"_On_Rocket_areaEntered")
			globals.enemies.add_child(Rocket)
			NextState()

		1:
			#Move the lobster and rocket together
			Lobster.targetPos.x = meetingPos
			Rocket.targetPos.x = meetingPos

		2:
			#Spawn the taskset logo, fill the pipe and remove the rocket and lobster
			Taskset = oTaskSet.instance()
			globals.enemies.add_child(Taskset)
			TitleText = oTitleText.instance()
			globals.enemies.add_child(TitleText)
			Rocket.queue_free()
			Lobster.queue_free()
			fill_pipe()
			Delay(0.3)
			NextState()
		
		3:	#Wait for the time to elapse
			Taskset.targetPos = Vector2(1000,1100)
		
		4:
			Taskset.scale = Vector2(2,2)
			Taskset.connect("atTarget",self,"on_Taskset_atTarget")
			Delay(0.15)
			NextState()
			
		5:
			pass
		6:	
			Taskset.scale = Vector2(1,1)
			Delay(0.3)
			NextState()
		7:
			pass
		8:			
			Taskset.scale = Vector2(2,2)
			Delay(0.15)
			NextState()
		9:
			pass
		10:
			Taskset.scale = Vector2(1,1)
			NextState()
		11:
			Delay(3)
			NextState()
		12:
			pass
		13:
			#Note: this is temporary.. as it needs to run in demo mode for a while?
			globals.Level_Data.Next_Level = "01"
			globals.bgmusic.stop()
			emit_signal("StateChange","LevelReset")
			
			NextState()


func NextState():
	TitleState +=1
	#print( "Intermission State: %s" % TitleState)

func Delay(time):
	yield(get_tree().create_timer(time), "timeout")
	NextState()
	
func fill_pipe():
	get_tree().call_group("PipeFilling","pipe_fill")
	
func empty_pipe():
	get_tree().call_group("PipeFilling","pipe_empty")

func _On_Rocket_areaEntered(_area):
	NextState()

func on_Taskset_atTarget():
	Taskset.queue_free()
	NextState()
