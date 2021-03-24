extends State
# warning-ignore:unused_class_variable
var trigger:bool = false

func enter(_args:Dictionary = {}):
	_owner.anim.play("WalkStop")
	_owner.target.trigger = true
	_owner.queue_free()
	
func exit(_args:Dictionary = {}):
	pass
func logic(_args:Dictionary = {}):
	pass
