tool
extends Node2D

export var lenght : float = 16 * 16 # in pixels
export var width : float = 16

var curve = Curve2D.new()

func _physics_process(_delta):
	if !is_visible_in_tree():
		return
	
	curve.clear_points()
	
	curve.add_point($Point0.position, Vector2(), $Point0Out.position - $Point0.position)
	curve.add_point($Point1.position, $Point1In.position - $Point1.position, Vector2())
	
	update()

func _draw():
	var points = curve.tessellate()
	
	var stretch : float = curve.get_baked_length() / lenght
	var remainder : float = 0
	for i in points.size() - 1:
		var p0 = points[i]
		var p1 = points[i + 1]
		
		var forward : Vector2 = (p1 - p0)
		var tranform = Transform2D(forward/16, forward.tangent().normalized()/4, p0)
		
		var piece_width = width / stretch * clamp(1.2 - float(i) / points.size(), .1, 1)
		
		draw_set_transform_matrix(tranform)
		draw_texture_rect_region(
			preload("res://vanilla/weapons/whip/texture.png"),
			Rect2(0, -piece_width / 2, 16, piece_width),
			Rect2(remainder, 0, forward.length() / stretch, 16))
		
		remainder += forward.length() / stretch
