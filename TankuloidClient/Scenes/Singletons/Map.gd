extends Node

var new_map

var map_generator = preload("res://Scenes/MainScenes/MapGenerator.tscn")

func FetchMapLayout():
	print("attempting to get Maplayout")
	rpc_id(1, "ReturnMapLayout")

remote func ReceiveMapLayout(layout):
	print("layout ", layout)
	new_map = map_generator.instance()
	new_map.transform.origin = Vector3(0,-0.95,0)
	new_map.name = "New Map"
	get_node("/root").add_child(new_map)
	
	BuildMap(layout)
	
func BuildMap(layout):
	var width = int(layout["width"])
	var height = int(layout["height"])
	var data : String = layout["data"]
	print("retrieved data ", layout)
	
	print(width)
	
#	match data[i]:
#		"0":
#			break
#		"1":
#			break
#	for i in range(width * height):

	# index in mesh library of wall mesh
	var wall_index = 1
	
	
	# add corners
	new_map.get_node("GridMap").set_cell_item(-1, 0, -1, wall_index)
	new_map.get_node("GridMap").set_cell_item(-1, 0, height, wall_index)
	new_map.get_node("GridMap").set_cell_item(width, 0, -1, wall_index)
	new_map.get_node("GridMap").set_cell_item(width, 0, height, wall_index)
	
	var cell_size = new_map.get_node("GridMap").cell_size
	# Set scale
	new_map.get_node("FloorMesh").scale = Vector3(width * cell_size.x, 1, height * cell_size.z)
	new_map.get_node("FloorMesh").transform.origin = Vector3(width * cell_size.x, 1, height * cell_size.z) / 2.0
	
	for i in range(width * height):
		if i >= data.length():
			print("exceeded map data size")
			return
		var x = i % width
		var z = i / width
		
		var mesh_index = 0
		match int(data[i]):
			0:
				mesh_index = 0
			1: 
				mesh_index = 1
			2: 
				mesh_index = 0
		new_map.get_node("GridMap").set_cell_item(x, 0, z, mesh_index)
		
		

		# add top wall 
		if z == 0:
			new_map.get_node("GridMap").set_cell_item(x, 0, -1, wall_index)
		# add bottom wall 
		if z == height - 1:
			new_map.get_node("GridMap").set_cell_item(x, 0, height, wall_index)
		# add right wall
		if x == width - 1:
			new_map.get_node("GridMap").set_cell_item(width, 0, z, wall_index)
		# add left wall
		if x == 0:
			new_map.get_node("GridMap").set_cell_item(-1, 0, z, wall_index)
		

		
		
	
