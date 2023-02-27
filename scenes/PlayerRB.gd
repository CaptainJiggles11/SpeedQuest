extends RigidBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _integrate_forces(state):
	var reset = get_owner().get("reset")
	if reset == true:
		state.transform.origin = Vector2.ZERO
		print("resetted")
		get_owner().set("reset", false)
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
