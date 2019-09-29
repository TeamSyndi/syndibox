extends Node

var sb : SyndiBox

func check(string):
	match emph:
		"[E:]": # Example
			if !sb.escape:
				string.erase(sb.step,4)
				string = string.insert(sb.step,char(8203))
#				sb.var = assign
	return string