extends Node2D
class_name Entity

onready var loop = get_parent()
onready var bar = get_node("HPBar")

var max_hp = 30
var hp : float = 0 setget set_hp

var loop_pos : float = 0 setget set_loop_pos

func _ready():
	set_hp(max_hp)

func set_hp(val):
	hp = clamp(val, 0, max_hp)
	bar.value = 100 * hp / max_hp

func set_loop_pos(val):
	loop_pos = fmod(val, TAU)
	var r = loop.radius
	position.x = r * cos(loop_pos)
	position.y = r * sin(loop_pos)
	rotation = loop_pos - TAU/4
