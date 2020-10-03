extends Enemy

func _init():
	max_hp = 500

func _ready():
	pass

func _set_counter_seq():
	counter_seq.reverse()
	counter_seq.invert()

func _on_death():
		queue_free()
		loop.victory()
