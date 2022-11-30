extends Node2D
const Fluid = preload("res://Fluid.gd")

const grav = 0
const volume = 1

# Declare member variables here. Examples:
var neighbors = []
var contents = {}
var content = 0
var fc = 0
var up = null
var down = null
var left = null
var right = null
var quad

# Called when the node enters the scene tree for the first time.
func _ready():
	quad = get_node("Polygon2D")

func get_content(other_fc, fluid_type):
	var my_fluid = null
	for fluid in contents:
		if fluid.name == fluid_type.name:
			my_fluid = fluid
	if my_fluid == null:
		return 0
		
	if other_fc > fc:
		return my_fluid.content + my_fluid.content_d1
	else:
		return my_fluid.content
		
func add_content(other_fc, fluid_type, amount):
	var my_fluid = null
	for fluid in contents:
		if fluid.name == fluid_type.name:
			my_fluid = fluid
			
	if my_fluid == null:
		my_fluid = Fluid.new()
		my_fluid.init(fluid_type, 0)
		
	if other_fc > fc:
		my_fluid.content_d2 += amount
	else:
		my_fluid.content_d1 += amount

# ideal amount of fluid in the bottom cell
func get_stable_state(total, vol, fluid):
	if total < 1:
		return 1
	elif total < 2*vol + fluid.compression:
		return (vol*vol + total*fluid.compression)/(vol + fluid.compression)
	else:
		return (total + fluid.compression)/2
		
func flow(flow, delta, fluid, neighbor):
	fluid.content_d1 -= flow * delta
	neighbor.add_content(fc, fluid, flow * delta)
	return flow*delta

func _process(delta):

	fc += 1
		
	var remaining_volume = volume
	for fluid in contents:
	
		fluid.content += fluid.content_d1
		fluid.content_d1 = fluid.content_d2
		fluid.content_d2 = 0
	
		var flow = 0
		var remaining_content = fluid.content
		if down != null:
			if fluid.falls:
				flow = get_stable_state(
					remaining_content + down.get_content(fc, fluid), remaining_volume, fluid)
			else:
				flow = (fluid.content - up.get_content(fc, fluid))
			flow = max(flow, 0)
			flow = min(flow, remaining_content) # max speed?
			remaining_content -= flow(flow, delta, fluid, down)
			
		if left != null:
			flow = (fluid.content - left.get_content(fc, fluid))
			flow = max(flow, 0)
			flow = min(flow, remaining_content)
			remaining_content -= flow(flow, delta, fluid, left)
			
		if right != null:
			flow = (fluid.content - right.get_content(fc, fluid))
			flow = max(flow, 0)
			flow = min(flow, remaining_content)
			remaining_content -= flow(flow, delta, fluid, right)
		
		if up != null:
			if fluid.falls:
				flow = remaining_content - get_stable_state(
					remaining_content + up.get_content(fc, fluid), remaining_volume, fluid)
			else:
				flow = (fluid.content - up.get_content(fc, fluid))
			flow = max(flow, 0)
			flow = min(flow, remaining_content)
			if flow > 0:
				pass
			remaining_content -= flow(flow, delta, fluid, up)
		
		remaining_volume -= fluid.content
		
		# rendering with polygon
		quad.visible = true
		if fluid.content < volume:
			var scale = fluid.content/volume
			if down != null and down.content < down.volume:
				quad.scale = Vector2(scale, scale)
				quad.position = Vector2(32*(1-scale), 32*(1-scale))
			else:
				quad.scale = Vector2(1, scale)
				quad.position = Vector2(0, 64*(1-scale))
			quad.color = Color(0.203922, 0.392157, 1, 0.5)
		else:
			var shade = .5 - min((fluid.content - volume)*fluid.compression, .5)
			quad.scale = Vector2(1,1)
			quad.color = Color(0.203922, 0.392157, 1, shade)
