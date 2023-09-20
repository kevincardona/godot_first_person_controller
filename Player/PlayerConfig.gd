extends Resource
class_name PlayerConfig

@export var base_speed: float = 6
@export var sprint_speed: float = 10
@export var jump_velocity: float = 9
@export var mouse_sensitivity: float = 0.1
@export var controller_sensitivity: float = 1000
@export var controller_look_smoothness: float = 0.2
@export var accel: int = 10
@export var decel: int = 10
@export var air_dampening: float = 0.8
@export var default_gravity: bool = false
@export var custom_gravity: float = 25
@export var walk_camera_fov: float = 75.0
@export var run_camera_fov: float = 85.0
@export var camera_fov_transition_speed: int = 5
@export var drop_object_speed: int = 10
@export var coyote_time_duration: float = 0.15
@export var has_inventory: bool = true

# Set these actions in the InputMap
@export var interact: String = "player_interact"
@export var drop: String = "player_drop"
@export var move_left: String = "player_move_left"
@export var move_right: String = "player_move_right"
@export var move_forward: String = "player_move_forward"
@export var move_backward: String = "player_move_backward"
@export var move_jump: String = "player_move_jump"
@export var move_sprint: String = "player_move_sprint"
@export var move_crouch: String = "player_move_crouch"
@export var look_left: String = "player_look_left"
@export var look_right: String = "player_look_right"
@export var look_up: String = "player_look_up"
@export var look_down: String = "player_look_down"
@export var open_inventory: String = "player_open_inventory"

func get_player_actions():
	var filtered_actions = []
	var all_actions = InputMap.get_actions()
	for action in all_actions:
		if action.begins_with("player_"):
			filtered_actions.append(action)
	return filtered_actions
	
func register_player_controls(player_index):
	var player_actions = get_player_actions()
	for action in player_actions:
		var new_action = "p" + str(player_index) + "_" + action
		set(action.replace("player_", ""), new_action)
		if not InputMap.has_action(new_action):
			InputMap.add_action(new_action)
			var events = InputMap.action_get_events(action)
			for event in events:
				if event is InputEventKey or event is InputEventJoypadButton or event is InputEventJoypadMotion:
					var cloned_event = event.duplicate()
					cloned_event.device = player_index
					InputMap.action_add_event(new_action, cloned_event)
