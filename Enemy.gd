extends Node2D

var rb
var sprite
enum enemy_type {none,zombie,skeleton,swampy}
export (enemy_type) var my_type = enemy_type.none
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	rb = $RigidBody2D
	sprite = $Sprite
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_RigidBody2D_body_shape_entered(body_id, body, body_shape, local_shape):
	sprite.modulate = Color(1,0,0)
	print("hit")
	yield(get_tree().create_timer(.1), "timeout")
	sprite.modulate = Color(1,1,1)
	pass # Replace with function body.
