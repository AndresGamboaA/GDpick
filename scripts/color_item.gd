extends Control

var color = Color(1,1,1,1) setget set_color
var text

func set_color(value):
	color = value
	$MarginContainer/HBoxContainer/color.modulate = value
	text = str(value.to_html()).replace("ff", "#")
	$MarginContainer/HBoxContainer/Label.text = text


func set_format(format):
	match(format):
		0:
			text = color.to_html().replace("ff", "#")
		1:
			text = "Color(" + str(color) + ")"
		2:
			text = "rgba(" + str(color.r8) + ", " + str(color.g8) + ", " + str(color.b8) + ", 1)"
	$MarginContainer/HBoxContainer/Label.text = text
	$MarginContainer/HBoxContainer/Label.text = text


func _on_deleteButton_pressed():
	queue_free()


func _on_copyButton_pressed():
	OS.clipboard = text
