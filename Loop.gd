extends Node2D

onready var mel = get_node("Mel")
onready var boss = get_node("Necro")
onready var victory_timer = get_node("VictoryTimer")
onready var intro_animation : AnimationPlayer = get_node("IntroAnimation")
onready var background = get_node("Background")
onready var flatground = get_node("FlatBackground")
onready var bgm : AudioStreamPlayer = get_node("BGM")

var radius = 750
var mooks = [
	load("res://Entities/Zombies/Zombie.tscn"),
	load("res://Entities/Bats/Bat.tscn"),
	load("res://Entities/Ghosts/Ghost.tscn"),
]
var target_population = 20
var intro_finished = false
var ground_flashing = false

func _ready():
	mel.loop_pos = TAU / 4
	intro_animation.play("Intro")

func _process(_delta):
	if ground_flashing:
		background.visible = not background.visible
	if intro_finished:
		repopulate()

func flash_ground():
	flatground.visible = true
	ground_flashing = true

func use_loop_ground():
	ground_flashing = false
	flatground.visible = false
	background.visible = true

func use_flat_ground():
	ground_flashing = false
	flatground.visible = true
	background.visible = false

func start_music():
	bgm.play()

func start_game():
	intro_finished = true
	mel.moving = true

func get_horde():
	return get_tree().get_nodes_in_group("mooks")

func count_horde():
	return len(get_horde())

func repopulate():
	while count_horde() < target_population:
		spawn_mook()

func spawn_mook(angle=null):
	var id = randf() * len(mooks) * count_horde() / target_population
	spawn_entity(mooks[id], angle)

func spawn_entity(res, angle=null):
	if angle == null:
		angle = get_next_gap()
	var entity = res.instance()
	add_child(entity)
	entity.loop_pos = angle
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
	var b = get_next_monster().loop_pos if count_horde() > 0 else mel.loop_pos
	var tries = 0
	while get_ccw_distance_in_pixels(a, b) < minimum_gap and tries <= count_horde():
		a = b
		var next = get_next_monster(a)
		b = next.loop_pos
		tries += 1
	return a - (minimum_gap / (2*radius))

# returns the next monster after (not AT) the specified angle
func get_next_monster(angle=null):
	if angle == null:
		angle = mel.loop_pos
	var ret = null
	for e in get_horde():
		if ret == null:
			ret = e
		else:
			if get_ccw_distance(angle, e.loop_pos) < get_ccw_distance(angle, ret.loop_pos):
				ret = e
	return ret

# gets the ccw distance from a to b in radians
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

# this gets the shortest distance from a to b in radians, ignoring directions
# only use this for AOE stuff; use get_ccw_distance() for finding nearest enemy
func get_distance(a, b):
	var d = fmod(abs(b - a), TAU)
	if d > TAU/2:
		d = TAU - d
	return d

# returns a list of monsters within +/- angle of position
func get_monsters_within_range(pos, angle):
	var ret = []
	for e in get_horde():
		if get_distance(pos, e.loop_pos) <= angle:
			ret.append(e)
	return ret

# returns a list of monsters within +/- pixels of position
func get_monsters_within_pixel_range(pos, pixels):
	var angle = pixels / radius
	return get_monsters_within_range(pos, angle)

func victory():
	print("You've defeated Loupe and saved your town!  Congratulations!")
	target_population = 0
	for e in get_horde():
		e.die()
		victory_timer.start()

func _on_VictoryTimer_timeout():
	get_tree().change_scene("res://TitleScreen.tscn")
