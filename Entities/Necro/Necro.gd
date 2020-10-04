extends Enemy

func _init():
	max_hp = 2000

func _ready():
	hint_overlay = load("res://TimeLimit/overlay_invert-reverse.png")

func _set_counter_seq():
	counter_seq.reverse()
	counter_seq.invert()

func _on_death():
		queue_free()
		loop.victory()
