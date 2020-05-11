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
	
	curve.add_point($BodyTop.position, N, -$BodyTop.transform.x * body_width)
	
	#curve.add_point(
	#	$BodyMiddle.transform.xform(Vector2.LEFT),
	#	-$BodyMiddle.transform.y,
	#	$BodyMiddle.transform.y)
	
	# left leg
	
	curve.add_point(
		$FootL.transform.xform(Vector2.LEFT),
		-$FootL.transform.y * leg_length, N)
	
	curve.add_point(
		$FootL.transform.xform(Vector2.RIGHT),
		N, -$FootL.transform.y * leg_length / 2)
	
	#curve.add_point($BodyBottom.position, Vector2(-body_width / 2, 0), Vector2(body_width / 2, 0))
	
	# right leg
	
	curve.add_point(
		$FootR.transform.xform(Vector2.LEFT),
		-$FootR.transform.y * leg_length / 2, N)
	
	curve.add_point(
		$FootR.transform.xform(Vector2.RIGHT),
		N, -$FootR.transform.y * leg_length)
	
	# body
	
	#curve.add_point(
	#	$BodyMiddle.transform.xform(Vector2.RIGHT),
	#	$BodyMiddle.transform.y,
	#	-$BodyMiddle.transform.y)
	
	curve.add_point($BodyTop.position, $BodyTop.transform.x * body_width, N)
	
	update()

func _draw():
	var zoom = get_viewport_transform().get_scale().length()
	if zoom == 0: return
	curve.bake_interval = 10 / zoom # higher bake interval == less points
	
	var points = curve.get_baked_points()
	if points.size() < 3: return
	draw_polygon(points, PoolColorArray([Color.white]))
	
	draw_set_transform_matrix($Head.transform)
	draw_circle(Vector2(), 16, Color.white)
	
	# render face
	var basis = Basis()
	basis = basis.rotated(Vector3.RIGHT, clamp(-$Head/Face.position.y, -16, 16) / 32 * PI)
	basis = basis.rotated(Vector3.UP, clamp($Head/Face.position.x, -16, 16) / 32 * PI)
	
	var t = Transform2D(
		Vector2(basis.x.x, basis.x.y) * face_scale * $Head.transform.x,
		Vector2(basis.y.x, basis.y.y) * face_scale * $Head.transform.y,
		$Head.transform.xform(Vector2(basis.z.x, basis.z.y) * 16))
	
	if face_node and get_node(face_node):
		get_node(face_node).transform = t
		
	else:
		var face_texture = preload("res://icon.png")
		draw_set_transform_matrix(t)
		draw_texture(face_texture, -face_texture.get_size() / 2)
		
	
