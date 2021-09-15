extends State

func enter(_args:Dictionary = {}):
	#_owner.position = _owner.start_pos.snapped(Vector2(1,1))
	_owner.anim.play("Repair")
	
func exit(_args:Dictionary = {}):
	pass
	
func logic(_args:Dictionary = {}):
	var _delta = _args["delta"]
	var _repair_amount = _owner.work_effeciency * _delta
	_owner.target.health -= _repair_amount
	if _owner.target.health <= 0:
		_owner.target.trigger = true
		_owner.target = null
		emit_signal("StateChange","Idle")
