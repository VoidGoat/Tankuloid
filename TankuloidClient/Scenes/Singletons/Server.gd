extends Node

var network = NetworkedMultiplayerENet.new()
#var ip = "127.0.0.1"
var ip = "52.255.134.51"
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
