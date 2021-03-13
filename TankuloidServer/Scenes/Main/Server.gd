extends Node

var network = NetworkedMultiplayerENet.new()
var port = 1909
var max_players = 100


# Called when the node enters the scene tree for the first time.
func _ready():
	StartServer()
	

func StartServer():
	network.create_server(port, max_players)
	get_tree().set_network_peer(network)
	print("Server started")
	
	network.connect("peer_connected", self, "_Peer_Connected")
	network.connect("peer_disconnected", self, "_Peer_Disconnected")

func _Peer_Connected(player_id):
	print("User " + str(player_id) + " Connected!")
	
func _Peer_Disconnected(player_id):
	print("User " + str(player_id) + " Disconnected!")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

remote func FetchData(test_string):
	var player_id = get_tree().get_rpc_sender_id()
	rpc_id(player_id, "ReturnData", "server says hello: " + test_string )
	print("sending " + test_string + " back to client")
