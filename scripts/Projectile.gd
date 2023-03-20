extends RigidBody2D

var attack_damage = 0
var friendly = false
var provided_velocity = Vector2(0,0)

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():

	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if friendly == true:
		attack_damage = Global.player_damage
		set_collision_layer_bit(1, true)
	else:
		linear_velocity = provided_velocity * 200
		set_collision_layer_bit(0, true)


func _on_Projectile_body_shape_entered(body_id, body, body_shape, local_shape):
	print(body)
	if body.name != "Projectile":
		if friendly == true:
			if body.name != "PlayerBody":
				queue_free()
		else:
			if body.name == "PlayerBody":
				body.get_parent().take_damage(attack_damage)
			if body.name != "EnemyBody":
				queue_free()


	pass # Replace with function body.
