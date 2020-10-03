extends Node

onready var seq_recorder = get_node("../SeqRecorder")

var bpm = 120
var seq
var playing = false
var position = 0
var now
var bells = []

func _ready():
	for i in range(Sequence.NOTE_RANGE):
		bells.append(get_parent().find_node("BellButton%s" % i))

func _process(delta):
	if playing:
		now += delta
		var new_position = floor((now) * bpm / 60)
		if new_position >= len(seq.notes):
			playing = false
			_on_finished()
		elif new_position != position:
			position = new_position
			play_current_note()

func play_current_note():
	play_note(seq.notes[position])

func play_note(note):
	if note >= 0:
		bells[note].play()

func play_seq(sequence):
	seq = sequence
	seq.print()
	now = 0
	position = 0
	playing = true
	play_current_note()

func _on_finished():
	seq_recorder.start_recording(floor(len(seq.notes)*1.5))
