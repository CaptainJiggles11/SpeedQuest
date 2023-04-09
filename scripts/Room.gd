extends Node2D

var loaded = false
var cleared = false
var obscure 
var adjacent_rooms
var room_number
var enemies = []

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	
	obscure = $RoomCollider/Sprite
	obscure.show()
	
	
	call_deferred("reparent",$"Walls (Tangible)")
	
	for i in self.get_children():
		i.set_process(false)
	
	if $Doors != null:
		$Doors.configure(adjacent_rooms)
		
		for node in get_children():
			if node.is_in_group("Enemies"):
				enemies.append(node)
		
		if enemies.size() <= 0:
			$Doors.open_room()
		else:
			$Doors.close_room()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if loaded == true:
		if enemies != null and $Doors != null:
			if enemies.size() <= 0:
				$Doors.open_room()
				enemies = null
				cleared = true
				Global.player.speed_modifier = 1.5
				
		if obscure.modulate.a > 0:
			obscure.modulate.a -= 5 * delta
	
	else:
		if obscure.modulate.a < 1:
			obscure.modulate.a += 3 * delta

			

func set_active(): 
	loaded = true
	Global.current_room = self
	if cleared == true:
		Global.player.speed_modifier = 1.5
	else:
		Global.player.speed_modifier = 1
	for i in self.get_children():
		i.set_process(true)
		
	for room in adjacent_rooms:
		print(room)
		for blocks in Global.player.minimap.minimap_blocks:
			print(blocks.block_number)
			if blocks.block_number == room + room_number:
				blocks.seen = true
	
		
func set_inactive():
	loaded = false
	for i in self.get_children():
		i.set_process(false)
	pass
	
func reparent(node):
	node.get_parent().remove_child(node)
	get_tree().get_nodes_in_group("LevelNavigation")[0].add_child(node)
	node.position = $"Decor (Intangible)".global_position

