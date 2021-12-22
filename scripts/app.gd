extends Node

onready var background = get_node("GUI/Background")
onready var color_picker = get_node("ColorPicker")
onready var panel = $GUI/MarginContainer/Panel

var mouse_pos
var prev_window_pos
var window_pos
var panel_at_left = true

func _ready():
	$AnimationPlayer.play("RESET")
	prev_window_pos = OS.window_position
	get_tree().get_root().set_transparent_background(true)
	get_tree().get_root().connect("size_changed", self, "on_window_size_changed")
	$FileDialog.add_filter("*.png ; PNG Images")


func _process(_delta):
	mouse_pos = get_viewport().get_mouse_position()
	
	if color_picker.using:
		if mouse_pos.x <= 300 and panel_at_left:
			$AnimationPlayer.play("move_panel_to_right")
			panel_at_left = false
		elif not panel_at_left and mouse_pos.x > get_viewport().get_visible_rect().size.x-300:
			$AnimationPlayer.play("move_panel_to_left")
			panel_at_left = true
	
	window_pos = OS.window_position
	
	# Clear the background if the windows is being moved
	if window_pos != prev_window_pos:
		clear()
		prev_window_pos = window_pos
	
	if Input.is_action_just_pressed("escape"):
		clear()
		color_picker.stop()


func take_screenshot():
	var output = []
	var image = "screenshot.png"
	var exit_code = OS.execute("import", ["-window", "root", "-monitor", image], true, output)
	
	var screenshot_image = Image.new()
	var cropped_screenshot_image = Image.new()
	screenshot_image.load("screenshot.png")
	cropped_screenshot_image.copy_from(screenshot_image)
	
	var window_size = OS.get_real_window_size()
	cropped_screenshot_image.blit_rect(screenshot_image, Rect2(window_pos, window_size), Vector2.ZERO)
	
	save_stex(cropped_screenshot_image, "screenshot_texture")

	var texture = load("screenshot_texture.stex")
	background.texture = texture
	color_picker.target_texture = texture
	color_picker.target_image = cropped_screenshot_image


# Taken from https://github.com/lifelike/godot-animator-import
static func save_stex(image, save_path):
	var tmppng = "%s-tmp.png" % [save_path]
	image.save_png(tmppng)
	var pngf = File.new()
	pngf.open(tmppng, File.READ)
	var pnglen = pngf.get_len()
	var pngdata = pngf.get_buffer(pnglen)
	pngf.close()
	Directory.new().remove(tmppng)
	
	var stexf = File.new()
	stexf.open("%s.stex" % [save_path], File.WRITE)
	stexf.store_8(0x47) # G
	stexf.store_8(0x44) # D
	stexf.store_8(0x53) # S
	stexf.store_8(0x54) # T
	stexf.store_32(image.get_width())
	stexf.store_32(image.get_height())
	stexf.store_32(0) # flags: Disable all of it as we're dealing with pixel-perfect images
	stexf.store_32(0x07100000) # data format
	stexf.store_32(1) # nr mipmaps
	stexf.store_32(pnglen + 6)
	stexf.store_8(0x50) # P
	stexf.store_8(0x4e) # N
	stexf.store_8(0x47) # G
	stexf.store_8(0x20) # space
	stexf.store_buffer(pngdata)
	stexf.close()


func on_window_size_changed():
	clear()


func on_focus_changed():
	clear()


func clear():
	background.texture = null
	color_picker.stop()


func _on_Panel_picker_selected():
	$GUI/MarginContainer/Panel.visible = false
	$screenshotTimer.start()


func _on_screenshotTimer_timeout():
	take_screenshot()
	$GUI/MarginContainer/Panel.visible = true
	color_picker.start()


func _on_ColorPicker_color_picked(color):
	panel.add_color(color)


func _on_Panel_export_button_pressed():
	if panel.get_color_items().size() > 0:
		$FileDialog.popup()


func _on_FileDialog_confirmed():
	var file_name = $FileDialog.current_file
	if file_name != "":
		var dir = $FileDialog.current_dir
		if not file_name.get_extension() == "png":
			file_name += ".png"
		save_pallete(dir + "/" + file_name)


func save_pallete(dir):
	var color_items = panel.get_color_items()
	var palleteImage = Image.new()
	palleteImage.create(color_items.size(), 1, false, Image.FORMAT_RGBA8)
	palleteImage.lock()
	for i in range(color_items.size()):
		palleteImage.set_pixel(i, 0, color_items[i].color)
	palleteImage.unlock()
	palleteImage.save_png(dir)


func _on_Panel_about_button_pressed():
	$GUI/AboutPanel.visible = true
func _on_CloseButton_pressed():
	$GUI/AboutPanel.visible = false
