extends Node

var current_scene = null

var player_position

var coin_count

var rng = RandomNumberGenerator.new()

func _ready():
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count() - 1)
	add_test_coin()
	
func _process(delta):
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


func add_test_coin():
	coin_count = 0
	for i in range(0, 10):
		print(i)
		var coin = preload("res://scenes/Coin.tscn").instance()
		coin.position = Vector2(rng.randi_range(-250, 250), rng.randi_range(-150, 150))
		coin.z_index = 1
		coin.get_child(0).connect("body_shape_entered", self, "_on_get_coin")
		add_child(coin)


func _on_get_coin(body_rid, body, body_shape_index, local_shape_index):
	if(body.name == "PlayerBody"):
		print("got coin")
		coin_count += 1
	else:
		print("not player")
