extends Node

var current_scene = null
var player_position
var coin_count = 0
var rng = RandomNumberGenerator.new()
var coin_sfx = load("res://art/audio/sfx/coin_sfx.wav")
var timer
var time
var player_health
var level = null
var alive = false
var player = null
var current_room = null
var floors = []
var BGM
var muted = false
var muted_sfx = false

var paused = false
var options_open = false

# Upgrades
var max_time = 120
var max_hp = 3
var player_damage = 1



func _ready():
	rng.randomize()
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count() - 1)
	time = max_time
	player_health = max_hp
	if timer != null:
		timer.disconnect("timeout", self, "_on_timer_timeout")
	timer = Timer.new()
	timer.connect("timeout", self, "_on_timer_timeout")
	add_child(timer)
	timer.start()
	
func _process(_delta):
	if is_instance_valid(current_room):
		pass
		
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
	for _i in range(0, 10):
		var coin = preload("res://scenes/Coin.tscn").instance()
		coin.position = Vector2(rng.randi_range(-250, 250), rng.randi_range(-150, 150))
		coin.get_child(0).connect("body_shape_entered", self, "_on_get_coin")
		add_child(coin)


func _on_timer_timeout():
	if alive and not paused:
		time -= 1
		if time == -1:
			open_shop()
	#print(time)


func _on_get_coin(the_coin):
	the_coin.queue_free()
	coin_count += 1
	var sfx = AudioStreamPlayer.new()
	sfx.bus = "SFX"
	sfx.stream = coin_sfx
	add_child(sfx)
	sfx.volume_db = -5
	sfx.play()
	yield(sfx, "finished")
	sfx.queue_free()
	
func _on_get_heart(heart):
	heart.queue_free()
	max_hp += 1
	player_health += 1
	var sfx = AudioStreamPlayer.new()
	sfx.bus = "SFX"
	sfx.stream = load("res://art/audio/sfx/heart_pickup.wav")
	add_child(sfx)
	sfx.volume_db = -5
	sfx.play()
	yield(sfx, "finished")
	sfx.queue_free()
		

func open_shop():
	alive = false
	goto_scene("res://scenes/Shop.tscn")

func pause():
	alive = false
	goto_scene("res://scenes/Pause Menu.tscn")
	
func start_game():
	floors = []
	alive = true
	time = max_time
	player_health = max_hp
	goto_scene("res://scenes/ROOMS/Level 1.tscn")
	floors.append(get_node("Level 1"))
	
func options():
	get_tree().root.add_child(ResourceLoader.load("res://scenes/Options.tscn").instance())

func next_floor():
	if floors.size() <= 2:
		time += max_time + 20
		var next_level = goto_scene("res://scenes/ROOMS/Level 1.tscn")
		floors.append(next_level)
	else:
		goto_scene("res://scenes/Game Over.tscn")
