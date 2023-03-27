extends RigidBody2D

var attack_damage = 0
export(bool) var friendly = false
var provided_velocity = Vector2(0,0)
var start_pos = Vector2(0,0)
var active = false
var height = 3
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():

	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _integrate_forces(state):
	if friendly == true:
		attack_damage = Global.player_damage
		#set_collision_layer_bit(1, true)
		set_collision_mask_bit(1, true)
	else:
		if active == true:
			linear_velocity = provided_velocity * 200
			#set_collision_layer_bit(0, true)
			set_collision_mask_bit(0,true)
			height -= .01
			$CollisionShape2D.scale -= Vector2(0.002,0.002)
			if height <= 0 or $CollisionShape2D.scale.x <= 0:
				queue_free()
		else:
			state.transform.origin = start_pos
			active = true


func _on_Projectile_body_shape_entered(body_id, body, body_shape, local_shape):
	if body.name != "Projectile":
		if friendly == true:
			if body.name != "PlayerBody":
				queue_free()
				pass
		else:
			if body.name == "PlayerBody":
				body.get_parent().take_damage(attack_damage)
			if body.name != "EnemyBody":
				queue_free()
				pass


	pass # Replace with function body.
