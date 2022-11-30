extends TileMap


# Declare member variables here. Examples:
export var cellTypeStr:String = ""
var cellType

# Called when the node enters the scene tree for the first time.
func _ready():
	celltype = load(cellType+".tscn")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
