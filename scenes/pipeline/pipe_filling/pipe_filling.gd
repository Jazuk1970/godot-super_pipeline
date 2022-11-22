extends Node2D
signal flow_output
onready var spr = $Sprite
onready var tmr = $Timer
var fsm:StateMachine = StateMachine.new()
var nextstate:String = ''
var type:int
var subtype:int
var flow_reverse:bool = false
var flip_x:bool = false
var flip_y:bool = false
var blockreq:bool setget _blocked
var blocked:bool = false
var flow_adjustment:int = 1
var flow_rate:float
var fillcol:Color = Color8(255,255,255)
var current_fill:int = 0
var current_state:int = 0
var empty_state:int = 0
var full_state:int = 16
var Anim_Arrays:Array = [\
						[0,1,2,3,4,5,6,7,8,27,26,25,24,23,22,21,0],\
						[0,1,2,3,4,5,6,7,8,37,36,35,34,33,32,31,0],\
						[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,45,44,43,42,41,40,39,38,37,36,35,34,33,32,31,0],\
						[0,1,2,3,4,53,52,51,0],\
						[0,17,18,19,20,49,48,47,0],\
						[0,1,2,3,4,5,6,7,8,9,10,11,12,10,11,9,12,38,37,36,35,34,33,32,31,0]]
var fill_states:Array = []
var base_frame:int
# warning-ignore:unused_class_variable
var current_frame:int
var _frames_per_row = 30
# warning-ignore:unused_class_variable
var grid_position:Vector2 =  Vector2.ZERO
# warning-ignore:unused_class_variable
var upstream:Object = null
# warning-ignore:unused_class_variable
var downstream:Object = null

var flow_in:bool = false
var flow_in_enable:bool = false
var flow_out:bool = false
var flow_out_enable:bool = false
var flow_state:int
var nextflowupdate:int = 0
var _instantfill:bool = false
var master_flow_enabled = true


func _ready():
	set_process(true)
	fsm._owner = self
	fsm.add_states($States)
	fsm._on_state_change("InitPipe")

func _process(delta):
	if fsm.state != null:
		var _args = {"delta":delta}
		if master_flow_enabled:
			fsm.state.logic(_args)
			_update_flowout()
			_update_flowin()
			if _instantfill:
				_updateflow()
		

func _on_Timer_timeout():
	if blockreq != blocked:
		blocked = blockreq

	#If a state change is requested update to the next state
	if nextstate != '':
		fsm._on_state_change(nextstate)
		nextstate = ''


	#If a flow update is requested update the flow count
	if nextflowupdate != 0:
		_updateflow()

	#Restart the timer
	tmr.start(flow_rate)

func _blocked(_val):
	blockreq = _val

func _updateflow():
	_instantfill = true if flow_rate <= 0 else false
	if _instantfill:
		#Instantly fill the pipe if we are filling or are empty
		if fsm.statename == "Filling" or fsm.statename == "Full":
			current_fill = full_state
		#Instantly empty the pipe if we are full or emptying
		elif fsm.statename == "Empty" or fsm.statename == "Emptying":
			current_fill = empty_state
	else:
		#Move to the next pipe "fill" state in the animation
		if fsm.statename == "Full":
			if current_fill > full_state + 8:
				current_fill = full_state -1
		current_fill += flow_adjustment
		if current_fill >= fill_states.size() or current_fill < 0:
			current_fill = 0 if not flow_reverse else fill_states.size() -1
	#Acknowledge that the flow update has been done
	nextflowupdate = 0
	#update the animation frame
	_update_fill()

func _update_fill():
	current_state = fill_states[current_fill]
	spr.frame = base_frame + current_state

func _update_flowin():
	#Start off by setting flow input to false
	flow_in_enable = false
	if not blocked:
		if fsm.statename == "Empty" or fsm.statename == "Filling":
			flow_in_enable = true
		if fsm.statename == "Full" and flow_out_enable:
			flow_in_enable = true

func _update_flowout():
	#Enable flow out by default
	flow_out_enable = true
	#Disable flow out by default
	flow_out = false
	#Check if we have a downstream pipe
	if downstream != null:
		#Update the flow output enable based on the downstream flow in enblae status
		if not downstream.blocked:
			flow_out_enable = downstream.flow_in_enable
		else:
			flow_out_enable = false
	if fsm.statename == "Full" or fsm.statename == "Emptying":
		flow_out = true
	#Update the flow input of the downstream pipe
	if downstream != null and flow_out_enable:
		downstream.flow_in = flow_out
	emit_signal("flow_output",flow_out)
	
func init_pipe():
	#Set the fill colour
	spr.modulate = fillcol
	#Create the empty pipe state value
	empty_state = 0
	#set the animation states if the pipe is straight
	if type == 3:
		fill_states = Anim_Arrays[5]
		full_state = 8
	elif subtype == 0 and type != 2:
		fill_states = Anim_Arrays[0]
		full_state = 8
	#set the animation states if the pipe is a corner
	elif subtype == 0 and type == 2:
		fill_states = Anim_Arrays[1]
		full_state = 8
	#set the animation states if this is a horizontal/hc or vertical/vc
	elif (subtype == 5 and type == 0) or (subtype == 15 and type == 1):
		fill_states = Anim_Arrays[2]
		full_state = 16
	elif subtype == 100:
		fill_states = Anim_Arrays[4]
		full_state = 20
	else:
		fill_states = Anim_Arrays[3]
		full_state = 4

	#set the starting "fill" state value, this ranges from 0 to the number of elements in the animation
	current_fill = 0 if not flow_reverse else fill_states.size() -1

	#Set the current animation frame from the animation list
	current_state = fill_states[current_fill]
	#Set the base frame number depending on the type of pipe
	base_frame = type * (_frames_per_row * 2)
	#Set the actual animation frame number in the set to be used
	spr.frame = empty_state
	#Set the orientation of the pipe graphic
	spr.flip_h = flip_x
	spr.flip_v = flip_y
	#Set-up the animation update timer
	tmr.one_shot = true
	tmr.start(flow_rate)
	#Set up the flow direction for the pipe
	if flow_reverse:
		flow_adjustment = -1
	else:
		flow_adjustment = 1

func pipe_fill():
	#fsm.statename == "Full"
	current_fill = full_state
	_update_fill()

func pipe_empty():
	#fsm.statename == "Empty"
	current_fill = empty_state
	_update_fill()

func master_flow_enable(state):
	master_flow_enabled = state
