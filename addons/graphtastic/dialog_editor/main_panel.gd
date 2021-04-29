tool
extends Control
onready var graph_paneltscn = preload("grapheditor/graph_panel.tscn")
var graph_panel
onready var filedialog = get_node("FileDialog")
onready var chaptermenu = get_node("VBoxContainer/MainMenu/ChapterMenuButton")
onready var label_filename_savedinfo = get_node("VBoxContainer/MainMenu/LabelFilename")
var chapterdata = [{"chapterID": 1, "chaptername": "chapter1", "poolstrings": []}]
var current_chapterID: int = 0
var copy_graphs_takeover = null

#this data should never get changed on runtime:
var empty_chapter_template= {"chapterID": 1, "chaptername": "unnamed", "poolstrings": []}
var headerinfo_chapter: PoolStringArray = ["<- chaptername", "<- chapterID"]
var headerinfo: PoolStringArray = ["nID", "slots", "name", "dialogtext", "speaker", "facepice", "off_x", "off_y", "choices", "connects"]


func _ready():
	chaptermenu.get_popup().connect("id_pressed", self, "_on_ChapterMenuButton_selected")
	get_node("NewChapterPopup").register_text_enter(get_node("NewChapterPopup/LineEdit"))
	get_node("RenameChapterPopup").register_text_enter(get_node("RenameChapterPopup/LineEdit"))
	set_current_chapter(1)


func set_current_chapter(newID):
	if newID == current_chapterID:
		print("cant set new chapter since it didnt change")
		return
	
	for chapter in chapterdata:
		if chapter["chapterID"] == newID:
			current_chapterID = newID
			setupChapterMenuButton()
			create_new_graphedit_from_current_chapter()
			return
	print("error: set_current_chapter went wrong!")


func setupChapterMenuButton(): 	
	chaptermenu.get_popup().clear()
	chaptermenu.get_popup().add_item("add New Chapter")
	chaptermenu.get_popup().add_item("change Name of Chapter")
	chaptermenu.get_popup().add_item("delete current Chapter")
	chaptermenu.get_popup().add_separator()
	for chapter in chapterdata:
		chaptermenu.get_popup().add_item(String(chapter["chapterID"])+" | "+chapter["chaptername"])	
		if chapter["chapterID"] == current_chapterID:
			chaptermenu.text= String(chapter["chapterID"])+" | "+chapter["chaptername"]
		


func create_new_graphedit_from_current_chapter(): 	#basically just extension of setupChapterMenuButton()
	if graph_panel != null:
		graph_panel.free()
	graph_panel = graph_paneltscn.instance()
	get_node("VBoxContainer").add_child(graph_panel)
	if copy_graphs_takeover != null:
		graph_panel.get_node("Vbox/GraphEdit").copy_d_graphs=copy_graphs_takeover
	
	var poolstrings
	for chapter in chapterdata:
		if chapter["chapterID"] ==current_chapterID:
			poolstrings= chapter["poolstrings"]
	graph_panel.get_node("Vbox/GraphEdit").set_data_from_poolstrings(poolstrings)


func load_current_chapter_from_graphedit():	
	copy_graphs_takeover=graph_panel.get_node("Vbox/GraphEdit").copy_d_graphs
	var poolstrings = graph_panel.get_node("Vbox/GraphEdit").get_data_from_poolstrings()
	for chapter in chapterdata:
		if chapter["chapterID"]==current_chapterID:
			chapter["poolstrings"] = poolstrings

#######     funcs to load and save to tsv       			 ###########
func _on_SaveTsv_pressed():
	filedialog.mode=4
	filedialog.popup_centered_ratio(0.7)
func _on_LoadTsv_pressed():
	filedialog.mode=0
	filedialog.popup_centered_ratio(0.7)
func _on_FileDialog_file_selected(filepath):
	if filedialog.mode==0:
		load_from_tsv(filepath)
	elif filedialog.mode==4:
		save_as_tsv(filepath)


func save_as_tsv(file_path:String):
	load_current_chapter_from_graphedit()
	var save = File.new()
	save.open(file_path, File.WRITE)
	save.store_csv_line(headerinfo, "	")
	for chapter in chapterdata:
		var info: PoolStringArray = [chapter["chaptername"], 
		headerinfo_chapter[0], String(chapter["chapterID"]), headerinfo_chapter[1], ]
		save.store_csv_line(info, "	")
		for poolstring in chapter["poolstrings"]:
			save.store_csv_line(poolstring, "	")


func load_from_tsv(file_path):
	var new_chapterdata = []
	var save = File.new()
	if not save.file_exists(file_path):
		print("graphtastic_error: no file to load")
		return
	save.open(file_path, File.READ)
	var loadedheader = save.get_csv_line("	")
	if loadedheader != headerinfo:
		print("graphtastic_error: headercheck error, file is corrupt and cant be loaded")
		return
	if save.eof_reached():
		print("graphtastic_error:, file empty cant load")
		return 
	var nextline = save.get_csv_line("	")
	if nextline.size() != 2*headerinfo_chapter.size():
		print("graphtastic_error: first chapter data size is wrong")
		return
	elif (nextline[1]==headerinfo_chapter[0] and nextline[3]==headerinfo_chapter[1]):
		var new_chapter = empty_chapter_template.duplicate()
		new_chapter["chapterID"]=nextline[2] as int
		new_chapter["chaptername"]=nextline[0]
		new_chapter["poolstrings"]=empty_chapter_template["poolstrings"].duplicate()
		new_chapterdata.push_back(new_chapter)
	else:
		print("graphtastic_error: no first chapter exists in file")
		return
	nextline = save.get_csv_line("	")
	while !save.eof_reached():
		if nextline.size() != headerinfo.size() and nextline.size() != 2*headerinfo_chapter.size():
			print("graphtastic_error file data of wrong column-size when loading the line: "+String(nextline))
			return
		elif nextline[1]==headerinfo_chapter[0] and nextline[3]==headerinfo_chapter[1]:
			var new_chapter = empty_chapter_template.duplicate()
			new_chapter["chapterID"]=nextline[2] as int
			new_chapter["chaptername"]=nextline[0]
			new_chapter["poolstrings"]=empty_chapter_template["poolstrings"].duplicate()
			new_chapterdata.push_back(new_chapter)
		else:
			new_chapterdata[new_chapterdata.size()-1]["poolstrings"].push_back(nextline)
		nextline = save.get_csv_line("	")
	chapterdata=new_chapterdata
	current_chapterID=0
	set_current_chapter(new_chapterdata[0]["chapterID"])
	
func parse_chapter_data(poolstring):
	var new 

###########		new- file/chapter	delete		changename		###########


func _on_NewFile_pressed():
	get_node("CreateNewFilePopup").popup_centered()
func _on_CreateNewFilePopup_confirmed():
	chapterdata=[] ###empty chapter data
	current_chapterID=0
	var empty_chapter = empty_chapter_template.duplicate()
	chapterdata.push_back(empty_chapter)
	set_current_chapter(1)


func _on_ChapterMenuButton_selected(listnr):
	if listnr == 0:_on_NewChapter_pressed()
	elif listnr == 1: _on_ChanngeChapterName_pressed()
	elif listnr == 2: _on_DeleteChapter_pressed() 
	else:
		var newid = chapterdata[listnr-4]["chapterID"]
		load_current_chapter_from_graphedit()
		set_current_chapter(newid)


func _on_NewChapter_pressed():
	get_node("NewChapterPopup").popup_centered()
	get_node("NewChapterPopup/LineEdit").grab_focus()
func _on_NewChapterPopup_confirmed():
	load_current_chapter_from_graphedit()
	var new_chapter_name = get_node("NewChapterPopup/LineEdit").text
	if new_chapter_name == "": new_chapter_name = "unnamed"
	var empty_chapter = empty_chapter_template.duplicate()
	for position in chapterdata.size():
		if chapterdata[position]["chapterID"] != (position+1):
			chapterdata.insert(position ,empty_chapter)
			chapterdata[position]["chapterID"]=position+1
			chapterdata[position]["chaptername"]=new_chapter_name
			set_current_chapter(position+1)
			return
	chapterdata.push_back(empty_chapter)
	chapterdata[chapterdata.size()-1]["chapterID"]=chapterdata.size()
	chapterdata[chapterdata.size()-1]["chaptername"]=new_chapter_name
	set_current_chapter(chapterdata.size())



func _on_DeleteChapter_pressed():
	get_node("DeleteChapterPopup").popup_centered()
func _on_DeleteChapterPopup_confirmed():
	if chapterdata.size() > 1:
		for chapter in chapterdata:
			if chapter["chapterID"] == current_chapterID:
				chapterdata.erase(chapter)
		set_current_chapter(chapterdata[0]["chapterID"])
	else: _on_CreateNewFilePopup_confirmed() 
		#cant delete last chapter so make new file instead
	


func _on_ChanngeChapterName_pressed():
	get_node("RenameChapterPopup").popup_centered()
	for chapter in chapterdata:
		if chapter["chapterID"] == current_chapterID:
			get_node("RenameChapterPopup/LineEdit").text=chapter["chaptername"]
	get_node("RenameChapterPopup/LineEdit").select_all()	#grab_focus()
	get_node("RenameChapterPopup/LineEdit").grab_focus()
func _on_RenameChapterPopup_confirmed():
	var new_chapter_name = get_node("RenameChapterPopup/LineEdit").text
	if new_chapter_name == "": new_chapter_name = "unnamed"
	for chapter in chapterdata:
			if chapter["chapterID"] == current_chapterID:
				chapter["chaptername"] = new_chapter_name
				setupChapterMenuButton()
				return
	print("error couldnt properly rename")
