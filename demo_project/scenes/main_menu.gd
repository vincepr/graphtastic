extends Control
var dialog_player_instance=null


func _ready():
	#make this listen if the singleton GTD sends the "GT_dialog_finished" signal
	var _error = GTD.connect("GT_dialog_finished", self, "on_done_playing")
	## lets fill the variables we want to use in this demo:
	GTD.variables={"playername": "default", "other data": 100, "health": 99,}
	GTD.pictures={"bg2": "res://demo_project/resources/pictures_bg/forest_bg.jpg"}


func _on_demo_project_pressed():
	
	#this is how you could integrate dialog into your own game:
	var dialog_player_tscn = preload("res://demo_project/scenes/dialog_player.tscn")
	dialog_player_instance= dialog_player_tscn.instance()
	#here we set the starting point of our dialog, then afterwards add it as a child to our scene_tree
	dialog_player_instance.resource="res://demo_project/story_files/intro.tsv"			
	dialog_player_instance.startChapter=1		
	dialog_player_instance.startId=1		
	add_child(dialog_player_instance)
	get_node("Start").visible=false		#just turns this main_menu invisible


func _on_mockup_editor_pressed():
	var scene = preload("res://addons/graphtastic/dialog_editor/main_panel.tscn")
	var start= scene.instance()
	add_child(start)
	get_node("Start").visible=false


func on_done_playing():
	#delete our now useless dialog_player, since he has finished with it's dialog
	if dialog_player_instance!= null:
		dialog_player_instance.queue_free()
	#make our menu visible again:
	get_node("Start").visible=true
