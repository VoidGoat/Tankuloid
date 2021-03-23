extends Spatial

var interp_speed = 5

var previous_position = Vector3(1,0,0)
var current_direction = Vector3(0,0,1)
var movement_direction = Vector3(0,0,1)

var epsilon = 0.01

# Called when the node enters the scene tree for the first time.
func _ready():
	#previous_position = global_transform.origin
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if previous_position.distance_to(global_transform.origin) > epsilon:
		var new_movement_direction = -(previous_position - global_transform.origin).normalized() 
		if new_movement_direction.dot(current_direction) < 0:
			movement_direction = -new_movement_direction
		else:
			movement_direction = new_movement_direction
	
	movement_direction = movement_direction.normalized()
	
	current_direction = interp_to_vec3(current_direction, movement_direction, delta, interp_speed)
	
	var new_basis = Basis()
	new_basis.z = current_direction.normalized()
	new_basis.y = Vector3(0, 1, 0)
	new_basis.x = new_basis.z.cross(new_basis.y)


	global_transform.basis = new_basis
	
	previous_position = global_transform.origin
	

func interp_to(current, target, delta, speed):
	if speed <= 0.0:
		return target;

	var dist = target - current;

	if (pow(dist, 2) < 0.000001):
		return target;
	var deltaMove = dist * clamp(delta * speed, 0, 1);

	return current + deltaMove;


func interp_to_vec3(current, target, delta, speed):
	var ret = Vector3()
	ret.x = interp_to(current.x, target.x, delta, speed);
	ret.y = interp_to(current.y, target.y, delta, speed);
	ret.z = interp_to(current.z, target.z, delta, speed);
	return ret
#
#
#	public static Vector3 InterpTo(Vector3 current, Vector3 target, float delta, float speed) {
#		Vector3 ret = new Vector3();
#
#		ret.x = InterpTo(current.x, target.x, delta, speed);
#		ret.y = InterpTo(current.y, target.y, delta, speed);
#		ret.z = InterpTo(current.z, target.z, delta, speed);
#
#		return ret;
#	}
