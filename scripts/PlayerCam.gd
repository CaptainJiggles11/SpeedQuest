extends Camera2D
export(float) var camera_range = 10

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var mouse_pos = get_viewport().get_mouse_position()
	var player_pos = Global.player_position
	
	position = Vector2(player_pos.x,player_pos.y) + Vector2( mouse_pos.x - get_viewport_rect().size.x/2 , mouse_pos.y - get_viewport_rect().size.y/2)/camera_range
	
