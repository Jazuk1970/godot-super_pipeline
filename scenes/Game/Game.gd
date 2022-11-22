extends Node2D
enum{OK =1,NOK = -1}
# warning-ignore:unused_class_variable
export (PackedScene) var oPlayer
# warning-ignore:unused_class_variable
export (PackedScene) var oPipeline
# warning-ignore:unused_class_variable
export (PackedScene) var oEnemySpawner
# warning-ignore:unused_class_variable
export (PackedScene) var oHelperSpawner
# warning-ignore:unused_class_variable
export (PackedScene) var oBarrel
onready var anim = $AnimationPlayer

var Level_data:Dictionary = {}
var Level:String
var fsm:StateMachine = StateMachine.new()
var player:Object
var pipeline:Object

# Called when the node enters the scene tree for the first time.
func _ready():
	globals.mainscene = self
	globals.level = $level
	globals.enemies = $enemies
	globals.helpers = $helpers
	globals.players = $players
	globals.hud = $hud
	globals.paused = $CanvasLayer/Paused
	globals.cameraanim = $AnimationPlayer
	globals.Game_State = fsm
	fsm._owner = self
	fsm.add_states($States)
	fsm._on_state_change("Init")
	set_process(true)
	Level = "00"
	globals.paused.visible = false
	
func _process(delta):
	if fsm.state != null:
		var _args = {"delta":delta}
		fsm.state.logic(_args)
		if !globals.OptionsState:
			if Input.is_action_just_pressed("ui_cancel"):
				if !(globals.Demo_Mode or Level == "00"):
					globals.Demo_Mode = true
					ResetAndStateChange("LevelReset")
				else:
					get_tree().quit()
			if Input.is_action_just_pressed("ui_accept") and fsm.statename != "Draw" and (globals.Demo_Mode or Level == "00"):
				globals.OptionsState = true
				ResetAndStateChange("Title")

		if Input.is_action_just_pressed("fire") and (globals.Demo_Mode or Level == "00"):
			globals.OptionsState = false
			ResetAndStateChange("NewGame")
	update()

func _save_level_data():
	var _data = [0,0]
	Level_data["pipe"] = _data[1]	#actual pipe data
	Level_data["start_position"] = "0000"	#xxyy grid start position
	Level_data["enemies"] = {}	#set of enemies
	Level_data["helpers"] = {}	#set of helpers (only 1 on super pipeline 1)
	Level_data["targetfill"] = 1000	#amount of fill required for level
	Level_data["next_level"] = 0	#next level number

	#enemy definitions (provisional)
	Level_data["enemies"][0] ={"type":"ant","start_pos":"0101","start_dir":"3","speed":"1","start_delay":"10","freq":"10"}
	Level_data["enemies"][1] ={"type":"ant","start_pos":"0101","start_dir":"3","speed":"1","start_delay":"10","freq":"10"}
	Level_data["enemies"][2] ={"type":"lobster","start_pos":"0510","start_dir":"1","speed":"1","start_delay":"15","freq":"20"}

	#helper definitions (provisional)
	Level_data["helpers"][0] ={"type":"mole","start_pos":"0101","start_dir":"2","speed":"3","start_delay":"0","freq":"0"}

	var _result = file_handling.SaveFile("res://level_data/level_01.json", Level_data)

func _on_DemoModeAdvance():
	var _dl = globals.Demo_Level.to_int()
	_dl += 1
	if _dl > 16:
		_dl = 1
	globals.Demo_Level = "%02d" % _dl
	fsm._on_state_change("LevelReset")

func on_Options_Status_Change(_state):
	globals.OptionsState = _state

func ResetAndStateChange(_state):
	#Free up the existing level objects
	utility.queue_free_children(globals.enemies)
	utility.queue_free_children(globals.helpers)
	utility.queue_free_children(globals.players)
	utility.queue_free_children(globals.level)
	fsm._on_state_change(_state)

