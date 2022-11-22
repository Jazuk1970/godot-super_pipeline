extends Container
onready var oHiScore:Object = $MainHud/TopLine/HI_Score/Score
onready var oPL1Score:Object = $MainHud/TopLine/PL1_Score/Score
onready var oPL2Score:Object = $MainHud/TopLine/PL2_Score/Score
onready var oPL1Lives:Object = $MainHud/BottomLine/PL1_Lives/Lives
onready var oPL2Lives:Object = $MainHud/BottomLine/PL2_Lives/Lives
onready var oPL1Label:Object = $MainHud/TopLine/PL1_Score/AnimationPlayer
onready var oPL2Label:Object = $MainHud/TopLine/PL2_Score/AnimationPlayer
onready var oLevelName:Object = $MainHud/BottomLine/LevelName/Name
onready var oDemoMode:Object = $MainHud/MidLine/DemoMode
onready var oMidLine:Object = $MainHud/MidLine
var PL1Score:int = 0
var PL2Score:int = 0
var HIScore:int = 0
var PL1Lives:int = 0
var PL2Lives:int = 0
var LevelName:String = ""
var maxselectablelevel = 8

func _ready():
	initialise()
	
func updateHud(node,val):
	node.text = val 

func updateScore(player,val):
	match player:
		1:
			PL1Score += val
			updateHud(oPL1Score,"%06d" % PL1Score)
			updateHiScore(PL1Score)
			globals.playerstats[player].score = PL1Score
		2:
			PL2Score += val
			updateHud(oPL2Score,"%06d" % PL2Score)
			updateHiScore(PL2Score)
			globals.playerstats[player].score = PL2Score
			
func updateLives(player,val):
	match player:
		1:
			if PL1Lives > 0:
				PL1Lives -= val
			updateHud(oPL1Lives,"%02d" % PL1Lives)
			globals.playerstats[player].lives = PL1Lives
		2:
			if PL2Lives > 0:
				PL2Lives -= val
			updateHud(oPL2Lives,"%02d" % PL2Lives)
			globals.playerstats[player].lives = PL2Lives

func updateHiScore(val):
	if val > HIScore:
		HIScore = val
	updateHud(oHiScore,"%06d" % HIScore)

func updateLevelName(_level_name = ""):
	LevelName = _level_name
	updateHud(oLevelName,_level_name)

func updatePlayer(player,state):
	match player:
		1:
			oPL1Label.play(state)
		2:
			oPL2Label.play(state)

func initialise():
	initplayerstats()
	PL1Score = globals.playerstats[1].score
	PL2Score = globals.playerstats[2].score
	PL1Lives = globals.playerstats[1].lives
	PL2Lives = globals.playerstats[2].lives
	updateScore(1,PL1Score)
	updateScore(2,PL2Score)
	updateLives(1,0)
	updateLives(2,0)
	updateHiScore(HIScore)
	updateLevelName(LevelName)
	demomode(false)

func demomode(_state:bool):
	oDemoMode.visible = _state

func initplayerstats():
	#Setup the player default
	globals.playerstats.clear()
	for _player in range(3): #1 is added because of the 0 in the array
		var _newplayer:PlayerStats = PlayerStats.new()
		_newplayer.lives = globals.Lives
		_newplayer.level = globals.Start_Level
		_newplayer.difficulty = globals.Difficulty_Level
		_newplayer.score = 0
		globals.playerstats.append(_newplayer)
