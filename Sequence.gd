class_name Sequence

const FREQS = [ 261.63, 293.66, 329.63, 392.00, 440.00 ] # C D E G A -- https://en.wikipedia.org/wiki/Pitch_(music)
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

# compare two arrays and return the number of differences, ignoring trailing -1s
func compare_notes(a, b):
	var errors = 0
	# first count the obvious errors
	for i in range(max(len(a), len(b))):
		if (len(a) <= i and b[i] >= 0) or (len(b) <= i and a[i] >= 0):
			errors += 1
		elif len(a) > i and len(b) > i:
			if a[i] != b[i]:
				errors += 1
	# now try removing individual items from a in case there's just an extra note
	for i in range(len(a)):
		var c = a
		if len(c) > 0:
			c.remove(i)
			print("---")
			print(a)
			print(c)
			print("---")
			var alt_errors = compare_notes(c, b) + 1
			errors = min(errors, alt_errors)
	# also try removing from b in case we simply missed a note
	for i in range(len(b)):
		var c = b
		if len(c) > 0:
			c.remove(i)
			var alt_errors = compare_notes(a, c) + 1
			errors = min(errors, alt_errors)
	return errors

# compare to another sequence and return the number of differences
func compare(other):
	print("Comparing:")
	print(notes)
	print(other.notes)
	print("....")
	return compare_notes(notes, other.notes)

# compare to another sequence and return the number of differences
func old_compare(other):
	var errors = 0
	for i in range(max(len(notes), len(other.notes))):
		if (len(notes) <= i and other.notes[i] >= 0) or (len(other.notes) <= i and notes[i] >= 0):
			errors += 1
		elif len(notes) > i and len(other.notes) > i:
			if notes[i] != other.notes[i]:
				errors += 1
	return errors

# generate a fresh sequence from scratch, rhythm and all
func generate_notes(length, num_notes):
	generate_rhythm(length, num_notes)
	populate_notes()

# generate a rhythm; it'll be played using the first note in the scale
func generate_rhythm(length, num_notes):
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
