extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Coins.text = str(Global.coin_count)
	$Time.text = str("Time: ",Global.time)
	$Health.text = str("Health: ",Global.player_health)
