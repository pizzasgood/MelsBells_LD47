extends CenterContainer

onready var resume_button : Button = find_node("ResumeButton")
onready var quit_button : Button = find_node("QuitButton")

func _on_ResumeButton_pressed():
	visible = false
	get_tree().paused = false

func _on_QuitButton_pressed():
	visible = false
	get_tree().paused = false
	get_tree().change_scene("res://TitleScreen.tscn")

func _ready():
	visible = false
	resume_button.connect("pressed", self, "_on_ResumeButton_pressed")
	quit_button.connect("pressed", self, "_on_QuitButton_pressed")

func _unhandled_input(event):
	if event.is_action_pressed("menu"):
		if visible:
			_on_ResumeButton_pressed()
		else:
			visible = true
			resume_button.grab_focus()
			get_tree().paused = true
		get_tree().set_input_as_handled()
