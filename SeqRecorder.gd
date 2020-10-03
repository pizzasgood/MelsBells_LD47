extends Node

onready var seq_player = get_node("../SeqPlayer")

var bpm = 120
var seq
var recording = false
var position = 0
var duration
var now

func _process(delta):
	if recording:
		now += delta
		var new_position = floor((now) * bpm / 60)
		if new_position >= duration:
			stop_recording()
		elif new_position != position:
			position = new_position
			seq.notes.append(-1)

func record_note(value):
	if recording:
		seq.notes[position] = value

func start_recording(beats):
	seq = Sequence.new()
	seq.notes.append(-1)
	now = 0
	position = 0
	duration = beats
	recording = true

func stop_recording():
	recording = false
	seq.trim()
	seq.print()
	_on_finished()

func _on_finished():
	print("Score: %s" % seq.compare(seq_player.seq))
	var new_seq = Sequence.new()
	new_seq.generate_notes(5, 3)
	seq_player.play_seq(new_seq)
