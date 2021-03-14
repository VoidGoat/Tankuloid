extends Node

var network = NetworkedMultiplayerENet.new()
#var ip = "127.0.0.1"
#var ip = "52.255.134.51"
var ip = "192.168.3.185"
var port = 1909
var max_players = 100

var latency = 0
var client_clock = 0 
var delta_latency = 0
var decimal_collector = 0.0
var latency_array = []


# Called when the node enters the scene tree for the first time.
func _ready():
	 ConnectToServer()

func _physics_process(delta):
	# increment client clock
	client_clock += int(delta * 1000) + delta_latency
	delta_latency = 0
	
	# keep track of left over data that is truncated and add in later
	decimal_collector += (delta * 1000) - int(delta * 1000)
	if decimal_collector >= 1.0:
		client_clock += 1
		decimal_collector -= 1.0
	
	
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
	rpc_id(1, "FetchServerTime", OS.get_system_time_msecs())
	
	# calculate latency adjustment
	var timer = Timer.new()
	timer.wait_time = 0.5
	timer.autostart = true
	timer.connect("timeout", self, "DetermineLatency")
	self.add_child(timer)

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
#	print(player_state)
	rpc_unreliable_id(1, "ReceivePlayerState", player_state)

remote func ReceiveWorldState(world_state):
#	print(world_state)
	
	# Update world state
	WorldState.UpdateWorldState(world_state)
	
	
remote func ReturnServerTime(server_time, client_time):
	latency = (OS.get_system_time_msecs() - client_time) / 2
	client_clock = server_time + latency
	print("new client clock is: ", client_clock)

# called by latency timer
func DetermineLatency():
	print("Determining Latency")
	rpc_id(1, "DetermineLatency", OS.get_system_time_msecs())
	
remote func ReturnLatency(client_time):
	latency_array.append((OS.get_system_time_msecs() - client_time) / 2)
	if latency_array.size() == 9:
		var total_latency = 0
		latency_array.sort()
		var mid_point = latency_array[4]
		# remove outliers
		for i in range(latency_array.size() - 1, -1, -1):
			if latency_array[i] > (2 * mid_point) and latency_array[i] > 20:
				latency_array.remove(i)
			else:
				total_latency += latency_array[i]
		delta_latency = (total_latency / latency_array.size()) - latency
		latency = total_latency / latency_array.size()
		print("New Latency: " + str(latency))
		print("Delta Latency: " + str(delta_latency))
		latency_array.clear()
	
