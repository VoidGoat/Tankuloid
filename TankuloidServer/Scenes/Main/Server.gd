extends Node

var network = NetworkedMultiplayerENet.new()
var port = 1909
var max_players = 100
var player_state_collection = {}

# store reference to player nodes on server
var player_dict = {}

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
	rpc_id(0, "SpawnNewPlayer", player_id, Vector3(5, 1, -5))
	# Spawn server player for collisions
	var new_player = player_spawn.instance()
	new_player.transform.origin = Vector3(10,5,10)
	new_player.name = str(player_id)
	$Players.add_child(new_player)
	player_dict[player_id] = (new_player)
	
	

func _Peer_Disconnected(player_id):
	print("User " + str(player_id) + " Disconnected!")
	rpc_id(0, "DespawnPlayer", player_id)
	
	player_state_collection.erase(player_id)
	
	player_dict[player_id].queue_free()
	player_dict.erase(player_id)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

var bullet_spawn = preload("res://Scenes/Entity/BulletServer.tscn")
remote func SpawnBullet(position, direction, client_time):
	var new_bullet = bullet_spawn.instance()
	new_bullet.transform.origin = position
	new_bullet.transform.basis = Basis()
	new_bullet.transform.basis.z = direction
	new_bullet.transform.basis.y = Vector3(0,1,0)
	new_bullet.transform.basis.x = direction.cross(Vector3(0,1,0))
	new_bullet.name = "bullet" 
	get_node("Bullets").add_child(new_bullet)
	
	# measured in distance per second
	var bullet_speed = 10
	# spawn fake bullet on clients
	rpc_id(0, "SpawnClientBullet", position, direction, bullet_speed, client_time)

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
	
