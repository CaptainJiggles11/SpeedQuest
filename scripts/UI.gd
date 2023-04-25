extends CanvasLayer


var health = []
var prev = Global.max_hp
var old_max = Global.max_hp
onready var music = $BGM

# Called when the node enters the scene tree for the first time.
func _ready():
	
	for i in range(Global.max_hp):
		var heart = preload("res://scenes/Heart.tscn").instance()
		heart.global_position = Vector2(i*80+50, 50)
		heart.play("full")
		add_child(heart)
		health.append(heart)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Global.BGM == null:
		Global.BGM = self
	$Coins.text = str(Global.coin_count)
	$Time.text = str(Global.time)
	$Floor.text = str("Floor "+str(Global.floors.size()))
	if Global.max_hp > old_max:
		for i in range(old_max, Global.max_hp):
			var heart = preload("res://scenes/Heart.tscn").instance()
			heart.global_position = Vector2(i*80+50, 50)
			heart.play("empty")
			add_child(heart)
			health.append(heart)
		old_max = Global.max_hp
	if Global.player_health < prev:
		for i in range(prev, Global.player_health, -1):
			health[i-1].play("empty")
		prev = Global.player_health
	elif Global.player_health > prev:
		for i in range(prev, Global.player_health):
			health[i].play("full")
		prev = Global.player_health
	
