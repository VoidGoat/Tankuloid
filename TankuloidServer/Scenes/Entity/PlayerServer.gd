extends KinematicBody



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func Die():
	visible = false
	$CollisionShape.disabled = true
	
func Respawn():
#	alive = true
	visible = true
	
	
	$CollisionShape.disabled = false
