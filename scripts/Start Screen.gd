extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready():
	print("start")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Exit_pressed():
	get_tree().quit()


func _on_Start_pressed():
	Global.start_game()
