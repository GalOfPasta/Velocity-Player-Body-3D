extends CharacterBody3D
class_name VelocityPlayerBody3D ## Character body that uses drag to limit player speed. Has camera anchor setup for physics interpolating camera position and frame based camera rotation. Also uses source engine sens.

@export var player_sensitivity: float = 0.00038397243459:
	set(value):
		var dots_per_360: float = 16363.6364
		var radians_per_dot: float = TAU / dots_per_360 # sensitivity multiplier for 1.0 CS 2 sensitivity
		player_sensitivity = value * radians_per_dot

@export_group("Camera")
@export var camera: Camera3D ## Camera3D for player view. Will be set to top level.
@export var camera_anchor: Marker3D ## Marker3D used for interpolating camera postion between physics frames. Should be at the desired camera position.

@export_group("Movement")
@export var move_force: float = 5000.0 ## Force to affect player velocity
@export var move_accel: float = 100.0 ## THIS DOES NOTHING RIGHT NOW
@export var mass: float = 90
@export var drag: float = 0.4
var mouse_input_buffer: Vector2


func apply_drag(delta: float) -> void:
	var v: float = velocity.length()
	var Fd: float = -drag * (v*v /2) 
	var dragVector: Vector3 = (velocity.normalized() * -1) * Fd
	velocity -= dragVector * delta


func apply_move_force(move_input_vec2: Vector2, delta: float) -> void:
	var tick_acceleration_delta = move_force / mass * delta ## the most 'force' can change velocity in this tick
	## NOTE. adding a 'waight' to the input should work unless the acceleration needs to be snappier then what the force apllied to the velocity can do 
	var move_input_sphere = Vector3(move_input_vec2.x, 0, move_input_vec2.y)
	var tick_accel_factor = velocity / tick_acceleration_delta ## How many ticks it would take to fully decelerate 
	var force_unitvector = (move_input_sphere * 2 - tick_accel_factor.limit_length(1)).limit_length(1) 
	## move input is *2 so it cant be mitigated by the velocity. 
	## If a velocity axis is less then or equal to the Max_Acceleration_Delta, and an input axis is 0, it will apply the percent of the MAD needed to stop
	## velocity.x / tick_acceleration_delta = 0.5 / 0.952 = 0.525. | force_unitvector.x = (input.x)0, - 0.525 = -0.525. force_unitvector.x = -0.525
	## force_vector.x = force_unitvector.x(-0.525) * tick_force(0.952) = -0.5.  velocity.x(0.5) + force_vector(-0.5) = 0
	var force_vector = (force_unitvector * move_force)
	velocity += force_vector / mass * delta


func update_camera() -> void:
	camera.position = camera_anchor.get_global_transform_interpolated().origin 
	camera.rotation = rotate_with_mouse_move_vector(mouse_input_buffer, camera.rotation)
	mouse_input_buffer = Vector2.ZERO


func add_to_mouse_buffer(move: Vector2) -> void:
	mouse_input_buffer += move

func rotate_with_mouse_move_vector(move_input: Vector2, inputRotation: Vector3) -> Vector3: # change this to use basis at some point
	var rot: Vector3 = inputRotation
	rot.x += (move_input.y * player_sensitivity)
	rot.y += (move_input.x * player_sensitivity)
	rot.x = clampf(rot.x, deg_to_rad(-90), deg_to_rad(90))
	return rot
