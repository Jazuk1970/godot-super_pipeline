extends State
# warning-ignore:unused_class_variable
export (PackedScene) var oHiScoresEntry
var time:float = 8.0
var hiscoreentry:Object
func enter(_args:Dictionary = {}):
	globals.hud.visible = false
	hiscoreentry = oHiScoresEntry.instance()
	hiscoreentry.currentplayer = globals.Current_Player
	hiscoreentry.connect("score_entered",self,"on_score_entered")
	globals.level.add_child(hiscoreentry)
			
func exit(_args:Dictionary = {}):
	pass
			
func logic(_args:Dictionary = {}):
	pass
	
func on_score_entered():
	hiscoreentry.disconnect("score_entered",self,"on_score_entered")
	if _owner.fsm.statename == "NewHiScore":

		#clean up the hiscore entry table
		utility.queue_free_children(globals.level)
		if globals.Players > 1:
			if globals.playerstats[1].lives == 0 and globals.playerstats[2].lives == 0:
				#All players dead - show high scores
				_owner.ResetAndStateChange("HiScores")
			else:
				#if the current player is 1 (and its game over) the next player in multiplay must be 2
				if globals.Current_Player == 1:
					globals.Current_Player =2
				else:
					#otherwise the next player must be 1
					globals.Current_Player =1
				_owner.Level = globals.playerstats[globals.Current_Player].level
				_owner.ResetAndStateChange("LevelReset")
		else:
			emit_signal("StateChange","HiScores")
