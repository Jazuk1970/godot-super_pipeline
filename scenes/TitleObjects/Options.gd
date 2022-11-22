extends Control
#Setup object access
onready var oNumOfPlayers = $MainOptionsContainer/OptionsContainer/OptionValues/valNoOfPlayers
onready var oNumOfLives = $MainOptionsContainer/OptionsContainer/OptionValues/valNoOflives
onready var oStartingLevel = $MainOptionsContainer/OptionsContainer/OptionValues/valStartingLevel
onready var oBGMusic = $MainOptionsContainer/OptionsContainer/OptionValues/valBGMusic
onready var oSelNumOfPlayers = $MainOptionsContainer/OptionsContainer/OptionSelections/selNoOfPlayers
onready var oSelNumOfLives = $MainOptionsContainer/OptionsContainer/OptionSelections/selNoOfLives
onready var oSelStartingLevel = $MainOptionsContainer/OptionsContainer/OptionSelections/selStartingLevel
onready var oSelBGMusic = $MainOptionsContainer/OptionsContainer/OptionSelections/selBGMusic

#signals
signal OptionsStatus(_value)
signal StartGame

var _numofplayers:int setget _setnumofplayers
var _numoflives:int setget _setnumoflives
var _startinglevel:String setget _setstartinglevel
var _bgmusic:bool = true setget _setbgmusic
var options:Array
var selections:Array
var optionsstatus:bool = false

export (Color) var highlight_color = Color(1.0,1.0,0.0)
var highlight_on:bool = false
var _Highlight_flash_timer:float
var flash_time:float = 0.75
var current_selection:int = 0
var last_selection:int = 0
export (int) var max_selectable_level = 8

# Called when the node enters the scene tree for the first time.
func _ready():
	oSelStartingLevel.max_value = max_selectable_level
	current_selection = 0
	last_selection = 0
	options.clear()
	selections.clear()
	self._setnumofplayers(globals.Players)
	self._setnumoflives(globals.Lives)
	self._setstartinglevel(globals.Start_Level.to_int())
	self._setbgmusic(globals.InGameMusic)

	#Add the options into an object
	for option in $MainOptionsContainer/OptionsContainer/OptionDescriptions.get_children():
		options.append(option)
	for selection in $MainOptionsContainer/OptionsContainer/OptionSelections.get_children():
		selections.append(selection)
		if optionsstatus:
			activate(current_selection,true)
			highlight(current_selection,true)
		else:
			activate(current_selection,false)
			highlight(current_selection,false)
	setoptions(optionsstatus)

func _process(_delta):
	if optionsstatus:
		_Highlight_flash_timer += _delta
		if _Highlight_flash_timer > flash_time:
			highlight_on =!highlight_on
			highlight(current_selection,highlight_on)
		if !$MainOptionsContainer/InstructionsContainer.visible:
			if Input.is_action_just_pressed("move_up"):
					active_selection(-1)

			if Input.is_action_just_pressed("move_down"):
					active_selection(1)

			if Input.is_action_just_pressed("move_left"):
					active_value(current_selection,-1)

			if Input.is_action_just_pressed("move_right"):
					active_value(current_selection,1)

		if Input.is_action_just_pressed("ui_accept") and current_selection == selections.size()-1:
			show_instructions()

	else:
		if Input.is_action_just_pressed("fire"):
			emit_signal("StartGame")
		if Input.is_action_just_pressed("ui_accept"):
			optionsstatus = true
			_ready()

	if Input.is_action_just_pressed("ui_cancel"):
		activate(current_selection,false)
		highlight(current_selection,false)
		optionsstatus = false
		_ready()
	
func _setnumofplayers(_val):
	_numofplayers = _val
	oNumOfPlayers.text = "%0d" % _val
	oSelNumOfPlayers.value = _val
	globals.Players = _val
	
func _setnumoflives(_val):
	_numoflives = _val
	oNumOfLives.text = "%0d" % _val
	oSelNumOfLives.value = _val
	globals.Lives = _val
	
func _setstartinglevel(_val):
	_startinglevel = "%02d" % _val
	oStartingLevel.text = str(_val)
	oSelStartingLevel.value = _val
	globals.Start_Level = "%02d" % _val
	
func _setbgmusic(_val):
	_bgmusic = _val
	if _val:
		oBGMusic.text = "ON"
		
	else:
		oBGMusic.text = "OFF"
	oSelBGMusic.pressed = _val
	globals.InGameMusic = _val
	
func _on_selNoOfPlayers_value_changed(_val):
	self._numofplayers = _val

func _on_selNoOfLives_value_changed(_val):
	self._numoflives = _val

func _on_selStartingLevel_value_changed(_val):
	self._startinglevel = _val

func _on_selBGMusic_toggled(_button_pressed):
	self._bgmusic = _button_pressed

func highlight(_selection,_state):
	match _state:
		false:
			options[_selection].set("custom_colors/font_color",null)
		true:
			options[_selection].set("custom_colors/font_color",highlight_color)
	#Reset the flash timer
	_Highlight_flash_timer = 0
		
func activate(_selection,_state):
	#Get the object type for the current selection
	var _type:String = selections[_selection].get_class()
	var _CheckState = !_state
	match _type:
		"HSlider":
			selections[_selection].editable = _state
			$MainOptionsContainer/AdjustmentHelp/lblAdjustmentHelp.text = "Use LEFT/RIGHT to adjust values"

		"CheckButton":
			selections[_selection].disabled = _CheckState
			$MainOptionsContainer/AdjustmentHelp/lblAdjustmentHelp.text = "Use LEFT/RIGHT to adjust values"

		"Control":
			$MainOptionsContainer/AdjustmentHelp/lblAdjustmentHelp.text = "Press ENTER to show instuctions"
		_:
			pass
		
func active_selection(_value):
	if (_value > 0 and current_selection < selections.size()-1) or (_value < 0 and current_selection > 0):
		if current_selection == selections.size()-2 and _value > 0 and !$MainOptionsContainer/OptionsContainer/OptionSelections.visible:
			return
		#Unhighlight the old selection and highlight the new selection
		last_selection = current_selection
		current_selection += _value
		highlight(last_selection,false)
		highlight(current_selection,true)
		activate(last_selection,false)
		activate(current_selection,true)


func active_value(_selection,_value):
	if !$MainOptionsContainer/OptionsContainer/OptionSelections.visible:
		return
	
	#Get the object type for the current selection
	var _type:String = selections[_selection].get_class()
	match _type:
		"HSlider":
			selections[_selection].value += _value
		"CheckButton":
			selections[_selection].pressed = true if _value > 0 else false
		_:
			pass
		
func show_instructions():
	$MainOptionsContainer/InstructionsContainer.visible = !$MainOptionsContainer/InstructionsContainer.visible
	$MainOptionsContainer/OptionsContainer.visible = !$MainOptionsContainer/OptionsContainer.visible
	$MainOptionsContainer/AdjustmentHelp.visible = !$MainOptionsContainer/AdjustmentHelp.visible

func setoptions(_status):
	$MainOptionsContainer/InstructionsContainer.visible = false
	$MainOptionsContainer/OptionsContainer.visible = true
	match _status:
		false:
			$MainOptionsContainer/PressToStart.visible = true
			$MainOptionsContainer/OptionsContainer/OptionSelections.visible = false
			$MainOptionsContainer/AdjustmentHelp.visible = false
			setinstructions(false)
		true:
			$MainOptionsContainer/PressToStart.visible = false
			$MainOptionsContainer/OptionsContainer/OptionSelections.visible = true
			$MainOptionsContainer/AdjustmentHelp.visible = true
			setinstructions(true)
	emit_signal("OptionsStatus",_status)

func setinstructions(_status):
	$MainOptionsContainer/OptionsContainer/OptionDescriptions/lblInstructions.visible = _status
	$MainOptionsContainer/OptionsContainer/OptionValues/valInstructions.visible = _status
	$MainOptionsContainer/OptionsContainer/OptionSelections/selInstructions.visible = _status
	
