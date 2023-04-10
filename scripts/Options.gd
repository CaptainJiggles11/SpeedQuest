extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$VBoxContainer/Music.pressed = not Global.muted
	$VBoxContainer/Sounds.pressed = not Global.muted_sfx
	$VBoxContainer/MusicSlider.value = 100
	$VBoxContainer/SoundSlider.value = 100


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Back_pressed():
	var root = get_tree().root
	root.remove_child(self)


func _on_Music_pressed():
	Global.muted = not Global.muted
	AudioServer.set_bus_mute(1, Global.muted)


func _on_Sounds_pressed():
	Global.muted_sfx = not Global.muted_sfx
	AudioServer.set_bus_mute(2, Global.muted_sfx)


func _on_MusicSlider_drag_ended(value_changed):
	var vol = $VBoxContainer/MusicSlider.value
	if vol == 0:
		vol = 10000000
	AudioServer.set_bus_volume_db(1, -pow((100-vol),2)/300)


func _on_SoundSlider_drag_ended(value_changed):
	var vol = $VBoxContainer/SoundSlider.value
	if vol == 0:
		vol = 10000000
	AudioServer.set_bus_volume_db(2, -pow((100-vol),2)/300)
