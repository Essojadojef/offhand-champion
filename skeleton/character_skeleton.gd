tool extends Node2D

export var body_width : float
export var leg_width : float
export var leg_length : float
export var face_node : NodePath
export var face_scale : float

var curve = Curve2D.new()

const N = Vector2();
const L = Vector2(-1, 0)
const R = Vector2(1, 0)
const U = Vector2(0, -1)

export var editor_only : bool = true

func _ready():
	if editor_only:
		visible = Engine.editor_hint
	set_process(visible)

func _process(delta):
	if !is_visible_in_tree():
		return
	
	curve.clear_points()
	
	# body
	curve.add_point($BodyTop.position, N, L * body_width)
	
	# outer leg
	curve.add_point(
		#$FootL.position + controller_offset($FootL, L * leg_width),
		$FootL.position + (L * leg_width).rotated($FootL.rotation),
		#controller_offset($FootL, U * leg_length), N)
		(U * leg_length).rotated($FootL.rotation), N)
	
	# inner leg
	curve.add_point(
		#$FootL.position + controller_offset($FootL, R * leg_width),
		$FootL.position + (R * leg_width).rotated($FootL.rotation),
		#Vector2(), Vector2(0, -leg_length / 2).rotated($FootL.rotation))
		N, (U * leg_length / 2).rotated($FootL.rotation))
	
	#curve.add_point($BodyBottom.position, Vector2(-body_width / 2, 0), Vector2(body_width / 2, 0))
	
	# inner leg
	curve.add_point(
		#$FootR.position - Vector2(leg_width, 0).rotated($FootR.rotation),
		$FootR.position + (L * leg_width).rotated($FootR.rotation),
		#Vector2(0, -leg_length / 2).rotated($FootR.rotation), Vector2())
		(U * leg_length / 2).rotated($FootR.rotation), N)
	
	# outer leg
	curve.add_point(
		#$FootR.position + Vector2(leg_width, 0).rotated($FootR.rotation),
		$FootR.position + (R * leg_width).rotated($FootR.rotation),
		#Vector2(), Vector2(0, -leg_length).rotated($FootR.rotation))
		N, (U * leg_length).rotated($FootR.rotation))
	
	# body
	curve.add_point($BodyTop.position, R * body_width, N)
	
	update()

static func controller_offset(node: Node, offset: Vector2) -> Vector2:
	return offset.rotated(node.rotation)

func _draw():
	var zoom = get_viewport_transform().get_scale().length()
	if zoom == 0: return
	curve.bake_interval = 10 / zoom # higher bake interval == less points
	
	var points = curve.get_baked_points()
	if points.size() < 3: return
	draw_polygon(points, PoolColorArray([Color.white]))
	
	draw_circle($Head.position, 16, Color.white)
	
	# render face
	var basis = Basis()
	basis = basis.rotated(Vector3.RIGHT, clamp(-$Head/Face.position.y, -16, 16) / 32 * PI)
	basis = basis.rotated(Vector3.UP, clamp($Head/Face.position.x, -16, 16) / 32 * PI)
	
	var t = Transform2D(
		Vector2(basis.x.x, basis.x.y) * face_scale,
		Vector2(basis.y.x, basis.y.y) * face_scale,
		Vector2(basis.z.x, basis.z.y) * 16 + $Head.position)
	
	if face_node and get_node(face_node):
		get_node(face_node).transform = t
		
	else:
		var face_texture = preload("res://icon.png")
		draw_set_transform_matrix(t)
		draw_texture(face_texture, -face_texture.get_size() / 2)
		
	
