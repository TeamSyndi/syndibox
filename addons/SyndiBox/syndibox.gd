"""
#########################################################################
################### SyndiBox Text Engine for Godot ######################
########################### Version 1.5.0 ###############################
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
|		3. Credits					# I love these people				|
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
export(String, MULTILINE) var DIALOG # Dialog
export(String) var CHARACTER_NAME # Character name
export(String, FILE, "*.png, *.jpg") var CHARACTER_PROFILE # Character profile
export(bool) var AUTO_ADVANCE = false # Auto-advance setting
export(String, FILE, "*.fnt, *.tres") var FONT # Default font
export(Array, String, FILE, "*.fnt, *.tres") var ALTERNATE_FONTS # Alternate fonts, [%0] to [%9]
export(int) var PADDING = 3 # Pixel padding between lines of text
export(String, FILE, "*.ogg, *.wav, *.mp3") var TEXT_VOICE # Default voice
export(bool) var PLAY_VOICE_ONCE = false # Voice one-shot setting
export(Color, RGB) var COLOR = Color("#FFFFFF") # Default color
export(float) var TEXT_SPEED = 0.03 # Default speed
export(bool) var PAUSE_AT_PUNCTUATION = false # Default period pause type
export(float) var PUNCTUATION_PAUSE_LENGTH = 0.0 # Default length of period pauses
export(bool) var INSTANT_PRINT = false # Default instant print
export(String, FILE, "*.gd") var CUSTOM_EFFECTS # Custom effects script

# Internal
onready var strings : PoolStringArray # String array containing our dialog
onready var def_font : Font # Default font
onready var def_profile : StreamTexture # Default profile
onready var profile : Sprite # Profile as sprite node
onready var prof_label : Label # Profile label for character
onready var x_offset : int # Dialog X-axis offset
onready var alt_fonts : Array # Other fonts
onready var font : Font # Font applied to current character
onready var def_color : Color # Default color
onready var color : Color # Color applied to current character
onready var def_speed : float # Default speed
onready var speed : float # Speed applied to current character
onready var timer : Timer # To time wait between characters
onready var voice : AudioStreamPlayer # To change speaker voices (WIP)
onready var tween : Tween # To tween positional effects
onready var snd_stream : AudioStream # Variable for loading text voice
onready var cur_tween : Dictionary # Array of tweens in each step
onready var tween_start : Vector2 # Default tween start position
onready var tween_end : Vector2 # Default tween end position
onready var tween_time : float = 0.1 # Default tween time in seconds
onready var tween_trans : int = Tween.TRANS_LINEAR # Default tween transition
onready var tween_ease : int = Tween.EASE_IN_OUT # Default tween ease
onready var tween_back : bool = false # Default tween patrol state
onready var tween_set : bool = false # Whether or not a position has been set for the char
onready var cur_set : int = 0 # Integer determining current string in array
onready var cur_string : String # Current string
onready var cur_length : String # String to determine current length
onready var cur_speed : float # Current speed of dialog
onready var saved_length : float = 0 # Saved printed length
onready var str_line : int = 0 # Integer determining current line in textbox
onready var heightTrack : int = 0 # Track how far down the screen to display text
onready var maxLineHeight : int = 0 # If font changes midline, track the max height the line reached
onready var cur_char : Dictionary # Dictionary of characters in each step
onready var edit_print : Label # Label used while in editor
onready var step : int = 0 # Current step in print state
onready var step_pause : int = 0 # Current step in pause state
onready var emph : String # Substring to match for tag checking
onready var escape : bool = false # Escape for effect tags (DEPRECATED)
onready var def_print : bool # Whether default printing is instant or turncated
onready var def_period : bool # Whether default period is paused or unpaused
onready var text_pause : bool = false # Whether or not to pause the printing
onready var text_hide : bool = false # Whether or not to hide the printing
onready var hide_timer # fuck
onready var custom = Node.new() # Filler for custom effect script
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
func _enter_tree():
	strings = DIALOG.split("\n")


func _ready(): # Called when ready.
	set_physics_process(true)
	# Grab custom effects script.
	if !CUSTOM_EFFECTS:
		CUSTOM_EFFECTS = "res://addons/SyndiBox/custom.gd"
	custom.set_script(load(CUSTOM_EFFECTS))
	add_child(custom)
	# Create profile if available.
	profile = Sprite.new()
	profile.set_centered(false)
	profile.set_offset(Vector2(0,rect_size.y))
	profile.set("position",profile.position + Vector2(-(margin_left / 2) + 5,-rect_size.y + (margin_bottom / 2) + 5))
	add_child(profile)
	prof_label = Label.new()
	prof_label.set("rect_position",prof_label.rect_position + Vector2(16,-38))
	add_child(prof_label)
	# Set these variables to their appropriate exports.
	cur_string = strings[cur_set]
	snd_stream = load(TEXT_VOICE)
	if !FONT:
		FONT = load("res://addons/SyndiBox/Assets/TextDefault.tres")
	if FONT is String:
		def_font = load(FONT)
	else:
		def_font = FONT
	for f in ALTERNATE_FONTS:
		alt_fonts.push_back(load(f))
	font = def_font
	def_color = COLOR
	color = def_color
	def_speed = TEXT_SPEED
	speed = def_speed
	cur_speed = speed
	def_print = INSTANT_PRINT
	def_period = PAUSE_AT_PUNCTUATION
	# Make a timer and set wait period to character's dialog speed.
	timer = Timer.new()
	timer.set_wait_time(speed)
	add_child(timer)
	
	# Make an audio stream player and set stream to character's dialog voice.
	voice = AudioStreamPlayer.new()
	voice.set_stream(snd_stream)
	voice.volume_db = -6
	add_child(voice)
	
	tween = Tween.new()
	tween_trans = tween.TRANS_LINEAR
	tween_ease = tween.EASE_IN_OUT
	add_child(tween)
	
	if !Engine.editor_hint && visible:
		print_dialog(cur_string)
#	else:
#		edit_dialog()
#	print_dialog(cur_string)


## 2a. Tag Setting ##

"""
It just sets tags.
"""

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


## 2b. Tag Checking ##

"""
Ctrl+F for:
	- speaker_check(): Character Presets
	- color_check(): Color Effects
	- font_check(): Using Alt Fonts
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

(Yes, this is a lot of work just to see fun little squigglies on a
screen. I suffered, and if you don't like what I made for you, you'll
suffer, too.)
"""

# Character Presets #
func speaker_check(string):
	match emph:
		"[_:]": # Default
			if !escape:
				string.erase(step,4)
				string = string.insert(step,char(8203) + "[:2][^r]")
				saved_length += font.get_string_size(cur_length).x
				if FONT is String:
					def_font = load(FONT)
				else:
					def_font = FONT
				def_color = COLOR
				def_speed = TEXT_SPEED
				font = def_font
				color = def_color
				speed = def_speed
				INSTANT_PRINT = def_print
				cur_length = ""
		"[_!]": # Default Interject
			if !escape:
				for i in cur_char:
					var wr = weakref(cur_char[i])
					if !wr.get_ref():
						continue
					else:
						cur_char[i].free()
						if cur_tween.has(i):
							cur_tween[i].free()
				cur_char = {}
				cur_tween = {}
				cur_length = ""
				str_line = 0
				string.erase(step,4)
				string = string.insert(step,char(8203) + "[^r]")
				saved_length += font.get_string_size(cur_length).x
				if FONT is String:
					def_font = load(FONT)
				else:
					def_font = FONT
				def_color = COLOR
				def_speed = TEXT_SPEED
				font = def_font
				color = def_color
				speed = def_speed
				INSTANT_PRINT = def_print
				cur_length = ""
	return string

# Font Presets #
func font_check(string):
	match emph:
		"[%0]": # Alt Font 0
			if !escape:
				string.erase(step,4)
				string = string.insert(step,char(8203))
				saved_length += font.get_string_size(cur_length).x
				cur_length = ""
				font = alt_fonts[0]
		"[%1]": # Alt Font 1
			if !escape:
				string.erase(step,4)
				string = string.insert(step,char(8203))
				saved_length += font.get_string_size(cur_length).x
				cur_length = ""
				font = alt_fonts[1]
		"[%2]": # Alt Font 2
			if !escape:
				string.erase(step,4)
				string = string.insert(step,char(8203))
				saved_length += font.get_string_size(cur_length).x
				cur_length = ""
				font = alt_fonts[2]
		"[%3]": # Alt Font 3
			if !escape:
				string.erase(step,4)
				string = string.insert(step,char(8203))
				saved_length += font.get_string_size(cur_length).x
				cur_length = ""
				font = alt_fonts[3]
		"[%4]": # Alt Font 4
			if !escape:
				string.erase(step,4)
				string = string.insert(step,char(8203))
				saved_length += font.get_string_size(cur_length).x
				cur_length = ""
				font = alt_fonts[4]
		"[%5]": # Alt Font 5
			if !escape:
				string.erase(step,4)
				string = string.insert(step,char(8203))
				saved_length += font.get_string_size(cur_length).x
				cur_length = ""
				font = alt_fonts[5]
		"[%6]": # Alt Font 6
			if !escape:
				string.erase(step,4)
				string = string.insert(step,char(8203))
				saved_length += font.get_string_size(cur_length).x
				cur_length = ""
				font = alt_fonts[6]
		"[%7]": # Alt Font 7
			if !escape:
				string.erase(step,4)
				string = string.insert(step,char(8203))
				saved_length += font.get_string_size(cur_length).x
				cur_length = ""
				font = alt_fonts[7]
		"[%8]": # Alt Font 8
			if !escape:
				string.erase(step,4)
				string = string.insert(step,char(8203))
				saved_length += font.get_string_size(cur_length).x
				cur_length = ""
				font = alt_fonts[8]
		"[%9]": # Alt Font 9
			if !escape:
				string.erase(step,4)
				string = string.insert(step,char(8203))
				saved_length += font.get_string_size(cur_length).x
				cur_length = ""
				font = alt_fonts[9]
		"[%r]": # Reset
			if !escape:
				string.erase(step,4)
				string = string.insert(step,char(8203))
				saved_length += font.get_string_size(cur_length).x
				cur_length = ""
				font = def_font
	return string

# Color Effects #
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
				heightTrack = maxLineHeight + PADDING
				str_line = str_line + 1
	return string

# Speed Effects #
func speed_check(string):
	match emph:
		"[*1]": # Fastest
			if !escape && !INSTANT_PRINT:
				string.erase(step,4)
				string = string.insert(step,char(8203))
				speed = 0.01
		"[*2]": # Fast
			if !escape && !INSTANT_PRINT:
				string.erase(step,4)
				string = string.insert(step,char(8203))
				speed = 0.03
		"[*3]": # Normal
			if !escape && !INSTANT_PRINT:
				string.erase(step,4)
				string = string.insert(step,char(8203))
				speed = 0.05
		"[*4]": # Slow
			if !escape && !INSTANT_PRINT:
				string.erase(step,4)
				string = string.insert(step,char(8203))
				speed = 0.1
		"[*5]": # Slowest
			if !escape && !INSTANT_PRINT:
				string.erase(step,4)
				string = string.insert(step,char(8203))
				speed = 0.2
		"[*i]": # Instant
			if !escape:
				string.erase(step,4)
				string = string.insert(step,char(8203))
				INSTANT_PRINT = true
		"[*r]": # Reset
			if !escape:
				string.erase(step,4)
				string = string.insert(step,char(8203))
				INSTANT_PRINT = def_print
				speed = def_speed
	return string

# Positional Effects #
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
				tween_set = true
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
				tween_set = true
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
				tween_set = true
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
				tween_set = false
	return string

# Pause Effects #
func pause_check(string):
	match string.substr(step,2):
		"[s": # In seconds
			if !text_pause:
				var pause_time = int(string.substr(step + 2,1))
				string.erase(step,4)
				string = string.insert(step,char(8203))
				timer.set_wait_time(pause_time)
				string = string.insert(step,char(8203))
				text_pause = true
		"[t": # In ticks (10 per second)
			if !text_pause:
				var pause_time = int(string.substr(step + 2,1))
				string.erase(step,4)
				string = string.insert(step,char(8203))
				timer.set_wait_time(pause_time * 0.1)
				string = string.insert(step,char(8203))
				text_pause = true
	return string

# Hide Effects #
func hide_check(string):
	match string.substr(step,2):
		"[|": # In seconds
			if !text_hide:
				var hide_time = int(string.substr(step + 2,1))
				string.erase(step,4)
				string = string.insert(step,char(8203))
				hide_timer = get_tree().create_timer(hide_time)
				text_hide = true
		"[:": # In ticks (10 per second)
			if !text_hide:
				var hide_time = int(string.substr(step + 2,1))
				string.erase(step,4)
				string = string.insert(step,char(8203))
				hide_timer = get_tree().create_timer(hide_time * 0.1)
				text_hide = true
	return string

func emph_check(string): # Called before printing each step

	# Save a four-character substring.
	emph = string.substr(step,4)
	# Attempt a match for every four-character substring within
	# our current string.
	string = speaker_check(string)
	string = font_check(string)
	string = color_check(string)
	string = speed_check(string)
	string = pos_check(string)
	string = pause_check(string)
	string = hide_check(string)
	string = custom.check(string)
	# Return our checked string.
	return string
################################## END ##################################

#########################
## 2c. Dialog Printing ##
#########################

"""
I'd preface what you're about to see, but...it's just drawing some text
characters. If it was interesting, I'd be streaming it on Picarto and
flipping out over how it's 'oRiGiNaL cHaRaCtEr Do NoT sTeAl'

Comments are ahead to explain everything. Proceed with caution.
"""

################################# BEGIN #################################
func print_dialog(string): # Called on draw
	string = string.insert(string.length()," ")
	# If there are characters left to print...
	while step <= string.length() - 1 && visible:
		# Set up profile
		if !text_hide:
			if CHARACTER_PROFILE is String:
				def_profile = load(CHARACTER_PROFILE)
			else:
				def_profile = CHARACTER_PROFILE
			if CHARACTER_PROFILE != null:
				x_offset = 48
			else:
				x_offset = 0
			prof_label.add_font_override("font",def_font)
			prof_label.add_color_override("font_color",def_color)
			prof_label.set_text(CHARACTER_NAME)
			profile.set_texture(def_profile)
		else:
			prof_label.set_text("")
			profile.set_texture(null)
		# Check for punctuation and whether to pause on it.
		if PAUSE_AT_PUNCTUATION:
			if (
				string.substr(step - 1,2) == ". " ||
				string.substr(step - 1,2) == "! " ||
				string.substr(step - 1,2) == "?"
			):
				yield(get_tree().create_timer(PUNCTUATION_PAUSE_LENGTH),"timeout")
		# Start the timer.
		if !Engine.editor_hint:
			timer.start()
		# Check for pauses and special effect markers.
		if text_pause && !INSTANT_PRINT:
			yield(timer,"timeout")
			text_pause = false
		if text_hide && !INSTANT_PRINT:
			$TextPanel.hide()
			yield(hide_timer,"timeout")
			$TextPanel.show()
			text_hide = false
		string = emph_check(string)
		# Find the full length of the string and height of the string
		var strSize = font.get_string_size(cur_length)
		var full_length : int = saved_length + strSize.x
		maxLineHeight = max(maxLineHeight, heightTrack + strSize.y)
		# If the string won't fit, transpose it.
		if strSize.x + font.get_string_size(cur_string.substr(step,cur_string.find(" ",step) - step)).x > rect_size.x - x_offset:
			cur_length = ""
			saved_length = 0
			heightTrack = maxLineHeight + PADDING
			str_line += 1
			full_length = saved_length + font.get_string_size(cur_length).x
			cur_string.erase(cur_string.find(" ",step),1)
		if heightTrack > rect_size.y:
			for i in cur_char:
				cur_char[i].rect_position.y -= font.get_string_size(cur_length).y + PADDING
				if cur_char[i].rect_position.y < 0:
					cur_char[i].hide()
			heightTrack -= font.get_string_size(cur_length).y + PADDING
		# Create a new label for the character in the current step.
		cur_char[step] = Label.new()
		# Set the character position.
		cur_char[step].set_position(Vector2(full_length + x_offset, heightTrack))
		# Set any variables for special effect markers found.
		# (Put your tag setter function here)
		if font:
			set_font(font)
		if color:
			set_color(color)
		if speed && !text_pause:
			set_speed(speed)
		if tween_set:
			set_pos(tween_start,tween_end)
		if snd_stream:
			voice.set_stream(snd_stream)
		# Set the character text.
		cur_char[step].set_text(string[step])
		# Record the character length to the string length
		# and finally add it.
		cur_length = cur_length + string[step]
		add_child(cur_char[step])
		# If typewriting, play the sound for the character's
		# voice and wait for timer.
		if (
			string.substr(step,1) != " " &&
			string.substr(step,1) != char(8203) &&
			!INSTANT_PRINT
		):
			if snd_stream:
				voice.play()
			yield(timer,"timeout")
			if PLAY_VOICE_ONCE:
				snd_stream = null
		cur_string = string
		step += 1

func edit_dialog(): # This is probably indefinitely broken.
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

func _input(event): # Called on input
	# If accept button is pressed for manual advancement...
	if (
		!Engine.editor_hint && event.is_action_pressed("ui_accept") &&
		!AUTO_ADVANCE &&
		visible
	):
		# ...and there are more characters to print...
		if step < cur_string.length() - 1:
			# ...print all characters instantly.
			PAUSE_AT_PUNCTUATION = false
			INSTANT_PRINT = true
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
					# Remove all existent characters.
					if cur_char.has(i):
						cur_char[i].free()
						# Remove existent tweens for existent characters.
						if cur_tween.has(i):
							cur_tween[i].free()
				# Ready the dialog variables for the next string.
				cur_speed = speed
				PAUSE_AT_PUNCTUATION = def_period
				INSTANT_PRINT = def_print
				cur_char = {}
				cur_tween = {}
				cur_length = ""
				str_line = 0
				cur_set += 1
				step = 0
				heightTrack = 0
				maxLineHeight = 0
				escape = false
				# Set our current string to the next string in the set.
				cur_string = strings[cur_set]
				# Call our print_dialog function.
				if visible:
					print_dialog(cur_string)

func _physics_process(delta): # Called every step
	# If 3 seconds have passed for auto advancement...
	if (
		!Engine.editor_hint &&
		AUTO_ADVANCE &&
		step_pause >= 120 &&
		visible
	):
		# If there are no more strings in the dialog...
		if cur_set >= strings.size() - 1:
			# Hide the textbox.
			hide()
		# If there are strings in the dialog...
		else:
			# For every character that has been printed...
			for i in cur_char:
				# Remove all existent characters.
				if cur_char.has(i):
					cur_char[i].free()
					# Remove existent tweens for existent characters.
					if cur_tween.has(i):
						cur_tween[i].free()
			# Ready the dialog variables for the next string.
			cur_speed = speed
			cur_char = {}
			cur_tween = {}
			cur_length = ""
			str_line = 0
			cur_set += 1
			step = 0
			heightTrack = 0
			maxLineHeight = 0
			step_pause = 0
			escape = false
			# Set our current string to the next string in the set.
			cur_string = strings[cur_set]
			# Call our print_dialog function.
			if visible:
				print_dialog(cur_string)
	# If the last step in the string length is reached...
	elif !Engine.editor_hint && step >= cur_string.length() - 1:
		# Increment our steps in waiting for auto advancement.
		step_pause += 1


func _exit_tree():
	remove_child(custom)
	pass
################################## END ##################################

############################
## 3. License and Credits ##
############################

"""
You made it to the end and you're still concious after probably bashing
your head in multiple times! Very impressive.

I'd like to personally thank a few people that have helped in the
process of me tailoring this code, whether tremendous, insignificant,
or even unknown.
 -----------------------------------------------------------------------
|																		|
|	SPECIAL THANKS TO:													|
|		Friends and Family - for keeping me sane while in California	|
|		Taylor Dhalin - for giving me a refreshing move to New York		|
|		Simone Cogrossi - a precious little bunny-kun					|
|		xuvatilavv - from the Godot Discord, fixed the instant print	|
|		Ahmed Guem - Local code wizard saves game from being Thanos'ed	|
|		Samantha - Love you lots and lots, hun <33333					|
|		Lucy from BCB - for being my code debug plushie					|
|		Certain-Cola brand - i like your soda thanks					|
|		Cigarettes - I really shouldn't be thanking you.				|
|		The Big G - you know the one don't lie							|
|																		|
|		YOU - This is who it was made for, after all.					|
|																		|
 -----------------------------------------------------------------------

enjoy your fun wigglies
~ Sudo
		oOOo <- (it my pawb beans)
"""

############################ THANK YOU FOR ##############################
############################### PLAYING #################################
