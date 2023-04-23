extends Camera2D
export(float) var camera_range = 10.0
var look_direction = Vector2(0,0)
export var decay = 0.8  # How quickly the shaking stops [0, 1].
export var max_offset = Vector2(100, 75)  # Maximum hor/ver shake in pixels.
export var max_roll = 0.1  # Maximum rotation in radians (use sparingly).

var trauma = 0.0  # Current shake strength.
var trauma_power = 2  # Trauma exponent. Use [2, 3].
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var player_pos = Global.player_position
	
	position = Vector2(player_pos.x,player_pos.y) + Vector2( look_direction.x - get_viewport_rect().size.x/2 , look_direction.y - get_viewport_rect().size.y/2)/camera_range
	
	if trauma:
		trauma = max(trauma - decay * delta, 0)
		shake()
	
func add_trauma(amount):
	trauma = min(trauma + amount, 1.0)

func shake():
	var amount = pow(trauma, trauma_power)
	rotation = max_roll * amount * rand_range(-1, 1)
	offset.x = max_offset.x * amount * rand_range(-1, 1)
	offset.y = max_offset.y * amount * rand_range(-1, 1)
