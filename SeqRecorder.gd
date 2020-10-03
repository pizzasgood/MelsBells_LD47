extends Node

onready var bg_flash : ColorRect = get_node("../BGFlash")
onready var seq_player = get_node("../SeqPlayer")
onready var failure_timer : Timer = get_node("FailureTimer")
onready var success_cooldown : Timer = get_node("SuccessCooldown")
onready var timer_bar : ProgressBar = get_parent().find_node("TimeLimit")

var recording = false
var position = 0

func _process(_delta):
	if not failure_timer.is_stopped():
		timer_bar.value = failure_timer.time_left / failure_timer.wait_time

func record_note(value):
	if recording:
		if value == seq_player.seq.notes[position]:
			_on_correct()
		else:
			_on_wrong()

func start_recording():
	failure_timer.start()
	position = 0
	recording = true

func stop_recording():
	recording = false
	_on_finished()

func _on_correct():
	position += 1
	if position >= len(seq_player.seq.notes):
		bg_flash.color = Color.green.darkened(0.5)
		print("Success!")
		stop_recording()

func _on_wrong():
	position = 0
	#TODO: error sound / shake
	bg_flash.color = Color.red.darkened(0.6)
	print("WRONG")

func _on_finished():
	failure_timer.stop()
	success_cooldown.start()

func _on_FailureTimer_timeout():
	#TODO: error sound / shake
	bg_flash.color = Color.red
	print("Time's up!  Next!")
	stop_recording()

func _on_SuccessCooldown_timeout():
	seq_player.play_random()
