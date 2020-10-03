extends Node

onready var seq_player = find_node("SeqPlayer")
onready var seq_recorder = find_node("SeqRecorder")

func _ready():
	var bells = []
	for i in range(Sequence.NOTE_RANGE):
		bells.append(find_node("BellButton%s" % i))
		bells[-1].setup(i, "bell_%s" % i)
	var seq = Sequence.new()
	seq.generate_notes(5, 3)
	seq_player.play_seq(seq)

func _unhandled_input(event):
	if event.is_action_pressed("ui_select"):
		var seq = Sequence.new()
		seq.generate_notes(5, 3)
		seq_player.play_seq(seq)
		get_tree().set_input_as_handled()

func generate_sequence():
	pass

