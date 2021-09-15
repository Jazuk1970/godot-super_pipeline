extends Node2D
signal flow_output
signal draw_done
enum{NONE = 0,RIGHT = 1,LEFT = 2,UP= 3,DOWN =4}
enum{HORIZONTAL = 0, VERTICAL = 1, CORNER = 2}
enum{TILE_NONE,TILE_START,TILE_END,TILE_HORIZONTAL,TILE_VERTICAL,TILE_CROSS,TILE_CORNER}
const blank_tile:int = 10
const _topHMove:int = 1
const _leftVMove:int = 1
const _rightVMove:int = 30
# warning-ignore:unused_class_variable
var _range1:Array = range(0,21)
# warning-ignore:unused_class_variable
var _range2:Array = range(17,32)
onready var map = $pipemap
onready var pipefilling = $PipeFilling
onready var tmr = $Timer
onready var navmap = $navmap
export var _colours:Array = [Color8(255,255,255),Color8(255,255,255),Color8(255,255,255),Color8(255,255,255),Color8(255,255,255),Color8(255,255,255),Color8(255,255,255),Color8(255,255,255)]
export (PackedScene) var oPipe
var flow_rate:float = 0.03
var draw_rate:float = 0.03
var _fillcol:Color = Color8(255,255,255,0)
# warning-ignore:unused_class_variable
var pipelines:Array = []
var pipeline:Array = []
var pipestring:String
var pipedata:Array = []
var elementtypes = {"hle":0,"hre":1,"h":2,"hc":5,"vte":10,"vbe":11,"v":12,"vc":15,"rdul":20,"dlru":21,"ludr":22,"urld":23,"move":99}
var elementtiles = [0,0,1,0,0,2,0,0,0,0,\
					3,3,4,0,0,5,0,0,0,0,\
					6,6,6,6,0,0,0,0,0,0]
var _dir = [Vector2.ZERO,Vector2.RIGHT,Vector2.LEFT,Vector2.UP,Vector2.DOWN]
var _prevneighbour:Object
var _direction:Vector2 = Vector2.ZERO
var _gridpos:Vector2 = Vector2.ZERO
var allowed_moves:Dictionary
var movelist:Dictionary
var _path:Array = []
var _path_compiled:bool = false
var _draw_idx:int = 0
var _reps:int = 0
var _type:int = 0
var startflow:bool setget _startflow
var stopflow:bool setget _stopflow
# warning-ignore:unused_class_variable
var test:bool = false
var _draw_done:bool = false
#var tilesize:Vector2



func _ready():
#
#	var _result = file_handling.SaveFile("user://level_02.json", pipestring)
#	var _data = file_handling.LoadFile("res://level_data/pipe_data/level_13.json")
#	var _data = file_handling.LoadFile("res://level_data/title.json")
#	if _data[0] == OK:
#		pipestring = str2var(_data[1])
#		_data = null
	initialise()
	allowed_moves = _set_allowed_moves()
	movelist = _createmovelist()
	globals.tile_size = map.get_cell_size()


func initialise():
	draw_roof()
	draw_ladder()

	pipedata = parse_pipestring(pipestring)
	_draw_idx = 0

func _process(_delta):
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().quit()
	if Input.is_key_pressed(KEY_1):
		self.startflow = true
	else:
		self.startflow = false
	if Input.is_key_pressed(KEY_2):
		self.stopflow = true
	else:
		self.stopflow = false
	update()

func parse_pipestring(_ps) -> Array: #Returns pipe data array
#parse the pipe string and return an data structure array where:
#the first element is the starting position,
#the second element is the starting direction : 0001 - right, 0002 - left, 003 - up, 0004 - down
#and all following elements are pipe codes and number of repeats
#pipe codes:
#00 - horizontal left end
#01 - horizontal right end
#02 - horizontal
#05 - horizontal cross
#10 - vertical top end
#11 - vertical bottom end
#12 - vertical
#15 - vertical cross
#20 - corner right/down or up/left
#21 - corner down/left or right/up
#22 - corner left/up or down/right
#23 - corner up/right or left/down
#99 - position move - note the xx after the 99 denotes direction
	var _pd:Array = []
	var _parsed:String = _ps
	_path.clear()
	_path_compiled = false
	_parsed = _parsed.replace('"','')
	while _parsed.length() > 0:
		var _s:String = _parsed.left(4)
		var _d:Array = []
		_d.append(int(_s.left(2)))
		_d.append(int(_s.right(2)))
		_pd.append(_d)
		_parsed = _parsed.trim_prefix(_s)
	return _pd

func _draw_pipe(_pd) -> bool: #Returns true when drawing complete
	var _pathpos:Vector2 = Vector2.ZERO
	if _draw_idx == 0:	#Is this the start of the pipe (starting position)
		_gridpos.x = _pd[_draw_idx][0]
		_gridpos.y = _pd[_draw_idx][1]
		_draw_idx += 1
		_fillcol = _colours[_pd[_draw_idx][0]]
		_direction = _dir[_pd[_draw_idx][1]]
		#Attempt to create a set of path nodes
		match _direction:
			Vector2.UP:
				_pathpos = _gridpos+Vector2(1,-1)
			Vector2.DOWN:
				_pathpos = _gridpos+Vector2(1,1)
			Vector2.LEFT:
				_pathpos = _gridpos+Vector2(1,0)
			Vector2.RIGHT:
				_pathpos = _gridpos+Vector2(-1,0)
		_path.append([_pathpos,TILE_START])
	if _reps == 0:
		if _draw_idx >= _pd.size() -1:
			if not _path_compiled:
				match _direction:
					Vector2.UP:
						_pathpos = _gridpos+Vector2(0,-1)
					Vector2.DOWN:
						_pathpos = _gridpos+Vector2(0,1)
					Vector2.LEFT:
						_pathpos = _gridpos+Vector2(-1,0)
					Vector2.RIGHT:
						_pathpos = _gridpos+Vector2(0,0)
				_path.append([_pathpos,TILE_END])
				_path_compiled = true
			return true
		_draw_idx += 1
		if _pd[_draw_idx][0] == elementtypes.move:
			_direction = _dir[_pd[_draw_idx][1]]
			_draw_idx += 1
			_gridpos.x = _pd[_draw_idx][0]
			_gridpos.y = _pd[_draw_idx][1]
			_draw_idx += 1
		_type = _pd[_draw_idx][0]
		_reps = _pd[_draw_idx][1]
	_add_element(_type)
	if _draw_idx == 2:
		var _result = connect("flow_output",pipeline[0],"update_flow")
	_reps -= 1
	return false

func _add_element(_e):
	var _fx:bool = false
	var _fy:bool = false
	var _tile = elementtiles[_e]
	var _pathpos:Vector2 = Vector2.ZERO

	match _e:
		0,2:	#Horizontal left end and horizontal
			map.set_cellv(_gridpos,_tile,_fx,_fy)
			map.set_cellv(_gridpos+Vector2(0,1),_tile,_fx,not _fy)
			_add_pipefilling(_gridpos,_e,_fx,_fy)
			_gridpos += _direction
		1:	#Horizontal right end
			_fx = true
			map.set_cellv(_gridpos,_tile,_fx,_fy)
			map.set_cellv(_gridpos+Vector2(0,1),_tile,_fx,not _fy)
			_add_pipefilling(_gridpos,_e,_fx,_fy)
			_gridpos += _direction
		5:	#Horizontal cross
			if _direction == _dir[LEFT]:
				map.set_cellv(_gridpos+Vector2(-1,0),_tile,_fx,_fy)
				map.set_cellv(_gridpos,_tile,not _fx,_fy)
				map.set_cellv(_gridpos+Vector2(-1,1),_tile,_fx,not _fy)
				map.set_cellv(_gridpos+Vector2(0,1),_tile,not _fx,not _fy)
				_pathpos = _gridpos+Vector2(0,0)
				_add_pipefilling(_gridpos,_e,_fx,_fy)
			elif _direction == _dir[RIGHT]:
				map.set_cellv(_gridpos,_tile,_fx,_fy)
				map.set_cellv(_gridpos+Vector2(1,0),_tile,not _fx,_fy)
				map.set_cellv(_gridpos+Vector2(0,1),_tile,_fx,not _fy)
				map.set_cellv(_gridpos+Vector2(1,1),_tile,not _fx,not _fy)
				_pathpos = _gridpos+Vector2(1,0)
				_add_pipefilling(_gridpos,_e,_fx,_fy)
			elif _direction == _dir[UP]:
				map.set_cellv(_gridpos+Vector2(0,-1),_tile,_fx,_fy)
				map.set_cellv(_gridpos+Vector2(1,-1),_tile,not _fx,_fy)
				map.set_cellv(_gridpos+Vector2(0,0),_tile,_fx,not _fy)
				map.set_cellv(_gridpos+Vector2(1,0),_tile,not _fx,not _fy)
				_pathpos = _gridpos+Vector2(1,-1)
				_add_pipefilling(_gridpos,_e,_fx,_fy)
			elif _direction == _dir[DOWN]:
				map.set_cellv(_gridpos,_tile,_fx,_fy)
				map.set_cellv(_gridpos+Vector2(1,0),_tile,not _fx,_fy)
				map.set_cellv(_gridpos+Vector2(0,1),_tile,_fx,not _fy)
				map.set_cellv(_gridpos+Vector2(1,1),_tile,not _fx,not _fy)
				_pathpos = _gridpos+Vector2(1,0)
				_add_pipefilling(_gridpos,_e,_fx,_fy)
			_path.append([_pathpos,TILE_CROSS])
			_gridpos += _direction * 2

		10,12:	#Vertical top end and vertical
			map.set_cellv(_gridpos,_tile,_fx,_fy)
			map.set_cellv(_gridpos+Vector2(1,0),_tile,not _fx,_fy)
			_add_pipefilling(_gridpos,_e,_fx,_fy)
			_gridpos += _direction
		11:	#Vertical bottom end
			_fy = true
			map.set_cellv(_gridpos,_tile,_fx,_fy)
			map.set_cellv(_gridpos+Vector2(1,0),_tile,not _fx,_fy)
			_add_pipefilling(_gridpos,_e,_fx,_fy)
			_gridpos += _direction
		15:	#Vertical cross
			_pathpos = _gridpos+Vector2(0,1)
			if _direction == _dir[DOWN]:
				map.set_cellv(_gridpos,_tile,_fx,_fy)
				map.set_cellv(_gridpos+Vector2(1,0),_tile,not _fx,_fy)
				map.set_cellv(_gridpos+Vector2(0,1),_tile,_fx,not _fy)
				map.set_cellv(_gridpos+Vector2(1,1),_tile,not _fx,not _fy)
				_add_pipefilling(_gridpos,_e,_fx,_fy)
				_pathpos = _gridpos+Vector2(1,0)
			elif _direction == _dir[UP]:
				map.set_cellv(_gridpos+Vector2(0,-1),_tile,_fx,_fy)
				map.set_cellv(_gridpos+Vector2(1,-1),_tile,not _fx,_fy)
				map.set_cellv(_gridpos,_tile,_fx,not _fy)
				map.set_cellv(_gridpos+Vector2(1,0),_tile,not _fx,not _fy)
				_add_pipefilling(_gridpos,_e,_fx,_fy)
				_pathpos = _gridpos+Vector2(1,-1)
			elif _direction == _dir[LEFT]:
				map.set_cellv(_gridpos+Vector2(-1,0),_tile,_fx,_fy)
				map.set_cellv(_gridpos+Vector2(0,0),_tile,not _fx,_fy)
				map.set_cellv(_gridpos+Vector2(-1,1),_tile,_fx,not _fy)
				map.set_cellv(_gridpos+Vector2(0,1),_tile,not _fx,not _fy)
				_add_pipefilling(_gridpos,_e,_fx,_fy)
				_pathpos = _gridpos+Vector2(0,0)
			elif _direction == _dir[RIGHT]:
				map.set_cellv(_gridpos,_tile,_fx,_fy)
				map.set_cellv(_gridpos+Vector2(1,0),_tile,not _fx,_fy)
				map.set_cellv(_gridpos+Vector2(0,1),_tile,_fx,not _fy)
				map.set_cellv(_gridpos+Vector2(1,1),_tile,not _fx,not _fy)
				_add_pipefilling(_gridpos,_e,_fx,_fy)
				_pathpos = _gridpos+Vector2(1,0)
			_path.append([_pathpos,TILE_CROSS])
			_gridpos += _direction * 2
		20:	#Corner right/down or up/left
			var _gp:Vector2
			var _ngp:Vector2
			if _direction == _dir[RIGHT]:
				_gp = _gridpos
				_ngp = _gp + Vector2(0,2)
				_direction = _dir[DOWN]
				_pathpos = _gridpos+Vector2(1,0)
			else:
				_gp = _gridpos + Vector2(0,-1)
				_ngp = _gp + Vector2(-1,0)
				_direction = _dir[LEFT]
				_pathpos = _gridpos+Vector2(1,-1)
			map.set_cellv(_gp,_tile,_fx,_fy)
			map.set_cellv(_gp + Vector2(1,0),_tile+1,_fx,_fy)
			map.set_cellv(_gp + Vector2(0,1),_tile+2,_fx,_fy)
			map.set_cellv(_gp + Vector2(1,1),_tile+3,_fx,_fy)
			_add_pipefilling(_gp,_e,_fx,_fy)
			_path.append([_pathpos,TILE_CORNER])
			_gridpos = _ngp

		21:	#Corner down/left or right/up
			var _gp:Vector2
			var _ngp:Vector2
			_fy = true
			if _direction == _dir[DOWN]:
				_gp = _gridpos
				_ngp = _gp + Vector2(-1,0)
				_direction = _dir[LEFT]
				_pathpos = _gridpos+Vector2(1,0)
			else:
				_gp = _gridpos
				_ngp = _gp + Vector2(0,-1)
				_direction = _dir[UP]
				_pathpos = _gridpos+Vector2(1,0)
			map.set_cellv(_gp,_tile+2,_fx,_fy)
			map.set_cellv(_gp + Vector2(1,0),_tile+3,_fx,_fy)
			map.set_cellv(_gp + Vector2(0,1),_tile+0,_fx,_fy)
			map.set_cellv(_gp + Vector2(1,1),_tile+1,_fx,_fy)
			_add_pipefilling(_gp,_e,_fx,_fy)
			_path.append([_pathpos,TILE_CORNER])
			_gridpos = _ngp
		22:	#corner left/up  or down/right
			var _gp:Vector2
			var _ngp:Vector2
			_fx = true
			_fy = true
			if _direction == _dir[LEFT]:
				_gp = _gridpos + Vector2(-1,0)
				_ngp = _gp + Vector2(0,-1)
				_direction = _dir[UP]
				_pathpos = _gridpos+Vector2(0,0)#(1,0)
			else:
				_gp = _gridpos
				_ngp = _gp + Vector2(2,0)
				_direction = _dir[RIGHT]
				_pathpos = _gridpos+Vector2(1,0)
			map.set_cellv(_gp,_tile+3,_fx,_fy)
			map.set_cellv(_gp + Vector2(1,0),_tile+2,_fx,_fy)
			map.set_cellv(_gp + Vector2(0,1),_tile+1,_fx,_fy)
			map.set_cellv(_gp + Vector2(1,1),_tile+0,_fx,_fy)
			_add_pipefilling(_gp,_e,_fx,_fy)
			_path.append([_pathpos,TILE_CORNER])
			_gridpos = _ngp
		23:	#Corner up/right or left/down
			var _gp:Vector2
			var _ngp:Vector2
			_fx = true
			if _direction == _dir[UP]:
				_gp = _gridpos + Vector2(0,-1)
				_ngp = _gp + Vector2(2,0)
				_direction = _dir[RIGHT]
				_pathpos = _gridpos+Vector2(1,-1)#(0,1)
			else:
				_gp = _gridpos + Vector2(-1,0)
				_ngp = _gp + Vector2(0,2)
				_direction = _dir[DOWN]
				_pathpos = _gridpos+Vector2(0,0)
			map.set_cellv(_gp,_tile+1,_fx,_fy)
			map.set_cellv(_gp + Vector2(1,0),_tile,_fx,_fy)
			map.set_cellv(_gp + Vector2(0,1),_tile+3,_fx,_fy)
			map.set_cellv(_gp + Vector2(1,1),_tile+2,_fx,_fy)
			_add_pipefilling(_gp,_e,_fx,_fy)
			_path.append([_pathpos,TILE_CORNER])
			_gridpos = _ngp



func _add_pipefilling(_pos,_e,_fx,_fy):
	var _basetype = int (_e / 10)
	match _basetype:
		HORIZONTAL:
			if _e == elementtypes.hc:
				var _crosspos = _pos
				var _oPipe = oPipe.instance()
				_oPipe._fillcol = _fillcol
				if _direction == _dir[LEFT] or _direction == _dir[UP]:
					_crosspos = _pos + _direction #adjust the position for crossing looking depending on approach direction
				var _crossingtilechanged = _find_crossing_tiles(_crosspos,_e)
				if _direction == _dir[UP] or _direction == _dir[DOWN]:
					_oPipe.subtype = _e if _direction == _dir[DOWN] else 100
					_oPipe.type = VERTICAL
				else:
					_oPipe.subtype = _e
					_oPipe.type = HORIZONTAL
				if _direction == _dir[LEFT]:
					_oPipe.position = map.map_to_world(_crosspos)
				else:
					_oPipe.position = map.map_to_world(_pos)
				_oPipe.grid_position = _pos
				_oPipe.name = "pipe_" + str(_e).pad_zeros(2) + "_" +str(pipeline.size()).pad_zeros(4)
				_oPipe.flow_rate = flow_rate
				if _direction == _dir[RIGHT] or \
					_direction == _dir[DOWN]:
					_oPipe.flow_reverse = false
				else:
					_oPipe.flow_reverse = true
				if _direction == _dir[UP] or _direction == _dir[DOWN]:
					oPipe.set("z_index",-11)
				else:
					oPipe.set("z_index",-10)
				if _prevneighbour != null:
					var _result = _prevneighbour.connect("flow_output",_oPipe,"update_flow")
				pipeline.append(_oPipe)
				pipefilling.add_child(_oPipe)
				_prevneighbour = _oPipe
				if not _crossingtilechanged:
					var _addelem = _oPipe.duplicate()
					_addelem.subtype = 100 if _direction == _dir[DOWN] else _e
					_addelem.type = _oPipe.type
					_addelem.flow_reverse = _oPipe.flow_reverse
					_addelem._fillcol = _oPipe._fillcol
					_addelem.flip_x = _oPipe.flip_x
					_addelem.flip_y = _oPipe.flip_y
					_addelem.flow_rate = _oPipe.flow_rate
					_addelem.position = map.map_to_world(_pos + _direction)
					_addelem.grid_position = _pos + _direction
					_addelem.name = "pipe_" + str(_e).pad_zeros(2) + "_" +str(pipeline.size()).pad_zeros(4)
					_addelem.set("z_index",oPipe.get("z_index"))
					var _result = _prevneighbour.connect("flow_output",_addelem,"update_flow")
					pipeline.append(_addelem)
					pipefilling.add_child(_addelem)
					_prevneighbour = _addelem
					_addelem = null
				_oPipe = null
			else:
				var _oPipe = oPipe.instance()
				_oPipe._fillcol = _fillcol
				_oPipe.type = HORIZONTAL
				_oPipe.position = map.map_to_world(_pos)
				_oPipe.grid_position = _pos
				_oPipe.name = "pipe_" + str(_e).pad_zeros(2) + "_" +str(pipeline.size()).pad_zeros(4)
				_oPipe.flow_rate = flow_rate
				if _direction == _dir[RIGHT] or \
					_direction == _dir[DOWN]:
					_oPipe.flow_reverse = false
				else:
					_oPipe.flow_reverse = true
					_oPipe.set("z_index",-10)
				if _prevneighbour != null:
					var _result = _prevneighbour.connect("flow_output",_oPipe,"update_flow")
				pipeline.append(_oPipe)
				pipefilling.add_child(_oPipe)
				_prevneighbour = _oPipe
				_oPipe = null
		VERTICAL:
			if _e == elementtypes.vc:
				var _crosspos = _pos
				var _oPipe = oPipe.instance()
				_oPipe._fillcol = _fillcol
				if _direction == _dir[LEFT] or _direction == _dir[UP]:
					_crosspos = _pos + _direction #adjust the position for crossing looking depending on approach direction
				var _crossingtilechanged = _find_crossing_tiles(_crosspos,_e)
				if _direction == _dir[LEFT] or _direction == _dir[RIGHT]:
					_oPipe.subtype = _e if _direction == _dir[RIGHT] else 100
					_oPipe.type = HORIZONTAL
				else:
					_oPipe.subtype = _e
					_oPipe.type = VERTICAL
				if _direction == _dir[UP]:
					_oPipe.position = map.map_to_world(_crosspos)
				else:
					_oPipe.position = map.map_to_world(_pos)
				_oPipe.grid_position = _pos

				_oPipe.name = "pipe_" + str(_e).pad_zeros(2) + "_" +str(pipeline.size()).pad_zeros(4)
				_oPipe.flow_rate = flow_rate
				if _direction == _dir[RIGHT] or \
					_direction == _dir[DOWN]:
					_oPipe.flow_reverse = false
				else:
					_oPipe.flow_reverse = true
				if _direction == _dir[LEFT] or _direction == _dir[RIGHT]:
					oPipe.set("z_index",-11)
				else:
					oPipe.set("z_index",-10)
				if _prevneighbour != null:
					var _result = _prevneighbour.connect("flow_output",_oPipe,"update_flow")
				pipeline.append(_oPipe)
				pipefilling.add_child(_oPipe)
				_prevneighbour = _oPipe
				if not _crossingtilechanged:
					var _addelem = _oPipe.duplicate()
					_addelem.subtype = 100 if _direction == _dir[RIGHT] else _e
					_addelem.type = _oPipe.type
					_addelem.flow_reverse = _oPipe.flow_reverse
					_addelem._fillcol = _oPipe._fillcol
					_addelem.flip_x = _oPipe.flip_x
					_addelem.flip_y = _oPipe.flip_y
					_addelem.flow_rate = _oPipe.flow_rate
					_addelem.position = map.map_to_world(_pos + _direction)
					_addelem.grid_position = _pos + _direction
					_addelem.name = "pipe_" + str(_e).pad_zeros(2) + "_" +str(pipeline.size()).pad_zeros(4)
					_addelem.set("z_index",oPipe.get("z_index"))
					var _result = _prevneighbour.connect("flow_output",_addelem,"update_flow")
					pipeline.append(_addelem)
					pipefilling.add_child(_addelem)
					_prevneighbour = _addelem
					_addelem = null
					_oPipe = null
			else:
				var _oPipe = oPipe.instance()
				_oPipe._fillcol = _fillcol
				_oPipe.type = VERTICAL
				_oPipe.position = map.map_to_world(_pos)
				_oPipe.grid_position = _pos
				_oPipe.name = "pipe_" + str(_e).pad_zeros(2) + "_" +str(pipeline.size()).pad_zeros(4)
				_oPipe.flow_rate = flow_rate
				if _direction == _dir[RIGHT] or \
					_direction == _dir[DOWN]:
					_oPipe.flow_reverse = false
				else:
					_oPipe.flow_reverse = true
					_oPipe.set("z_index",-10)
				if _prevneighbour != null:
					var _result = _prevneighbour.connect("flow_output",_oPipe,"update_flow")
				pipeline.append(_oPipe)
				pipefilling.add_child(_oPipe)
				_prevneighbour = _oPipe
				_oPipe = null
		CORNER:
			var _oPipe = oPipe.instance()
			_oPipe._fillcol = _fillcol
			_oPipe.type = CORNER
			_oPipe.flip_x = _fx
			_oPipe.flip_y = _fy
			_oPipe.position = map.map_to_world(_pos)
			_oPipe.grid_position = _pos
			_oPipe.name = "pipe_" + str(_e).pad_zeros(2) + "_" +str(pipeline.size()).pad_zeros(4)
			_oPipe.flow_rate = flow_rate
			_oPipe.set("z_index",-10)
			if _direction == _dir[DOWN] or \
				_direction == _dir[UP] and (_fy or _fx):
				_oPipe.flow_reverse = false
			else:
				_oPipe.flow_reverse = true
			if _prevneighbour != null:
				var _result = _prevneighbour.connect("flow_output",_oPipe,"update_flow")
			pipeline.append(_oPipe)
			pipefilling.add_child(_oPipe)
			_prevneighbour = _oPipe
			_oPipe = null

func _find_crossing_tiles(_pos,_e) -> bool:
#finds the crossing tiles of a junction and modif
#	for i in range (pipeline.size()-1):
#		var _p = pipeline[i]
#		if _p.grid_position == _pos:
	var i = get_pipe(_pos)
	if i == -1:
		return false
	var _p = pipeline[i]
			#if the tile being crossed is the same type as this tile no need to modify the crossing tiles
	if _p.type != int( _e /10 ):
		_p.subtype = _e
		_p.init_pipe()
		var _nextelem = -1 if _p.flow_reverse else 1
		_p = pipeline[i + _nextelem]
		_p.subtype = 100 #if _p.flow_reverse else 100
		_p.init_pipe()
		return true
	else:
		return false
#	return false

func get_pipe(_pos) -> int:
	for i in range (pipeline.size()-1):
		if pipeline[i].grid_position == _pos:
			return i
	return -1

func _on_Timer_timeout():
	_draw_done = _draw_pipe(pipedata)
	if not _draw_done:
		tmr.start(draw_rate)
	else:
		_create_navmap()
		emit_signal("draw_done")

func _startflow(_val):
	if _val:
		emit_signal("flow_output",true,_fillcol)
	startflow = _val

func _stopflow(_val):
	if _val:
		emit_signal("flow_output",false,_fillcol)
	stopflow = _val

func draw_pipeline():
	print("starting pipeline draw")
	tmr.start(draw_rate)

func _draw():
	var _maxwidth = 1920
	var _maxheight = 1080
	for _col in range(0,_maxwidth,32):
		draw_line(Vector2(_col,0),Vector2(_col,_maxheight),Color8(88,88,88,55),1.0)
	for _row in range(0,_maxheight,32):
		draw_line(Vector2(0,_row),Vector2(_maxwidth,_row),Color8(88,88,88,55),1.0)
	if _path_compiled:
		for _e in _path.size():
			if _e < _path.size() -1:
				draw_line(_path[_e][0]*32,_path[_e+1][0]*32,Color8(00,250,00),1,0)
			draw_circle(_path[_e][0]*32,5,Color8(0,255,255))

func _createmovelist() -> Dictionary:
	var _ml = {}
	#horizontal tile movements
	_ml[0] = {Vector2.RIGHT:[[],[_topHMove]],Vector2.LEFT:[[],[_topHMove]]}
	_ml[1] = {Vector2.RIGHT:[[],[_topHMove]],Vector2.LEFT:[[],[_topHMove]]}
	_ml[1000] = {Vector2.RIGHT:[[],[_topHMove]],Vector2.LEFT:[[],[_topHMove]]}

	#vertical tile movments
	_ml[3] = {Vector2.UP:[[_rightVMove],[]],Vector2.DOWN:[[_rightVMove],[]]}
	_ml[4] = {Vector2.UP:[[_rightVMove],[]],Vector2.DOWN:[[_rightVMove],[]]}
	_ml[1003] = {Vector2.UP:[[_leftVMove],[]],Vector2.DOWN:[[_leftVMove],[]]}
	_ml[1004] = {Vector2.UP:[[_leftVMove],[]],Vector2.DOWN:[[_leftVMove],[]]}
	_ml[2002] = {Vector2.UP:[[_rightVMove],[]],Vector2.DOWN:[[_rightVMove],[]]}
	_ml[2003] = {Vector2.UP:[[_rightVMove],[]],Vector2.DOWN:[[_rightVMove],[]]}
	_ml[2005] = {Vector2.UP:[[_rightVMove],[]],Vector2.DOWN:[[_rightVMove],[]]}
	_ml[3002] = {Vector2.UP:[[_leftVMove],[]],Vector2.DOWN:[[_leftVMove],[]]}
	_ml[3003] = {Vector2.UP:[[_leftVMove],[]],Vector2.DOWN:[[_leftVMove],[]]}
	_ml[3005] = {Vector2.UP:[[_leftVMove],[]],Vector2.DOWN:[[_leftVMove],[]]}

	#cross tile movments
	_ml[2] = {
		Vector2.RIGHT:[[],[_range1]],Vector2.LEFT:[[],[_range1]],
		Vector2.UP:[[_range2],[]],Vector2.DOWN:[[_range2],[]]
		}
	_ml[5] = {
		Vector2.RIGHT:[[],[_range1]],Vector2.LEFT:[[],[_range1]],
		Vector2.UP:[[_range2],[]],Vector2.DOWN:[[_range2],[]]
		}
	_ml[1002] = {
		Vector2.RIGHT:[[],[_range1]],Vector2.LEFT:[[],[_range1]],
		Vector2.UP:[[_range1],[]],Vector2.DOWN:[[_range1],[]]
		}
	_ml[1005] = {
		Vector2.RIGHT:[[],[_range1]],Vector2.LEFT:[[],[_range1]],
		Vector2.UP:[[_range1],[]],Vector2.DOWN:[[_range1],[]]
		}


	#corner tile movements
	_ml[6] = {Vector2.RIGHT:[[],[_topHMove]],Vector2.LEFT:[[],[_range1]],Vector2.UP:[[_rightVMove],[]],Vector2.DOWN:[[_range2],[]]}
	_ml[7] = {Vector2.RIGHT:[[],[_topHMove]],Vector2.LEFT:[[],[_range1]],Vector2.UP:[[_leftVMove],[_range2]],Vector2.DOWN:[[_leftVMove],[]]}
	_ml[8] = {Vector2.UP:[[_rightVMove],[]],Vector2.DOWN:[[_rightVMove],[]]}
	_ml[9] = {Vector2.UP:[[_leftVMove],[]],Vector2.DOWN:[[_leftVMove],[]]}
	_ml[1006] = {Vector2.RIGHT:[[],[_range1]],Vector2.LEFT:[[],[_topHMove]],Vector2.UP:[[_leftVMove],[_range2]],Vector2.DOWN:[[_range1],[]]}
	_ml[1007] = {Vector2.RIGHT:[[],[_range1]],Vector2.LEFT:[[],[_topHMove]],Vector2.UP:[[_rightVMove],[_range2]],Vector2.DOWN:[[_rightVMove],[]]}
	_ml[1008] = {Vector2.UP:[[_leftVMove],[]],Vector2.DOWN:[[_leftVMove],[]]}
	_ml[1009] = {Vector2.UP:[[_rightVMove],[]],Vector2.DOWN:[[_rightVMove],[]]}
	_ml[2008] = {Vector2.RIGHT:[[],[_topHMove]],Vector2.LEFT:[[],[_range1]],Vector2.UP:[[_range2],[]],Vector2.DOWN:[[_rightVMove],[_topHMove]]}
	_ml[2009] = {Vector2.RIGHT:[[],[_topHMove]],Vector2.LEFT:[[],[_range1]],Vector2.UP:[[_leftVMove],[]],Vector2.DOWN:[[_leftVMove],[_topHMove]]}
	_ml[3008] = {Vector2.RIGHT:[[],[_range1]],Vector2.LEFT:[[],[_range1]],Vector2.UP:[[_range1],[]],Vector2.DOWN:[[_leftVMove],[_topHMove]]}
	_ml[3009] = {Vector2.RIGHT:[[],[_range1]],Vector2.LEFT:[[],[_topHMove]],Vector2.UP:[[_rightVMove],[]],Vector2.DOWN:[[_rightVMove],[_topHMove]]}
	return _ml

func _set_allowed_moves() -> Dictionary:
	var _am = {}
	_am[Vector2.RIGHT] = {0:[1,2,5,6,1000],1:[0,2,5,6,1000,2008],2:[1002],5:[1005],1000:[0,1,2,5,6,2008],1002:[1,1000],1005:[0,1,1000],1006:[0,1,1000],1007:[1006],3008:[0,1,1000],3009:[3008]}
	_am[Vector2.LEFT] = {0:[1,1000,1005,1006,3008],1:[0,1000,1002,1005,1006,3008],2:[0,1,1000],5:[0,1,1000],6:[0,1,1000],7:[6],1000:[0,1,1002,1005,1006,3008],1002:[2],1005:[5],2008:[1,1000],2009:[2008]}
	_am[Vector2.UP] = {2:[3,4,2003,2005],3:[4,8,1009,2002,2005],4:[3,8,1009,2002,2003,2005],5:[3,2003],8:[6],9:[7],1002:[1003,1004,3003],1003:[9,1004,1008,3002,3005],1004:[9,1003,1008,3002,3003,3005],1005:[1003,1004,3005],1008:[1006],1009:[1007],2002:[2],2003:[3,4,8,2002,2005],2005:[5],2008:[4,2003],2009:[1004,3003],3002:[1002],3003:[1003,1004,3002,3005],3005:[1005],3008:[1003,1004,3002,3003],3009:[3,4,2002,2003]}
	_am[Vector2.DOWN] = {2:[2002],3:[2,4,5,2003,3009],4:[2,3,2003,2008,3009],5:[2005],6:[3,4,8],7:[9],8:[3,4,2003],9:[1003,1004],1002:[3002],1003:[1002,1004,1005,3003,3008],1004:[1002,1003,1005,2009,3003,3008],1005:[3005],1006:[1008],1007:[1009],1008:[1003,1004],1009:[3,4],2002:[3,4,2003,3009],2003:[2,4,5,2008,3009],2005:[3,4,2003],3002:[1003,1004,3003,3008],3003:[1002,1004,2009,3008],3005:[1003,1004,1005,3003]}
	return _am

func checkmove(_pf:PipeFollower,_intilemove:bool = true):# -> PipeFollower:
	var _navtile:int
	#Get the centre world position of the current tile
	var _gridworldpos:Vector2 = navmap.map_to_world(_pf.gridpos)
	var _intilemov_minus:Vector2 = (_pf.position - _gridworldpos).abs()
	var _intilemov_plus:Vector2 = Vector2(32,32) - _intilemov_minus.abs()

	_navtile = navmap.get_cellv(_pf.gridpos)
	if _navtile == TILE_HORIZONTAL:
		_pf.available_directions[Vector2.LEFT] = 1.0
		_pf.available_directions[Vector2.RIGHT] = 1.0
		_pf.available_directions[Vector2.UP] = 0.0
		_pf.available_directions[Vector2.DOWN] = 0.0
	elif _navtile == TILE_VERTICAL:
		_pf.available_directions[Vector2.LEFT] = 0.0
		_pf.available_directions[Vector2.RIGHT] = 0.0
		_pf.available_directions[Vector2.UP] = 1.0
		_pf.available_directions[Vector2.DOWN] = 1.0
	elif _navtile == TILE_CROSS:
		_pf.available_directions[Vector2.LEFT] = 1.0
		_pf.available_directions[Vector2.RIGHT] = 1.0
		_pf.available_directions[Vector2.UP] = 1.0
		_pf.available_directions[Vector2.DOWN] = 1.0
	elif _navtile == TILE_START or _navtile == TILE_END:
		if navmap.get_cellv(_pf.gridpos + Vector2.LEFT) == -1:
			_pf.available_directions[Vector2.LEFT] = 0.0
		else:
			_pf.available_directions[Vector2.LEFT] = 1.0
		if navmap.get_cellv(_pf.gridpos + Vector2.RIGHT) == -1:
			_pf.available_directions[Vector2.RIGHT] = 0.0
		else:
			_pf.available_directions[Vector2.RIGHT] = 1.0
		_pf.available_directions[Vector2.UP] = 0.0
		_pf.available_directions[Vector2.DOWN] = 0.0
	elif _navtile == TILE_CORNER:
		if navmap.get_cellv(_pf.gridpos + Vector2.LEFT)== -1 and (_intilemov_minus.x < _pf.dist +1 or not _intilemove):
			_pf.available_directions[Vector2.LEFT ] = 0.0
		else:
			_pf.available_directions[Vector2.LEFT] = 1.0
		if navmap.get_cellv(_pf.gridpos + Vector2.RIGHT) == -1 and (_intilemov_plus.x < _pf.dist +1 or not _intilemove):
			_pf.available_directions[Vector2.RIGHT] = 0.0
		else:
			_pf.available_directions[Vector2.RIGHT] = 1.0
		if navmap.get_cellv(_pf.gridpos + Vector2.UP) == -1 :#and _intilemov_minus.y < _pf.dist:
			_pf.available_directions[Vector2.UP] = 0.0
		else:
			_pf.available_directions[Vector2.UP] = 1.0
		if navmap.get_cellv(_pf.gridpos + Vector2.DOWN) == -1 :# and _intilemov_plus.y < _pf.dist:
			_pf.available_directions[Vector2.DOWN] = 0.0
		else:
			_pf.available_directions[Vector2.DOWN] = 1.0

	else:
		_pf.available_directions[Vector2.LEFT] = 0.0
		_pf.available_directions[Vector2.RIGHT] = 0.0
		_pf.available_directions[Vector2.UP] = 0.0
		_pf.available_directions[Vector2.DOWN] = 0.0
	if _pf.direction:
		_pf.dist = float(_pf.available_directions[_pf.direction]*_pf.dist)
	else:
		_pf.dist = 0.0
	return



	#original checkmove code
	_pf.ti = _get_tile_info(_pf.position,_pf.gridpos)	#get current tile information
#	_pf.nti = _next_tile_in_direction(_pf.position,_pf.gridpos,_pf.direction) #get next tile informaiton
	_pf.intilemoveOK = false
	_pf.tiletilemoveOK = false
	var _checkdir = Vector2.UP
	_pf.nti = _next_tile_in_direction(_pf.position,_pf.gridpos,_checkdir) #get next tile informaiton
	_pf.available_directions[_checkdir] = _ismovevalid(_pf,_checkdir)
	_checkdir = Vector2.DOWN
	_pf.nti = _next_tile_in_direction(_pf.position,_pf.gridpos,_checkdir) #get next tile informaiton
	_pf.available_directions[_checkdir] = _ismovevalid(_pf,_checkdir)
	_checkdir = Vector2.LEFT
	_pf.nti = _next_tile_in_direction(_pf.position,_pf.gridpos,_checkdir) #get next tile informaiton
	_pf.available_directions[_checkdir] = _ismovevalid(_pf,_checkdir)
	_checkdir = Vector2.RIGHT
	_pf.nti = _next_tile_in_direction(_pf.position,_pf.gridpos,_checkdir) #get next tile informaiton
	_pf.available_directions[_checkdir] = _ismovevalid(_pf,_checkdir)
	if _pf.direction:
		_pf.dist = _pf.available_directions[_pf.direction]
	else:
		_pf.dist = 0.0
	return# _pf

# warning-ignore:shadowed_variable
func _ismovevalid(_pf, _dir) -> float:
	var _ml = _getmovelist(movelist,_pf.ti[6])
	if _ml.has(_dir):
		if _ml[_dir]:
			if _checkmovelist(_ml[_dir],_pf.ti[5]):
				if _checknexttilemove(_pf.dist,_dir,_pf.prevdirection,_pf.ti[6],_pf.nti[6]):
					return _pf.dist
				else:
					if _pf.dist < _pf.nti[7] -1:
						return _pf.dist
					else:
						return _pf.nti[7] - 1
			else:
				pass
	else:
		return 0.0
	return 0.0

# warning-ignore:shadowed_variable
func _checknexttilemove(_dist, _dir, _prevdir,_uctv,_untv) -> bool:
	#check to see if the player can move in the requested direction for the next tile and position
	var _am = []
	if allowed_moves[_dir].has(_uctv):
		_am = allowed_moves[_dir][_uctv]
		if _am.has(_untv) or _uctv == _untv:
			return true
	return false

# warning-ignore:shadowed_variable
func _distance_to_next_tile(_pos:Vector2,_gp:Vector2,_dir:Vector2) -> float:
	var _wgp = map.map_to_world(_gp + _dir)
# warning-ignore:incompatible_ternary
	var _xofs = 0 if _dir.x > -1 else globals.tile_size.x -1
# warning-ignore:incompatible_ternary
	var _yofs = 0 if _dir.y > -1 else globals.tile_size.y -1
	var _dist
	if _dir.x:
		_dist = _pos.distance_to(Vector2(_wgp.x + _xofs - _dir.x, _pos.y))
	if _dir.y:
		_dist = _pos.distance_to(Vector2(_pos.x, _wgp.y + _yofs - _dir.y))
	return _dist

# warning-ignore:shadowed_variable
func _next_tile_in_direction(_pos:Vector2,_gp:Vector2,_dir:Vector2) -> Array:
	var _t = _get_tile_info(position,_gp + _dir)
	_t.append(_distance_to_next_tile(_pos,_gp,_dir))
	return _t

func _get_tile_info(_pos,_gp) -> Array:
	var _a = []
	_a.append(map.get_cellv(_gp)) #element [0] - tile ID
	if _a[0] != -1:
		_a.append(map.tile_set.tile_get_name(_a[0])) #element [1] - tile name
	else:
		_a.append("")
	_a.append(map.is_cell_x_flipped(_gp.x,_gp.y)) #element [2] - x flip state
	_a.append(map.is_cell_y_flipped(_gp.x,_gp.y)) #element [3] - y flip state
	_a.append(map.map_to_world(_gp))  #element [4] - grid position in world co-ords
	_a.append(_pos - _a[4]) #element [5] - position within cell
	var _uctv = _a[0]
	if _a[2]:
		_uctv += 1000
	if _a[3]:
		_uctv += 2000
	_a.append(_uctv) #element[6] - unique tile value
	return _a

func _getmovelist(_ml,_tile) -> Dictionary:
	if _ml.has(_tile):
		return _ml[_tile]
	return {}

func _checkmovelist(_ml:Array,_pos:Vector2) -> bool:
	var _x = int(_pos.x)
	var _y = int(_pos.y)
	var _xfound:bool = false
	var _yfound:bool = false
	if _ml: #check if there is anything in the array at all
		var _mvx = _ml[0]
		var _mvy = _ml[1]
		if not _xfound:
			#check the horizontal value/values
			if _mvx:
				if _mvx.has(_x):
					_xfound = true
				else:
					for _e in _mvx:
						if typeof(_e) == TYPE_ARRAY:
							if _e.has(_x):
								_xfound = true
								break
			else:
				_xfound = true
		if not _yfound:
			#check the horizontal value/values
			if _mvy:
				if _mvy.has(_y):
					_yfound = true
				else:
					for _e in _mvy:
						if typeof(_e) == TYPE_ARRAY:
							if _e.has(_y):
								_yfound = true
								break
			else:
				_yfound = true
		if _xfound and _yfound:
			return true
	return false

func draw_roof():
	var _start_pos = Vector2(0,6)
	for _l in range(50):
		map.set_cell(_start_pos.x + _l, _start_pos.y,12)

func draw_ladder():
	var _start_pos = Vector2(44,7)
	for _l in range(26):
		map.set_cell(_start_pos.x, _start_pos.y + _l,11)
		map.set_cell(_start_pos.x +1, _start_pos.y + _l,11,true)

func _create_navmap():
	var _sp:Vector2
	var _ep:Vector2
	var _data:Array = []
	var _ti:int
	var _dir:int
	var _fr:int
	var _rs:int
	var _fp:Vector2
	for _e in _path.size()-1:
		#get the start point, end point and type of tile at the start point
		_data = _path[_e]
		_sp = _data[0]
		_ti = _data[1]
		_data = _path[_e+1]
		_ep = _data[0]
		navmap.set_cellv(_sp,_ti)
		#check the direction of travel between start point and end point
		if _sp.x == _ep.x:
			_dir = TILE_VERTICAL
			_fr = _ep.y - _sp.y
		elif _sp.y == _ep.y:
			_dir = TILE_HORIZONTAL
			_fr = _ep.x - _sp.x
		else:
			_dir = TILE_HORIZONTAL
			_fr = _ep.x - _sp.x
		if _fr < 0:
			_rs = -1
		else:
			_rs = 1
		for _fill in range(_rs,_fr,_rs):

			if _dir == TILE_VERTICAL:
				_fp = _sp + Vector2(0,_fill)
			else:
				_fp = _sp + Vector2(_fill,0)
			navmap.set_cellv(_fp,_dir)
	_data = _path.back()
	navmap.set_cellv(_data[0],_data[1])

func _pctTile(_p:Vector2,_s:Vector2 = Vector2(32,32)) -> Vector2:
	var _pct:Vector2
	_pct.x = _s.x / _p.x
	_pct.y = _s.y / _p.y
	return _pct
