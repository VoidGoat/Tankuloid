extends Spatial

var lifetime = 3


# Called when the node enters the scene tree for the first time.
func _ready():
	for child in get_children():
		if child is Particles:
			child.one_shot = true
	
	# Destroy particle after lifetime is complete
	var timer = Timer.new()
	timer.wait_time = lifetime
	timer.autostart = true
	timer.connect("timeout", self, "Destroy")
	self.add_child(timer)

func Destroy():
	queue_free()
