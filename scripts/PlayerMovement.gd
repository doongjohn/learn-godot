extends CharacterBody3D


@export_subgroup("Camera")
@export var camera_container: Node3D
var camera_orig_position: Vector3
var camera_tween_container: Node3D
var camera_tween: Tween

@export_subgroup("Gravity")
@export var gravity: float = 37
@export var max_fall_speed: float = 12
var is_landed: bool = false

@export_subgroup("Walk")
@export var min_walk_speed: float = 40
@export var max_walk_speed: float = 200
@export var walk_speed_accel: float = 300
@export var walk_speed_decel: float = 600
var input_dir: Vector3 = Vector3.ZERO
var prev_walk_dir: Vector3 = Vector3.ZERO
var walk_dir: Vector3 = Vector3.ZERO
var walk_speed: float

@export_subgroup("Jump")
@export var jump_force: float = 12


func _ready():
	camera_tween_container = camera_container.get_child(0)
	camera_orig_position = camera_tween_container.position


func _process(_delta: float):
	# reset walk input
	input_dir.z = 0
	input_dir.x = 0

	# get walk input
	if Input.is_key_pressed(KEY_W): input_dir.z -= 1
	elif Input.is_key_pressed(KEY_S): input_dir.z += 1
	if Input.is_key_pressed(KEY_D): input_dir.x += 1
	elif Input.is_key_pressed(KEY_A): input_dir.x -= 1
	input_dir = input_dir.normalized()

	# calculate walk vector
	var camera_global_basis = camera_container.get_global_transform().basis
	var walk_dir_foward = camera_global_basis.z * input_dir.z
	var walk_dir_right = camera_global_basis.x * input_dir.x
	walk_dir = (walk_dir_foward + walk_dir_right)
	if walk_dir != Vector3.ZERO:
		prev_walk_dir = walk_dir

	# get jump input
	if Input.is_key_pressed(KEY_SPACE):
		input_dir.y = 1


func apply_gravity(delta: float):
	if !is_landed:
		velocity.y = max(velocity.y - gravity * delta, -max_fall_speed)


func land():
	if is_on_floor():
		if !is_landed:
			is_landed = true
			on_landed()
	else:
		is_landed = false


func on_landed():
	# landing camera tween
	if camera_tween: camera_tween.kill()
	if velocity.y < -0.6:
		camera_tween = create_tween().set_trans(Tween.TRANS_SINE)
		var down_position = camera_tween_container.position + Vector3.UP * velocity.y * 0.5
		camera_tween.tween_property(camera_tween_container, 'position', down_position, 0.08).from(camera_orig_position)
		camera_tween.tween_property(camera_tween_container, 'position', camera_orig_position, 0.2)


func walk(delta: float):
	if walk_dir == Vector3.ZERO:
		walk_speed = max(0, walk_speed - walk_speed_decel * delta)
	else:
		walk_speed = max(min_walk_speed, walk_speed + walk_speed_accel * delta)
		walk_speed = min(max_walk_speed, walk_speed)

	var walk_velocity = prev_walk_dir * (walk_speed * delta)
	velocity.x = walk_velocity.x
	velocity.z = walk_velocity.z

	# walk camera tween
	if walk_speed > 80 and camera_tween and !camera_tween.is_running():
		camera_tween = create_tween().set_trans(Tween.TRANS_SINE)
		var down_position = camera_tween_container.position + Vector3.DOWN * 0.05
		camera_tween.tween_property(camera_tween_container, 'position', down_position, 0.15).from(camera_orig_position)
		camera_tween.tween_property(camera_tween_container, 'position', camera_orig_position, 0.2)


func jump():
	if is_landed and input_dir.y != 0:
		velocity.y = jump_force

	# reset input
	input_dir.y = 0


func _physics_process(delta: float):
	apply_gravity(delta)
	land()
	walk(delta)
	jump()

	move_and_slide()
