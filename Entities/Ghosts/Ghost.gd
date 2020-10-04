extends Enemy

func _ready():
	hint_overlay = load("res://TimeLimit/overlay_reverse.png")

func _set_counter_seq():
	counter_seq.reverse()
