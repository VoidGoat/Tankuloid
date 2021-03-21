extends KinematicBody

var speed = 14
var bounces = 0
var lifetime = 15

# particles to spawn
var bounce_effect_spawn = preload("res://Scenes/ParticleScenes/BulletBounce.tscn")

func _ready():
	
	var self_destruct_timer = Timer.new()
	self_destruct_timer.wait_time = lifetime
	self_destruct_timer.autostart = true
	self_destruct_timer.connect("timeout", self, "SelfDestruct")
	self.add_child(self_destruct_timer)
	
	$ShootSound.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var movement_vec = -speed * delta * global_transform.basis.z
	
	var collision = move_and_collide(movement_vec)
	if (collision):
		if collision.collider.is_in_group("players"):
#			queue_free()
			return
		if collision.collider.is_in_group("bullets"):
			queue_free()
		if bounces >= 1:
			queue_free()
		
		global_transform.basis = global_transform.basis.orthonormalized()
		global_transform.basis.z = -global_transform.basis.z.reflect(collision.normal).normalized()
		global_transform.basis.y = Vector3(0,1,0)
		global_transform.basis.x = global_transform.basis.z.cross(global_transform.basis.y)
		bounces += 1
		
		# spawn bounce effect
		var bounce = bounce_effect_spawn.instance()
		bounce.transform.origin = transform.origin
		get_node("/root/MainScene").add_child(bounce)

func SelfDestruct():
	queue_free()
