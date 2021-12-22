extends PanelContainer
signal picker_selected
signal export_button_pressed
signal about_button_pressed

var color_item_scene = preload("res://scenes/color_item.tscn")
var format = 0


func _ready():
	var option_button = $VBoxContainer/MarginContainer2/HBoxContainer/OptionButton
	option_button.add_item("HEX")
	option_button.add_item("GDscript")
	option_button.add_item("CSS")


func add_color(color):
	var color_item = color_item_scene.instance()
	color_item.color = color
	color_item.set_format(format)
	$VBoxContainer/MarginContainer3/ScrollContainer/colorList.add_child(color_item)
	var scrollbar = $VBoxContainer/MarginContainer3/ScrollContainer.get_v_scrollbar()
	$VBoxContainer/MarginContainer3/ScrollContainer.scroll_vertical = scrollbar.max_value

func _on_Button_pressed():
	emit_signal("picker_selected")
	_on_Button_mouse_exited()


func _on_OptionButton_item_selected(index):
	format = index
	var color_items = $VBoxContainer/MarginContainer3/ScrollContainer/colorList.get_children()
	for color_item in color_items:
		color_item.set_format(index)


func _on_Button_mouse_entered():
	$VBoxContainer/PanelContainer/HBoxContainer/Button.modulate = Color(0.23, 0.23, 0.23, 1)


func _on_Button_mouse_exited():
	$VBoxContainer/PanelContainer/HBoxContainer/Button.modulate = Color(1, 1, 1, 1)


func _on_expoortButton_pressed():
	emit_signal("export_button_pressed")


func get_color_items():
	return $VBoxContainer/MarginContainer3/ScrollContainer/colorList.get_children()


func _on_aboutButton_pressed():
	emit_signal("about_button_pressed")
