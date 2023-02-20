extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
<<<<<<< Updated upstream
	$Coins.text = "COINS: " + str(Global.coin_count)
=======
	$Coins.text = str(Global.coin_count)
	$Time.text = str(Global.time)
>>>>>>> Stashed changes
