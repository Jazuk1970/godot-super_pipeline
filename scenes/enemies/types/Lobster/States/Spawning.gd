extends State
func enter(_args:Dictionary = {}):
	if globals.Game_State.statename != "Intermission":
		_owner.target = choose_target()
		_owner.pf.gridpos = _owner.target.grid_position
		_owner.direction = Vector2.RIGHT
	else:
		_owner.pf.gridpos = Vector2(_owner.pipeline.pipedata[0][0]+_owner.pipeline.pipedata[2][1],_owner.pipeline.pipedata[0][1])
		_owner.direction = Vector2.LEFT
	_owner.setposition(_owner.pipemap.map_to_world(_owner.pf.gridpos) + Vector2(1,1))

	_owner.anim.play("Walk")
	if globals.Game_State.statename == "Play":
		AudioManager.sfx_play("LOBSTER")
	emit_signal("StateChange","WalkPipe")
	
func exit(_args:Dictionary = {}):
	pass
	
func logic(_args:Dictionary = {}):
	var _delta = _args["delta"]
	pass

func choose_target() -> Object:
	_owner.targets.append(_owner.pipeline.pipeline.front())
	_owner.targets.append(_owner.pipeline.pipeline.back())
	randomize()
	return _owner.targets[randi()%2]
	
