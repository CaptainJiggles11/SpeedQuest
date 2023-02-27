extends Node2D

var cleared = false
var tree 
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	tree = get_tree()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if tree.has_group("Enemies"):
		pass
	else:
		cleared = true
