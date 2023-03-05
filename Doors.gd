extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func configure(adjacent):
	if !adjacent.has(Vector2(0,-1)):
		$"North Door".queue_free()
	if !adjacent.has(Vector2(0,1)):
		$"South Door".queue_free()
	if !adjacent.has(Vector2(1,0)):
		$"East Door".queue_free()
	if !adjacent.has(Vector2(-1,0)):
		$"West Door".queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
