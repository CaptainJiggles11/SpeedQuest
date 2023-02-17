extends Node2D


#Player Setup
enum character_class {none,melee,ranger,mage}
export (character_class) var my_class = character_class.none
var input_velocity = Vector2.ZERO
var player_position = Vector2.ZERO
var local_mouse_pos
var viewport_center
var rb
var sprite
var inventory = []

#Player States
var player_facing = [["topleft", "left", "bottomleft"],["top","idle","bottom"],["top right","right","bottom right"]]
var rolling = false
var can_roll = true

#Player Stats
export(float) var walk_speed = 1
export(float) var attack_damage = 3
export(float) var roll_cooldown = .1

#Weapon Stats
export (float) var weapon_offset = 15


# Called when the node enters the scene tree for the first time.
func _ready():
	rb = get_node("PlayerBody")
	sprite = get_node("PlayerBody/AnimatedSprite")
	viewport_center = Vector2(get_viewport_rect().size.x/2,get_viewport_rect().size.y/2) #Middle of the viewport.
	
	match my_class:
		character_class.melee:
			print("melee")
		character_class.ranger:
			print("ranger")
		character_class.mage:
			print("mage")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	Global.player_position = rb.position
	local_mouse_pos = get_viewport().get_mouse_position() #Mouse position on the viewport.
	
	movement() #Controls player movement (Walking, Rolling)
	weapon_movement(delta) #Controls the revolving weapon.
	
	#print(input_velocity.x+1,input_velocity.y+1)
	#print(player_facing[input_velocity.x+1][input_velocity.y+1])
	
func movement():
	input_velocity = Vector2.ZERO
	player_position = rb.position
	
	
	#Roll Mechanic-- gives a burst of speed and intangibility on press.
	if can_roll == true:
		if Input.is_action_pressed("roll"):
			rb.linear_velocity = rb.linear_velocity*2
			rolling = true
			can_roll = false
			sprite.animation = "roll"
			sprite.frame = 0
			
	#Get WASD inputs.
	if rolling == false:
		if Input.is_action_pressed("ui_right"):
			input_velocity.x += 1
		if Input.is_action_pressed("ui_left"):
			input_velocity.x -= 1
		if Input.is_action_pressed("ui_down"):
			input_velocity.y += 1
		if Input.is_action_pressed("ui_up"):
			input_velocity.y -= 1
		
		#Actually sets rigidbody velocity.
		rb.linear_velocity = input_velocity.normalized() * walk_speed * 100 
		
		
		#Flips character x according to mouse position.
		if local_mouse_pos.x < viewport_center.x:
			sprite.flip_h = true
		else:
			sprite.flip_h = false
			
		#If the player isn't pressing either movement keys, play idle animation.
		
		var current_frame = sprite.frame 
		
		if abs(input_velocity.x) < 1 and abs(input_velocity.y) < 1:
			if (local_mouse_pos-viewport_center).normalized().y < -.5:
				sprite.animation = "upidle"
				sprite.frame = current_frame
			elif (local_mouse_pos-viewport_center).normalized().y > .5:
				sprite.animation = "downidle"
				sprite.frame = current_frame
			else:
				sprite.animation = "idle"
				sprite.frame = current_frame
			#If moving, set walking animation.
		elif (local_mouse_pos-viewport_center).normalized().y < -.5:
			sprite.animation = "up"
		elif (local_mouse_pos-viewport_center).normalized().y > .5:
			sprite.animation = "down"
		else:
			sprite.animation = "right"

	else: #If rolling
		#Slow down after the initial burst of speed from pressing roll.
		if sprite.frame < 8:
			rb.linear_velocity = Vector2(rb.linear_velocity.x/1.001,rb.linear_velocity.y/1.01)
		else: #After the 8th frame (hitting the ground), slow down significantly faster.
			rb.linear_velocity = Vector2(rb.linear_velocity.x/1.03,rb.linear_velocity.y/1.03)
			
		yield(sprite,"animation_finished") #Wait for the last frame to end rolling state.
		rolling = false
		
		yield(get_tree().create_timer(roll_cooldown), "timeout") #Wait out the roll cooldown before you can roll again.
		can_roll = true

func weapon_movement(delta):
	#Vector of mouse to middle of screen + a really silly way to account for the screen disjoint.
	var mouse_dir = (local_mouse_pos-Vector2(viewport_center.x+rb.linear_velocity.x/6, viewport_center.y)).normalized() 
	var angleTo = $Weapon.transform.x.angle_to(mouse_dir) #Idk
	
	#Makes Weapon render below the player sprite if they are looking upwards.
	if (local_mouse_pos-viewport_center).normalized().y < .5:
		sprite.z_index = 1
	else:
		sprite.z_index = 0
	
	#Set the weapon's position to a radius around the player
	$Weapon.position = player_position + mouse_dir * weapon_offset + Vector2(0,5) 
	#Magic
	$Weapon.rotate(sign(angleTo)* min(delta * 100, abs(angleTo))) 
