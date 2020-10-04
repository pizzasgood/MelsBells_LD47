extends Entity
class_name Enemy

onready var mel = get_node("../Mel")
onready var bg_flash : ColorRect = get_node("/root/Main").find_node("BGFlash")
onready var seq_player = get_node("/root/Main").find_node("SeqPlayer")
onready var seq_recorder = get_node("/root/Main").find_node("SeqRecorder")
onready var death_effect : CPUParticles2D = get_node("Evaporation")
onready var death_sfx : AudioStreamPlayer2D = get_node("DeathSFX")

var reward = 10
var difficulty = 3
var own_seq := Sequence.new()
var counter_seq := Sequence.new()
var cooldown : Timer
var affect_mel_on_death = false

func _ready():
	cooldown = Timer.new()
	cooldown.one_shot = true
	cooldown.wait_time = 1
	cooldown.connect("timeout", self, "_on_cooldown_timeout")
	add_child(cooldown)

func _process(_delta):
	if hp == 0:
		sprite.visible = not sprite.visible

func _set_counter_seq():
	pass

func engage():
	own_seq.generate_notes(difficulty)
	counter_seq.copy_from(own_seq)
	_set_counter_seq()
	own_seq.print()
	counter_seq.print()
	seq_recorder.set_target(self)
	seq_player.play_seq(own_seq)

func take_hit():
	self.hp -= mel.strength
	if hp > 0:
		bg_flash.color = Color.blue.darkened(0.5)
		print("Success!")
		cooldown.start()
	else:
		mel.hp += reward
		bg_flash.color = Color.blue
		print("Monster defeated!")
		die(true)

func give_small_hit():
	mel.hp -= max(2, reward / 5)
	# TODO: error sound / shake
	bg_flash.color = Color.red.darkened(0.6)
	mel.short_buzz.play()
	print("WRONG")

func give_big_hit():
	mel.hp -= reward / 2
	# TODO: error sound / shake
	bg_flash.color = Color.red
	mel.long_buzz.play()
	print("Time's up!")
	if mel.bossfight and mel.hp < mel.max_hp / 2:
		mel.knockout()
	else:
		cooldown.start()

func die(affect_mel=false):
	hp = 0 #specifically DON'T use the setter here
	affect_mel_on_death = affect_mel
	death_effect.emitting = true
	death_sfx.play()
	cooldown.start()

func _on_cooldown_timeout():
	if hp > 0:
		engage()
	else:
		_on_death()

func _on_death():
	if affect_mel_on_death:
		mel.moving = true
	visible = false
	queue_free()
