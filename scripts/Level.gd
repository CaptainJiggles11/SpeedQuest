extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var size = 10
var room_offset = 510
var generate_room_amount = 7
var instanced_rooms = []

export(Array, PackedScene) var rooms
export(PackedScene) var boss_room
export(PackedScene) var start_room
export(PackedScene) var treasure_room

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.level = self
	get_tree().root.add_child(self)
	var map = null

	while map == null:
		map = generate_map(generate_room_amount)

	generate_floor(map)
	
	

func generate_floor(map): #Actually fills the world with level nodes.
	
	for x in range(size):
		for y in range(size):
			match map[x][y]:
				
				99: #Replace with Start Room
					var new_room = start_room.instance()
					instanced_rooms.append(new_room)
					new_room.position = Vector2(room_offset*(x-size/2),room_offset*(y-size/2))
					new_room.set("adjacent_rooms", get_adjacent(map,Vector2(x,y)))
					new_room.set("room_number", Vector2(x,y))
					self.add_child(new_room)
					
					$Player/Minimap.add_block(Vector2(x,y), Color(.5,.5,.5,1))
					
				1: #Normal Room
					var new_room = choose(rooms).instance()
					instanced_rooms.append(new_room)
					new_room.position = Vector2(room_offset*(x-size/2),room_offset*(y-size/2))
					new_room.set("adjacent_rooms", get_adjacent(map,Vector2(x,y)))
					new_room.set("room_number", Vector2(x,y))
					self.add_child(new_room)
					
					$Player/Minimap.add_block(Vector2(x,y), Color(.5,.5,.5,1))
					
				2: #Treasure Room
					var new_room = treasure_room.instance()
					instanced_rooms.append(new_room)
					new_room.position = Vector2(room_offset*(x-size/2),room_offset*(y-size/2))
					new_room.set("adjacent_rooms", get_adjacent(map,Vector2(x,y)))
					new_room.set("room_number", Vector2(x,y))
					self.add_child(new_room)
					
					$Player/Minimap.add_block(Vector2(x,y), Color(1,1,0,1))
					
					
				3: #Boss Room
					var new_room = boss_room.instance()
					instanced_rooms.append(new_room)
					new_room.position = Vector2(room_offset*(x-size/2),room_offset*(y-size/2))
					new_room.set("adjacent_rooms", get_adjacent(map,Vector2(x,y)))
					new_room.set("room_number", Vector2(x,y))
					self.add_child(new_room)
					
					$Player/Minimap.add_block(Vector2(x,y), Color(1,0,1,1))

func generate_map(room_number): #Roughly fills matrix with normal rooms that originate from the start room.
	var rng = RandomNumberGenerator.new()
	var matrix = []
	for x in range(size):
		matrix.append([])
		for y in range(size):
			matrix[x].append(0)
	
	#matrix[vertical][horizontal] 
	#Vert: +/DOWN -/UP | Horiz: +/RIGHT -/LEFT
	matrix[size/2][size/2] = 99
	print(size/2)
	
	var room_count = 0
	while room_count < room_number:
		var room_things = []
		for x in range(size):
			for y in range(size):
				if matrix[x][y] != 0:
					room_things.append(Vector2(x,y))
					var next_room = null
					#Makes sure the next room is placed within grid size.
					while next_room == null or x+next_room[0] > size-1 or y+next_room[1] > size-1: 
						randomize()
						next_room = choose([[0,1],[0,-1],[-1,0],[1,0]]) #Chooses a cardinal direction.
						if x+next_room[0] < size-1 and x+next_room[0] > 0 and y+next_room[1] < size-1 and y+next_room[1] > 0: #Super messy way of me preventing out of index crashes.
							if matrix[x+next_room[0]][y+next_room[1]] == 0:
								matrix[x+next_room[0]][y+next_room[1]] = 1 #Places a room (1) in the map (matrix).
								room_count+=1
							else:
								next_room = null
					if room_count > room_number:
						return fix_map(matrix)
					break
	return fix_map(matrix)

func fix_map(matrix): #Irons out map irregularities and places special rooms.
	var potential_boss_rooms = []
	
	for x in range(size-1):
		for y in range(size-1):
			if matrix[x][y] == 1:
				#If a room touches four others, delete it.
				if get_adjacent(matrix,Vector2(x,y)).size() + get_diagonal(matrix,Vector2(x,y)).size() >= 7:
					matrix[x][y] = 0
					
				#If a room only has one neighbor, it's a potential boss room.
				var potential_room = get_adjacent(matrix,Vector2(x,y))
				if potential_room.size() == 1:
					if matrix[x+potential_room[0].x][y+potential_room[0].y] == 1:
						potential_boss_rooms.append(Vector2(x,y))

	#print("boss rooms:", potential_boss_rooms.size())
	
	if potential_boss_rooms.size() <= 1:
		return null
	else:
		#Imma look into a pathfinding algorithm, currently picks a random isolated room to be boss/treasure room.
		#Change this to find_furthest_room
		var pick_room = choose(potential_boss_rooms)
		potential_boss_rooms.remove(potential_boss_rooms.find(pick_room))
		matrix[pick_room.x][pick_room.y] = 3
		
		#Change this to find_closest_room 
		pick_room = choose(potential_boss_rooms)
		potential_boss_rooms.remove(potential_boss_rooms.find(pick_room))
		matrix[pick_room.x][pick_room.y] = 2
		return matrix

func get_adjacent(matrix,current_room): #Slighty Evil
	var adjacent_rooms = []
	
	if current_room.x+1 < size-1:
		if matrix[current_room.x+1][current_room.y] != 0:
			adjacent_rooms.append(Vector2(1,0))
			
	if current_room.x-1 > 0:
		if matrix[current_room.x-1][current_room.y] != 0:
			adjacent_rooms.append(Vector2(-1,0))
			
	if current_room.y+1 < size-1:
		if matrix[current_room.x][current_room.y+1] != 0:
			adjacent_rooms.append(Vector2(0,1))
			
	if current_room.y-1 > 0:
		if matrix[current_room.x][current_room.y-1] != 0:
			adjacent_rooms.append(Vector2(0,-1))
			

	return adjacent_rooms

func get_diagonal(matrix,current_room): #Extremely Evil.
	var diagonal_rooms = []
	
	if current_room.y+1 < size-1:
		if current_room.x+1 < size-1:
			if matrix[current_room.x+1][current_room.y+1] != 0:
				diagonal_rooms.append(Vector2(1,0))
		if current_room.x-1 > 0:
			if matrix[current_room.x-1][current_room.y+1] != 0:
				diagonal_rooms.append(Vector2(-1,0))
	
	if current_room.y-1 > 0:
		if current_room.x+1 < size-1:
			if current_room.y+1 < size-1:
				if matrix[current_room.x+1][current_room.y-1] != 0:
					diagonal_rooms.append(Vector2(0,1))
		if current_room.x-1 > 0:
			if current_room.y-1 > 0:
				if matrix[current_room.x-1][current_room.y-1] != 0:
					diagonal_rooms.append(Vector2(0,-1))
			
	return diagonal_rooms

func choose(array):
	return array[randi() % array.size()]

