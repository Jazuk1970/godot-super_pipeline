extends Node

func vect2Int(_v2:Vector2) -> Vector2:
	#Reduce the precision of a vector 2 to integer values
	return Vector2(int(_v2.x),int(_v2.y))
	
static func queue_free_children(node: Node) -> void:
	if node == null:
		return
	for n in node.get_children():
		node.remove_child(n)
		n.queue_free()
