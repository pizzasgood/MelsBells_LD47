extends ColorRect

var duration = 1

func _process(delta):
	if color != Color.black:
		color = color.darkened(delta/duration)


