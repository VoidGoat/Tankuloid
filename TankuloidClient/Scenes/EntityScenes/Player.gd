extends KinematicBody


var speed = 10.0
var respawn_time = 3
var player_state


var ammo = 5
var max_ammo = 5

var bullet_spawn = preload("res://Scenes/EntityScenes/Bullet.tscn")

var alive = true

var respawn_ui : Node

var reload_timer = Timer.new()

func _ready():
	reload_timer.wait_time = 1
	reload_timer.connect("timeout", self, "Reload")
	reload_timer.one_shot = true
	self.add_child(reload_timer)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	UpdateLookPosition()
	
	if (Input.is_action_just_pressed("fire_primary") and ammo > 0 and alive):

		var direction = -$TankTopPivot.transform.basis.z
		var position = $TankTopPivot/Muzzle.global_transform.origin
		# send bullet to server
		Server.SpawnBullet(position, direction)
		ammo -= 1
		
		reload_timer.start(0)
		


	
# called by timer
func Reload():
	ammo = max_ammo
	print("reloaded")

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
	
	if alive:
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


var explosion_spawn = preload("res://Scenes/ParticleScenes/PlayerDeath.tscn")
var respawn_ui_spawn = preload("res://Scenes/UI/RespawnUI.tscn")
# Called when player has been killed
func Die():
	if not alive:
		return
	
	alive = false
	visible = false
	
	$PlayerCollisionShape.disabled = true
	
	var explosion = explosion_spawn.instance()
	explosion.transform.origin = global_transform.origin
	get_node("/root/MainScene").add_child(explosion)
	
	respawn_ui = respawn_ui_spawn.instance()
	get_node("/root").add_child(respawn_ui)
	
	# Respawn after duration
	var timer = Timer.new()
	timer.wait_time = respawn_time
	timer.autostart = true
	timer.one_shot = true
	timer.connect("timeout", self, "RequestRespawn")
	self.add_child(timer)

func RequestRespawn():
	Server.RequestRespawn()
	
func Respawn(spawn_position):
	alive = true
	visible = true
	
	global_transform.origin = spawn_position
	
	$PlayerCollisionShape.disabled = false
	
	respawn_ui.queue_free()

