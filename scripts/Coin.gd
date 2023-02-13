extends Node2D

var sprite


# Called when the node enters the scene tree for the first time.
func _ready():
	sprite = get_node("Area2D/AnimatedSprite")
	sprite.animation = "spin"
	sprite.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

