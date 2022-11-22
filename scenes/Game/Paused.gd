extends Control
var paused:bool = false
func _process(_delta):
	if globals.Game_State.statename == "Play":
		if Input.is_action_just_pressed("pause"):
			TogglePauseMode(!paused)
	else:
		if paused:
			TogglePauseMode(false)
		
func TogglePauseMode(_paused):
	paused = _paused
	globals.paused.visible = paused
	get_tree().paused = paused
