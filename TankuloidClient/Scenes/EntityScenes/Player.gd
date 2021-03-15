extends KinematicBody


var speed = 10.0
var player_state

var bullet_spawn = preload("res://Scenes/EntityScenes/Bullet.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (Input.is_action_just_pressed("submit")):
		print("attempting to submit")
		Server.FetchData("I am player")
	UpdateLookPosition()
	
	if (Input.is_action_just_pressed("fire_primary")):
		var new_bullet = bullet_spawn.instance()
		new_bullet.transform.origin = $TankTopPivot/Muzzle.global_transform.origin
		new_bullet.transform.basis = $TankTopPivot.transform.basis
		new_bullet.transform.basis.z *= -1
		new_bullet.name = "bullet" 
		get_node("/root/MainScene").add_child(new_bullet)
	
	

func UpdateLookPosition():
	var cursor_direction =  $Camera.project_ray_normal(get_viewport().get_mouse_position())
	cursor_direction = cursor_direction.normalized()
	var direction_scale = (global_transform.origin.y - $Camera.global_transform.origin.y) / cursor_direction.y
	var look_position = $Camera.global_transform.origin + (cursor_direction * direction_scale)
	$LookAtIndicator.global_transform.origin = look_position
#	print("Mouse ", get_viewport().get_mouse_position())
#	print("cursor_direction ", cursor_direction)
	
	var new_basis = Basis()
	new_basis.z = (look_position - global_transform.origin).normalized()
	new_basis.y = Vector3(0,1,0)
	new_basis.x = new_basis.z.cross(new_basis.y)
	$TankTopPivot.global_transform.basis = new_basis

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
	var look_rotation = atan2($TankTopPivot.global_transform.basis.z.x, $TankTopPivot.global_transform.basis.z.z)
#	print(look_rotation)
	player_state = {"T": OS.get_system_time_msecs(), "P": global_transform.origin, "R": look_rotation}
	Server.SendPlayerState(player_state)
	
	
