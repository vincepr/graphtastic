tool
extends "res://addons/graphtastic/dialog_player/normal_mode/textbox/gt_dialog_textbox.gd"
export(NodePath) var singleton

func set_GTP():
	GTP=get_node(singleton)
