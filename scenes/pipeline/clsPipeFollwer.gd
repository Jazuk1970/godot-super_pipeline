extends Node
class_name PipeFollower
# warning-ignore:unused_class_variable
var gridpos:Vector2
# warning-ignore:unused_class_variable
var position:Vector2
# warning-ignore:unused_class_variable
var direction:Vector2
# warning-ignore:unused_class_variable
var inputdirection:Vector2
# warning-ignore:unused_class_variable
var prevdirection:Vector2
# warning-ignore:unused_class_variable
var lastmovement:Vector2
# warning-ignore:unused_class_variable
var ti:Array = [0,'',false,false,Vector2.ZERO,Vector2.ZERO,0]
# warning-ignore:unused_class_variable
var nti:Array = [0,'',false,false,Vector2.ZERO,Vector2.ZERO,0,0]
# warning-ignore:unused_class_variable
var intilemoveOK:bool
# warning-ignore:unused_class_variable
var tiletilemoveOK:bool
# warning-ignore:unused_class_variable
var supressdirchange:bool
# warning-ignore:unused_class_variable
var dist:float
# warning-ignore:unused_class_variable
var facingdirection:Vector2
# warning-ignore:unused_class_variable
var fdmemory:Vector2
# warning-ignore:unused_class_variable
var moving:bool
# warning-ignore:unused_class_variable
var available_directions:Dictionary = {}

