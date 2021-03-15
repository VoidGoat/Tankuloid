extends KinematicBody


var speed = 10.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (Input.is_action_just_pressed("submit")):
		print("attempting to submit")
		Server.FetchData("I am player")
		
func MovePlayer(position):
	global_transform.origin = position

func RotateTurret(look_direction):
	var new_basis = Basis()
	new_basis.z = look_direction
	new_basis.y = Vector3(0,1,0)
	new_basis.x = new_basis.z.cross(new_basis.y)
	$TankTopPivot.global_transform.basis = new_basis.orthonormalized()
