extends Node

# world state key
# Categories:
# PS = players
#
# T = time
# P = position
# 
var last_world_state_time = 0

# store previous world states
var world_state_buffer = []

# in msecs
var interpolation_offset = 100


func UpdateWorldState(world_state):
	if world_state["T"] > last_world_state_time:
		last_world_state_time = world_state["T"]
		world_state_buffer.append(world_state)


func _physics_process(delta):
	var render_time = Server.client_clock - interpolation_offset
	if world_state_buffer.size() > 1:
		while world_state_buffer.size() > 2 and render_time > world_state_buffer[2].T:
			world_state_buffer.remove(0)
		if world_state_buffer.size() > 2: # we have a future state so we should interpolate
			var interpolation_factor = float(render_time - world_state_buffer[1]["T"]) / float(world_state_buffer[2]["T"] - world_state_buffer[1]["T"])
			for player in world_state_buffer[2]["PS"].keys():
				if str(player) == "T":
					continue
				if player == get_tree().get_network_unique_id():
					continue
				if not world_state_buffer[1]["PS"].has(player):
					continue
				if get_node("/root/MainScene/OtherPlayers").has_node(str(player)):
					var new_position = lerp(world_state_buffer[1]["PS"][player]["P"], world_state_buffer[2]["PS"][player]["P"], interpolation_factor)
					get_node("/root/MainScene/OtherPlayers/" + str(player)).MovePlayer(new_position)
				else:
					print("spawning player")
					Server.SpawnNewPlayer(player, world_state_buffer[2]["PS"][player]["P"])
		elif render_time > world_state_buffer[1].T: # we do not have a future state so we should extrapolate if 
			var extrapolation_factor = float(render_time - world_state_buffer[0]["T"]) / float(world_state_buffer[1]["T"] - world_state_buffer[0]["T"]) - 1.0
			for player in world_state_buffer[1]["PS"].keys():
				if str(player) == "T":
					continue
				if player == get_tree().get_network_unique_id():
					continue
				if not world_state_buffer[0]["PS"].has(player):
					continue
				if get_node("/root/MainScene/OtherPlayers").has_node(str(player)):
					var position_delta =  world_state_buffer[1]["PS"][player]["P"] - world_state_buffer[0]["PS"][player]["P"]
					var new_position = world_state_buffer[1]["PS"][player]["P"] + (position_delta * extrapolation_factor)
					get_node("/root/MainScene/OtherPlayers/" + str(player)).MovePlayer(new_position)
				else:
					print("spawning player")
					Server.SpawnNewPlayer(player, world_state_buffer[1]["PS"][player]["P"])
			
#
#func UpdateWorldState(world_state):
#	if world_state["T"] > last_world_state_time:
#		last_world_state_time = world_state["T"]
#		world_state.erase("T")
#		world_state.erase(get_tree().get_network_unique_id()) # remove current player from state
#		for player in world_state.keys():
#			if get_tree().root.get_node("MainScene/OtherPlayers").has_node(str(player)):
#				get_tree().root.get_node("MainScene/OtherPlayers/" + str(player)).MovePlayer(world_state[player]["P"])
#			else:
#				print("spawning new player")
#				Server.SpawnNewPlayer(player, world_state[player]["P"])
