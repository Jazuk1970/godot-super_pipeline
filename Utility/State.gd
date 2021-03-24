extends Node
class_name State
# warning-ignore:unused_signal
signal StateComplete
# warning-ignore:unused_signal
signal StateChange
# warning-ignore:unused_class_variable
var fsm:StateMachine = null
# warning-ignore:unused_class_variable
var _owner:Object

func enter(_args:Dictionary = {}):
	pass

func exit(_args:Dictionary = {}):
	pass
	
func logic(_args:Dictionary = {}):
	pass
		
