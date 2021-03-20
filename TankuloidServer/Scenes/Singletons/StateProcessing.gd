extends Node

var world_state

var frame_counter = 0
var frame_divisor = 3

func _physics_process(delta):
	frame_counter = (frame_counter + 1) % frame_divisor

	if frame_counter % frame_divisor == 0:
		if not get_parent().player_state_collection.empty():
			world_state = {}
			world_state["PS"] = get_parent().player_state_collection.duplicate(true)
			for player in world_state["PS"].keys():
				world_state["PS"][player].erase("T")
			world_state["T"] = OS.get_system_time_msecs()
			
			get_parent().SendWorldState(world_state)
			
			# Update server player positions
			for player_id in get_parent().player_dict.keys():
				if world_state["PS"].has(int(player_id)):
					get_parent().player_dict[player_id].transform.origin = world_state["PS"][int(player_id)]["P"]


