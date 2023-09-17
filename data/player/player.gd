extends CharacterBody3D

# Exports
@export var base_speed = 10
@export var sprint_speed = 10
@export var jump_velocity = 6
@export var sensitivity = 0.1
@export var accel = 10
@export var air_dampening = 0.8
@export var default_gravity: bool = false
@export var custom_gravity: float = 15

# Variables
var speed = base_speed
var sprinting = false
var camera_fov_extents = [75.0, 85.0]
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# Coyote Time variables
var coyote_time_duration = 0.15
var coyote_timer = 0.0
var can_jump = true

# Onready Variables
@onready var components = {
	"head": $head,
	"camera": $head/camera,
	"camera_animation": $head/camera/camera_animation
}
@onready var world = get_parent()

# Initialization
func _ready():
	components.camera.current = true
	if not default_gravity:
		gravity = custom_gravity

# Main Loop
func _process(delta):
	handle_sprinting(delta)

func _physics_process(delta):
	handle_gravity_and_jumping(delta)
	handle_movement(delta)

# Handlers
func handle_sprinting(delta):
	if Input.is_action_pressed("move_sprint"):
		sprinting = true
		speed = sprint_speed
		components.camera.fov = lerp(components.camera.fov, camera_fov_extents[1], 10 * delta)
	else:
		sprinting = false
		speed = base_speed
		components.camera.fov = lerp(components.camera.fov, camera_fov_extents[0], 10 * delta)

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
	var direction = input_dir.normalized().rotated(-components.head.rotation.y)
	direction = Vector3(direction.x, 0, direction.y)
	if is_on_floor():
		velocity.x = lerp(velocity.x, direction.x * speed, accel * delta)
		velocity.z = lerp(velocity.z, direction.z * speed, accel * delta)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed * air_dampening, accel * delta / 5)
		velocity.z = lerp(velocity.z, direction.z * speed * air_dampening, accel * delta / 5)

	if input_dir.length() > 0.01 and is_on_floor():
		components.camera_animation.play("head_bob", 0.5)
	else:
		components.camera_animation.play("reset", 0.5)

	move_and_slide()

func _input(event):
	if event is InputEventMouseMotion:
		components.head.rotation_degrees.y -= event.relative.x * sensitivity
		components.head.rotation_degrees.x -= event.relative.y * sensitivity
		components.head.rotation.x = clamp(components.head.rotation.x, deg_to_rad(-90), deg_to_rad(90))

# Pause Handlers
func _on_pause():
	pass

func _on_unpause():
	pass
