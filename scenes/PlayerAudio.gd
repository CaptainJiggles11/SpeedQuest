extends Node2D

export (Array) var hitsounds
export (Array) var footsteps
export (Array) var sword_sfx
export (Array) var bow_sfx
export (Array) var staff_sfx
export (Array) var roll
export (Array) var dmg

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func play_sound(sound_name):
	var sfx = AudioStreamPlayer.new()
	add_child(sfx)
	var rand_value = randi() % sound_name.size()
	sfx.stream = sound_name[rand_value]
	sfx.play()
	yield(sfx, "finished")
	sfx.queue_free()

	
