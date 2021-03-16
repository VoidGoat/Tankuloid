extends Node

#var map_layout = {
#	"width" : 5,
#	 "height" : 5,
#	 "data" : "0000000000000000000000000"}
var layout_path = "res://saved_maps/map1.json"
func _ready():
	BuildMap(LoadLayout(layout_path))

var map_generator = preload("res://Scenes/Main/MapGenerator.tscn")

remote func ReturnMapLayout():
	var player_id = get_tree().get_rpc_sender_id()
	print("sending map layout to", player_id)
	
	var map_layout = LoadLayout(layout_path)
	rpc_id(player_id, "ReceiveMapLayout", map_layout)


func LoadLayout(path):
	var file = File.new()
	file.open(path, File.READ)
	var content = file.get_as_text()
	var layout = parse_json(content)
	print("content ", content)
	print("layout ", layout)
	file.close()
	
	
	return layout

func BuildMap(layout):
	# create new map generator
	var new_map = map_generator.instance()
	new_map.transform.origin = Vector3(0,-0.9,0)
	new_map.name = "New Map"
	get_node("/root").call_deferred("add_child", new_map)
	
	var width = int(layout["width"])
	var height = int(layout["height"])
	var data : String = layout["data"]
	print(data)
	
	
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
			
		
		
		
	

