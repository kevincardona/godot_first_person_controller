extends CharacterBody3D

@export var base_speed = 10
@export var sprint_speed = 10
@export var jump_velocity = 6
@export var sensitivity = 0.1
@export var accel = 10
@export var decel = 10
@export var air_dampening = 0.8
@export var default_gravity: bool = false
@export var custom_gravity: float = 15
@export var walk_camera_fov = 75.0
@export var run_camera_fov = 85.0
@export var camera_fov_transition_speed = 5
@export var drop_object_speed = 10

var speed = base_speed
var sprinting = false
var camera_fov_extents = [walk_camera_fov, run_camera_fov]
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var coyote_time_duration = 0.15
var coyote_timer = 0.0
var can_jump = true
var picked_up_object = null

@onready var head = $head
@onready var camera = $head/camera
@onready var camera_animation = $head/camera/camera_animation
@onready var reach = $head/camera/interaction
@onready var hand = $head/hand

func _ready():
	camera.current = true
	if not default_gravity:
		gravity = custom_gravity

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
		if Input.is_action_pressed("interact") && obj.has_method("pick_up") && not picked_up_object:
			obj.pick_up(hand)
			picked_up_object = obj

func handle_held_object(delta):
	if not picked_up_object:
		return
	if Input.is_action_pressed("drop"):
		picked_up_object.drop(drop_object_speed)
		picked_up_object = null

func handle_sprinting(delta):
	if Input.is_action_pressed("move_sprint"):
		sprinting = true
		speed = sprint_speed
		camera.fov = lerp(camera.fov, camera_fov_extents[1], camera_fov_transition_speed * delta)
	else:
		sprinting = false
		speed = base_speed
		camera.fov = lerp(camera.fov, camera_fov_extents[0], camera_fov_transition_speed * delta)

func handle_gravity_and_jumping(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
		coyote_timer += delta
		if coyote_timer > coyote_time_duration:
			can_jump = false
	else:
		coyote_timer = 0.0
		can_jump = true

	if Input.is_action_pressed("move_jump") and (is_on_floor() or can_jump):
		velocity.y += jump_velocity
		can_jump = false

func handle_movement(delta):
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = input_dir.normalized().rotated(-head.rotation.y)
	direction = Vector3(direction.x, 0, direction.y)
	var accel_rate = accel if not direction == Vector3(0, 0, 0) else decel
	if is_on_floor():
		velocity.x = lerp(velocity.x, direction.x * speed, accel_rate * delta)
		velocity.z = lerp(velocity.z, direction.z * speed, accel_rate * delta)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed * air_dampening, accel * delta / 5)
		velocity.z = lerp(velocity.z, direction.z * speed * air_dampening, accel * delta / 5)

	if input_dir.length() > 0.01 and is_on_floor():
		camera_animation.play("head_bob", 0.5)
	else:
		camera_animation.play("reset", 0.5)

	move_and_slide()

func _input(event):
	if event is InputEventMouseMotion:
		head.rotation_degrees.y -= event.relative.x * sensitivity
		head.rotation_degrees.x -= event.relative.y * sensitivity
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-90), deg_to_rad(90))

# Pause Handlers
func _on_pause():
	pass

func _on_unpause():
	pass
