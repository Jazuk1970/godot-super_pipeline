extends Node

func vect2Int(_v2:Vector2) -> Vector2:
	#Reduce the precision of a vector 2 to integer values
	return Vector2(int(_v2.x),int(_v2.y))
	
