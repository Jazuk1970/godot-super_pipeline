extends Node
var DEBUG:bool = false
var screen_size:Vector2
# warning-ignore:unused_class_variable
var tile_size:Vector2
# warning-ignore:unused_class_variable
var mainscene:Object
# warning-ignore:unused_class_variable
var level:Object
# warning-ignore:unused_class_variable
var players:Object
# warning-ignore:unused_class_variable
var enemies:Object
# warning-ignore:unused_class_variable
var helpers:Object
# warning-ignore:unused_class_variable
var barrel:Object
# warning-ignore:unused_class_variable
var hud:Object
# warning-ignore:unused_class_variable
var paused:Object
# warning-ignore:unused_class_variable
var cameraanim:Object
# warning-ignore:unused_class_variable
var bgmusic:Object
# warning-ignore:unused_class_variable

var Level_Data:Dictionary
# warning-ignore:unused_class_variable
var Next_Level:String
# warning-ignore:unused_class_variable
var Game_State:Object
# warning-ignore:unused_class_variable
var Demo_Mode:bool
# warning-ignore:unused_class_variable
var Demo_NextState:int
# warning-ignore:unused_class_variable
var Demo_Level:String
# warning-ignore:unused_class_variable
var Current_Player:int
# warning-ignore:unused_class_variable
var Current_Level_Number:int
# warning-ignore:unused_class_variable
var oCurrent_Player:Object

#HighScore Information
# warning-ignore:unused_class_variable
const HIGH_SCORE_FILE_NAME = "user://hiscores.json"
var hiscores:Dictionary = {}

#Options
# warning-ignore:unused_class_variable
var Start_Level:String = "01"
# warning-ignore:unused_class_variable
var Difficulty_Level:int = 1
# warning-ignore:unused_class_variable
var Lives:int = 3
# warning-ignore:unused_class_variable
var Players:int = 1
# warning-ignore:unused_class_variable
var InGameMusic:bool = true setget _SetMusicMode
var OptionsState:bool 

#GameStates
#Player Variables
var playerstats:Array = [(playerstats),(playerstats),(playerstats)]

func _ready():
	screen_size.x = ProjectSettings.get_setting("display/window/size/width")
	screen_size.y = ProjectSettings.get_setting("display/window/size/height")

func getVect(_strPos) -> Vector2:
	if _strPos.length() < 4:
		return Vector2.ZERO
	return Vector2(_strPos.left(2),_strPos.right(2))

func _SetMusicMode(_val):
	InGameMusic = _val
	AudioManager.set_music_mode(_val)

func getHiscores():
	#load the high scores from the user data file
	#If is doesn't exist create a default set-up
	hiscores = {}
	var _data = file_handling.LoadFile(HIGH_SCORE_FILE_NAME)
	if _data[0] == OK:
		hiscores = str2var(_data[1])
	else:
		for _hs in range(10,0,-1):
			hiscores[11-_hs] = newScore(_hs * 1000,"TSK")
			saveHiscores()

func saveHiscores():
	#Save the high score to user data
	var _result = file_handling.SaveFile(HIGH_SCORE_FILE_NAME,hiscores)
	
func getRank(_score) -> int:
	#Find the players rank from the supplied score
	#If the player hasn't ranked the rank will be -1
	for _rank in range(1,hiscores.size()+1):
		if _score >=  hiscores[_rank].score:
			return _rank
	return -1

func setRank(_rank,_score,_name,_lives,_skill):
	var _newhighscores:Dictionary =  {}
	#Create the new score
	if _rank == 1:
		#player has ranked as 1, copy all but 1 previous scores after players score
		_newhighscores[_rank] = newScore(_score,_name,_lives,_skill)
		for _oldscore in range(1,hiscores.size()):
			_newhighscores[_newhighscores.size()+1] = hiscores[_oldscore]
	else:
		#first copy the scores upto the players rank
		for _oldscore in range(1,_rank):
			_newhighscores[_newhighscores.size()+1] = hiscores[_oldscore]
		#Insert the players score
		_newhighscores[_newhighscores.size()+1] = newScore(_score,_name,_lives,_skill)
		#Copy the remaining scores inot the new high score table
		for _oldscore in range(_rank,hiscores.size()):
			_newhighscores[_newhighscores.size()+1] = hiscores[_oldscore]
	return _newhighscores
	
func newScore(_score:int, _name:String = "...", _lives:int = 3, _skill:int = 2) -> Dictionary:
	var _newscore:Dictionary = {}
	_newscore["score"] = _score
	_newscore["name"] = _name
	_newscore["lives"] = _lives
	_newscore["skill"] = _skill
	return _newscore
