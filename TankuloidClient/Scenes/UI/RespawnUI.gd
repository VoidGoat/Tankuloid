extends Control


var death_details = [
	"You were annihilated by %",
	"Blasted by %",
	"Your ass was grass and % mowed it",
	"The sweet release of death, provided by %",
	"Panzer? I hardly know her. -%",
	"Killed with malice aforethought by %",
	"% says tanks for the kill",
	"% 360 no scoped you",
	"% 720 no scoped you",
	
]

var suicide_details = [
	"Congratulations, you played yourself",
	"Absolutely stunning",
	"But the worst enemy you can meet will always be yourself. \n -Friedrich Nietzsche",
	"You aim like a Bob Semple",
	"You're supposed to shoot the other tanks",
	"You opened up a can of whoop ass and spilled it all over yourself."
]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func Init(killer_id):
	randomize()
	var killer_name = Server.player_data[killer_id]["N"]
	var details = ""
	if get_tree().get_network_unique_id() == int(killer_id):
		details = suicide_details[randi() % suicide_details.size()]
		print(suicide_details.size())
		print(randi())
	else:
		details = death_details[randi() % death_details.size()]
	$Details.text = details.replace("%", killer_name)
