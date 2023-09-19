extends CharacterBody3D

@export var player_index = 0
@export var p_config: Resource = load("res://scripts/player/PlayerConfig.gd").new()

var speed = p_config.base_speed
var sprinting = false
var camera_fov_extents = [p_config.walk_camera_fov, p_config.run_camera_fov]
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var toggled_sprint = false
var coyote_timer = 0.0
var can_jump = true
var picked_up_object = false

@onready var head = $head
@onready var camera = $head/camera
@onready var camera_animation = $head/camera/camera_animation
@onready var reach = $head/camera/interaction
@onready var hand = $head/hand

func _ready():
	camera.current = true
	if not p_config.default_gravity:
		gravity = p_config.custom_gravity
	p_config.register_player_controls(player_index)

func _process(delta):
	handle_sprinting(delta)
	handle_interaction(delta)

func _physics_process(delta):
	handle_gravity_and_jumping(delta)
	handle_movement(delta)
	handle_held_object(delta)

# Handlers
func handle_interaction(delta):
	if reach.is_colliding():
		var obj = reach.get_collider()
		if Input.is_action_pressed(p_config.interact) && obj.has_method("pick_up") && not picked_up_object:
			obj.pick_up(hand)
			picked_up_object = obj

func handle_held_object(delta):
	if not picked_up_object:
		return
	if Input.is_action_pressed(p_config.drop):
		picked_up_object.drop(p_config.drop_object_speed)
		picked_up_object = null

func handle_sprinting(delta):
	var move_dir = Input.get_vector(p_config.move_left, p_config.move_right, p_config.move_forward, p_config.move_backward)
	if Input.is_action_pressed(p_config.move_sprint):
		sprinting = true
		speed = p_config.sprint_speed
		camera.fov = lerp(camera.fov, camera_fov_extents[1], p_config.camera_fov_transition_speed * delta)
	elif move_dir.length() < 0.1:
		sprinting = false
		speed = p_config.base_speed
		camera.fov = lerp(camera.fov, camera_fov_extents[0], p_config.camera_fov_transition_speed * delta)

func handle_gravity_and_jumping(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
		coyote_timer += delta
		if coyote_timer > p_config.coyote_time_duration:
			can_jump = false
	else:
		coyote_timer = 0.0
		can_jump = true
	if Input.is_action_pressed(p_config.move_jump) and (is_on_floor() or can_jump):
		velocity.y += p_config.jump_velocity
		can_jump = false

func _input(event):
	if event is InputEventMouseMotion && player_index == 0:
		head.rotation_degrees.y -= event.relative.x * p_config.mouse_sensitivity
		head.rotation_degrees.x -= event.relative.y * p_config.mouse_sensitivity
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func handle_movement(delta):
	var move_dir = Input.get_vector(p_config.move_left, p_config.move_right, p_config.move_forward, p_config.move_backward)
	var direction = move_dir.normalized().rotated(-head.rotation.y)
	direction = Vector3(direction.x, 0, direction.y)
	var accel_rate = p_config.accel if not direction == Vector3(0, 0, 0) else p_config.decel
	if is_on_floor():
		velocity.x = lerp(velocity.x, direction.x * speed, accel_rate * delta)
		velocity.z = lerp(velocity.z, direction.z * speed, accel_rate * delta)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed * p_config.air_dampening, p_config.accel * delta / 5)
		velocity.z = lerp(velocity.z, direction.z * speed * p_config.air_dampening, p_config.accel * delta / 5)

	if move_dir.length() > 0.01 and is_on_floor():
		camera_animation.play("head_bob", 0.5)
	else:
		camera_animation.play("reset", 0.5)
	move_and_slide()
	
	var look_dir = Input.get_vector(p_config.look_right, p_config.look_left, p_config.look_up, p_config.look_down)
	var target_rotation_x = head.rotation_degrees.x - look_dir.y * p_config.controller_sensitivity * delta
	var target_rotation_y = head.rotation_degrees.y + look_dir.x * p_config.controller_sensitivity * delta
	if look_dir.length() > 0.01:
		head.rotation_degrees.x = lerp(head.rotation_degrees.x, target_rotation_x, p_config.controller_look_smoothness)
		head.rotation_degrees.y = lerp(head.rotation_degrees.y, target_rotation_y, p_config.controller_look_smoothness)
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-90), deg_to_rad(90))
