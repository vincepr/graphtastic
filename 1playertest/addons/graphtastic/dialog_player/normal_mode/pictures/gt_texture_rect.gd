extends TextureRect


export(bool) var is_persistent = false
export(int, "Left", "Center", "Right") var identifier=1
var error_label=null


# Called when the node enters the scene tree for the first time.
var GTP
func set_GTP():
	GTP=get_node("/root/GTP")


func _ready():
	set_GTP()
	self.visible=false
	self.texture=null
	var _err= GTP.connect("GT_set_pictures", self, "_on_GT_set_pictures")
	_err= GTP.connect("GT_dialog_finished", self, "_on_GT_dialog_finished")


func _on_GT_dialog_finished():
	self.visible=false

func _on_GT_set_pictures(pictures):
	#print(pictures)
	if error_label != null:
		error_label.queue_free()
		error_label=null
	var is_valid_picture=false
	var pic = parse_json(pictures)
	pic = pic[identifier]
	var file2Check = File.new()
	if file2Check.file_exists(pic): 
		texture=load(pic)
		is_valid_picture=true
	else:
		if pic in GTP.pictures:
			pic=String(GTP.pictures[pic])
			if file2Check.file_exists(pic): 
				texture=load(pic)
				is_valid_picture=true
	
	if is_valid_picture:
		self.visible=true
	else: 
		if texture!=null and is_persistent:
			self.visible=true
		else: 
			texture=null
			if pic == "" or pic == " " or pic == "#":
				self.visible=false
			else:
				create_error_message(pic)
				self.visible=true
	file2Check.close()

func create_error_message(pic):
	error_label = Label.new()
	self.add_child(error_label)
	error_label.text="no picture in: "+pic
	
	