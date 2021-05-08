extends Control

onready var texbox = get_node("VBoxContainer/TextboxSpace/GTDialogTextbox")
var resource
var startChapter
var startId

func _ready():
	texbox.resource_path=resource
	texbox.chapterID=startChapter
	texbox.startID=startId
	texbox._ready()					# we need to call _ready() again with these valid new starting points (they were empty before)
	
	#if we want wanted to set a different textspeed,
	# each time we create a dialog we could add that here aswell
	# textbox.textspeed=....



###  the next part is to connect our pulsing button and its invisible parent (over the textbox)
### to simulate a keypress when clicked

func _on_Touch_Button_pressed():
	simulate_key()


func _on_Contine_Button_pressed():
	simulate_key()


func simulate_key():
	var event = InputEventKey.new()
	event.pressed = true
	event.scancode = 32
	texbox._input(event)
	
	
### this will hide and show our "waiting for input"/continue button 
func _on_GTDialogTextbox_GT_text_animation_finished():
	get_node("VBoxContainer/TextboxSpace/Touch_Button").visible=true


func _on_GTDialogTextbox_GT_text_animation_started():
	get_node("VBoxContainer/TextboxSpace/Touch_Button").visible=false

