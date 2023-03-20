extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var adjacent_rooms = []


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func configure(adjacent):
	if adjacent != null:
		if !adjacent.has(Vector2(0,-1)):
			$"North Door".queue_free()
		if !adjacent.has(Vector2(0,1)):
			$"South Door".queue_free()
		if !adjacent.has(Vector2(1,0)):
			$"East Door".queue_free()
		if !adjacent.has(Vector2(-1,0)):
			$"West Door".queue_free()
			
		for door in get_children():
				adjacent_rooms.append(door)
	
func close_room():
	for door in adjacent_rooms:
		if weakref(door).get_ref():
			remove_child(door)
	
func open_room():
	for door in adjacent_rooms:
		if weakref(door).get_ref():
			add_child(door)

# Called every frame. 'delta' is the elapsed time since the previous frame.
