extends RigidBody2D
var reset_pos = Vector2.ZERO
var stop = false
var og_scale = scale
onready var CS = get_node("CollisionShape2D")
var tween = null
var falling = false
# Called when the node enters the scene tree for the first time.
func _ready():

	pass # Replace with function body.

func _integrate_forces(state):
	var reset = get_owner().get("reset")
	if reset == true:
		if tween != null:
			tween.stop()
		state.transform.origin = reset_pos
		get_owner().set("reset", false)
		print(reset_pos)
	
	var move_player = get_owner().get("move_player")
	if move_player != null:
		state.transform.origin += move_player
		get_owner().set("move_player", null)
	
	if stop == true:
		linear_velocity = Vector2.ZERO
		stop = false

func spin():
	disable_collision()
	tween = create_tween().set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(self, "scale", Vector2.ZERO, .5)
	var stween = create_tween().set_trans(Tween.TRANS_LINEAR)
	stween.tween_property(self, "rotation_degrees", 360 , .5)

func disable_collision():
	falling = true
	set_collision_layer_bit(0,false)
	set_collision_mask_bit(0,false)
	set_collision_layer_bit(1,false)
	set_collision_layer_bit(2,false)
	set_collision_layer_bit(3,false)
	
func enable_collision():
	falling = false
	rotation_degrees = 0
	set_collision_layer_bit(0,true)
	set_collision_mask_bit(0,true)
	set_collision_layer_bit(1,true)
	set_collision_layer_bit(2,true)
	set_collision_layer_bit(3,true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
