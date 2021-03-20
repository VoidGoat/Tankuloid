extends Control

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var player = get_parent()
	var counter = 0
	for child in $Container.get_children():
		if counter < player.ammo:
			child.visible = true
		else:
			child.visible = false
		counter += 1
