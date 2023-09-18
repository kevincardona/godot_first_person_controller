extends RigidBody3D

var dropped = false

func _ready():
	pass

func _process(delta):
	print(name, " rotation: ", rotation)
	print(name, " transform: ", transform)
	if dropped == true:
		apply_impulse(transform.basis.z, -transform.basis.z * 10)
		dropped = false
	pass

