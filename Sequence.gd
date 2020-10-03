class_name Sequence

const FREQS = [ 493.88, 659.26, 880.00 ] # B E A -- https://en.wikipedia.org/wiki/Pitch_(music)#Labeling_pitches
const NOTE_RANGE = len(FREQS)

var notes = [] # just a simple sequence, no polyphony

# swap high and low notes
func invert():
	for i in range(len(notes)):
		if notes[i] >= 0:
			notes[i] = NOTE_RANGE - 1 - notes[i]

# reverse the order of the notes
func reverse():
	notes.invert()

# generate a fresh sequence from scratch, rhythm and all
func generate_notes(length, num_notes=null):
	generate_rhythm(length, num_notes)
	populate_notes()

# generate a rhythm; it'll be played using the first note in the scale
func generate_rhythm(length, num_notes=null):
	if num_notes == null:
		num_notes = length
	notes = []
	for i in range(length):
		if i < num_notes:
			notes.append(0)
		else:
			notes.append(-1)
	notes.shuffle()
	ltrim()
	rpad(length)

# populate all the non-blank notes, e.g. after generating a rhythm
# this can be used on its own to repopulate a sequence without changing the rhythm
func populate_notes():
	for i in range(len(notes)):
		if notes[i] >= 0:
			notes[i] = randi() % NOTE_RANGE

# remove any blank slots from the front
func ltrim():
	while len(notes) > 0 and notes.front() < 0:
		notes.pop_front()

# remove any blank slots from the back
func rtrim():
	while len(notes) > 0 and notes.back() < 0:
		notes.pop_back()

# remove any blank slots from the front and back
func trim():
	ltrim()
	rtrim()

# add silence to the end until the sequence is the appropriate length
func rpad(length):
	while len(notes) < length:
		notes.push_back(-1)

# add silence to the front until the sequence is the appropriate length
func lpad(length):
	while len(notes) < length:
		notes.push_front(-1)

func print():
	print(notes)
