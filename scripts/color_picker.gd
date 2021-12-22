extends Node2D
signal color_picked(color)

var target_texture = null setget set_target_texture
var target_image

var using = false
var mouse_pos
onready var camera = get_node("Viewport/Camera2D")


func _process(_delta):
	if not using:
		return
	
	mouse_pos = get_viewport().get_mouse_position()
	camera.position = mouse_pos
	$View.position = mouse_pos
	
	if (target_image):
		target_image.lock()
		$View/CurrentColor.modulate = target_image.get_pixel(mouse_pos.x, mouse_pos.y)
		target_image.unlock()
		
	if Input.is_action_just_pressed("click"):
		emit_signal("color_picked", $View/CurrentColor.modulate)
		$View/AnimationPlayer.play("getColor")


func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			# zoom in
			if event.button_index == BUTTON_WHEEL_UP:
				if camera.zoom.x > 0:
					camera.zoom -= Vector2(0.05, 0.05)
			if event.button_index == BUTTON_WHEEL_DOWN:
				if camera.zoom.x < 1:
					camera.zoom += Vector2(0.05, 0.05)
				# call the zoom function

func start():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	using = true
	$View.visible = true


func stop():
	target_image = null
	target_texture = null
	$Viewport/targetTexture.texture = null
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	using = false
	$View.visible = false


func set_target_texture(value):
	target_texture = value
	$Viewport/targetTexture.texture = value
