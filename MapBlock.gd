extends Sprite
var block_number = Vector2.ZERO
var visited = false
var seen = false
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	modulate = Color(1,1,1,0)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if weakref(Global.current_room).get_ref():
		if Global.current_room.room_number == block_number:
			modulate = Color(1,0,0)
			visited = true
			seen = true
		elif seen == true and visited == false:
			modulate = Color(.5,.5,.5,1)
		elif visited == true:
			modulate = Color(1,1,1)
