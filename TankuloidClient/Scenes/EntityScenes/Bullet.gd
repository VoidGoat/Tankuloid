extends KinematicBody

var speed = 20


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	global_transform.origin += -speed * delta * global_transform.basis.z
