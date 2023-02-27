extends Node

var current_scene = null
var player_position
var coin_count
var rng = RandomNumberGenerator.new()
var coin_sfx = load("res://art/audio/sfx/coin_sfx.wav")
var timer
var time
var player_health = 3

func _ready():
	rng.randomize()
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count() - 1)
	add_test_coin()
	add_test_enemy()
	time = 10
	timer = Timer.new()
	timer.connect("timeout", self, "_on_timer_timeout")
	add_child(timer)
	timer.start()
	
	
func goto_scene(path):
	# This function will usually be called from a signal callback,
	# or some other function in the current scene.
	# Deleting the current scene at this point is
	# a bad idea, because it may still be executing code.
	# This will result in a crash or unexpected behavior.

	# The solution is to defer the load to a later time, when
	# we can be sure that no code from the current scene is running:

	call_deferred("_deferred_goto_scene", path)


func _deferred_goto_scene(path):
	# It is now safe to remove the current scene
	current_scene.free()

	# Load the new scene.
	var s = ResourceLoader.load(path)

	# Instance the new scene.
	current_scene = s.instance()

	# Add it to the active scene, as child of root.
	get_tree().root.add_child(current_scene)

	# Optionally, to make it compatible with the SceneTree.change_scene() API.
	get_tree().current_scene = current_scene


# test function
func add_test_coin():
	coin_count = 0
	for i in range(0, 10):
		var coin = preload("res://scenes/Coin.tscn").instance()
		coin.position = Vector2(rng.randi_range(-250, 250), rng.randi_range(-150, 150))
		coin.get_child(0).connect("body_shape_entered", self, "_on_get_coin")
		add_child(coin)


func _on_timer_timeout():
	time -= 1


func _on_get_coin(body_rid, body, body_shape_index, local_shape_index):
	if(body.name == "PlayerBody"):
		coin_count += 1
		var sfx = AudioStreamPlayer.new()
		sfx.stream = coin_sfx
		add_child(sfx)
		sfx.play()
		yield(sfx, "finished")
		sfx.queue_free()


# test function
func add_test_enemy():
	var enemy = preload("res://scenes/Enemy.tscn").instance()
	enemy.init("bigzombie")
	enemy.position = Vector2(-250, -150)
	add_child(enemy)
	enemy = preload("res://scenes/Enemy.tscn").instance()
	enemy.init("skeleton")
	enemy.position = Vector2(0, -150)
	add_child(enemy)
	enemy = preload("res://scenes/Enemy.tscn").instance()
	enemy.init("zombie")
	enemy.position = Vector2(250, -150)
	add_child(enemy)
	enemy = preload("res://scenes/Enemy.tscn").instance()
	enemy.init("swampy")
	enemy.position = Vector2(-250, 150)
	add_child(enemy)
	enemy = preload("res://scenes/Enemy.tscn").instance()
	enemy.position = Vector2(250, 150)
	enemy.init("chort")
	add_child(enemy)
