extends RichTextLabel

signal GT_dialog_started
signal GT_dialog_finished
signal GT_text_changed
signal GT_text_animation_finished
signal GT_text_animation_started
signal GT_set_speaker
signal GT_set_pictures
signal GT_set_choices
signal GT_variables_were_changed


export(String, FILE, "*.tsv") var resource_path
export(int, 1, 9999) var chapterID = 1
export(int, 1, 9999) var startID = 1
export(float, 0.1, 10) var textspeed =1
export(InputEvent) var contine_key
export(InputEvent) var skip_key 

const anim_playertscn = preload("animation_player.tscn")
const story_file_helpergd = preload("story_file_helper.gd")
var anim_player = anim_playertscn.instance()
var story_helper =story_file_helpergd.new()
var next_graphs = []
var is_waiting_for_choice=false 
var is_animation_finished=false


func _ready():
	self.bbcode_enabled=true
	add_child(anim_player)
	anim_player.playback_speed=textspeed
	if !story_helper.load_from_tsv(resource_path):
		dialog_finished()
		return
	if !story_helper.set_startpoint(chapterID, startID): 
		dialog_finished()
		return
	setup_signals()
	emit_signal("GT_dialog_started")
	main_loop()


func _input(event):			#player input handling
	if is_animation_finished and !is_waiting_for_choice:
		if event is InputEventKey:
			if event.scancode == KEY_SPACE and event.pressed == true:
				main_move_to_next_graph()


func dialog_finished():
	emit_signal("GT_dialog_finished")
	queue_free()


func setup_signals():
	var _err
	#ingoing:
	_err = anim_player.connect("animation_finished", self ,"_on_Body_AnimationPlayer_animation_finished")
	_err = GTP.connect("GT_choice_made", self ,"_on_GT_choice_made")	
	#outgoing: (all to GTP- singleton who forwards them)
	_err = connect("GT_dialog_started", GTP ,"_on_GT_dialog_started")
	_err = connect("GT_set_choices", GTP, "_on_GT_set_choices")
	_err = connect("GT_set_pictures", GTP, "_on_GT_set_pictures")
	_err = connect("GT_set_speaker", GTP, "_on_GT_set_speaker")
	_err = connect("GT_dialog_finished", GTP, "_on_GT_dialog_finished")
	_err = connect("GT_text_animation_started", GTP, "_on_GT_text_animation_started")
	_err = connect("GT_text_animation_finished", GTP, "_on_GT_text_animation_finished")
	_err = connect("GT_variables_were_changed", GTP, "_on_GT_variables_were_changed")
	
	

func main_loop():
	#set datasets
	var current = story_helper.get_current_data() ###  {"nid": 1, "dialogtext" "speaker "pictures" "choices" "connects"}
	do_dialogtext(current["dialogtext"])
	do_speaker(current["speaker"])
	do_pictures(current["pictures"])
	
	next_graphs = do_choices_connects(current["choices"], current["connects"])
	#print(next_graphs)
	if next_graphs.size() == 1:### only 1 next graph: ###
		is_waiting_for_choice=false
	elif next_graphs.size() >1:#### multiple selections to choose from
		is_waiting_for_choice=true
	else:
		is_waiting_for_choice=false#later add here goto next chapter check before
		next_graphs=[]
	is_animation_finished=false
	emit_signal("GT_text_animation_started")
	anim_player.play("TextFadeIn")
	

func main_move_to_next_graph(nextID=0):
	if next_graphs.size()==0:
		dialog_finished()
	elif next_graphs.size()==1:
		story_helper.change_current_to(next_graphs[0]["next_nID"])
		emit_signal("GT_text_changed")
		main_loop()
	else: 		##### graphsize >1
		story_helper.change_current_to(nextID)
		main_loop()


func do_dialogtext(dialog:String):
	var current_text=dialog
	# do if function
	if "<change>" in current_text:
		current_text = _parse_change_variables(current_text)
	if "<signal>" in current_text:
		current_text = _parse_custom_signals(current_text)	
	#do inject variables between #()#
	current_text=GTP.inject_variables(current_text)
	bbcode_text=current_text

func do_speaker(speaker:String):
	emit_signal("GT_set_speaker", speaker)
	
	
func do_pictures(pictures:String):
	emit_signal("GT_set_pictures", pictures)
	

func do_choices_connects(choices:Array, connects:Array):
	var next_connections = get_valid_next_connections(choices,connects)
	var counter = 0
	for connection in next_connections:
		if GTP.check_if(connection["if"]): 
			counter+=1
	if counter==0: return []
	return next_connections


func get_valid_next_connections(choices:Array, connects:Array):
	var all_valid_connections=[]
	for connection in connects:
		var dict = {"next_nID": connection[1] as int,
		"choice": choices[connection[0]][0],
		"if": choices[connection[0]][1]
		}
		all_valid_connections.push_back(dict)
	return all_valid_connections 
	#[{"choice": "red potion", "if": "3==3", "next_nID": 2},{"choice": "blue potion", "if": "10>4", "next_nID":3},{"choice": "blue potion", "if": "10>4", "next_nID":4}]




#####			incomming signals:				####
func _on_Body_AnimationPlayer_animation_finished(_anim_name):
	is_animation_finished = true
	emit_signal("GT_text_animation_finished")
	if is_waiting_for_choice: emit_signal("GT_set_choices",next_graphs)


func _on_GT_choice_made(next_nID:int):
	main_move_to_next_graph(next_nID)
	

### 			text manipulation functions:		####
func _get_tagged_text(tag : String, text : String) -> String:
	var start_tag = "<"+tag+">"
	var end_tag = "</"+tag+">"
	var start_index = text.find(start_tag) + start_tag.length()
	var end_index = text.find(end_tag)
	var substr_length = end_index - start_index
	return text.substr(start_index, substr_length)


func _parse_change_variables(text : String) -> String:
	var variable_count = text.count("<change>")
	var changes=[]
	for _i in range(variable_count):
		var splitcommand = _get_tagged_text("change", text).split("=", true, 1)
		var _error = GTP.change_variable_to(splitcommand[0], splitcommand[1])
		var start_index = text.find("<change>")
		var end_index = text.find("</change>") + "</change>".length()
		var substr_length = end_index - start_index
		text.erase(start_index, substr_length)
		changes.push_back([splitcommand[0], GTP.parse_expr(splitcommand[1])])
	emit_signal("GT_variables_were_changed", changes)
	return text

func _parse_custom_signals(text: String) -> String:
	var variable_count = text.count("<signal>")
	var signals=[]
	for _i in range(variable_count):
		var one_signal=_get_tagged_text("signal", text)
		print("one_signal")
		print("parser for signals in work atm")
	return text
