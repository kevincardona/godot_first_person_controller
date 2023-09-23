extends Node

@export var speed: float = 100

@onready var spinner = $spinner

func _physics_process(delta):
	spinner.rotate(Vector3(0,1,0), 1 * speed * delta)
