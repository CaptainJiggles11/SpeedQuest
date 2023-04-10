extends Node2D

var sprite
var chase_player = false
# Called when the node enters the scene tree for the first time.
func _ready():
	sprite = get_node("Area2D/AnimatedSprite")
	sprite.animation = "bounce"
	z_index = 1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if chase_player == false:
		if Vector2(global_position).distance_to(Global.player_position) > 200:
			chase_player = true
	else:
		global_position += (Global.player_position - global_position).normalized() * 2


func _on_Area2D_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if body.name == "PlayerBody":
		Global._on_get_heart(self)
