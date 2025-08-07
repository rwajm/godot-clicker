extends Node

func format_number(number: float) -> String:
	if number < 1000000:
		return str(int(number))
	elif number < 1000000000:
		return "%.2fM" % (number / 1000000.0)
	else:
		return "%.2fB" % (number / 1000000000.0)
