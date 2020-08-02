tool
extends EditorPlugin

const MainPanel = preload("res://addons/wojtekpil.biomes/BiomeEditor.tscn")
const MainPanelIcon = preload("res://addons/wojtekpil.biomes/icons/icon_main.svg")
const BiomeRenderer = preload("res://addons/wojtekpil.biomes/scripts/runtime/BiomeRenderer.gd")
const BiomeRendererIcon = preload("res://addons/wojtekpil.biomes/icons/icon.svg")


var main_panel_instance


func _enter_tree():
	var base_control = get_editor_interface().get_base_control()
	main_panel_instance = MainPanel.instance()
	main_panel_instance.set_preview_provider(get_editor_interface().get_resource_previewer())
	#main_panel_instance.call_deferred("setup_dialogs", base_control)
	# Add the main panel to the editor's main viewport.
	get_editor_interface().get_editor_viewport().add_child(main_panel_instance)
	# Hide the main panel. Very much required.
	make_visible(false)
	#Register node
	add_custom_type("ProceduralBiome", "Spatial", BiomeRenderer, BiomeRendererIcon)



func _exit_tree():
	if main_panel_instance:
		main_panel_instance.queue_free()
	remove_custom_type("ProceduralBiome")


func has_main_screen():
	return true


func make_visible(visible):
	if main_panel_instance:
		main_panel_instance.visible = visible


func get_plugin_name():
	return "Biomes"


func get_plugin_icon():
	return MainPanelIcon
