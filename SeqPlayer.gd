extends Node

onready var seq_recorder = get_node("../SeqRecorder")
onready var warmup_timer : Timer = get_node("Warmup")

var bpm = 180
var seq
var warmed_up = false
var playing = false
var position
var now
var bells = []
var difficulty = 3

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
	start()

func play_random():
	seq = Sequence.new()
	seq.generate_notes(difficulty)
	start()

func start():
	if not warmed_up:
		warmup_timer.start()
		return
	now = 0
	position = 0
	playing = true
	play_current_note()

func _on_finished():
	seq_recorder.start_recording()


func _on_Warmup_timeout():
	warmed_up = true
	start()
