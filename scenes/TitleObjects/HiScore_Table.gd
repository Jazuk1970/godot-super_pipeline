extends Control

signal score_entered

onready var scores = $MaiHiScoreContainer/HiScoreContainer/Score
onready var names = $MaiHiScoreContainer/HiScoreContainer/Name
onready var lives = $MaiHiScoreContainer/HiScoreContainer/Lives
onready var skill = $MaiHiScoreContainer/HiScoreContainer/Skill


#var _hsnodes:Dictionary = {}
var _last_score:int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	globals.getHiscores()
	showHiScores()

func showHiScores():
	var hiscore_scores = scores.get_children()
	var hiscore_names = names.get_children()
	var hiscore_lives = lives.get_children()
	var hiscore_skill = skill.get_children()
	for _hs in range(1,11):
		hiscore_scores[_hs-1].text = str(globals.hiscores[_hs]["score"])
		hiscore_names[_hs-1].text = str(globals.hiscores[_hs]["name"])
		hiscore_lives[_hs-1].text = str(globals.hiscores[_hs]["lives"])
		hiscore_skill[_hs-1].text = str(globals.hiscores[_hs]["skill"])
