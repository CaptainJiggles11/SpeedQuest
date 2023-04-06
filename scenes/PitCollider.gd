extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_PitCollider_body_entered(body):
	if body.name == ("Hazards (Tangible)"):
		#print(body.get_cell(position.x,position.y))
		match body.get_cell(position.x,position.y):
			-1:
				get_parent().get_parent().reset = true
				get_parent().reset_pos = get_parent().get_parent().grounded_pos -get_parent().linear_velocity.normalized() * 15
			3:
				get_parent().get_parent().reset = true
				get_parent().reset_pos = get_parent().get_parent().grounded_pos -get_parent().linear_velocity.normalized() * 15
				
