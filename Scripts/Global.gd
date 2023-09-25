## NOTE: THIS SHOULD BE ADDED AS A SINGLETON. ADD TO AUTOLOAD TAB IN PROJECT SETTINGS
extends Node

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _open_game_menu():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _close_game_menu():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
