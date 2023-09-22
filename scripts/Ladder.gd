extends Area3D

func is_player(body):
	var regex = RegEx.new()
	regex.compile("^player\\d*$")
	
	if regex.search(body.name):
		return true
	return false

func _on_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if is_player(body):
		body.ladders_entered += 1
		if body.ladders_entered > 0:
			body.current_state = body.State.LADDER

func _on_body_shape_exited(body_rid, body, body_shape_index, local_shape_index):
	if is_player(body):
		body.ladders_entered -= 1
		if body.ladders_entered == 0:
			body.current_state = body.State.NORMAL
