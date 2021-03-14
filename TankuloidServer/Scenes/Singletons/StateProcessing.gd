extends Node

var world_state

func _physics_process(delta):
	if not get_parent().player_state_collection.empty():
		world_state = {}
		world_state["PS"] = get_parent().player_state_collection.duplicate(true)
		for player in world_state["PS"].keys():
			world_state["PS"][player].erase("T")
		world_state["T"] = OS.get_system_time_msecs()
		
		get_parent().SendWorldState(world_state)
