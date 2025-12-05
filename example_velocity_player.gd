extends VelocityPlayerBody3D



var player_rotation: Vector3:
	get:
		return camera.rotation
	set (value):
		camera.rotation = value


func _physics_process(delta: float) -> void:
	var move_input_vector = Input.get_vector("move_left", "move_right", "move_forward", "move_back").rotated(-player_rotation.y)
	apply_drag(delta)
	apply_move_force(move_input_vector ,delta)
	## Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
	move_and_slide()


func _process(_delta: float) -> void:
	update_camera()


func _unhandled_input(event: InputEvent) -> void: ## Adds mouse move to input buffer
	if event is InputEventMouseMotion:
		add_to_mouse_buffer(-event.screen_relative)
		return
	if event.is_action_pressed("ui_cancel"):
		print("end")
		get_tree().quit()
	if event.is_action_pressed("mouse_right_click"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if event.is_action_pressed("mouse_left_click"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
