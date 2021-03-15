extends Spatial

# Called when the node enters the scene tree for the first time.
func _ready():
	var cells = $GridMap.get_used_cells()
	
	var min_x = 10000000000
	var max_x = -1000000000
	var min_z = 10000000000
	var max_z = -1000000000
	for cell in cells:
		if cell.x < min_x:
			min_x = int(cell.x)
		if cell.x > max_x:
			max_x = int(cell.x)
		if cell.z < min_z:
			min_z = int(cell.z)
		if cell.z > max_z:
			max_z = int(cell.z)
	
	var height = abs(max_z - min_z)
	var width = abs(max_x - min_x)
	
	
	var data = ""
	for i in range(width * height):
		var x = (i % width) - min_x
		var z = (i / width) - min_z
		
		data += str($GridMap.get_cell_item(x, 0, z))
	var layout = {}
	
	layout["width"] = width
	layout["height"] = height
	layout["data"] = data
	save( "res://saved_maps/map1.json", to_json(layout))
	
func save(path, content):
	var file = File.new()
	file.open(path, File.WRITE)
	file.store_string(content)
	file.close()

func load():
	var file = File.new()
	file.open("user://save_game.dat", File.READ)
	var content = file.get_as_text()
	file.close()
	return content
