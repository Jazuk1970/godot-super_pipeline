extends Control
signal score_entered
signal hammertime_done

onready var player = $MaiHiScoreContainer/HiScoreContainer/VBoxContainer/HBoxContainer1/Player
onready var rank = $MaiHiScoreContainer/HiScoreContainer/VBoxContainer/HBoxContainer2/Rank
onready var score = $MaiHiScoreContainer/HiScoreContainer/VBoxContainer/HBoxContainer/Score
onready var seconds = $MaiHiScoreContainer/HiScoreContainer/VBoxContainer/HBoxContainer3/Seconds
onready var lettersleft = $MaiHiScoreContainer/Letters/Left
onready var letterSelected = $MaiHiScoreContainer/Letters/Selected
onready var lettersright = $MaiHiScoreContainer/Letters/Right
onready var hscname = $MaiHiScoreContainer/Name
onready var ht = $HAMMER_TIME
onready var anim = $AnimationPlayer
onready var timer = $Timer

const letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ. <*"
var numberofleftletters:int
var numberofrightletters:int
var entrytime:float = 50.0
var hammertime:float = 0.75
var currentindex:int = 0
var currentname:String
var scoreentered:bool


#PlayerVariables
var currentplayer:int = 1
var currentrank:int = 0
var currentscore:int = 0
var currentlives:int = 0
var currentskill:int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	var _ranks:Array = ["st","nd","rd","th"]
	var _ranked:String
	globals.getHiscores()
	currentscore = globals.playerstats[globals.Current_Player].score
	currentlives = globals.Lives
	currentskill = globals.Difficulty_Level
	scoreentered = false
	currentname = ""
	
	#Get the players rank
	currentrank = globals.getRank(currentscore)
	if currentrank >=4:
		_ranked  = _ranks[3]
	else:
		_ranked = _ranks[currentrank -1]
	player.text = str(currentplayer)
	rank.text = str(currentrank) + _ranked	
	score.text = str(currentscore)
	numberofleftletters = (letters.length()/2)
	numberofrightletters = letters.length() - (numberofleftletters +1)
	timer.start(entrytime)
	updateletters()
	anim.play("IDLE")


func _process(_delta):
	#Update the remaining time
	seconds.text=str("%02d" % timer.time_left)
	if ht.time_left == 0:
		if !scoreentered:
			if Input.is_action_just_pressed("move_left"):
				if currentindex == 0:
					currentindex = letters.length()-1
				else:
					currentindex -=1
				updateletters()
			elif Input.is_action_just_pressed("move_right"):
				if currentindex == letters.length()-1:
					currentindex = 0
				else:
					currentindex +=1
				updateletters()
			elif Input.is_action_just_pressed("fire"):
				if letterSelected.text == "<":
					currentname = currentname.substr(0,clamp(currentname.length()-1,0,3))
					hscname.text = currentname
					anim.play("HAMMER")
					AudioManager.sfx_play("HAMMER")
					ht.start(hammertime)
				elif letterSelected.text == "*":
					anim.play("HAMMER")
					AudioManager.sfx_play("HAMMER")
					ht.start(hammertime)
					wait_for_hammertime_done()
				else:
					if currentname.length() < 3:
						currentname += letterSelected.text
						hscname.text = currentname
						anim.play("HAMMER")
						AudioManager.sfx_play("HAMMER")
						ht.start(hammertime)
						if currentname.length() == 3:
							currentindex = letters.length()-1
							updateletters()
			
func getletters(index) -> Array:
	var selectedletter:String = ""
	var leftletters:String = ""
	var rightletters:String = ""
	var subindex:int
	#1st get the selected letter
	selectedletter = letters.substr(index,1)
	
	#get the left letters
	subindex = index -1
	for letter in range(numberofleftletters):
		if subindex < 0:
			subindex = letters.length()-1
		leftletters = letters.substr(subindex,1) + leftletters
		subindex -= 1
	

	#get the left letters
	subindex = index + 1
	for letter in range(numberofrightletters):
		if subindex > letters.length()-1:
			subindex = 0
		rightletters += letters.substr(subindex,1)
		subindex += 1
	
	return [leftletters,selectedletter,rightletters]

func updateletters():
	var currentletters:Array = getletters(currentindex)
	lettersleft.text = currentletters[0]
	letterSelected.text = currentletters[1]
	lettersright.text = currentletters[2]
	#add a little more time after moving
	timer.start(clamp(timer.time_left + 5,5,entrytime))
	
func _on_Timer_timeout():
	enterscore()

func _on_HAMMER_TIME_timeout():
	anim.play("IDLE")
	AudioManager.sfx_stop("HAMMER")
	emit_signal("hammertime_done")
	
func wait_for_hammertime_done():
	yield(self,"hammertime_done")
	enterscore()
	
func enterscore():
	scoreentered = true
	globals.hiscores = globals.setRank(currentrank,currentscore,currentname,currentlives,currentskill)
	globals.saveHiscores()
	emit_signal("score_entered")
