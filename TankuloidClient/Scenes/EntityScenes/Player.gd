extends KinematicBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var speed = 10.0
var player_state

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (Input.is_action_just_pressed("submit")):
		print("attempting to submit")
		Server.FetchData("I am player")
		

func _physics_process(delta):
	ProcessMovement(delta)
	UpdatePlayerState()
	
func ProcessMovement(delta):
	var movement_dir = Vector3()
	
	if (Input.is_action_pressed("move_forward")):
		movement_dir += -transform.basis.z
	if (Input.is_action_pressed("move_backward")):
		movement_dir += transform.basis.z
	if (Input.is_action_pressed("move_right")):
		movement_dir += transform.basis.x
	if (Input.is_action_pressed("move_left")):
		movement_dir += -transform.basis.x
	movement_dir = movement_dir.normalized()
	
	move_and_collide(movement_dir * speed * delta)

func UpdatePlayerState():
	player_state = {"T": OS.get_system_time_msecs(), "P": global_transform.origin}
	Server.SendPlayerState(player_state)
	
	
