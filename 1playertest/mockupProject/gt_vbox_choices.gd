extends VBoxContainer
var button_group= ButtonGroup.new()
var current_graphs=[]
signal GT_choice_made
signal GT_all_choices_are_disabled
export(bool) var flat_buttons =0
export(int, "Left", "Center", "Right") var align_text=1
export(bool) var clip_text=0
export(Texture) var icon

func _ready():
	self.visible=false
	for child in get_children():
		child.queue_free()
	var _err
	_err= GTP.connect("GT_set_choices", self ,"_on_GT_set_choices")
	_err= connect("GT_choice_made", GTP, "_on_GT_choice_made")
	_err= connect("GT_all_choices_are_disabled", GTP, "_on_GT_all_choices_are_disabled")



func _on_GT_set_choices(graphs:Array):	#[] of {"choice" "if" "next_nID"}
	button_group= ButtonGroup.new()
	var disabled_buttons_counter=0
	for graph in graphs:
		var button= Button.new()
		button.icon=icon
		button.flat= flat_buttons
		button.clip_text= clip_text
		button.align=align_text
		button.editor_description=String(graph["next_nID"])
		button.text=graph["choice"]
		if button.text=="": button.text="unnamed choice"
		if !GTP.check_if(graph["if"]):
			disabled_buttons_counter+=1
			button.hint_tooltip=graph["if"]
			button.disabled=true
		button.set_button_group(button_group)
		button.connect("pressed", self, "_on_Button_pressed")
		add_child(button)
		self.visible=true
	if disabled_buttons_counter>=graphs.size():
		print("Graphtastic error: All choices disabled! no possible way to continue")
		emit_signal("GT_all_choices_are_disabled")
		


func _on_Button_pressed():
	var next_nID = button_group.get_pressed_button().editor_description as int
	emit_signal("GT_choice_made",next_nID)
	self.visible=false
	for child in get_children():
		child.queue_free()
