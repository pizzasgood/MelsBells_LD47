extends Entity

var strength setget , get_strength

var moving = false
var falling = false
var target : Enemy
var walk_speed : float = 150
var fly_speed : float = 300
var fall_speed : float = 500
var angular_speed : float
var fighting_distance : float = 100
var fighting_angle : float
var bossfight = false

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
			moving = true
			self.loop_pos = TAU / 2
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
			bossfight = true
			target = loop.boss
			var target_pos = target.position
			target_pos.x -= fighting_distance
			var amount = fly_speed * delta
			if position != target_pos:
				position = position.move_toward(target_pos, amount)
			else:
				rotation = 0
				moving = false
				target.engage()

func get_strength():
	return 10 + hp

func knockout():
	print("Ouch!  You'll have to power back up to continue.")
	bossfight = false
	falling = true

func _unhandled_input(event):
	if event.is_action("ui_up"):
		self.hp = max_hp - 10
	if event.is_action("ui_down"):
		self.hp = 0
	if event.is_action("ui_right"):
		loop.victory()
