extends Control

var label = preload("res://Scenes/UI/LeaderboardLabel.tscn")

# take in dictionary
# {"1834784012" : {"name" : "bob", "kills": "2", "deaths:0"}
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func UpdateLeaderboard(player_data):
	for child in $Container/Names.get_children():
		if child.name != "Header":
			child.queue_free()
	for child in $Container/Kills.get_children():
		if child.name != "Header":
			child.queue_free()
	for child in $Container/Deaths.get_children():
		if child.name != "Header":
			child.queue_free()
	
	print("player_data", player_data)
	for id in player_data.keys():
		# add label
		var name_label = label.instance()
		name_label.text = player_data[id]["N"]
		$Container/Names.add_child(name_label)
		
		var kills_label = label.instance()
		kills_label.text = str(player_data[id]["K"])
		$Container/Kills.add_child(kills_label)
		
		var deaths_label = label.instance()
		deaths_label.text = str(player_data[id]["D"])
		$Container/Deaths.add_child(deaths_label)
