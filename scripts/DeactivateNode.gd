extends RigidBody3D


func set_active(active: bool):
	if active:
		process_mode = Node.PROCESS_MODE_INHERIT
		show()
	else:
		process_mode = Node.PROCESS_MODE_DISABLED
		hide()


func _ready():
	coro()
	print('hello')

	set_active(false)
	await get_tree().create_timer(2.0).timeout
	set_active(true)


func coro():
	while true:
		await get_tree().create_timer(2.0).timeout
		print("wow!")
