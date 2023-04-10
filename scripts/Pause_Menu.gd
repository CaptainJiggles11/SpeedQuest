extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("pause") and not Global.options_open:
		_on_Resume_pressed()


func _on_Resume_pressed():
	var root = get_tree().root
	root.remove_child(self)
	root.get_child(root.get_child_count()-1).get_child(3).visible = true
	root.get_child(root.get_child_count()-1).get_child(1).get_child(3).visible = true
	Global.paused = false


func _on_Options_pressed():
	get_tree().root.add_child(ResourceLoader.load("res://scenes/Options.tscn").instance())
	Global.options_open = true


func _on_Exit_pressed():
	var root = get_tree().root
	while root.get_child_count() > 1:
		root.remove_child(root.get_child(1))

	root.add_child(ResourceLoader.load("res://scenes/Start Screen.tscn").instance())
	
	Global.current_scene = null
	Global.coin_count = 0
	Global.rng = RandomNumberGenerator.new()
	Global.coin_sfx = load("res://art/audio/sfx/coin_sfx.wav")
	Global.player_health
	Global.level = null
	Global.alive = false
	Global.player = null
	Global.current_room = null
	Global.floors = []

	Global.muted = false
	Global.muted_sfx = false

	Global.paused = false
	Global.options_open = false

	# Upgrades
	Global.max_time = 120
	Global.max_hp = 3
	Global.player_damage = 1
	
	Global._ready()
