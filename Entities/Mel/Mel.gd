extends Entity

var strength setget , get_strength

var moving = false
var target : Enemy
var speed : float = 200
var angular_speed : float
var fighting_distance : float = 100
var fighting_angle : float

func _init():
	max_hp = 100

func _ready():
	set_hp(0)
	angular_speed = speed / loop.radius
	fighting_angle = fighting_distance / loop.radius

func _process(delta):
	if moving:
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
			target = loop.boss
			var target_pos = target.position
			target_pos.x -= fighting_distance
			var amount = speed * delta
			if position != target_pos:
				position = position.move_toward(target_pos, amount)
			else:
				rotation = 0
				moving = false
				target.engage()

func get_strength():
	return 10 + hp
