extends Node2D

const FluidCell = preload("res://FluidCell.tscn")
const Fluid = preload("res://Fluid.gd")
const FluidConsts = preload("res://FluidConsts.gd")
const LEN = 12
const HEI = 8

var cells
var domain
var starting_water
		
var water = Fluid.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	
	cells = {}
	domain = get_node("Domain")
	starting_water = get_node("StartingWater")
	
	var partial_cells = {}
	var sub_cells = domain.get_used_cells()
	
	for sc in sub_cells:
		var sv = Vector2(floor(sc.x/2), floor(sc.y/2))
		if sv in partial_cells:
			partial_cells[sv] += 1
		else:
			partial_cells[sv] = 1
	
	for sv in partial_cells:
		if partial_cells[sv] == 4:
			cells[sv] = FluidCell.instance()
			add_child(cells[sv])
			cells[sv].position = sv * 64
	
	for fc in cells:
		cells[fc].up = cells.get(fc + Vector2(0, -1))
		cells[fc].left = cells.get(fc + Vector2(-1, 0))
		cells[fc].right = cells.get(fc + Vector2(1, 0))
		cells[fc].down = cells.get(fc + Vector2(0, 1))
		
	var full_cells = starting_water.get_used_cells()
	for fc in full_cells:
		if fc in cells:
			cells[fc].contents[FluidConsts.Names.WATER] = cells[fc].volume
	starting_water.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
var fc = 0 
func _process(delta):
	fc += 1
	if Input.is_mouse_button_pressed(BUTTON_LEFT):
		var mpos = get_viewport().get_mouse_position()
		var mvec = Vector2(floor(mpos.y/64), floor(mpos.x/64))
		if mvec in cells:
			cells[mvec].add_content(fc, 2*delta)
