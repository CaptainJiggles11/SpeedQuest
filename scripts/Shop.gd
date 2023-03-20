extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Start_pressed():
	Global.alive = true
	Global.time = 10
	Global.player_health = 3
	var root = get_tree().root
	root.remove_child(self)
	Global.goto_scene("res://scenes/ROOMS/Level.tscn")
