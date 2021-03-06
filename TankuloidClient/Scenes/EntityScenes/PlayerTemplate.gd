extends KinematicBody


var speed = 10.0
var alive = true
var invincible_time = 2

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


# Update color and such
func UpdatePlayerData(player_data):
#	var material = $TankBottomPivot/BodyMesh.get_surface_material(0)
	var material = SpatialMaterial.new()
	if player_data.has(int(self.name)):
		material.albedo_color = player_data[int(self.name)]["C"]
	print("HEYOOOO")
	$TankBottomPivot/BodyMesh.set_surface_material(0, material)


var explosion_spawn = preload("res://Scenes/ParticleScenes/PlayerDeath.tscn")
# Called when player has been killed
func Die(killer_id):
	if not alive:
		return
	alive = false
	visible = false
	$PlayerCollisionShape.disabled = true
	
	var explosion = explosion_spawn.instance()
	explosion.transform.origin = global_transform.origin
	get_node("/root/MainScene").add_child(explosion)
	
	$DeathSound.play()
	
	


func Respawn(spawn_position):
	if alive:
		pass
	alive = true
	
	global_transform.origin = spawn_position
	
	$PlayerCollisionShape.disabled = false
	
	$ShieldDisplay.Shrink(invincible_time, 1)
	
	yield(get_tree().create_timer(0.5), "timeout")
	visible = true
	
	
	
