extends Node

# This is just an example. You should probably save a
# copy of this file elsewhere, it will most likely get
# overwritten every update.

onready var sb = get_parent()

func check(string):
	match sb.emph:
		"[X:]": # Example
			if !sb.escape:
				string.erase(sb.step,4)
				string = string.insert(sb.step,char(8203) + "[:2][^r]")
				sb.saved_length = sb.font.get_string_size(sb.cur_length).x
				sb.CHARACTER_NAME = "X. Ample"
				sb.CHARACTER_PROFILE = null
				sb.def_font = load("res://addons/SyndiBox/Assets/TextDefault.tres")
				sb.def_color = Color("#C0C0C0")
				sb.def_speed = 0.05
				sb.font = sb.def_font
				sb.color = sb.def_color
				sb.speed = sb.def_speed
				sb.cur_length = ""
		"[X!]": # Example Interject
			if !sb.escape:
				for i in sb.cur_char:
					var wr = weakref(sb.cur_char[i])
					if !wr.get_ref():
						continue
					else:
						sb.cur_char[i].free()
						if sb.cur_tween.has(i):
							sb.cur_tween[i].free()
				sb.cur_char = {}
				sb.cur_tween = {}
				sb.cur_length = ""
				sb.str_line = 0
				string.erase(sb.step,4)
				string = string.insert(sb.step,char(8203) + "[^r]")
				sb.saved_length = sb.font.get_string_size(sb.cur_length).x
				sb.CHARACTER_NAME = "X. Ample"
				sb.CHARACTER_PROFILE = null
				sb.def_font = load("res://Assets/Fonts/TextBasis.tres")
				sb.def_color = Color("#C0C0C0")
				sb.def_speed = 0.05
				sb.font = sb.def_font
				sb.color = sb.def_color
				sb.speed = sb.def_speed
				sb.cur_length = ""
	return string
