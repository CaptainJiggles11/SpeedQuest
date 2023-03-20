extends Node2D

#Boss Stats
export (float) var health = 3
export (float) var speed = 50
export (int) var damage = 1
var actual_speed
var slow = 1

#Boss States
enum attack_type {none,chase,jump,shoot}
export (attack_type) var my_attack = attack_type.none
export (bool) var passable = false

#Boss Setup
var rb
var sprite
var sfx
var path: Array = []
var level_navigation: Navigation2D = null


onready var line2d = $Line2D


# Called when the node enters the scene tree for the first time.
func _ready():
	rb = $BossBody
	sprite = $BossBody/Sprite
	sfx = $BossBody/BossAudio
	yield(get_tree(), "idle_frame")
	
	speed = 30
	health = 8
	sprite.animation = "slime_idle"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	level_navigation = get_parent().get_node("LevelNavigation")
	line2d.global_position = Vector2.ZERO
	if health <= 0:
		death()
	
	actual_speed = speed * slow
	if slow < 1:
		slow+= delta
	
	if global_position.x > Global.player_position.x:
		sprite.flip_h = false
		pass
	else:
		sprite.flip_h = true
		pass
		
	match my_attack:
		attack_type.none:
			pass
		attack_type.chase:
			if passable == true:
				generate_path()
				navigate(delta)
			else:
				global_position += (Global.player_position - global_position).normalized() * actual_speed * delta 
		attack_type.jump:
			pass
		attack_type.shoot:
			pass
		
	pass


func _on_RigidBody2D_body_shape_entered(body_id, body, body_shape, local_shape):
	#print(body.name)
	if body.name == "WeaponBody":
		sprite.modulate = Color(1,0,0)
		#print("hit")
		yield(get_tree().create_timer(.1), "timeout")
		sprite.modulate = Color(1,1,1)
		position -= (Global.player_position - self.position).normalized() * 3
		slow = .75
		take_damage(body.attack_damage)
	pass # Replace with function body.
	
func take_damage(damage_dealt):
	sfx.play_sound(sfx.hitsounds)
	health-=damage_dealt
	#print(health)

func generate_path():
	if level_navigation != null:
		path = level_navigation.get_simple_path(rb.global_position, Global.player_position, true)
		line2d.points = path
		
func navigate(delta):
	if path.size() > 0:
		position += global_position.direction_to(path[1]).normalized() * actual_speed * delta
		if global_position == path[0]:
			path.pop_front()

func death():
	var coin = preload("res://scenes/Coin.tscn").instance()
	coin.position = position
	get_parent().add_child(coin)
	queue_free()
