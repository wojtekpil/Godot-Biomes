tool
extends GraphNode


func is_multiple_connections_enabled_on_slot(_slot: int):
	return false


func generate_resource(_output_slot: int):
	return null


func _on_BiomeNodeMesh_close_request():
	queue_free()


func _on_BiomeNodeMesh_resize_request(new_minsize: Vector2):
	rect_size = new_minsize
