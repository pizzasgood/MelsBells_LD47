extends TextureButton

onready var player : AudioStreamPlayer = get_node("AudioStreamPlayer")
onready var seq_recorder = get_node("/root/Main/SeqRecorder")
var rate : int
var duration = 0.5 #seconds
var amplitude = 0.5
var action = "unbound"
var note

func _unhandled_input(event):
	if event.is_action_pressed(action):
		_on_BellButton_pressed()
		get_tree().set_input_as_handled()

func _on_BellButton_pressed():
	play()
	seq_recorder.record_note(note)

func play():
	player.play()

func setup(index, action_name):
	note = index
	action = action_name
	_set_freq(Sequence.FREQS[note])

func _set_freq(freq):
	var tone = AudioStreamSample.new()
	tone.format = AudioStreamSample.FORMAT_16_BITS
	rate = tone.mix_rate
	var samples = duration * tone.mix_rate
	var max_amp
	match(tone.format):
		AudioStreamSample.FORMAT_8_BITS:
			max_amp = 128
		AudioStreamSample.FORMAT_16_BITS:
			max_amp = pow(2, 15)
		_:
			push_error("ToneGen does not support AudioStreamSample format %s" % tone.format)
			get_tree().quit()
	var data = []
	for n in range(0, samples):
		var parts = []
		parts.append(sin_gen(n, freq))
		parts.append(tri_gen(n, freq))
		var val := 0.0
		for p in parts:
			val += p
		val /= parts.size()
		val *= max_amp * amplitude * (samples - n) / samples
		match(tone.format):
			AudioStreamSample.FORMAT_8_BITS:
				data.append(int(val))
			AudioStreamSample.FORMAT_16_BITS:
				data.append(int(val) % 256)
				data.append(int(val / 256))
	tone.data = PoolByteArray(data)
	player.stream = tone

func sin_gen(n, freq, phase=0):
	return sin(n * freq * TAU / rate + phase)

func saw_gen(n, freq, phase=0):
	return 2 * fmod(n * freq / rate + phase / TAU + 0.5, 1.0) - 1

func tri_gen(n, freq, phase=0):
	return 2 * abs(saw_gen(n, freq, phase + TAU / 4)) - 1

func squ_gen(n, freq, phase=0):
	return 1 if sin_gen(n, freq, phase) >= 0 else -1

func print_csv():
	var file = File.new()
	file.open("user://graphs/graph.csv", File.WRITE)
	var line = ""
	var data = Array(player.stream.data)
	#convert from unsigned to signed
	for n in range(0, len(data)):
		if data[n] > 127: #TODO: not sure if 127 or 128
			data[n] -= 256 #TODO: not sure if 255 or 256
	match(player.stream.format):
		AudioStreamSample.FORMAT_8_BITS:
			for n in range(0, len(data)):
				var d = data[n]
				line += "%s,%s\n" % [ (1.0*n)/rate, d ]
		AudioStreamSample.FORMAT_16_BITS:
			for n in range(0, len(data), 2):
				var d = data[n+1] * 256 + data[n]
				line += "%s,%s\n" % [ (n/2.0)/rate, d ]
		_:
			push_error("ToneGen does not support AudioStreamSample format %s" % player.stream.format)
			get_tree().quit()
	file.store_string(line)
	file.close()
