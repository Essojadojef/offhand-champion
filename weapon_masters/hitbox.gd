tool extends Area2D
class_name Hitbox, "hitbox.png"

export var active: bool = false setget set_active

export var damage : float = 1

export(float) var launch_distance = 1

export(float) var launch_angle = 0

var exceptions = []

func set_active(value: bool):
	active = value
	set_physics_process(value)
	
	if !active:
		exceptions.clear()

func _ready():
	set_physics_process(false)
	collision_layer = 0
	collision_mask = 1

func _physics_process(delta):
	
	for i in get_overlapping_bodies():
		if i is Entity and owner.can_hit(i) and !exceptions.has(i):
			exceptions.append(i)
			
			var launch_vector = Vector2.RIGHT.rotated(global_rotation + deg2rad(launch_angle))
			launch_vector *= global_scale * launch_distance
			owner.emit_signal("hit", i, damage, launch_vector)
			

func _draw():
	if Engine.editor_hint:
		draw_line(Vector2(), Vector2.RIGHT.rotated(deg2rad(launch_angle)) * launch_distance * 16, Color.black)
