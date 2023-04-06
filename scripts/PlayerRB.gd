extends RigidBody2D
var reset_pos = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _integrate_forces(state):
	var reset = get_owner().get("reset")
	if reset == true:
		state.transform.origin = reset_pos
		get_owner().set("reset", false)
		print(reset_pos)
	
	var move_player = get_owner().get("move_player")
	if move_player != null:
		state.transform.origin += move_player
		get_owner().set("move_player", null)
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
