extends CanvasLayer
onready var player = $Control/Container1/Title2/PLayer

# Called when the node enters the scene tree for the first time.
func _ready():
	player.text = "%02d" % globals.Current_Player


