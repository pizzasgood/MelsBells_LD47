extends Node

onready var seq_player = find_node("SeqPlayer")
onready var seq_recorder = find_node("SeqRecorder")

func _ready():
	var bells = []
	for i in range(Sequence.NOTE_RANGE):
		bells.append(find_node("BellButton%s" % i))
		bells[-1].setup(i, "bell_%s" % i)

