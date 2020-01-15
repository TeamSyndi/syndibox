extends Node

# This is just an example. You should probably save a
# copy of this file elsewhere, it will most likely get
# overwritten every update.

onready var sb = get_parent()

func check(string):
	match sb.emph:
		"[&:]": # Example
			if !sb.escape:
				string.erase(sb.step,4)
				string = string.insert(sb.step,char(8203))
				sb.saved_length = sb.font.get_string_size(sb.cur_length).x
				sb.def_font = load("res://addons/SyndiBox/Assets/TextDefault.tres")
				sb.def_color = Color("#C0C0C0")
				sb.def_speed = 0.05
				sb.font = sb.def_font
				sb.color = sb.def_color
				sb.speed = sb.def_speed
				sb.cur_length = ""
	return string
