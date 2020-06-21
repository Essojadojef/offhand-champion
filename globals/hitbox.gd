tool extends Area2D
class_name Hitbox, "hitbox.png"

onready var weapon = owner

export var active: bool = false setget set_active

export var damage : int = 10
export(float) var launch_distance = 1 setget set_launch_distance
export(float) var launch_angle = 0 setget set_launch_angle
export var attribute_name : String
export var attribute_value : int

var exceptions = []

func set_active(value: bool):
	active = value
	set_physics_process(value)
	
	if !active:
		exceptions.clear()

func set_launch_distance(value: float):
	launch_distance = value
	
	if Engine.editor_hint:
		update()

func set_launch_angle(value: float):
	launch_angle = value
	
	if Engine.editor_hint:
		update()

func _ready():
	set_physics_process(false)
	collision_layer = 2
	collision_mask = 7

func _physics_process(delta):
	
	for i in get_overlapping_areas():
		if get_script() == i.get_script(): # is Hitbox
			var opponent = i.get_user()
			if i.active and can_hit(opponent):
				# clashed
				exceptions.append(opponent)
				weapon.clash(self, i)
	
	for i in get_overlapping_bodies():
		if i is Entity and can_hit(i):
			exceptions.append(i)
			
			i.damage(self) # makes the target take damage from this hitbox
			weapon.emit_signal("hit", i, self) # tells the user that the hit connected
			

func can_hit(entity: Entity):
	return !exceptions.has(entity) and weapon.can_hit(entity)

func get_user() -> Entity:
	return weapon.user

func get_knockback() -> Vector2:
	return Vector2.RIGHT.rotated(global_rotation + deg2rad(launch_angle)) * global_scale * launch_distance

func get_hitlag() -> int:
	return int(damage * get_knockback().length() * .2)

func get_attributes() -> Dictionary:
	var attributes = weapon.get_attack_attributes(self)
	
	if attribute_name and attribute_value:
		if attributes.has(attribute_name):
			attributes[attribute_name] += attribute_value
		else:
			attributes[attribute_name] += attribute_value
	
	return attributes

func _draw():
	if Engine.editor_hint:
		draw_line(
			Vector2(),
			Vector2.RIGHT.rotated(deg2rad(launch_angle)) * launch_distance * 32,
			Color.black, 2)
