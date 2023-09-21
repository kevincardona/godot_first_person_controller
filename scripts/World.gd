extends Node3D

var focused = true

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _on_area_3d_body_entered(body):
	print("entered")
	print(body.name)
	$player.position = Vector3(0,3,0)
