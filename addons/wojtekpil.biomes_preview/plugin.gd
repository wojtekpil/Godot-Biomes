tool
extends EditorPlugin

var edited_scene: Node setget set_edited_scene
const BiomeRenderer = preload("res://addons/wojtekpil.biomes/scripts/runtime/BiomeRenderer.gd")


func _enter_tree():
	connect("scene_changed", self, "set_edited_scene")

func _exit_tree():
	pass

# Always active
func handles(node: Object):
	set_edited_scene(node.get_tree().get_edited_scene_root())
	return true


func update_all_biome_nodes(node, camera):
	if node == null:
		return
	if node is BiomeRenderer:
		node.update_viewer_position(camera)
	for N in node.get_children():
		if N.get_child_count() > 0:
			update_all_biome_nodes(N, camera)


func set_edited_scene(new_root: Node):
	edited_scene = new_root


func forward_spatial_gui_input(camera, event):
	update_all_biome_nodes(edited_scene, camera)
	return false
