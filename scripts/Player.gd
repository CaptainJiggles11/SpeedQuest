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
			input_velocity.x = 1
		if Input.is_action_pressed("ui_left"):
			input_velocity.x = -1
		if Input.is_action_pressed("ui_down"):
			input_velocity.y = 1
		if Input.is_action_pressed("ui_up"):
			input_velocity.y = -1
		
		#Actually sets rigidbody velocity.
		rb.linear_velocity = input_velocity.normalized() * walk_speed * 100 
		
		#Flips character x according to mouse position.
		if get_viewport().get_mouse_position().x < get_viewport_rect().size.x/2:
			sprite.flip_h = true
		else:
			sprite.flip_h = false
			
		#If the player isn't pressing either movement keys, play idle animation.
		if abs(input_velocity.x) < 1 and abs(input_velocity.y) < 1:
			sprite.animation = "idle"
		else: #If moving, set walking animation.
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
	
