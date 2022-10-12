extends Container
onready var oHiScore:Object = $MainHud/TopLine/HI_Score/Score
onready var oPL1Score:Object = $MainHud/TopLine/PL1_Score/Score
onready var oPL2Score:Object = $MainHud/TopLine/PL2_Score/Score
onready var oPL1Lives:Object = $MainHud/BottomLine/PL1_Lives/Lives
onready var oPL2Lives:Object = $MainHud/BottomLine/PL2_Lives/Lives
onready var oPL1Label:Object = $MainHud/TopLine/PL1_Score/AnimationPlayer
onready var oPL2Label:Object = $MainHud/TopLine/PL2_Score/AnimationPlayer
onready var oLevelName:Object = $MainHud/BottomLine/LevelName/Name
var PL1Score:int = 0
var PL2Score:int = 0
var HIScore:int = 0
var PL1Lives:int = 0
var PL2Lives:int = 0
var LevelName:String = ""

func _ready():
	_initialise()
	
func _updateHud(node,val):
	node.text = val 

func _updateScore(player,val):
	match player:
		1:
			PL1Score += val
			_updateHud(oPL1Score,"%06d" % PL1Score)
			_updateHiScore(PL1Score)
		2:
			PL2Score += val
			_updateHud(oPL2Score,"%06d" % PL2Score)
			_updateHiScore(PL2Score)

func _updateLives(player,val):
	match player:
		1:
			if PL1Lives > 0:
				PL1Lives -= val
			_updateHud(oPL1Lives,"%02d" % PL1Lives)
		2:
			if PL2Lives > 0:
				PL2Lives -= val
			_updateHud(oPL2Lives,"%02d" % PL2Lives)

func _updateHiScore(val):
	if val > HIScore:
		HIScore = val
	_updateHud(oHiScore,"%06d" % val)

func _updateLevelName(val):
	LevelName = val
	_updateHud(oLevelName,val)

func _updatePlayer(player,state):
	match player:
		1:
			oPL1Label.play(state)
		2:
			oPL2Label.play(state)

func _initialise():
	PL1Score = 0
	PL2Score = 0
	PL1Lives = 3
	PL2Lives = 3
	_updateScore(1,PL1Score)
	_updateScore(2,PL2Score)
	_updateLives(1,0)
	_updateLives(2,0)
	_updateHiScore(HIScore)
	_updateLevelName(LevelName)

