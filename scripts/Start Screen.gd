extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready():
	print(get_tree().root.get_child(0))
	AudioServer.add_bus(1)
	AudioServer.set_bus_name(1, "Music")
	AudioServer.add_bus(2)
	AudioServer.set_bus_name(2, "SFX")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Exit_pressed():
	get_tree().quit()


func _on_Start_pressed():
	Global.start_game()
	var root = get_tree().root
	root.remove_child(self)


func _on_Options_pressed():
	Global.options()
