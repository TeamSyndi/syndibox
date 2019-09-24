"""
#########################################################################
################### SyndiBox Text Engine for Godot ######################
########################### Version 1.0.0 ###############################
#########################################################################

'A text engine with everything you want and need will cost
 you two years time and 20 gallons of tears.' ~ Sudo

 -----------------------------------------------------------------------
|																		|
|	Quick Navigation (Ctrl+F and paste):								|
|		1. Variables				# Everything the code says			|
|		2. Functions				# Everything the code does			|
|		   b. Tag Checking				# Run first, typed second		|
|		   a. Tag Setting				# Run second, typed first		|
|		   c. Dialog Printing			# Loop to print each character	|
|		3. License and Credits		# Thank me and thank you			|
|																		|
 -----------------------------------------------------------------------

This is the script used for the SyndiBox text engine.
Scrapped from a previously created text engine I made
called the 'MaloBox' text engine, part of the 'MaloSuite'
GameMaker toolset, and adapted for use in Godot Engine.
No current plans for release, but I do hope to release it
at some point. Maybe after Polterheist! is released itself.

This text engine allows for custom features, such as:
	+ Loading custom dialog from a separate GDScript
	+ Setting character presets which can be accessed
	  with a special two-character marker (narrator for
	  Polterheist! is '&:', Casper is 'C:', etc.)
	+ Dynamic color and font mid-sentences
	+ Dynamic speed mid-sentences (in progress)
	+ Positional effects such as shaking and waving
	  (in progress)
	+ Custom textbox colors, borders, and backgrounds
	  (in progress)
	+ Dynamic switching of properties for characters
	  already set (to-do)

#########################################################################
#########################################################################
"""

##################
## 1. Variables ##
##################

################################# BEGIN #################################

# Best not to mess with these unless you know what you're doing.
tool
extends ReferenceRect

# Exported
export(String, MULTILINE) var DIALOG # Exported dialog
export(bool) var AUTO_ADVANCE = false# Exported auto-advance setting
export(String, FILE, "*.tres") var FONT # Exported font
export(String, FILE) var TEXT_VOICE # Exported voice
export(Color, RGB) var COLOR = Color("#FFFFFF") #Exported color
export(float) var TEXT_SPEED = 0.03 # Exported speed

# Internal
var strings : PoolStringArray # String array containing our dialog
var auto_adv : bool = false # Auto dialog advancement state (defaults to false)
var def_font : PackedScene # Default font
var font : PackedScene # Font applied to current character
var def_color : Color # Default color
var color : Color # Color applied to current character
var def_speed : float # Default speed
var speed : float # Speed applied to current character
var timer : Timer # To time wait between characters
var voice : AudioStreamPlayer # To change speaker voices (WIP)
var tween : Tween # To tween positional effects
var snd_stream : AudioStream # Variable for loading text voice
var cur_tween : Dictionary # Array of tweens in each step
var tween_start : Vector2 # Default tween start position
var tween_end : Vector2 # Default tween end position
var tween_time : float = 0.1 # Default tween time in seconds
var tween_trans # Default tween transition
var tween_ease # Default tween ease
var tween_back : bool = false # Default tween patrol state
var cur_set : int = 0 # Integer determining current string in array
var cur_string : String # Current string
var cur_length : String # String to determine current length
var cur_speed : float # Current speed of dialog
var saved_length : int = 0 # Saved printed length
var str_line : int = 0 # Integer determining current line in textbox
var cur_char : Dictionary # Dictionary of characters in each step
var edit_print : Label # Label used while in editor
var step : int = 0 # Current step in print state
var step_pause : int = 0 # Current step in pause state
var emph : String # Substring to match for tag checking
var escape : bool = false # Escape for effect tags (DEPRECATED)

################################## END ##################################

##################
## 2. Functions ##
##################

"""
2b. Tag Checking
2a. Tag Setting
2c. Dialog Printing
"""

################################# BEGIN #################################

func _ready(): # Called when ready.

	set_physics_process(true)

	# Set these variables to their appropriate exports.
	strings = DIALOG.split("\n")
	cur_string = strings[cur_set]
	snd_stream = load(TEXT_VOICE)
	auto_adv = AUTO_ADVANCE
	def_font = load(FONT)
	font = def_font
	def_color = COLOR
	color = def_color
	def_speed = TEXT_SPEED
	speed = def_speed
	cur_speed = speed

	# Make a timer and set wait period to character's dialog speed.
	timer = Timer.new()
	timer.process_mode = timer.TIMER_PROCESS_PHYSICS
	timer.set_wait_time(speed)
	add_child(timer)
	
	# Make an audio stream player and set stream to character's dialog voice.
	voice = AudioStreamPlayer.new()
	voice.set_physics_process(true)
	voice.set_stream(snd_stream)
	voice.volume_db = -18
	add_child(voice)
	
	tween = Tween.new()
	tween.set_physics_process(true)
	tween_trans = tween.TRANS_LINEAR
	tween_ease = tween.EASE_IN_OUT
	add_child(tween)


## a. Tag Setting ##

func set_font(font): # For setting a font override
	cur_char[step].add_font_override("font",font)

func set_color(color): # For setting a color override
	cur_char[step].add_color_override("font_color",color)

func set_speed(speed): # For setting a speed override
	timer.set_wait_time(speed)

func set_pos(start,end): # For setting a position override
	# This one was frustrating.

	# Create a new tween on the physics process and add it..
	cur_tween[step] = Tween.new()
	cur_tween[step].set_tween_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	add_child(cur_tween[step])

	# If the tween patrols back and forth...
	if tween_back:

		# Hold all variables for this step.
		var hold_tween = cur_tween[step]
		var hold_char = cur_char[step]
		var hold_pos = hold_char.get_position()
		var hold_time = tween_time
		var hold_trans = tween_trans
		var hold_ease = tween_ease

		# While the tweened character returns true (i.e., exists)...
		while hold_char:
			# Create the appropriate tween for the called effect.
			hold_tween.interpolate_property(
				hold_char,
				"rect_position",
				hold_pos + start,
				hold_pos + end,
				hold_time,
				hold_trans,
				hold_ease
			)
			# Start the tween.
			hold_tween.start()
			# Wait for tween to complete...
			yield(hold_tween,"tween_completed")
			# ...then create the same tween with start and end reversed.
			hold_tween.interpolate_property(
				hold_char,
				"rect_position",
				hold_pos + end,
				hold_pos + start,
				hold_time,
				hold_trans,
				hold_ease
			)
			hold_tween.start()
			# Finally, wait for tween to complete before looping.
			yield(hold_tween,"tween_completed")

	# If tween does not patrol back and forth...
	elif !tween_back:

		# Get the position of the current character's step.
		var char_pos = cur_char[step].get_position()

		# Create the appropriate tween for the called effect.
		cur_tween[step].interpolate_property(
			cur_char[step],
			"rect_position",
			char_pos + start,
			char_pos + end,
			tween_time,
			tween_trans,
			tween_ease
		)

		# Allow looping tween and start.
		cur_tween[step].set_repeat(true)
		cur_tween[step].start()

################################## END ##################################

######################
## 2b. Tag Checking ##
######################

"""
Ctrl+F for:
	- speaker_check(): Character Presets
	- color_check(): Color Effects
	- speed_check(): Speed Effects
	- pos_check(): Position Effects

Each match statement works like this:
 -------------------------------------------------------------------------------
|																				|
|	# This is a check for the character speaking.								|
|	speaker_check(string):														|
|		# Match with our two-character substring check.							|
|		match emph:																|
|			# We're going to match for 'C:', for Casper.						|
|			'C:':																|
|				# Only execute if we don't have an escape pending				|
|				# (In this case, it would be '`:'.)								|
|				if !escape:														|
|					# Erase the tag from the string.							|
|					string.erase(step,4)										|
|					# Insert a special non-width space to replace it.			|
|					# THIS IS IMPORTANT. WITHOUT IT, NESTED TAGS DON'T WORK.	|
|					string = string.insert(step,char(8203))						|
|					# Assign our saved length according to the font we use.		|
|					saved_length = font.get_string_size(cur_length).x			|
|					# Assign our current length to an empty string.				|
|					cur_length = ''												|
|					# Assign our default font as the one for Casper.			|
|					def_font = load('res://Players/Casper/casper_font.tres')	|
|					# Assign our default color to Casper's cyan.				|
|					def_color = Color('#00FFFF')								|
|					# Assign our default speed for Casper's speech.				|
|					def_speed = 0.03											|
|					# Assign our currents to defaults.							|
|					font = def_font												|
|					color = def_color											|
|					speed = def_speed											|
|																				|
|	# Make sure we save all edits to the current string and return it as well.	|
|	cur_string = string															|
|	return string																|
|																				|
 -------------------------------------------------------------------------------

You can add as many cases to match as you'd like. Follow this pattern if
you'd like to make your own custom check as well. If you do make your own
custom check, you must add your check within the emph_check() function to
execute along with the defaults:
 -------------------------------------------
|											|
|	emph_check():							|
|		var emph = string.substr(step,4)	|
|											|
|		speaker_check()						|
|		color_check()						|
|		font_check()						|
|		pos_check()							|
|		custom_check()						|
|											|
 -------------------------------------------

Finally, make a function for setting your values to the correct character
properties in the list of set functions (can't help you there), and call
that function in the print_dialog() function.

(Yes, this is a lot of work just to see fun little squigglies on a screen. I
suffered, and if you don't like what I made for you, you'll suffer, too.)
"""

################################# BEGIN #################################

# Character Presets #
func speaker_check(string):
	match emph:
		"[_:]": # Default
			if !escape:
				string.erase(step,4)
				string = string.insert(step,char(8203))
				def_font = load(FONT)
				def_color = COLOR
				def_speed = TEXT_SPEED
				font = def_font
				color = def_color
				speed = def_speed
				saved_length = font.get_string_size(cur_length).x
				cur_length = ""
	cur_string = string
	return string

# Color Effects
func color_check(string):
	match emph:
		"[`0]": # Black
			if !escape:
				string.erase(step,4)
				string = string.insert(step,char(8203))
				color = Color("#000000")
		"[`1]": # Dark Blue
			if !escape:
				string.erase(step,4)
				string = string.insert(step,char(8203))
				color = Color("#0000AA")
		"[`2]": # Dark Green
			if !escape:
				string.erase(step,4)
				string = string.insert(step,char(8203))
				color = Color("#00AA00")
		"[`3]": # Dark Aqua
			if !escape:
				string.erase(step,4)
				string = string.insert(step,char(8203))
				color = Color("#00AAAA")
		"[`4]": # Dark Red
			if !escape:
				string.erase(step,4)
				string = string.insert(step,char(8203))
				color = Color("#AA0000")
		"[`5]": # Dark Purple
			if !escape:
				string.erase(step,4)
				string = string.insert(step,char(8203))
				color = Color("#AA00AA")
		"[`6]": # Gold
			if !escape:
				string.erase(step,4)
				string = string.insert(step,char(8203))
				color = Color("#FFAA00")
		"[`7]": # Gray
			if !escape:
				string.erase(step,4)
				string = string.insert(step,char(8203))
				color = Color("#AAAAAA")
		"[`8]": # Dark Gray
			if !escape:
				string.erase(step,4)
				string = string.insert(step,char(8203))
				color = Color("#555555")
		"[`9]": # Blue
			if !escape:
				string.erase(step,4)
				string = string.insert(step,char(8203))
				color = Color("#5555FF")
		"[`a]": # Green
			if !escape:
				string.erase(step,4)
				string = string.insert(step,char(8203))
				color = Color("#55FF55")
		"[`b]": # Aqua
			if !escape:
				string.erase(step,4)
				string = string.insert(step,char(8203))
				color = Color("#55FFFF")
		"[`c]": # Red
			if !escape:
				string.erase(step,4)
				string = string.insert(step,char(8203))
				color = Color("#FF5555")
		"[`d]": # Light Purple
			if !escape:
				string.erase(step,4)
				string = string.insert(step,char(8203))
				color = Color("#FF55FF")
		"[`e]": # Yellow
			if !escape:
				string.erase(step,4)
				string = string.insert(step,char(8203))
				color = Color("#FFFF55")
		"[`f]": # White
			if !escape:
				string.erase(step,4)
				string = string.insert(step,char(8203))
				color = Color("#FFFFFF")
		"[`r]": # Reset
			if !escape:
				string.erase(step,4)
				string = string.insert(step,char(8203))
				color = def_color
		"[`#]": # New Line
			if !escape:
				string.erase(step,4)
				string = string.insert(step,char(8203))
				cur_length = ""
				saved_length = 0
				str_line = str_line + 1
	cur_string = string
	return string

# Speed Effects
func speed_check(string):
	match emph:
		"[*1]": # Fastest
			if !escape:
				string.erase(step,4)
				string = string.insert(step,char(8203))
				speed = 0.01
		"[*2]": # Fast
			if !escape:
				string.erase(step,4)
				string = string.insert(step,char(8203))
				speed = 0.03
		"[*3]": # Normal
			if !escape:
				string.erase(step,4)
				string = string.insert(step,char(8203))
				speed = 0.05
		"[*4]": # Slow
			if !escape:
				string.erase(step,4)
				string = string.insert(step,char(8203))
				speed = 0.1
		"[*5]": # Slowest
			if !escape:
				string.erase(step,4)
				string = string.insert(step,char(8203))
				speed = 0.2
		"[*r]": # Reset
			if !escape:
				string.erase(step,4)
				string = string.insert(step,char(8203))
				speed = def_speed
	cur_string = string
	return string

# Positional Effects
func pos_check(string):
	match emph:
		"[^t]": # Tipsy
			if !escape:
				string.erase(step,4)
				string = string.insert(step,char(8203))
				tween_start = Vector2(0,0)
				tween_end = Vector2(0,-2)
				tween_time = 0.15
				tween_trans = Tween.TRANS_SINE
				tween_ease = Tween.EASE_IN_OUT
				tween_back = true
		"[^d]": # Drunk
			if !escape:
				string.erase(step,4)
				string = string.insert(step,char(8203))
				tween_start = Vector2(-1,0)
				tween_end = Vector2(1,0)
				tween_time = 0.3
				tween_trans = Tween.TRANS_SINE
				tween_ease = Tween.EASE_IN_OUT
				tween_back = true
		"[^v]": # Vibrate
			if !escape:
				string.erase(step,4)
				string = string.insert(step,char(8203))
				tween_start = Vector2(rand_range(-2,2),rand_range(-2,2))
				tween_end = Vector2(rand_range(-2,2),rand_range(-2,2))
				tween_time = 0.1
				tween_trans = Tween.TRANS_LINEAR
				tween_ease = Tween.EASE_IN_OUT
				tween_back = false
		"[^r]": # Reset
			if !escape:
				string.erase(step,4)
				string = string.insert(step,char(8203))
				tween_start = Vector2(0,0)
				tween_end = Vector2(0,0)
				tween_time = 0.1
				tween_trans = Tween.TRANS_LINEAR
				tween_ease = Tween.EASE_IN_OUT
				tween_back = false
	cur_string = string
	return string
func emph_check(string): # Called before printing each step

	# Save a two-character substring.
	emph = string.substr(step,4)
	# Attempt a match for every two-character substring within
	# our current string.
	string = speaker_check(string)
	string = color_check(string)
	string = speed_check(string)
	string = pos_check(string)
	# Return our checked string.
	return string

################################## END ##################################

#########################
## 2c. Dialog Printing ##
#########################

"""
I'd preface what you're about to see, but...it's just drawing some text
characters. If it was interesting, I'd be streaming it on Picarto and
flipping out over how it's an 'original character do not steal'

Comments are ahead to explain everything. Proceed with caution.
"""

################################# BEGIN #################################

func print_dialog(string): # Called on draw
	# If there are characters left to print...
	if step >= 0 && step <= string.length() - 1:
		# Start the timer.
		timer.start()
		# Check for special effect markers.
		string = emph_check(string)
		# Remove all the non-width space characters.
		# Find the full length of the string.
		var full_length : int = saved_length + font.get_string_size(cur_length).x
		# If the string won't fit, break it into lines.
		if full_length > rect_size.x:
			cur_length = ""
			saved_length = 0
			str_line = str_line + 1
			full_length = saved_length + font.get_string_size(cur_length).x
		# Create a new label for the character in the current step.
		cur_char[step] = Label.new()
		# Set the character position.
		cur_char[step].set_position(Vector2(full_length,16 * str_line))
		# Set any variables for special effect markers found.
		# (Put your tag setter function here)
		set_font(font)
		set_color(color)
		set_speed(speed)
		set_pos(tween_start,tween_end)
		# Set the character text.
		cur_char[step].set_text(string[step])
		# Record the character length to the string length and finally add it.
		cur_length = cur_length + string[step]
		add_child(cur_char[step])
		# We gotta set the speed after the character apparently I dunno why
		if (
			string.substr(step + 1,1) == " " ||
			string.substr(step + 1,1) == char(8203)
		):
			set_speed(0.001)
		else:
			set_speed(speed)
		# Play the sound for the character's voice.
		if (
			string.substr(step,1) != " " &&
			string.substr(step,1) != char(8203)
		):
			voice.play()
		# Wait for timer to end and increment to the next step.
		yield(timer,"timeout")
		step += 1
	# If there are no characters left to print...
	else:
		# Keep step from incrementing (Prevents index range related crashing)
		step = string.length() - 1
	# Update the canvas.
	update()

func edit_dialog():
	for i in cur_string.length() - 1:
		step = i
		cur_string = emph_check(cur_string)
	var edit_str = Label.new()
	edit_str.set_name("EditorText")
	edit_str.set_position(Vector2(0,0))
#	for i in cur_string.length() - 1:
#		set_font(font)
#		set_color(color)
#		set_speed(speed)
#		set_pos(tween_start,tween_end)
	edit_str.set_text(cur_string)
	if !get_node("EditorText"):
		add_child(edit_str)
	update()

func _input(event): # Called on input
	# If accept button is pressed for manual advancement...
	if !Engine.editor_hint && event.is_action_pressed("ui_accept") and !auto_adv:
		# ...and there are more characters to print...
		if step < cur_string.length() - 1:
			# ...print all characters instantly.
			# (sowwy ish bwoken .n.)
			set_speed(0)
		# ...and there are no more characters to print...
		else:
			# ...then if there are no more strings in the dialog...
			if cur_set >= strings.size() - 1:
				# Hide the textbox.
				hide()
			# ...then if there are more strings in the dialog...
			else:
				# For every character that has been printed...
				for i in cur_char:
					# Get a weak reference.
					var wr = weakref(cur_char[i])
					# If there is no character in reference...
					if !wr.get_ref():
						# Carry on.
						pass
					# If there is a character in reference...
					else:
						# Free it from the buffer.
						cur_char[i].free()
				# Ready the dialog variables for the next string.
				cur_speed = speed
				cur_char = {}
				cur_length = ""
				str_line = 0
				cur_set = cur_set + 1
				step = 0
				escape = false
				# Set our current string to the next string in the set.
				cur_string = strings[cur_set]

func _physics_process(delta): # Called every step
	if Engine.editor_hint:
		strings = DIALOG.split("\n")
		cur_set = strings.size() - 1
		cur_string = strings[cur_set]
	# If 2 seconds have passed for auto advancement...
	if !Engine.editor_hint && auto_adv && step_pause >= 180:
		# If there are no more strings in the dialog...
		if cur_set >= strings.size() - 1:
			# Hide the textbox.
			hide()
		# If there are strings in the dialog...
		else:
			# For every character that has been printed...
			for i in cur_char:
				# Get a weak reference.
				var wr = weakref(cur_char[i])
				# If there is no character in reference...
				if !wr.get_ref():
					# Carry on.
					pass
				# If there is a character in reference...
				else:
					# Free it from the buffer.
					cur_char[i].free()
			# Ready the dialog variables for the next string.
			cur_speed = speed
			cur_char = {}
			cur_length = ""
			str_line = 0
			cur_set += 1
			step = 0
			step_pause = 0
			escape = false
			# Set our current string to the next string in the set.
			cur_string = strings[cur_set]
	# If the last step in the string length is reached...
	elif !Engine.editor_hint && step >= cur_string.length() - 1:
		# Increment our steps in waiting for auto advancement.
		step_pause += 1


func _draw(): # Called when drawing to the canvas
	if !Engine.editor_hint:
		print_dialog(cur_string)
#	else:
#		edit_dialog()

################################## END ##################################

############################
## 3. License and Credits ##
############################

"""
You made it to the end and you're still concious after probably bashing
your head in multiple times! Very impressive. Here's some legal stuff.
 -------------------------------------------------------
|														|
|	This text engine is under the Creative Commons		|
|	Attribution-ShareAlike 4.0 International			|
|	License.											|
|														|
|	With this license, you are free to:					|
|		SHARE - copy and redistribute the material in	|
|		any medium or format							|
|		ADAPT - remix, transform, and build upon the	|
|		material for any purpose, even commercially		|
|														|
|	Your use of this material is restricted to the		|
|	following terms:									|
|		ATTRIBUTION - You must give appropriate			|
|		credit, provide a link to the license, and		|
|		indicate if changes were made. You may do		|
|		so in any reasonable manner, but not in any		|
|		way that suggests the licensor endorses you		|
|		or your use.									|
|		SHAREALIKE - If you remix, transform, or		|
|		build upon this material, you must distribute	|
|		your contributions under the same license as	|
|		the orignial.									|
|		NO OTHER RESTRICTIONS - You may not apply		|
|		terms or technological measures that legally	|
|		restrict others from doing anything the			|
|		license permits.								|
|														|
|	A copy of the Creative Commons Attribution-			|
|	ShareAlike 4.0 International license and a link to	|
|	the full legal document is available at:			|
|														|
|	https://creativecommons.org/licenses/by-sa/4.0		|
|														|
 -------------------------------------------------------

Finally, I'd like to personally thank a few people that have had
help in the process of me tailoring this code, whether tremendous,
insignificant, or even unknown.
 -----------------------------------------------------------------------
|																		|
|	SPECIAL THANKS TO:													|
|		Friends and Fanily - for keeping me sane while in California	|
|		Taylor Dhalin - for giving me a refreshing move to New York		|
|		Simone Cogrossi - a precious little bunny-kun					|
|		Samantha - Love you lots and lots, hun <33333					|
|		Lucy from BCB - for being my code debug plushie					|
|		Certain-Cola brand - i like your soda thanks					|
|		Cigarettes - I really shouldn't be thanking you.				|
|		The Big G - you know the one don't lie							|
|																		|
|		And you.														|
|																		|
 -----------------------------------------------------------------------


enjoy your fun wigglies

~ Sudo

"""

############################ THANK YOU FOR ##############################
############################# DOWNLOADING ###############################

