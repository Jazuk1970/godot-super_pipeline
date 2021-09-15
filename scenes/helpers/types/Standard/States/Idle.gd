extends State
func enter(_args:Dictionary = {}):
	_owner.anim.play("Idle")
	_owner._setposition(_owner.position)
	
func exit(_args:Dictionary = {}):
	pass
	
func logic(_args:Dictionary = {}):
	pass

