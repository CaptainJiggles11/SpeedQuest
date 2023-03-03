extends Node2D

var sprite

# Called when the node enters the scene tree for the first time.
func _ready():
	sprite = get_node("Area2D/AnimatedSprite")
	sprite.animation = "spin"

	z_index = 1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



func _on_Area2D_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if body.name == "PlayerBody":
		Global._on_get_coin(self)
	
