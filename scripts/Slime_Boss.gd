extends Node2D

#Boss Stats
export (float) var health = 3.0
export (float) var speed = 50.0
export (int) var damage = 1
export (int) var projectile_damage = 1
var actual_speed
var slow = 1

#Boss States
enum attack_type {idle,radial,burst,follow}
export (attack_type) var my_attack = attack_type.idle
export (bool) var passable = false
var jumping = false
#Boss Setup
var rb
var sprite
var sfx
var path: Array = []
var level_navigation: Navigation2D = null
export (PackedScene) var projectile
var timer = 2
var jump_dir = Vector2.ZERO
var moving = false
var collision
var fight_start = false
export (PackedScene) var stair

onready var line2d = $Line2D


# Called when the node enters the scene tree for the first time.
func _ready():
	rb = $BossBody
	sprite = $BossBody/Sprite
	sfx = $BossBody/BossAudio
	collision = $BossBody/CollisionShape2D
	yield(get_tree(), "idle_frame")
	
	speed = 30
	health = 30
	sprite.animation = "slime_idle"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if fight_start == false:
		fight_start = true
		Global.BGM.stop()
		yield(get_tree().create_timer(1), "timeout")
		Global.BGM.stream = load("res://art/audio/music/SpeedQuest - (BOSS 1).wav")
		Global.BGM.play()
	
	level_navigation = get_parent().get_node("LevelNavigation")
	line2d.global_position = Vector2.ZERO
	if health <= 0:
		death()
	
	actual_speed = speed * slow
	if slow < 1:
		slow+= delta
	
	match my_attack:
		0: #Idle
			if timer >= 0:
				timer-=delta
			else:
				randomize()
				choose_attack()
				
		1: #Radial
			choose_attack()
		2: #Burst
			if timer <= 0:
				burst()
			else:
				timer -= delta
		3: #Follow:
			if timer <= 0:
				var rand = rand_range(.5,1)
				if jumping == false:
					var _jump_start = global_position
					var og_scale = sprite.scale
					jump_dir = (Global.player_position - global_position).normalized()
					sprite.power = rand
					var jump_end = Global.player_position
					sprite.jump_end = jump_end
					sprite.animation = "slime_jump"
					jumping = true
					collision.disabled = true
					yield(sprite,"animation_finished")
					moving = true
					sprite.scale = og_scale
					sprite.animation = "slime_airborne"
					sprite.up()
					yield(get_tree().create_timer(rand), "timeout")
					sprite.down()
					yield(sprite,"animation_finished")
					radial()
					sprite.animation = "slime_stunned"
					sprite.squash(Vector2(1.2,.8), .5)
					yield(get_tree().create_timer(rand/1.5), "timeout")
					jumping = false
					moving = false
					collision.disabled = false
					timer = rand

	
				else:
					if sprite.frame == 2 and sprite.animation == "slime_jump":
						sprite.scale = Vector2(.8,1.2)
						sprite.moving = true
					if sprite.frame == 0 and sprite.animation == "slime_fall":
						sprite.scale = Vector2(.8,1.2)
					if moving == true:
						global_position = global_position.linear_interpolate(sprite.jump_end,.2)
					
			else:
				timer -= delta

func _on_RigidBody2D_body_shape_entered(_body_id, body, _body_shape, _local_shape):

	if body.name == "WeaponBody":
		sprite.modulate = Color(1,0,0)
		yield(get_tree().create_timer(.1), "timeout")
		sprite.modulate = Color(1,1,1)
		position -= (Global.player_position - self.position).normalized() * 3
		slow = .75
		take_damage(body.attack_damage)
		
	if "Projectile" in body.name and body.friendly == true:
		sprite.modulate = Color(1,0,0)
		yield(get_tree().create_timer(.1), "timeout")
		take_damage(Global.player_damage)
		sprite.modulate = Color(1,1,1)
		position -= (Global.player_position - self.position).normalized() * 3
		slow = .5

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
	Global.BGM.stop()
	get_parent().get("enemies").erase(self)
	var heart = preload("res://scenes/Heart_Container.tscn").instance()
	heart.position = position
	var new_stair = preload("res://scripts/Stair.tscn").instance()
	new_stair.position = position + Vector2(0,-30)
	get_parent().add_child(new_stair)
	get_parent().add_child(heart)
	queue_free()

func shoot(direction = (Global.player_position - global_position).normalized(), shootPos = position + (Global.player_position - global_position).normalized() * 10):
	var new_projectile = projectile.instance()
	new_projectile.set("friendly", false)
	new_projectile.set("attack_damage", projectile_damage)
	new_projectile.set("provided_velocity", direction)
	new_projectile.set("start_pos", shootPos)
	get_parent().add_child(new_projectile)
	new_projectile.use_sprite.animation = "slimeball"
	return new_projectile

func choose_attack():
	my_attack = attack_type.values()[ randi()%attack_type.size() ]

func burst():
	timer = 100
	sprite.animation = "slime_charge"
	sprite.squeeze(Vector2(.9,1.5),.5)
	yield(sprite,"animation_finished")
	sprite.animation = "slime_shoot"
	yield(sprite,"animation_finished")
	sprite.animation = "slime_idle"
	sprite.squash(Vector2(1.2,.8),.25)
	var _shoot_angle = Vector2.UP
	for _x in range(64):
		var ran = rand_range(.75,1.5)
		randomize()
		var new_projectile = shoot((Global.player_position - rb.global_position).normalized()*rand_range(0,1) + Vector2(rand_range(-.4,.4),rand_range(-.4,.4)), rb.global_position )
		new_projectile.get_child(0).scale = Vector2(ran,ran)
	randomize()
	choose_attack()
	timer = rand_range(2,3)

func radial():
	Global.player.player_cam.add_trauma(.2)
	var shoot_angle = Vector2.UP
	for _x in range(128):
		shoot(shoot_angle.normalized(),global_position + shoot_angle)
		shoot_angle = shoot_angle.rotated(deg2rad(15/4))
	randomize()
	choose_attack()
	timer = rand_range(3,5)

