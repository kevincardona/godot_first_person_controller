extends RigidBody3D

@onready var original_parent = get_parent()
@export var can_drop: bool = true
var original_freeze = null
var picked_up_by = null

func _ready():
	pass

func pick_up(by):
	original_freeze = self.freeze
	freeze = true
	original_parent.remove_child(self)
	by.add_child(self)
	picked_up_by = by
	transform = Transform3D()
	
func drop(impulse = 10):
	if picked_up_by == null || can_drop == false:
		return
	picked_up_by.remove_child(self)
	original_parent.add_child(self)
	global_transform = picked_up_by.global_transform
	picked_up_by = null
	freeze = original_freeze
	apply_impulse(global_transform.basis.z * impulse * -1)

func _process(delta):
	pass

