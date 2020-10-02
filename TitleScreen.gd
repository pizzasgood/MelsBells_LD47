extends Node

onready var start_button : Button = find_node("StartButton")
onready var exit_button : Button = find_node("ExitButton")

func _on_StartButton_pressed():
	get_tree().change_scene("res://Main.tscn")

func _on_ExitButton_pressed():
	get_tree().quit()

func _ready():
	start_button.connect("pressed", self, "_on_StartButton_pressed")
	exit_button.connect("pressed", self, "_on_ExitButton_pressed")
	start_button.grab_focus()

	if OS.get_name() == "HTML5":
		exit_button.queue_free()

