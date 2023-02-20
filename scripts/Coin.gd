extends Node2D

var sprite
var remove

# Called when the node enters the scene tree for the first time.
func _ready():
	sprite = get_node("Area2D/AnimatedSprite")
	sprite.animation = "spin"
	sprite.play()
	remove = false
	z_index = 1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if remove:
		Global.remove_child(self)


func _on_Area2D_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if body.name == "PlayerBody":
		remove = true
	
