extends Node3D


@export var sensitivity: float = 0.0022
@export var player: Node3D
@export var y_offset: float = 2
@onready var camera: Camera3D = $TweenContainer/Camera3d


func _process(_delta: float):
	# follow player
	var new_pos: Vector3 = player.position
	new_pos.y += y_offset
	position = new_pos


func _unhandled_input(event: InputEvent):
	# hide mouse cursor
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	# show mouse cursor
	if event is InputEventKey and event.keycode == KEY_ESCAPE:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	# mouse look
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			# horizontal rotation
			rotate_y(-event.relative.x * sensitivity)
			# vertical rotaion
			camera.rotate_x(-event.relative.y * sensitivity)
			# limit the vertical rotaion
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))
