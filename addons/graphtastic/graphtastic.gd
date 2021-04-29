tool
extends EditorPlugin

const MainPanel = preload("res://addons/graphtastic/dialog_editor/main_panel.tscn")
var main_panel_instance


func _enter_tree():
	add_custom_type("GTPlayer", "Control", preload("dialog_player/dialog_player.gd"), preload("graphtastic_icon.png"))
	main_panel_instance = MainPanel.instance()
	# Add the main panel to the editor's main viewport.
	get_editor_interface().get_editor_viewport().add_child(main_panel_instance)
	# Hide the main panel. Very much required.
	make_visible(false)


func _exit_tree():
	remove_custom_type("GTPlayer")
	if main_panel_instance:
		main_panel_instance.queue_free()


func has_main_screen():
	return true


func make_visible(visible):
	if visible:
		main_panel_instance.show()
	else:
		main_panel_instance.hide()


func get_plugin_name():
	return "GraphTastic"


func get_plugin_icon():
	# Must return some kind of Texture for the icon.
	return preload("graphtastic_icon.png")#get_editor_interface().get_base_control().get_icon("Node", "EditorIcons")
