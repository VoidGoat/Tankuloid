extends Node

var network = NetworkedMultiplayerENet.new()
var port = 1909
var max_players = 100
var player_state_collection = {}

# store reference to player nodes on server
var player_dict = {}

# Keep track of player info like health and kills
# {"104879234": {H": 100, "K": 3}}
var player_data = {}

var next_bullet_id = 1000

var color_list = [Color(0, 1, 0), Color(0, 0, 1), Color(1, 0, 0), Color(1, 1, 0),  Color(1, 0, 1), Color(0, 1, 1)]

var color_counter = 0

# Called when the node enters the scene tree for the first time.
func _ready():

	StartServer()
	

func StartServer():
	network.create_server(port, max_players)
	get_tree().set_network_peer(network)
	print("Server started")
	
	network.connect("peer_connected", self, "_Peer_Connected")
	network.connect("peer_disconnected", self, "_Peer_Disconnected")

var player_spawn = preload("res://Scenes/Entity/PlayerServer.tscn")
func _Peer_Connected(player_id):
	print("User " + str(player_id) + " Connected!")
	
	
	
	# Choose spawn_point
	var spawn_position = Vector3(5, 1, -5)
#	print($Map.available_spawn_points.size())
#	if $Map.available_spawn_points.size() > 0:
#		print("selecting spawn")
#		spawn_position = $Map.available_spawn_points[0]
#		$Map.occupied_spawn_points.append(spawn_position)
#		$Map.available_spawn_points.remove(0)
	spawn_position = $Map.CalculateBestSpawnPoint()
	
	
	rpc_id(0, "SpawnNewPlayer", player_id, spawn_position)
	# Spawn server player for collisions
	var new_player = player_spawn.instance()
	new_player.transform.origin = spawn_position
	new_player.name = str(player_id)
	$Players.add_child(new_player)
	player_dict[player_id] = (new_player)
	

	
	

func _Peer_Disconnected(player_id):
	print("User " + str(player_id) + " Disconnected!")
	rpc_id(0, "DespawnPlayer", player_id)
	
	player_state_collection.erase(player_id)
	
	player_dict[player_id].queue_free()
	player_dict.erase(player_id)
	
	player_data.erase(player_id)

remote func ReceiveNickname(nickname):
	# add player entry
	var player_id = get_tree().get_rpc_sender_id()
	var new_color =  color_list[color_counter % color_list.size()].darkened(0.35)
#	color_list[0].darkened()
	color_counter += 1

#	print("New color is", new_color, " --- ", player_data.keys().size())
	player_data[player_id] = {"N": nickname, "K": 0, "D": 0, "C": new_color}

	rpc_id(0, "UpdatePlayerData", player_data)

remote func ReceiveRespawnRequest():
	var player_id = get_tree().get_rpc_sender_id()
	var spawn_position = $Map.CalculateBestSpawnPoint()
	
	# Reenable collisions and such
	get_node("Players/" + str(player_id)).Respawn()
	rpc_id(0, "RespawnPlayer", player_id, spawn_position)
	
var bullet_spawn = preload("res://Scenes/Entity/BulletServer.tscn")
remote func SpawnBullet(position, direction, owner_id, client_time):
	var id = next_bullet_id
	
	var new_bullet = bullet_spawn.instance()
	new_bullet.transform.origin = position
	new_bullet.transform.basis = Basis()
	new_bullet.transform.basis.z = direction
	new_bullet.transform.basis.y = Vector3(0,1,0)
	new_bullet.transform.basis.x = direction.cross(Vector3(0,1,0))
	new_bullet.name = "bullet_" + str(id)
	new_bullet.owner_id = owner_id
	get_node("Bullets").add_child(new_bullet)
	
	next_bullet_id += 1
	
	# measured in distance per second
	var bullet_speed = 10
	# spawn fake bullet on clients
	# Send current server time so clients can compensate
	rpc_id(0, "SpawnClientBullet", position, direction, bullet_speed, OS.get_system_time_msecs(), id)

func DestroyBullet(bullet_name):
	rpc_id(0, "DestroyClientBullet", bullet_name)

remote func FetchData(test_string):
	var player_id = get_tree().get_rpc_sender_id()
	rpc_id(player_id, "ReturnData", "server says hello: " + test_string )
	print("sending " + test_string + " back to client")

remote func ReceivePlayerState(player_state):
	var player_id = get_tree().get_rpc_sender_id()
	if player_state_collection.has(player_id):
		# make sure you're using latest player_state
		if player_state_collection[player_id]["T"] < player_state["T"]:
			player_state_collection[player_id] = player_state
	else:
		player_state_collection[player_id] = player_state
	
remote func SendWorldState(world_state):
	rpc_unreliable_id(0, "ReceiveWorldState", world_state)

remote func FetchServerTime(client_time):
	var player_id = get_tree().get_rpc_sender_id()
	rpc_id(player_id, "ReturnServerTime", OS.get_system_time_msecs(), client_time)
	
remote func DetermineLatency(client_time):
	var player_id = get_tree().get_rpc_sender_id()
	rpc_id(player_id, "ReturnLatency", client_time)

# player id is who is dying and killer_id is who launched the bulllet
func KillPlayer(player_id, killer_id):
	# Only get kill if you killed some one other than yourself
	if int(killer_id) != int(player_id):
		player_data[int(killer_id)]["K"] += 1
	player_data[int(player_id)]["D"] += 1
	
	get_node("Players/" + str(player_id)).Die()
	
	rpc_id(0, "UpdatePlayerData", player_data)
	
	rpc_id(0, "KillPlayer", player_id, killer_id)

