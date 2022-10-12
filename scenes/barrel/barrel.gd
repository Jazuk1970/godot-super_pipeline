extends Node2D
var _fill_level:int = 0

func fill_level(val):
	$FillLevel.text = "%04d" % val
	_fill_level = val

