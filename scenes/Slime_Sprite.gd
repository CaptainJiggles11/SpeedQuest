extends AnimatedSprite

var og_scale = scale
var enter_anim = false
var jump_end = Vector2.ZERO
var power = 1
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func squash(squash_scale, speed):
	scale = squash_scale
	var tween := create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", og_scale, speed*power)
		
func up():
	var tween := create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "global_position", global_position + Vector2(0,-45), 0.05)
	squash(Vector2(.75,1.5), .5)
	tween.tween_property(self, "global_position", global_position + Vector2(0,-50), 0.25)

func down():
	var tweenn := create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	animation = "slime_fall"
	tweenn.tween_property(self, "global_position", jump_end, 0.2)
