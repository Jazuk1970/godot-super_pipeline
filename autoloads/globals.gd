extends Node
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
var Level_Data:Dictionary

func _ready():
	screen_size.x = ProjectSettings.get_setting("display/window/size/width")
	screen_size.y = ProjectSettings.get_setting("display/window/size/height")

func getVect(_strPos) -> Vector2:
	if _strPos.length() < 4:
		return Vector2.ZERO
	return Vector2(_strPos.left(2),_strPos.right(2))
