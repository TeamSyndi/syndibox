extends Node

var sb = load("res://addons/SyndiBox/syndibox.gd")

func check(string):
	match emph:
		"[E:]": # Example
			if !sb.escape:
				string.erase(sb.step,4)
				string = string.insert(sb.step,char(8203))
#				other_stuff = other_things
	return string