extends Node

#var map_layout = {
#	"width" : 5,
#	 "height" : 5,
#	 "data" : "0000000000000000000000000"}

remote func ReturnMapLayout():
	var player_id = get_tree().get_rpc_sender_id()
	print("sending map layout to", player_id)
	
	var map_layout = LoadLayout()
	rpc_id(player_id, "ReceiveMapLayout", map_layout)


func LoadLayout():
	var file = File.new()
	file.open("res://saved_maps/map1.json", File.READ)
	var content = file.get_as_text()
	var layout = parse_json(content)
	print("content ", content)
	print("layout ", layout)
	file.close()
	
	
	return layout
