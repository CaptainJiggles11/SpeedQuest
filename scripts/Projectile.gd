extends RigidBody2D

var attack_damage = 0
export(bool) var friendly = false
var provided_velocity = Vector2(0,0)
var start_pos = Vector2(0,0)
var active = false
var height = 3
var piercing_left = 0
var stop = false
var fall_speed = 1
onready var use_sprite = $CollisionShape2D/Sprite
onready var CS = get_node("CollisionShape2D")
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	
	if friendly == true:
		set_collision_layer_bit(6, false)
	else:
		set_collision_layer_bit(0,true)
		
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _integrate_forces(state):
	
	if friendly == true:
		attack_damage = Global.player_damage
		#set_collision_layer_bit(1, true)
		set_collision_layer_bit(7, true)
		set_collision_layer_bit(6, false)
		linear_velocity = provided_velocity
		show()
	else:
		if active == true:
			if height > 3:
				CS.set_deferred("disabled",true)
			else:
				CS.set_deferred("disabled",false)
				
			use_sprite.position = Vector2(0, -height)
			show()
			linear_velocity = provided_velocity * 200
			#set_collision_layer_bit(0, true)
			set_collision_layer_bit(6,true)
			height -= .01 * fall_speed
			$CollisionShape2D.scale -= Vector2(0.002,0.002)
			$CollisionShape2D/Shadow.modulate = Color(1,1,1,1)
			if height <= 0 or $CollisionShape2D.scale.x <= 0:
				queue_free()
		else:
			state.transform.origin = start_pos
			active = true
			
	if use_sprite.animation == "wizard_dash" and stop == false:
		if use_sprite.frame < 4:
			linear_velocity /= -10
		else:
			linear_velocity = provided_velocity
			use_sprite.animation = "wizard_loop"
			stop = true


func _on_Projectile_body_shape_entered(_body_id, body, _body_shape, _local_shape):
	if body.name != "Projectile":
		if friendly == true:
			
			if "Walls (Tangible)" in body.name:
				queue_free()
				
			if body.name != "PlayerBody" and body.name != "WeaponBody":
					queue_free()

		else:
			if body.name == "PlayerBody":
				body.get_parent().take_damage(attack_damage)
				
			if body.name == "WeaponBody":
				print('spehm')
				if use_sprite.animation == "wizard_dash" or use_sprite.animation == "wizard_loop":
					print('spehm2')
					get_parent().take_damage(.5)
					queue_free()
					
			if body.name != "EnemyBody":
				queue_free()

