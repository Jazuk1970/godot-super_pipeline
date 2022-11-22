extends State
var intstate:int = 0
func enter(_args:Dictionary = {}):
	_owner.pipeline._draw_done = false
	if globals.Level_Data.Level_Type == "Pipeline":
		intstate = 0
		AudioManager.music_play("GET_READY")
	elif globals.Level_Data.Level_Type == "Title":
		intstate = 2
		if globals.Level_Data.has("Music"):
			AudioManager.music_play(globals.Level_Data.Music)
	else:
		intstate = 2
				
func exit(_args:Dictionary = {}):
	pass
	
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
