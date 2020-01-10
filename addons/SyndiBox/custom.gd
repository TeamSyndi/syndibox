extends Node

# This is just an example. You should probably save a
# copy of this file elsewhere, it will most likely get
# overwritten every update.

onready var sb = get_parent()

func check(string):
	match sb.emph:
		"[&:]": # Narrator
			if !sb.escape:
				string.erase(sb.step,4)
				string = string.insert(sb.step,char(8203))
				sb.def_font = load("res://Fonts/TextBasis.tres")
				sb.def_color = Color("#C0C0C0")
				sb.def_speed = 0.05
				sb.font = sb.def_font
				sb.color = sb.def_color
				sb.speed = sb.def_speed
				sb.saved_length = sb.font.get_string_size(sb.cur_length).x
				sb.cur_length = ""
		"[C:]": # Casper
			if !sb.escape:
				string.erase(sb.step,4)
				string = string.insert(sb.step,char(8203))
				sb.def_font = load("res://Players/Casper/casper_font.tres")
				sb.def_color = Color("#00FFFF")
				sb.def_speed = 0.05
				sb.font = sb.def_font
				sb.color = sb.def_color
				sb.speed = sb.def_speed
				sb.saved_length = sb.font.get_string_size(sb.cur_length).x
				sb.cur_length = ""
		"[M:]": # Myrtle
			if !sb.escape:
				string.erase(sb.step,4)
				string = string.insert(sb.step,char(8203))
				sb.def_font = load("res://Players/Myrtle/myrtle_font.tres")
				sb.def_color = Color("#FF00FF")
				sb.def_speed = 0.05
				sb.font = sb.def_font
				sb.color = sb.def_color
				sb.speed = sb.def_speed
				sb.saved_length = sb.font.get_string_size(sb.cur_length).x
				sb.cur_length = ""
		"[m:]": # Mara
			if !sb.escape:
				string.erase(sb.step,4)
				string = string.insert(sb.step,char(8203))
				sb.def_font = load("res://Players/Mara/mara_font.tres")
				sb.def_color = Color("#F0F0F0")
				sb.def_speed = 0.075
				sb.font = sb.def_font
				sb.color = sb.def_color
				sb.speed = sb.def_speed
				sb.saved_length = sb.font.get_string_size(sb.cur_length).x
				sb.cur_length = ""
		"[Z:]": # Zero
			if !sb.escape:
				string.erase(sb.step,4)
				string = string.insert(sb.step,char(8203))
				sb.def_font = load("res://Players/Zero/zero_font.tres")
				sb.def_color = Color("#00FF00")
				sb.def_speed = 0.05
				sb.font = sb.def_font
				sb.color = sb.def_color
				sb.speed = sb.def_speed
				sb.saved_length = sb.font.get_string_size(sb.cur_length).x
				sb.cur_length = ""
		"[L:]": # Lucifer (why not)
			if !sb.escape:
				string.erase(sb.step,4)
				string = string.insert(sb.step,char(8203))
				sb.def_font = load("res://Fonts/hell_font.tres")
				sb.def_color = Color("#AA0000")
				sb.def_speed = 0.05
				sb.font = sb.def_font
				sb.color = sb.def_color
				sb.speed = sb.def_speed
				sb.saved_length = sb.font.get_string_size(sb.cur_length).x
				sb.cur_length = ""
		"[S:]": # Sudo (JP)
			if !sb.escape:
				string.erase(sb.step,4)
				string = string.insert(sb.step,char(8203))
				sb.def_font = load("res://Fonts/sudo_font.tres")
				sb.def_color = Color("#FFFFFF")
				sb.def_speed = 0.05
				sb.font = sb.def_font
				sb.color = sb.def_color
				sb.speed = sb.def_speed
				sb.saved_length = sb.font.get_string_size(sb.cur_length).x
				sb.cur_length = ""
	return string
