extends CanvasLayer

export (PackedScene) var map_block
var block_offset = 20
var vp
var minimap_blocks = []
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	vp = $Control/ViewportContainer/Viewport
	

	pass # Replace with function body.

func add_block(coords, color):
	var x = coords.x
	var y = coords.y
	var _vpc = vp.size/2
	var new_block = map_block.instance()
	vp.add_child(new_block)
	new_block.position = Vector2(x * block_offset ,y * block_offset)
	new_block.block_number = Vector2(x,y)
	new_block.color = color
	minimap_blocks.append(new_block)
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
