extends CharacterBody3D
class_name VelocityPlayerBody3D

#var sensitivity_mulitplier: float
@export var player_sensitivity: float = 0.00038397243459:
	set(value):
		var dots_per_360: float = 16363.6364
		var radians_per_dot: float = TAU / dots_per_360 # sensitivity multiplier for 1.0 CS 2 sensitivity
		player_sensitivity = value * radians_per_dot
		print(player_sensitivity)


@export_group("Camera")
@export var camera: Camera3D ## Camera3D for player view. Will be set to top level.
@export var camera_anchor: Marker3D ## Marker3D used for interpolating camera postion between physics frames. Should be at the desired camera position.

@export_group("Movement")
@export var move_force: float = 5000.0 ## Force to affect player velocity
@export var mass: float = 90
@export var move_accel: float = 100.0
@export var drag: float = 0.4
var bufferd_move_vector: Vector3
var mouse_input: Vector2
var move_input_vector: Vector2

var player_rotation: Vector3:
	get:
		return camera.rotation
	set (value):
		camera.rotation = value


func _ready() -> void:
	
	camera.top_level = true


func _physics_process(delta: float) -> void:
	## Drag
	var v: float = velocity.length()
	var Fd: float = -drag * (v*v /2) 
	var dragVector: Vector3 = (velocity.normalized() * -1) * Fd
	velocity -= dragVector * delta
	
	## Add player input 
	var tick_acceleration_delta = move_force / mass * delta ## the most 'force' can change velocity in this tick
	move_input_vector = Input.get_vector("move_left", "move_right", "move_forward", "move_back").rotated(-player_rotation.y)
	## NOTE. adding a 'waight' to the input should work unless the acceleration needs to be snappier then what the force apllied to the velocity can do 
	var move_input_sphere = Vector3(move_input_vector.x, 0, move_input_vector.y)
	var tick_accel_factor = velocity / tick_acceleration_delta ## How many ticks it would take to fully decelerate 
	var force_unitvector = (move_input_sphere * 2 - tick_accel_factor.limit_length(1)).limit_length(1) 
	## move input is *2 so it cant be mitigated by the velocity. 
	## If a velocity axis is less then or equal to the Max_Acceleration_Delta, and an input axis is 0, it will apply the percent of the MAD needed to stop
	## velocity.x / tick_acceleration_delta = 0.5 / 0.952 = 0.525. | force_unitvector.x = (input.x)0, - 0.525 = -0.525. force_unitvector.x = -0.525
	## force_vector.x = force_unitvector.x(-0.525) * tick_force(0.952) = -0.5.  velocity.x(0.5) + force_vector(-0.5) = 0
	var force_vector = (force_unitvector * move_force)
	velocity += force_vector / mass * delta
	
	
	## Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
	move_and_slide()


func _process(_delta: float) -> void:
	camera.position = camera_anchor.get_global_transform_interpolated().origin 
	camera.rotation = rotate_with_mouse_move_vector(mouse_input, camera.rotation)
	mouse_input = Vector2.ZERO


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_input = -event.screen_relative
		return
	if event.is_action_pressed("ui_cancel"):
		print("end")
		get_tree().quit()
	if event.is_action_pressed("mouse_right_click"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if event.is_action_pressed("mouse_left_click"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED



func rotate_with_mouse_move_vector(move_input: Vector2, inputRotation: Vector3) -> Vector3: # change this to use basis at some point
	var rot: Vector3 = inputRotation
	rot.x += (move_input.y * player_sensitivity)
	rot.y += (move_input.x * player_sensitivity)
	rot.x = clampf(rot.x, deg_to_rad(-90), deg_to_rad(90))
	return rot
