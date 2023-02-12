extends Camera2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var mouse_pos = get_viewport().get_mouse_position()
	var player_pos = get_node("/root/Global").player_position
	
	#position = Vector2(player_pos.x - mouse_pos.x, player_pos.y - mouse_pos.y)
	position = Vector2(player_pos.x,player_pos.y) + Vector2( mouse_pos.x - get_viewport_rect().size.x/2 , mouse_pos.y - get_viewport_rect().size.y/2)/2
	pass
