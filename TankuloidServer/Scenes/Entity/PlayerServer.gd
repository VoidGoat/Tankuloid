extends KinematicBody


var invincible = false
var invincible_time = 2

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
	invincible = true
	
	yield(get_tree().create_timer(invincible_time), "timeout")
	invincible = false
	

