extends Node2D

var loaded = false
var cleared = false

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	

	for i in self.get_children():
		i.set_process(false)
		
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
		
func set_active(): 
	for i in self.get_children():
		i.set_process(true)
		
func set_inactive():
	
	for i in self.get_children():
		i.set_process(false)
	pass
		
	
