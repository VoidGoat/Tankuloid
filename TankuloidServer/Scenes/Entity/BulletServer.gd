extends KinematicBody

var speed = 14
var bounces = 0
var lifetime = 15

var owner_id

func _ready():
	var self_destruct_timer = Timer.new()
	self_destruct_timer.wait_time = lifetime
	self_destruct_timer.autostart = true
	self_destruct_timer.connect("timeout", self, "SelfDestruct")
	self.add_child(self_destruct_timer)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var movement_vec = -speed * delta * global_transform.basis.z
	
	var collision = move_and_collide(movement_vec)
	if (collision):
		if collision.collider.is_in_group("players"):
			if not collision.collider.invincible:
				get_node("/root/Server").KillPlayer(collision.collider.name, owner_id)
			get_node("/root/Server").DestroyBullet(self.name)
			queue_free()
		if collision.collider.is_in_group("bullets"):
			queue_free()
		if bounces >= 1:
			queue_free()
		global_transform.basis = global_transform.basis.orthonormalized()
		global_transform.basis.z = -global_transform.basis.z.reflect(collision.normal).normalized()
		global_transform.basis.y = Vector3(0,1,0)
		global_transform.basis.x = global_transform.basis.z.cross(global_transform.basis.y)
		bounces += 1

func SelfDestruct():
	queue_free()
