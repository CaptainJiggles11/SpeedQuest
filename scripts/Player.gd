extends Node2D

#Misc 
var local_mouse_pos
var viewport_center
var rb
var _timer = null
var player_cam = null
var devmode = false
var rb_script = load("res://scenes/PlayerRB.gd").new()
var move_player = null
var look_direction = Vector2(1,1)


#Controller
var deadzone = 0.5




#Audio Setup
var sfx

#Player Setup
enum character_class {none,melee,ranger,mage}
export (character_class) var my_class = character_class.none
var input_velocity = Vector2.ZERO
var player_position = Vector2.ZERO
var sprite
var inventory = []


#Player States
var player_facing = [["topleft", "left", "bottomleft"],["top","idle","bottom"],["top right","right","bottom right"]]
var rolling = false
var can_roll = true
var walking = false
var attacking = false
var reset = false
var i_frames = 0
var door_timer = 0

#Player Stats
export(float) var walk_speed = 1
export(float) var attack_damage = 1
export(float) var roll_cooldown = .1
export(float) var attack_cooldown = .4
export(float) var roll_velocity = 1.8


#Weapon Stats
export (float) var weapon_offset = 20


func _ready():
	rb = get_node("PlayerBody")
	sprite = get_node("PlayerBody/AnimatedSprite")
	sfx = get_node("PlayerBody/PlayerSfx")
	viewport_center = Vector2(get_viewport_rect().size.x/2,get_viewport_rect().size.y/2) #Middle of the viewport.
	Global.player_position = rb.global_position
	player_cam = $PlayerCam
	
	_timer = Timer.new()
	add_child(_timer)
	_timer.connect("timeout", self, "_on_Timer_timeout")
	_timer.set_wait_time(.2)
	_timer.set_one_shot(false) # Make sure it loops
	_timer.start()
	
	match my_class:
		character_class.melee:
			print("melee")
		character_class.ranger:
			print("ranger")
		character_class.mage:
			print("mage")

func _process(delta):
	Global.player_damage = attack_damage
	Global.player_position = rb.global_position
	local_mouse_pos = get_viewport().get_mouse_position() #Mouse position on the viewport.
	
	
	movement() #Controls player movement (Walking, Rolling)
	weapon_movement(delta) #Controls the revolving weapon.
	if Input.is_action_just_pressed("attack"):
		attack()
	#print(input_velocity.x+1,input_velocity.y+1)
	#print(player_facing[input_velocity.x+1][input_velocity.y+1])
	
	if door_timer >= 0:
		door_timer -= delta
		
	if i_frames >= 0:
		i_frames -= delta

func movement():
	input_velocity = Vector2.ZERO
	player_position = rb.global_position
	
	if Input.is_action_just_pressed("pause"):
		Global.level = self
		Global.alive = false
		get_tree().root.remove_child(self)
		get_tree().root.add_child(load("res://scenes/Pause Menu.tscn").instance())

	
	#Roll Mechanic-- gives a burst of speed and intangibility on press.
	if can_roll == true:
		if Input.is_action_pressed("roll"):
			rb.linear_velocity = rb.linear_velocity*roll_velocity
			rb.set_collision_layer_bit(0, false)
			rb.set_collision_layer_bit(1, false)
			rb.set_collision_layer_bit(2, false)
			rb.set_collision_layer_bit(3, false)
			rolling = true
			can_roll = false
			sprite.animation = "roll"
			sprite.frame = 0
			sfx.play_sound(sfx.roll)


	#Get WASD inputs.
	if rolling == false:
		if Input.get_connected_joypads().size() >= 1:
			joypad_controls()
		else:
			keyboard_controls()
		
		#Actually sets rigidbody velocity.
		rb.linear_velocity = input_velocity.normalized() * walk_speed * 100 
		
		
		#Flips character x according to mouse position.
		if look_direction.x < 0:
			sprite.flip_h = true
		
		else:
			sprite.flip_h = false
			
			
		#If the player isn't pressing either movement keys, play idle animation.
		
		var current_frame = sprite.frame 
		
		if abs(input_velocity.x) < .01 and abs(input_velocity.y) < .01:
			walking = false
			if look_direction.y < -.5:
				sprite.animation = "upidle"
				sprite.frame = current_frame
			elif look_direction.y > .5:
				sprite.animation = "downidle"
				sprite.frame = current_frame
			else:
				sprite.animation = "idle"
				sprite.frame = current_frame
			#If moving, set walking animation.
		else:
			walking = true
			if look_direction.y < -.5:
				sprite.animation = "up"
			elif look_direction.y > .5:
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
		rb.set_collision_layer_bit(0, true) #Player
		rb.set_collision_layer_bit(1, true) #Enemy
		rb.set_collision_layer_bit(2, true) #Enemy Projectiles
		rb.set_collision_layer_bit(3, true) #Hazards

func weapon_movement(delta):
	#Vector of mouse to middle of screen + a really silly way to account for the screen disjoint.
	
	var angleTo = $Weapon.transform.x.angle_to(look_direction)
	
	#Makes Weapon render below the player sprite if they are looking upwards.
	if look_direction.y < .5:
		$Weapon.z_index = sprite.z_index - 1
	else:
		$Weapon.z_index = sprite.z_index + 1
	
	#Set the weapon's position to a radius around the player
	$Weapon.position = player_position + look_direction.normalized() * weapon_offset + Vector2(0,5) 
	#Magic
	$Weapon.rotate(sign(angleTo)* min(delta * 100, abs(angleTo))) 

func attack():
	if rolling == false and attacking == false:
		$PlayerCam.add_trauma(.15)
		$Weapon/WeaponBody.set("friendly", true)
		$Weapon/WeaponBody/CollisionShape2D.disabled = false
		attacking = true
		$Weapon.frame = 0
		sfx.play_sound(sfx.sword_sfx)
		$Weapon.play()
		yield(get_tree().create_timer(.2), "timeout")
		$Weapon/WeaponBody/CollisionShape2D.disabled = true
		yield(get_tree().create_timer(attack_cooldown), "timeout")
		attacking = false

func take_damage(amount):
	if i_frames <= 0:
		i_frames = 1.5
		Global.player_health -= amount
		sfx.play_sound(sfx.dmg)

func _on_Timer_timeout():
	if walking == true and rolling == false:
		sfx.play_sound(sfx.footsteps)

func _on_PlayerBody_body_shape_entered(body_id, body, body_shape, local_shape):
	if body.name == ("Hazards (Tangible)"):
		#print(body.get_cell(position.x,position.y))
		match body.get_cell(position.x,position.y):
			-1:
				#Pitfall ID
				reset = true
				#print(reset)
			3:
				reset = true

	if body.name == "EnemyBody" and i_frames <= 0:
		take_damage(1)
		if Global.player_health == 0:
			Global.open_shop()
	
	if door_timer <= 0:
		match body.name:
			"North Door":
				move_player = Vector2(0,-50)
				door_timer = .5
			"South Door":
				move_player = Vector2(0,50)
				door_timer = .5
			"West Door":
				move_player = Vector2(-50,0)
				door_timer = .5
			"East Door":
				move_player = Vector2(50,0)
				door_timer = .5

func _on_Area2D_area_shape_entered(area_id, area, area_shape, self_shape):
	if area.name == ("RoomCollider"):
		area.get_parent().set_active()
			
	pass # Replace with function body.

func _on_Area2D_area_shape_exited(area_id, area, area_shape, self_shape):
	if area != null:
		if area.name == ("RoomCollider"):
			area.get_parent().set_inactive()
		
	pass # Replace with function body.

func keyboard_controls():
	
	look_direction = (local_mouse_pos-viewport_center).normalized()
	
	if Input.is_action_pressed("ui_right"):
		input_velocity.x += 1
	if Input.is_action_pressed("ui_left"):
		input_velocity.x -= 1
	if Input.is_action_pressed("ui_down"):
		input_velocity.y += 1
	if Input.is_action_pressed("ui_up"):
		input_velocity.y -= 1
	
	look_direction = (local_mouse_pos-Vector2(viewport_center.x+rb.linear_velocity.x/6, viewport_center.y)).normalized() 
	$PlayerCam.set("look_direction", get_viewport().get_mouse_position())
	
	if devmode == true:
		if Input.is_action_just_released("scroll_up"):
			player_cam.zoom = Vector2(player_cam.zoom.x - .1, player_cam.zoom.y - .1 )
		if Input.is_action_just_released("scroll_down"):
			player_cam.zoom = Vector2(player_cam.zoom.x + .1, player_cam.zoom.y + .1 )

func joypad_controls():
	#Gets joystick axes and sets the movement variables for movement()
	var left_stick_rl = Input.get_joy_axis(0, JOY_AXIS_0)
	var left_stick_ud = Input.get_joy_axis(0, JOY_AXIS_1)
	var right_stick_rl = Input.get_joy_axis(0, JOY_AXIS_2)
	var right_stick_ud = Input.get_joy_axis(0 ,JOY_AXIS_3)
	
	if abs(right_stick_rl) > deadzone || abs(right_stick_ud) > deadzone:

		look_direction = Vector2(right_stick_rl, right_stick_ud)
		$PlayerCam.set("look_direction", get_viewport_rect().size/2 + look_direction*200)

	
	if abs(left_stick_rl) > deadzone || abs(left_stick_ud) > deadzone:
		input_velocity.x += left_stick_rl
		input_velocity.y += left_stick_ud
		
	if Input.is_action_pressed("ui_right"):
		input_velocity.x += 1
	if Input.is_action_pressed("ui_left"):
		input_velocity.x -= 1
	if Input.is_action_pressed("ui_down"):
		input_velocity.y += 1
	if Input.is_action_pressed("ui_up"):
		input_velocity.y -= 1

