extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var size = 7
var room_offset = 510
export(Array, PackedScene) var rooms

# Called when the node enters the scene tree for the first time.
func _ready():
	generate_floor(generate_map())
	
	
	pass # Replace with function body.

func generate_floor(map):
	for x in range(size):
		for y in range(size):
			if map[x][y] == 1:
				var new_room = rooms[0].instance()
				new_room.position = Vector2(room_offset*(x-size/2),room_offset*(y-size/2))
				self.add_child(new_room)
	
	
	
func generate_map():
	var rng = RandomNumberGenerator.new()
	var matrix = []
	for x in range(size):
		matrix.append([])
		for y in range(size):
			matrix[x].append(0)
	
	#matrix[vertical][horizontal] 
	#Vert: +/DOWN -/UP | Horiz: +/RIGHT -/LEFT
	matrix[size/2][size/2] = 1
	
	for z in range(5):	
		for x in range(size):
			for y in range(size):
				if matrix[x][y] == 1:
					var next_room = null
					while next_room == null or x+next_room[0] > size-1 or y+next_room[1] > size-1:
						randomize()
						next_room = choose([[0,1],[0,-1],[-1,0],[1,0],[0,0]])
						
					matrix[x+next_room[0]][y+next_room[1]] = 1
	return matrix

func choose(array):
	return array[randi() % array.size()]
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
