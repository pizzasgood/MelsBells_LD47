extends Node

onready var seq_player = get_node("../SeqPlayer")
onready var failure_timer : Timer = get_node("FailureTimer")
onready var timer_bar : ProgressBar = get_parent().find_node("TimeLimit")

var recording = false
var position = 0
var target : Enemy

func _process(_delta):
	if not failure_timer.is_stopped():
		timer_bar.value = failure_timer.time_left / failure_timer.wait_time

func record_note(value):
	if recording:
		if value == target.counter_seq.notes[position]:
			_on_correct()
		else:
			_on_wrong()

func start_recording():
	failure_timer.start()
	position = 0
	recording = true

func stop_recording():
	recording = false
	failure_timer.stop()

func set_target(t):
	target = t

func _on_correct():
	position += 1
	if position >= len(seq_player.seq.notes):
		stop_recording()
		target.take_hit()

func _on_wrong():
	position = 0
	target.give_small_hit()

func _on_FailureTimer_timeout():
	stop_recording()
	target.give_big_hit()
