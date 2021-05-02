extends RichTextLabel


## only change speaker if there is a change
export(bool) var speaker_persistent = true

func _ready():
	self.visible=false
	self.bbcode_enabled=true
	bbcode_text=""
	var _err= GTP.connect("GT_set_speaker", self, "_on_GT_set_speaker")
	_err= GTP.connect("GT_dialog_finished", self, "_on_GT_dialog_finished")

func _on_GT_set_speaker(speaker):
	if speaker_persistent:
		if bbcode_text!="" or bbcode_text!= " ":
			if speaker=="" or speaker==" ":
				#case for persistent here speaker "keeps speaking" till another speaker comes
				self.visible=true
				return
	bbcode_text=speaker
	if bbcode_text!="" or bbcode_text!= " ":
		self.visible=true
	else: self.visible=false

func _on_GT_dialog_finished():
	self.visible=false
	bbcode_text=""

