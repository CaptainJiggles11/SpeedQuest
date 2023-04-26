extends Node2D

#Boss Stats
export (float) var health = 3.0
export (float) var speed = 50.0
export (int) var damage = 1
export (int) var projectile_damage = 1
var actual_speed
var slow = 1
var fight_start = false

#Boss States
enum attack_type {idle,up,fire,shoot,radial, burst}
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
var wait = false
var hovering = false
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
	health = 50
	sprite.animation = "dragon_idle"
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if fight_start == false and Global.BGM != null:
		Global.BGM.stop()
		fight_start = true
		yield(get_tree().create_timer(1), "timeout")
		Global.BGM.stream = load("res://art/audio/music/SpeedQuest - (BOSS 1).wav")
		Global.BGM.play()
		
		
	if health <= 0:
		death()
	
	actual_speed = speed * slow
	if slow < 1:
		slow+= delta

	if global_position.x < Global.player_position.x:
		sprite.flip_h = false
	else:
		sprite.flip_h = true
	
	#print(wait, timer)
	if wait == false:
		if timer > 0:
			timer-=delta
			global_position += (Global.player_position - global_position).normalized() * actual_speed * delta
			sprite.animation = "dragon_walk"
		else:
			match my_attack:
				0: #Idle
					wait = true
					idle()
					
				1: #up
					if health <= 10:
						wait = true
						#idle()
						up()
					else:
						choose_attack()
					
				2: #Fire
					wait = true
					#idle()
					fire()
					
				3: #Hellfire
					choose_attack()
					#hellfire()
					
				4: #Radial
					wait = true
					#idle()
					radial()
					
				5: #Burst
					wait = true
					#idle()
					burst()
				


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
		take_damage(Global.player_damage * .5)
		sprite.modulate = Color(1,1,1)
		position -= (Global.player_position - self.position).normalized() * 3
		slow = .5

func take_damage(damage_dealt):
	print(damage_dealt)
	sfx.play_sound(sfx.hitsounds)
	health-=damage_dealt

func death():
	set_process(false)
	rb.CS.disabled = true
	sprite.animation = "dragon_death"
	yield(sprite,"animation_finished")
	
	Global.BGM.stop()
	get_parent().get("enemies").erase(self)
	var heart = preload("res://scenes/Heart_Container.tscn").instance()
	heart.position = position
	var new_stair = preload("res://scripts/Stair.tscn").instance()
	new_stair.position = position + Vector2(0,-30)
	get_parent().add_child(new_stair)
	get_parent().add_child(heart)
	queue_free()

func shoot(direction = (Global.player_position - global_position).normalized(), shootPos = global_position + (Global.player_position - global_position).normalized() * 10):
	var new_projectile = projectile.instance()
	new_projectile.set("friendly", false)
	new_projectile.set("attack_damage", projectile_damage)
	new_projectile.set("provided_velocity", direction)
	new_projectile.set("start_pos", shootPos)
	add_child(new_projectile)
	return new_projectile

func choose_attack():
	my_attack = null
	while my_attack == null:
		randomize()
		my_attack = attack_type.values()[ randi()%attack_type.size() ]
		if health <= 10 and rand_range(0,1) >= .5:
			my_attack = 1
	return my_attack

func idle():
	var thang = rand_range(1, 2)
	yield(get_tree().create_timer(thang), "timeout")

	randomize()
	choose_attack()
	timer = 0
	wait = false
	
func up():
	if hovering == false:
		sprite.animation = "dragon_launch"
		yield(sprite,"animation_finished")
		rb.CS.set_deferred("disabled",true)
		sprite.uptwo(Vector2(0,-40), .5)
		sprite.animation = "dragon_hover"
		hovering = true
		yield(get_tree().create_timer(1), "timeout")
		hellfire()



func hellfire():
	var tween := create_tween().set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(sprite, "modulate", Color(1,0,0), 1)
	yield(sprite,"animation_finished")
	sprite.modulate = Color(1,1,1)
	
	for _y in range(3,6):
		randomize()
		var wrange = rand_range(1.5,2)
		for _x in range(256):
			randomize()
			var new_projectile = shoot(Vector2.ZERO,global_position + Vector2(rand_range(-300,300),rand_range(-300,300)))
			new_projectile.CS.set_deferred("disabled",true)
			new_projectile.shadow.position = new_projectile.shadow.position + Vector2(0,-4)
			new_projectile.height = rand_range(30,80)
			new_projectile.fall_speed = (rand_range(10,50))
			new_projectile.use_sprite.animation = "fire"
			new_projectile.use_sprite.frame = int(rand_range(0,3))
			new_projectile.CS.scale *= int(rand_range(3,5))
		
		var stween := create_tween().set_trans(Tween.TRANS_LINEAR)	
		stween.tween_property(sprite, "modulate", Color(1,0,0), wrange)
		yield(get_tree().create_timer(wrange), "timeout")
		sprite.modulate = Color(1,1,1)
		
	yield(get_tree().create_timer(1), "timeout")
	
	sprite.animation = "dragon_land"
	sprite.downtwo(Vector2(0,40), 1)
	yield(get_tree().create_timer(1), "timeout")
	rb.CS.set_deferred("disabled",false)
	hovering = false
	randomize()
	choose_attack()
	timer = rand_range(5,7)
	wait = false



func fire():
	var shoot_angle = Vector2.UP

	sprite.animation = "dragon_firestart"
	var tween := create_tween().set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(sprite, "modulate", Color(1,1,1), 1)
	yield(sprite,"animation_finished")
	sprite.modulate = Color(1,1,1)
	sprite.animation = "dragon_fire"
	
	for _x in range(128):
		randomize()
		var strange = rand_range(64,128)
		var wrange = rand_range(.01,.03)
		var new_projectile = shoot(shoot_angle.normalized(),global_position + shoot_angle)
		new_projectile.use_sprite.animation = "fire"
		new_projectile.CS.scale *= 4
		shoot_angle = shoot_angle.rotated(deg2rad(strange))
		yield(get_tree().create_timer(wrange), "timeout")
	randomize()
	choose_attack()
	sprite.animation = "dragon_firestop"
	timer = rand_range(2,3)
	wait = false

func burst():
	sprite.animation = "dragon_firestart"
	var tween := create_tween().set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(sprite, "modulate", Color(1,0,0), 1)
	yield(sprite,"animation_finished")
	sprite.modulate = Color(1,1,1)
	sprite.animation = "dragon_fire"
	
	for _y in range(1,4):
		var wrange = rand_range(1.5,2)
		var shoot_angle = Vector2.UP
		for _x in range(127):
			randomize()
			var new_projectile = shoot(shoot_angle.normalized() * rand_range(.5,1.5),global_position + shoot_angle)
			new_projectile.use_sprite.animation = "fire"
			new_projectile.use_sprite.frame = int(rand_range(0,3))
			new_projectile.CS.scale *= 4
			shoot_angle = shoot_angle.rotated(deg2rad(15/4))
		
		var stween := create_tween().set_trans(Tween.TRANS_LINEAR)	
		stween.tween_property(sprite, "modulate", Color(1,0,0), wrange)
		yield(get_tree().create_timer(wrange), "timeout")
		sprite.modulate = Color(1,1,1)
		
	randomize()
	choose_attack()
	sprite.animation = "dragon_firestop"
	timer = rand_range(3,5)
	wait = false

func radial():
	sprite.animation = "dragon_firestart"
	var tween := create_tween().set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(sprite, "modulate", Color(0,0,1), 1)
	yield(sprite,"animation_finished")
	sprite.modulate = Color(1,1,1)
	sprite.animation = "dragon_fire"
	
	for _y in range(1,8):
		randomize()
		var rvel = rand_range(.25,1)
		var wrange = rand_range(.5,1)
		var shoot_angle = Vector2.UP
		for _x in range(127):
			randomize()
			var new_projectile = shoot(shoot_angle.normalized() * rvel,global_position + shoot_angle)
			new_projectile.use_sprite.animation = "fire"
			new_projectile.use_sprite.frame = int(rand_range(0,3))
			new_projectile.CS.scale *= 4
			shoot_angle = shoot_angle.rotated(deg2rad(15/4))
			
		yield(get_tree().create_timer(wrange), "timeout")
		
	randomize()
	choose_attack()
	sprite.animation = "dragon_firestop"
	timer = rand_range(1,3)
	wait = false
	

