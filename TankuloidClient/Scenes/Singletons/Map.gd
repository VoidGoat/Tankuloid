extends Node

var new_map

var map_generator = preload("res://Scenes/MainScenes/MapGenerator.tscn")

func FetchMapLayout():
	print("attempting to get Maplayout")
	rpc_id(1, "ReturnMapLayout")

remote func ReceiveMapLayout(layout):
	print("layout ", layout)
	new_map = map_generator.instance()
	new_map.global_transform.origin = Vector3(0,-0.95,0)
	new_map.name = "New Map"
	get_node("/root").add_child(new_map)
	
	BuildMap(layout)
	
func BuildMap(layout):
	var width = int(layout["width"])
	var height = int(layout["height"])
	var data : String = layout["data"]
	print(data)
	
#	match data[i]:
#		"0":
#			break
#		"1":
#			break
#	for i in range(width * height):
	
	for i in range(width * height):
		if i >= data.length():
			print("exceeded map data size")
			return
		var x = i % width
		var z = i / width
		new_map.get_node("GridMap").set_cell_item(x, 0, z, int(data[i]))
		
		# add top wall 
		if z == 0:
			new_map.get_node("GridMap").set_cell_item(x, 0, -1, 1)
		# add bottom wall 
		if z == height - 1:
			new_map.get_node("GridMap").set_cell_item(x, 0, height, 1)
		# add right wall
		if x == width - 1:
			new_map.get_node("GridMap").set_cell_item(width, 0, z, 1)
		# add left wall
		if x == 0:
			new_map.get_node("GridMap").set_cell_item(-1, 0, z, 1)
			
		
		
		
	
