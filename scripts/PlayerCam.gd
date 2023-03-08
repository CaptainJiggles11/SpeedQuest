extends Camera2D
export(float) var camera_range = 10
var look_direction = Vector2(0,0)
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var player_pos = Global.player_position
	
	print(look_direction)
#	position = Vector2(player_pos.x,player_pos.y) + Vector2( mouse_pos.x - get_viewport_rect().size.x/2 , mouse_pos.y - get_viewport_rect().size.y/2)/camera_range
	position = Vector2(player_pos.x,player_pos.y) + Vector2( look_direction.x - get_viewport_rect().size.x/2 , look_direction.y - get_viewport_rect().size.y/2)/camera_range
	
