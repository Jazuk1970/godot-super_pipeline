extends State
var intstate:int = 0
func enter(_args:Dictionary = {}):
	
	_owner.pipeline._draw_done = false
	if globals.Level_Data.Level_Type == "Pipeline":
		intstate = 0
		$AudioStreamPlayer.play()
	else:
		intstate = 2
func exit(_args:Dictionary = {}):
	$AudioStreamPlayer.stop()

func logic(_args:Dictionary = {}):
	if _owner.pipeline._draw_idx == 0 and _owner.pipeline.tmr.is_stopped():
		_owner.pipeline.draw_pipeline()
	if not _owner.pipeline._draw_done:
		return
	if intstate == 0:
		Delay(.5)
		intstate += 1
	if intstate == 2:
		
		if globals.Level_Data.Level_Type == "Pipeline":
			emit_signal("StateChange","Play")
		else:
			emit_signal("StateChange",globals.Level_Data.Level_Type)
		
func Delay(time):
	yield(get_tree().create_timer(time), "timeout")
	intstate += 1	
