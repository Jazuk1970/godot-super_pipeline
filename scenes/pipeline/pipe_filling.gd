extends Node2D
signal flow_output
onready var spr = $Sprite
onready var tmr = $Timer
var type:int
var subtype:int
var flow_reverse:bool = false
var flip_x:bool = false
var flip_y:bool = false
var flow_in:bool = false
var flow_out:bool = false
var blockreq:bool setget _blocked
var blocked:bool = false
var _nextflowupdate:int = 0
var flow_adjustment:int = 1
var flow_rate:float
var _fillcol:Color = Color8(255,255,255)
var current_fill:int = 0
var current_state:int = 0
var empty_state:int = 0
var full_state:int = 16
var Anim_Arrays:Array = [\
						[0,1,2,3,4,5,6,7,8,27,26,25,24,23,22,21,0],\
						[0,1,2,3,4,5,6,7,8,37,36,35,34,33,32,31,0],\
						[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,45,44,43,42,41,40,39,38,37,36,35,34,33,32,31,0],\
						[0,1,2,3,4,53,52,51,0],\
						[0,17,18,19,20,49,48,47,0]]
var fill_states:Array = []
var base_frame:int
# warning-ignore:unused_class_variable
var current_frame:int
var _frames_per_row = 30
# warning-ignore:unused_class_variable
var grid_position:Vector2 =  Vector2.ZERO

func _ready():
	init_pipe()

func init_pipe():
	spr.modulate = _fillcol
	empty_state = 0
	if subtype == 0 and type != 2: #if the pipe is straight
		fill_states = Anim_Arrays[0]
		full_state = 8
	elif subtype == 0 and type == 2: #if the pipe is a corner
		fill_states = Anim_Arrays[1]
		full_state = 8
	elif (subtype == 5 and type == 0) or (subtype == 15 and type == 1):	#If this is a horizontal/hc or vertical/vc
		fill_states = Anim_Arrays[2] # use full size array
		full_state = 16
	elif subtype == 100:
		fill_states = Anim_Arrays[4] # use full size array
		full_state = 20
	else:
		fill_states = Anim_Arrays[3] # use full size array
		full_state = 4
		
	current_fill = 0 if not flow_reverse else fill_states.size() -1
	current_state = fill_states[current_fill]
	spr.frame = empty_state
	spr.flip_h = flip_x
	spr.flip_v = flip_y
	tmr.one_shot = true
	tmr.stop()
	base_frame = type * (_frames_per_row * 2)
	
	if flow_reverse:
		flow_adjustment = -1
	else:
		flow_adjustment = 1


#update flow function called via a signal to change the input state of this pipe and start the flow timer functions
func update_flow(_flow:bool,_col):
	if current_state == empty_state or current_state == full_state:
		_nextflowupdate = 0
		_fillcol = _col
		flow_in = _flow

		if flow_rate > 0:
			tmr.start(flow_rate)
		else:
			_on_Timer_timeout()
	else:
		_nextflowupdate = 1 if _flow else 2
		

func _on_Timer_timeout():
	var _actualflow_in:bool
	var _instantfill:bool = true
	if (current_state == empty_state or current_state == full_state):
		if _nextflowupdate != 0:
			flow_in = true if _nextflowupdate == 1 else false
			_nextflowupdate = 0
		if blockreq != blocked:
			blocked = blockreq
	_actualflow_in = false if blocked else flow_in
	if _actualflow_in:
		if current_state == empty_state:
			spr.modulate = _fillcol
		while _instantfill:	
			if flow_rate > 0:
				_instantfill = false
			if current_state != full_state:
				current_fill += flow_adjustment
				if current_fill >= fill_states.size():
					current_fill = 0
				current_state = fill_states[current_fill]
				spr.frame = base_frame + current_state
				if current_state == full_state:
					flow_out = true
					emit_signal("flow_output",flow_out,_fillcol)
					tmr.stop()
				else:
					if not _instantfill:
						tmr.start(flow_rate)
			else:
				_instantfill = false
	else:
		while _instantfill:
			if flow_rate > 0:
				_instantfill = false
			if current_state != empty_state:
				current_fill += flow_adjustment
				current_state = fill_states[current_fill]
				spr.frame = base_frame + current_state
				if current_state == empty_state:
					flow_out = false
					current_fill = 0 if not flow_reverse else fill_states.size() -1
					emit_signal("flow_output",flow_out,_fillcol)
					tmr.stop()
				else:
					if not _instantfill:
						tmr.start(flow_rate)
			else:
				_instantfill = false
	if _nextflowupdate != 0 or blocked or blockreq:
		tmr.start(flow_rate)
		
func _blocked(_val):
	blockreq = _val
	if tmr.is_stopped():
		tmr.start(flow_rate)
