extends State
# warning-ignore:unused_class_variable
export (PackedScene) var oRocket
# warning-ignore:unused_class_variable
export (PackedScene) var oTaskSet
# warning-ignore:unused_class_variable
export (PackedScene) var oLobster
# warning-ignore:unused_class_variable
export (PackedScene) var oTitleText
# warning-ignore:unused_class_variable
export (PackedScene) var oOptions

var Lobster:Object
var Rocket:Object
var Taskset:Object
var TitleText:Object
var TitleState:int = 0
var _delay_time:float = 1.0
var _helper_start_position:int = 60
var meetingPos:int = 650

func enter(_args:Dictionary = {}):
	if globals.OptionsState:
		globals.hud.visible = false
		if AudioManager.sfx_list.has("BGM3"):
			var _stream:int = AudioManager.sfx_list["BGM3"]
			if AudioManager.music_player.stream != AudioManager.samples[_stream]:
				AudioManager.music_play("BGM3")
		TitleState = 30

	else:
		TitleState = 0
	if !globals.Demo_Mode:
		globals.Demo_Mode = true
		globals.Demo_NextState = 0

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
			#Move the lobster and rocket together, a signal advances the state when the two meet
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
		
		3:	#Wait for the time to elapse and start the taskset logo moving
			#The time delay advances to the next state
			Taskset.targetPos = Vector2(1000,1100)
		
		4:
			#Make the taskset logo bigger, setup another delay
			Taskset.scale = Vector2(2,2)
			Delay(0.15)
			NextState()
			
		5:
			#Wait for the delay to finish
			#The time delay advances to the next state
			pass
		6:	
			#Make the taskset logo normal size, and setup another delay
			Taskset.scale = Vector2(1,1)
			Delay(0.3)
			NextState()
		7:
			#Wait for the delay to finsih
			#The time delay advances to the next state
			pass
		8:
			#Make the taskset logo bigger again, setup another delay
			Taskset.scale = Vector2(2,2)
			Delay(0.15)
			NextState()
		9:
			#Wait for the delay to finish
			#The time delay advances to the next state
			pass
		10:
			#Make the taskset logo normal size for the last time
			Taskset.scale = Vector2(1,1)
			NextState()
		11:
			#Setup a delay before spawning an options scene
			Delay(5)
			NextState()
		12:
			#Wait for the delay to finish
			#The time delay advances to the next state
			pass
		13:
			TitleState = 30
		30:
			#Clean up the level pipe, lobster, player, helper etc
			utility.queue_free_children(globals.enemies)
			utility.queue_free_children(globals.helpers)
			utility.queue_free_children(globals.players)
			utility.queue_free_children(globals.level)
			#Spawn an options scene
			var options = oOptions.instance()
			options.optionsstatus = globals.OptionsState
			options.connect("OptionsStatus",_owner,"on_Options_Status_Change")
			globals.level.add_child(options)
			Delay(5)
			NextState()
		31:
			#Options handling
			if globals.OptionsState:
				TitleState = 50
		32:
			#Note: this is temporary.. as it needs to run in demo mode for a while?
			globals.Demo_NextState = 1
			emit_signal("StateChange","LevelReset")
			NextState()
		50:
			if !globals.OptionsState:
				Delay(2)
				NextState()
		51:
			pass
		52: 
			globals.Demo_NextState = 0
			emit_signal("StateChange","LevelReset")	

func NextState():
	TitleState +=1

func Delay(time):
	yield(get_tree().create_timer(time), "timeout")
	if !globals.OptionsState:
		NextState()
	
func fill_pipe():
	get_tree().call_group("PipeFilling","pipe_fill")
	
func empty_pipe():
	get_tree().call_group("PipeFilling","pipe_empty")

func _On_Rocket_areaEntered(_area):
	NextState()

func on_Taskset_atTarget():
	Taskset.queue_free()
	


