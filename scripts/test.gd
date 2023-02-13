extends Node2D

var coin
var coin_count


# Called when the node enters the scene tree for the first time.
func _ready():
	coin_count = 0
	coin = preload("res://scenes/Coin.tscn").instance()
	coin.position = Vector2(50,50)
	coin.z_index = 1
	coin.get_child(0).connect("body_shape_entered", self, "_on_get_coin")
	add_child(coin)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_get_coin(body_rid, body, body_shape_index, local_shape_index):
	if(body.name == "PlayerBody"):
		print("got coin")
		remove_child(coin)
		coin_count += 1
		$CanvasLayer/Coins.text = "COINS: " + str(coin_count)
	else:
		print("not player")
