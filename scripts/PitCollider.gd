extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var rb
var player 
var sequence = false

# Called when the node enters the scene tree for the first time.
func _ready():
	rb = get_parent()
	player = rb.get_parent()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_PitCollider_body_entered(body):
	if body.name == ("Hazards (Tangible)") and sequence == false:
		#print(body.get_cell(position.x,position.y))
		match body.get_cell(position.x,position.y):
			-1:
				pit_sequence()
				
			3:
				pit_sequence()
	

func pit_sequence():
	sequence = true
	player.i_frames = 99
	player.sfx.play_sound(player.sfx.fall_sounds,-20)
	player.can_roll = false
	var initial_ground = player.grounded_pos
	var initial_velocity = rb.linear_velocity.normalized()
	player.rolling = true
	$CollisionShape2D.set_deferred("disabled", true)
	rb.spin()
	yield(get_tree().create_timer(.5), "timeout")
	player.reset = true
	rb.reset_pos = initial_ground - initial_velocity * 20
	player.i_frames = 2
	get_parent().set_collision_mask_bit(3, true)
	player.true_damage(1)
	yield(get_tree().create_timer(.5), "timeout")
	rb.enable_collision()
	player.can_roll = true
	player.rolling = false
	$CollisionShape2D.set_deferred("disabled", false)
	get_parent().set_collision_mask_bit(3, false)
	sequence = false
				
				
