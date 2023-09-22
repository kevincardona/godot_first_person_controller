extends CharacterBody3D

signal open_game_menu

@export var player_index: int = 0
@export var player_name: String = "Steve"
@export var config: PlayerConfig = null
@export var inventory: Inventory = null

var gravity
var speed = 0
var sprinting = false
var toggled_sprint = false
var coyote_timer = 0.0
var can_jump = true
var picked_up_object = false
var inventory_opened = false
var freeze_movement = false
var ladders_entered = 0

@onready var head = $head
@onready var camera = $head/camera
@onready var camera_animation = $head/camera/camera_animation
@onready var reach = $head/camera/interaction
@onready var hand = $head/hand

enum State {
	NORMAL,
	LADDER
}

var current_state = State.NORMAL

func _ready():
	if config == null:
		push_error(self.name, " config is undefined...")
		return
	camera.current = true
	config.register_player_controls(player_index)
	gravity = config.gravity

func _physics_process(delta):
	if config == null:
		return
	handle_inventory(delta)
	if !freeze_movement:
		handle_sprinting(delta)
		handle_interaction(delta)
		handle_held_object(delta)
		handle_movement(delta)
		handle_gravity_and_jumping(delta)
		move_and_slide()

# Handlers
func handle_inventory(delta):
	if Input.is_action_just_released(config.open_inventory):
		if inventory == null:
			push_warning("Player tried to open the inventory but doesn't have one!")
			return
		if not inventory_opened:
			inventory.open()
			inventory_opened = true
			freeze_movement = true
		else:
			inventory.close()
			inventory_opened = false
			freeze_movement = false
			

func handle_interaction(delta):
	if reach.is_colliding():
		var obj = reach.get_collider()
		if Input.is_action_pressed(config.interact) && obj.has_method("pick_up") && not picked_up_object:
			obj.pick_up(hand)
			picked_up_object = obj

func handle_held_object(delta):
	if not picked_up_object:
		return
	if Input.is_action_pressed(config.drop):
		picked_up_object.drop(config.drop_object_speed)
		picked_up_object = null

func handle_sprinting(delta):
	var move_dir = Input.get_vector(config.move_left, config.move_right, config.move_forward, config.move_backward)
	if Input.is_action_pressed(config.move_sprint):
		sprinting = true
		speed = config.sprint_speed
		camera.fov = lerp(camera.fov, config.run_camera_fov, config.camera_fov_transition_speed * delta)
	elif move_dir.length() < 0.1:
		sprinting = false
		speed = config.base_speed
		camera.fov = lerp(camera.fov, config.walk_camera_fov, config.camera_fov_transition_speed * delta)

func handle_gravity_and_jumping(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
		coyote_timer += delta
		if coyote_timer > config.coyote_time_duration:
			can_jump = false
	else:
		coyote_timer = 0.0
		can_jump = true
	if Input.is_action_pressed(config.move_jump) and (is_on_floor() or can_jump):
		velocity.y += config.jump_velocity
		can_jump = false

func _input(event):
	if not freeze_movement && config && event is InputEventMouseMotion && player_index == 0:
		head.rotation_degrees.y -= event.relative.x * config.mouse_sensitivity
		head.rotation_degrees.x -= event.relative.y * config.mouse_sensitivity
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func handle_movement(delta):
	var move_dir = Input.get_vector(config.move_left, config.move_right, config.move_forward, config.move_backward)
	var direction = move_dir.normalized().rotated(-head.rotation.y)
	direction = Vector3(direction.x, 0, direction.y)
	var accel_rate = config.accel if not direction == Vector3(0, 0, 0) else config.decel
	if is_on_floor() || current_state == State.NORMAL:
		velocity.x = lerp(velocity.x, direction.x * speed, accel_rate * delta)
		velocity.z = lerp(velocity.z, direction.z * speed, accel_rate * delta)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed * config.air_dampening, config.accel * delta / 5)
		velocity.z = lerp(velocity.z, direction.z * speed * config.air_dampening, config.accel * delta / 5)

	if move_dir.length() > 0.01 and is_on_floor() and State.NORMAL:
		camera_animation.play("head_bob", 0.5)
	else:
		camera_animation.play("reset", 0.5)
	
	var look_dir = Input.get_vector(config.look_right, config.look_left, config.look_up, config.look_down)
	var target_rotation_x = head.rotation_degrees.x - look_dir.y * config.controller_sensitivity * delta
	var target_rotation_y = head.rotation_degrees.y + look_dir.x * config.controller_sensitivity * delta
	if look_dir.length() > 0.01:
		head.rotation_degrees.x = lerp(head.rotation_degrees.x, target_rotation_x, config.controller_look_smoothness)
		head.rotation_degrees.y = lerp(head.rotation_degrees.y, target_rotation_y, config.controller_look_smoothness)
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-90), deg_to_rad(90))

	if current_state == State.LADDER:
		gravity = 0
		if Input.is_action_pressed(config.move_forward):
			velocity.y = config.climb_speed
		else:
			velocity.y = -config.climb_speed
	else:
		gravity = config.gravity
