extends Node2D
enum{OK =1,NOK = -1}
# warning-ignore:unused_class_variable
export (PackedScene) var oPlayer
# warning-ignore:unused_class_variable
export (PackedScene) var oPipeline
# warning-ignore:unused_class_variable
export (PackedScene) var oEnemySpawner

#object refenences

# warning-ignore:unused_class_variable
onready var PlayerPos = $Container/VBoxContainer/HBoxContainer/Label2
# warning-ignore:unused_class_variable
onready var PlayerGridPos = $Container/VBoxContainer/HBoxContainer2/Label2
# warning-ignore:unused_class_variable
onready var TileInfo = $Container/VBoxContainer/HBoxContainer3/Label2
# warning-ignore:unused_class_variable
onready var NextTileInfo = $Container/VBoxContainer/HBoxContainer4/Label
# warning-ignore:unused_class_variable
onready var Clickloc = $Container/VBoxContainer/HBoxContainer5/Label
var Level_data:Dictionary = {}
var Level:String
var fsm:StateMachine = StateMachine.new()

var player:Object
var pipeline:Object

#TODO:
#	ADD PLAYER START DIRECTION TO JSON LEVEL DATA
# Called when the node enters the scene tree for the first time.
func _ready():
	globals.mainscene = self
	globals.level = $level
	globals.enemies = $enemies
	globals.players = $players

	fsm._owner = self
	fsm.add_states($States)
	fsm._on_state_change("Init")
	set_process(true)
	Level = "level_01"
	
func _process(delta):
	if fsm.state != null:
		var _args = {"delta":delta}
		fsm.state.logic(_args)
		if Input.is_mouse_button_pressed(BUTTON_LEFT):
			var _mp = get_global_mouse_position()
			var _mpgp = pipeline.map.world_to_map(_mp)
			Clickloc.text = str(_mpgp)
	update()

func _save_level_data():
	var _data = [0,0]
	Level_data["pipe"] = _data[1]	#actual pipe data
	Level_data["start_position"] = "0000"	#xxyy grid start position
	Level_data["enemies"] = {}	#set of enemies
	Level_data["helpers"] = {}	#set of helpers (only 1 on super pipeline 1)
	Level_data["targetfill"] = 1000	#amount of fill required for level
	Level_data["next_level"] = 0	#next level number
	
	#enemy definitions (previsional)
	Level_data["enemies"][0] ={"type":"ant","start_pos":"0101","start_dir":"3","speed":"1","start_delay":"10","freq":"10"}
	Level_data["enemies"][1] ={"type":"ant","start_pos":"0101","start_dir":"3","speed":"1","start_delay":"10","freq":"10"}
	Level_data["enemies"][2] ={"type":"lobster","start_pos":"0510","start_dir":"1","speed":"1","start_delay":"15","freq":"20"}
	
	#helper definitions (provisional)
	Level_data["helpers"][0] ={"type":"mole","start_pos":"0101","start_dir":"2","speed":"3","start_delay":"0","freq":"0"}

	var _result = file_handling.SaveFile("res://level_data/level_01.json", Level_data)


#debug only, showing player position on grid
func _draw():
	if player:
		var _gp = player.global_position
		var _ts = globals.tile_size
		var _gridpos = pipeline.map.world_to_map(_gp)
		var _snapped = pipeline.map.map_to_world(_gridpos,true)
		draw_rect(Rect2(_snapped,_ts),Color8(220,0,0,150),false)
