extends Node
class_name StateMachine
signal StateCompleted
signal StateChanged
var states:Dictionary = {}
var history:Array = []
var maxhistory:int = 20
var statename:String
var state:Object
var _owner:Object
export (bool) var DEBUG = false

func state_back():
	if history.size() > 0:
		state_change(history.pop_front())

func add_states(_states:Object):
	states = {}
	for _state in _states.get_children():
		if _state:
			states[_state.name] = _state
			_state.connect("StateComplete", self,"_on_state_complete")
			_state.connect("StateChange", self,"_on_state_change")
			_state._owner = _owner

func _on_state_complete():
	emit_signal("StateCompleted",state)

func _on_state_change(_next_state):
	if _next_state != null:
		state_change(_next_state)
		

func state_change(_next_state):
	if _next_state != null:
		if state != null:
			history.push_front(state.name)
			if history.size() > maxhistory:
				history.pop_back()
			state.exit()
		if states.has(_next_state):
			if DEBUG:
				print("Node:", _owner.name,", State changed to :",_next_state)
			state = states[_next_state]
			statename = state.name
			state.enter()
			emit_signal("StateChanged",_next_state)

		else:
			if DEBUG:
				print("Node:", _owner.name,", state: ",_next_state," requested but does not exists")
