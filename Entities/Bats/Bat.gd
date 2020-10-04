extends Enemy

func _ready():
	hint_overlay = load("res://TimeLimit/overlay_invert.png")

func _set_counter_seq():
	counter_seq.invert()
