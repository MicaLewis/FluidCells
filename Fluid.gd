class_name Fluid

var name
var weight
var compression
var falls
var color
var content
var content_d1
var content_d2

func init(base, _content):
	name = base.name
	weight = base.weight
	compression = base.compression
	falls = base.falls
	color = base.color
	content = _content
	content_d1 = 0
	content_d2 = 0 # for when your neighbor is trying to tell you something but they're in the future
	
static func sort(a, b):
	return a.weight < b.weight
