extends Node3D

var focused = true

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(_delta):
	if focused and Input.is_action_just_released("game_unfocus"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		focused = false
	if not focused and Input.is_action_just_pressed("game_focus"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		focused = true

func _on_area_3d_body_entered(body):
	print("entered")
	print(body.name)
	$player.position = Vector3(0,3,0)
