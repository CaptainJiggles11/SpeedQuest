extends CanvasLayer

var time_cost
var hp_cost
var dmg_cost

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$Coins.text = str(Global.coin_count)
	time_init()
	hp_init()
	dmg_init()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Start_pressed():
	Global.start_game()
	var root = get_tree().root
	root.remove_child(self)


func time_init():
	var level = (Global.max_time - 10)/5
	$TimeUpgrade/Level.text = "Level " + str(level)
	time_cost = level*5
	$TimeUpgrade/Cost.text = str(time_cost)


func hp_init():
	var level = Global.max_hp
	$HealthUpgrade/Level.text = "Level " + str(level)
	hp_cost = level*20
	$HealthUpgrade/Cost.text = str(hp_cost)


func dmg_init():
	print(Global.player_damage)
	var level = Global.player_damage
	$DmgUpgrade/Level.text = "Level " + str(level)
	dmg_cost = level*50
	$DmgUpgrade/Cost.text = str(dmg_cost)
	

func _on_TimeUpgrade_pressed():
	if Global.coin_count >= time_cost:
		Global.coin_count -= time_cost
		Global.max_time += 5
		$Coins.text = str(Global.coin_count)
		time_init()
	else:
		print("error")


func _on_HealthUpgrade_pressed():
	if Global.coin_count >= hp_cost:
		Global.coin_count -= hp_cost
		Global.max_hp += 1
		$Coins.text = str(Global.coin_count)
		hp_init()
	else:
		print("error")


func _on_DmgUpgrade_pressed():
	if Global.coin_count >= dmg_cost:
		Global.coin_count -= dmg_cost
		Global.player_damage += 1
		$Coins.text = str(Global.coin_count)
		dmg_init()
	else:
		print("error")
