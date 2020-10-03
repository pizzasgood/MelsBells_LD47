extends Node2D

onready var mel = get_node("Mel")
onready var boss = get_node("Necro")
onready var victory_timer = get_node("VictoryTimer")

var radius = 1000
var mooks = [
	load("res://Entities/Zombies/Zombie.tscn"),
	load("res://Entities/Bats/Bat.tscn"),
	load("res://Entities/Ghosts/Ghost.tscn"),
]
var horde = []
var target_population = 5

func _ready():
	mel.loop_pos = TAU / 4
	repopulate()
	mel.moving = true

func _process(_delta):
	repopulate()

func repopulate():
	while len(horde) < target_population:
		spawn_mook()

func spawn_mook(angle=null):
	var id = randf() * len(mooks) * len(horde) / target_population
	spawn_entity(mooks[id], angle)

func spawn_entity(res, angle=null):
	var entity = res.instance()
	add_child(entity)
	entity.loop_pos = angle if angle != null else get_next_gap()
	horde.append(entity)
func spawn_zombie(angle=null):
	spawn_entity(mooks[0], angle)
func spawn_bat(angle=null):
	spawn_entity(mooks[1], angle)
func spawn_ghost(angle=null):
	spawn_entity(mooks[2], angle)

# identifies the next gap ahead of Mel in which a monster could be spawned
func get_next_gap():
	var minimum_gap = 300.0
	var a = mel.loop_pos
	var b = get_next_monster().loop_pos if len(horde) > 0 else mel.loop_pos
	var tries = 0
	while get_ccw_distance_in_pixels(a, b) < minimum_gap and tries <= len(horde):
		a = b
		b = get_next_monster(a).loop_pos
		tries += 1
	return a - (minimum_gap / (2*radius))

# returns the next monster after (not AT) the specified angle
func get_next_monster(angle=null):
	if angle == null:
		angle = mel.loop_pos
	var ret = null
	for e in horde:
		if ret == null:
			ret = e
		else:
			if get_ccw_distance(angle, e.loop_pos) < get_ccw_distance(angle, ret.loop_pos):
				ret = e
	return ret

func get_ccw_distance(a, b):
	# if a == b we're considering them to be a full circle apart
	# this enables searching for the nearest entity to another entity without fear of it just finding itself
	if fmod(a, TAU) == fmod(b, TAU):
		return TAU
	while b >= a:
		b -= TAU
	while b + TAU < a:
		b += TAU
	return a - b

func get_ccw_distance_in_pixels(a, b):
	return get_ccw_distance(a, b) * radius

func victory():
	print("You've defeated Loupe and saved your town!  Congratulations!")
	for e in horde:
		e.explode()
		victory_timer.start()

func _on_VictoryTimer_timeout():
	get_tree().change_scene("res://TitleScreen.tscn")
