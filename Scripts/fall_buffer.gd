extends Area3D

func is_player(body):
	var regex = RegEx.new()
	regex.compile("^player\\d*$")
	
	if regex.search(body.name):
		return true
	return false

func _on_body_entered(body):
	if is_player(body):
		body.position = Vector3(0,5,0)
