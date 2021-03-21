extends MeshInstance

var shrink_time
var duration

var time = 0

func _ready():
	set_process(false)
	visible = false

# Called when the node enters the scene tree for the first time.
func _process(delta):
	time += delta
	scale = Vector3(1, 1, 1) * ( 1 - clamp(shrink_time + time - duration, 0, 1) / shrink_time)
#	print(clamp(shrink_time + time - duration, 0, 1)/ shrink_time)



func Shrink(whole, shrink):
	duration = whole
	shrink_time = shrink
	time = 0
	visible = true
	set_process(true)
	yield(get_tree().create_timer(duration), "timeout")
	set_process(false)
	visible = false
