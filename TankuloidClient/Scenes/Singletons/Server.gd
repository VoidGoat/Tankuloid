extends Node

var network = NetworkedMultiplayerENet.new()
var ip = "127.0.0.1"
#var ip = "52.255.134.51"
#var ip = "40.122.44.165"
var port = 1909
var max_players = 100




# Called when the node enters the scene tree for the first time.
func _ready():
	 ConnectToServer()
	

func ConnectToServer():
	network.create_client(ip, port)
	get_tree().set_network_peer(network)
	print("Attempting to connect to server")
	
	network.connect("connection_failed", self, "_OnConnectionFailed")
	network.connect("connection_succeeded", self, "_OnConnectionSucceeded")

func _OnConnectionFailed():
	print("Failed to Connect!")
	
func _OnConnectionSucceeded():
	print("Successfully connected!")

func FetchData(test_string):
	rpc_id(1, "FetchData", test_string)

remote func ReturnData(s_return_string):
	print(s_return_string)


var player_spawn = preload("res://Scenes/EntityScenes/PlayerTemplate.tscn")
remote func SpawnNewPlayer(player_id, spawn_position):
	print("spawning new player")
	if get_tree().get_network_unique_id() == player_id:
		pass
	else:
		if not get_tree().root.get_node("MainScene/OtherPlayers").has_node(str(player_id)):
			var new_player = player_spawn.instance()
			new_player.transform.origin = spawn_position
			new_player.name = str(player_id)
			get_tree().root.get_node("MainScene/OtherPlayers").add_child(new_player)
		
remote func DespawnPlayer(player_id):
	print("despawning!" + str(player_id))
	yield(get_tree().create_timer(0.2), "timeout")
	get_tree().root.get_node("MainScene/OtherPlayers/" + str(player_id)).queue_free()
	

func SendPlayerState(player_state):
	print(player_state)
	rpc_unreliable_id(1, "ReceivePlayerState", player_state)

remote func ReceiveWorldState(world_state):
	print(world_state)
	
	# Update world state
	WorldState.UpdateWorldState(world_state)
