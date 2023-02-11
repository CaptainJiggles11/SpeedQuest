extends Node2D


#Player Setup
enum character_class {none,melee,ranger,mage}
export (character_class) var my_class = character_class.none
var input_velocity = Vector2.ZERO
var player_position = Vector2.ZERO
var inventory = []
var rb
var sprite

#Player States
var player_facing = [["topleft", "left", "bottomleft"],["top","idle","bottom"],["top right","right","bottom right"]]
var rolling = false
var can_roll = true

#Player Stats
export(float) var walk_speed = 1
export(float) var attack_damage = 3
export(float) var roll_cooldown = .1


# Called when the node enters the scene tree for the first time.
func _ready():
	rb = get_node("RigidBody2D")
	sprite = get_node("RigidBody2D/AnimatedSprite")
	match my_class:
		character_class.melee:
			print("melee")
		character_class.ranger:
			print("ranger")
		character_class.mage:
			print("mage")
			
			

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	movement()
	print(input_velocity.x+1,input_velocity.y+1)
	print(player_facing[input_velocity.x+1][input_velocity.y+1])
	
func movement():
	input_velocity = Vector2.ZERO
	player_position = self.position
	
	if can_roll == true:
		if Input.is_action_pressed("roll"):
			rb.linear_velocity = rb.linear_velocity*2
			rolling = true
			can_roll = false
			sprite.animation = "roll"
			sprite.frame = 0

	if rolling == false:
		if Input.is_action_pressed("ui_right"):
			input_velocity.x = 1
		if Input.is_action_pressed("ui_left"):
			input_velocity.x = -1
		if Input.is_action_pressed("ui_down"):
			input_velocity.y = 1
		if Input.is_action_pressed("ui_up"):
			input_velocity.y = -1
		
		rb.linear_velocity = input_velocity.normalized() * walk_speed * 100
		
		#If the player isn't pressing either movement keys, play idle animation.
		if abs(input_velocity.x) <= 0 and abs(input_velocity.y) <= 0:
			sprite.animation = "idle"
		else:
			sprite.animation = "right"
			if get_viewport().get_mouse_position().x < player_position.x:
				sprite.flip_h = true
			else:
				sprite.flip_h = false
	else:
		if sprite.frame < 8:
			rb.linear_velocity = Vector2(rb.linear_velocity.x/1.001,rb.linear_velocity.y/1.01)
		else:
			rb.linear_velocity = Vector2(rb.linear_velocity.x/1.03,rb.linear_velocity.y/1.03)
		yield(sprite,"animation_finished")
		rolling = false
		yield(get_tree().create_timer(roll_cooldown), "timeout")
		can_roll = true
	
