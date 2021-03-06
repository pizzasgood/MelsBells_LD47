extends Entity

onready var crash_splash : CPUParticles2D = get_node("CrashSplash")
onready var crash_timer : Timer = get_node("CrashTimer")
onready var take_flight : AudioStreamPlayer2D = get_node("TakeFlight")
onready var crash_player : AudioStreamPlayer2D = get_node("CrashPlayer")
onready var short_buzz : AudioStreamPlayer = get_node("ShortBuzz")
onready var long_buzz : AudioStreamPlayer = get_node("LongBuzz")
onready var sparks : AnimatedSprite = get_node("Sparks")
onready var wings : AnimatedSprite = get_node("Wings")
onready var aura : AnimatedSprite = get_node("Aura")
onready var overflow : CPUParticles2D = get_node("ManaOverflow")

var strength setget , get_strength

var moving = false
var falling = false
var target
var walk_speed : float = 150
var fly_speed : float = 400
var fall_speed : float = 1000
var angular_speed : float
var fighting_distance : float = 100
var fighting_angle : float
var bossfight = false
var suppress_effects = false

func _init():
	max_hp = 100

func _ready():
	set_hp(0)
	angular_speed = walk_speed / loop.radius
	fighting_angle = fighting_distance / loop.radius

func _process(delta):
	if falling:
		var target_pos = Vector2(-loop.radius, 0)
		var amount = fall_speed * delta
		if position != target_pos:
			position = position.move_toward(target_pos, amount)
		else:
			falling = false
			self.loop_pos = TAU / 2
			do_shockwave()
			crash_timer.start()
			crash_player.play()
	elif moving:
		if hp < max_hp:
			# move to the next mook
			target = loop.get_next_monster()
			var amount = angular_speed * delta
			var target_angle = target.loop_pos + fighting_angle
			if loop.get_ccw_distance(loop_pos, target_angle) > amount:
				self.loop_pos -= amount
			else:
				self.loop_pos = target_angle
				moving = false
				target.engage()
		else:
			# fly to the boss battle!
			if not bossfight:
				bossfight = true
				take_flight.play()
			target = loop.boss
			var target_pos = target.position
			target_pos.x -= fighting_distance
			var amount = fly_speed * delta
			if position != target_pos:
				position = position.move_toward(target_pos, amount)
				var distance = position.distance_to(target_pos)
				if distance < 200:
					rotation = lerp_angle(loop_pos - TAU/4, 0, (200-distance) / 200)
			else:
				rotation = 0
				moving = false
				target.engage()
	if not suppress_effects:
		aura.visible = true if hp >= 0.4 * max_hp else false
		sparks.visible = true if hp >= 0.6 * max_hp else false
		wings.visible = true if (hp >= 0.8 * max_hp or bossfight) else false
		overflow.emitting = true if hp >= max_hp else false

func get_strength():
	return 10 + hp

func step_sprite():
	sprite.frame = (sprite.frame + 1) % sprite.frames.get_frame_count(sprite.animation)

func celebrate():
	sprite.play()

func knockout():
	print("Ouch!  You'll have to power back up to continue.")
	bossfight = false
	falling = true

# kill everything nearby
func do_shockwave():
	crash_splash.emitting = true
	for i in loop.get_monsters_within_range(loop_pos, 2 * fighting_angle):
		i.die()

func stop_effects():
	suppress_effects = true
	aura.visible = false
	sparks.visible = false
	wings.visible = false
	overflow.emitting = false

func _on_CrashTimer_timeout():
	moving = true

# these are some cheat codes for debugging
func _unhandled_input(event):
	if OS.is_debug_build():
		if event.is_action_pressed("ui_select"):
			self.hp += 20
		if event.is_action_pressed("ui_up"):
			self.hp = max_hp
		if event.is_action_pressed("ui_down"):
			self.hp = 0
		if event.is_action_pressed("ui_right"):
			self.loop_pos -= TAU / 4
		if event.is_action_pressed("ui_end"):
			loop.victory()
		if event.is_action("ui_left"):
			do_shockwave()
