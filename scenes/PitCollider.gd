extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var rb
var player 

# Called when the node enters the scene tree for the first time.
func _ready():
	rb = get_parent()
	player = rb.get_parent()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_PitCollider_body_entered(body):
	if body.name == ("Hazards (Tangible)"):
		#print(body.get_cell(position.x,position.y))
		match body.get_cell(position.x,position.y):
			-1:
				player.reset = true
				rb.reset_pos = player.grounded_pos -rb.linear_velocity.normalized() * 15
				player.i_frames = 2
				get_parent().set_collision_mask_bit(3, true)
				yield(get_tree().create_timer(.5), "timeout")
				get_parent().set_collision_mask_bit(3, false)
			3:
				player.reset = true
				rb.reset_pos = player.grounded_pos -rb.linear_velocity.normalized() * 15
				player.i_frames = 2
				get_parent().set_collision_mask_bit(3, true)
				yield(get_tree().create_timer(.5), "timeout")
				get_parent().set_collision_mask_bit(3, false)
				
