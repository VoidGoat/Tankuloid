extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_JoinGameButton_button_up():
	var ip = $Center/Container/ServerLineEdit.text
	var nickname = $Center/Container/NicknameLineEdit.text
	print("Button pressed!", ip, " ", nickname)
	Server.ConnectToServer(ip, nickname)
	queue_free()
