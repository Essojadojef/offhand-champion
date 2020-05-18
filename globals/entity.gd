extends KinematicBody2D
class_name Entity

const COLLISION_TESTS = 4

var velocity = Vector2()
var forced_velocity = Vector2()
var initial_forced_velocity = Vector2()

var walk_speed = 100

var on_ground = false
#var on_wall = false

export var gravity = 1500


signal damaged(attacker, damage, launch)

var stun = 0
var combo_damage

var state_queue = []
var state_queue_index = 0
const STATE_QUEUE_LENGHT = 7


func _ready():
	add_to_group("entities")


func get_state(): pass # virtual
func set_state(_state: Dictionary): pass # virtual

func push_state():
	state_queue_index = (state_queue_index + 1) % STATE_QUEUE_LENGHT
	state_queue[state_queue_index] = get_state()

func rollback(frames: int):
	assert(frames < STATE_QUEUE_LENGHT)
	state_queue_index -= frames
	set_state(state_queue[state_queue_index])





func _physics_process(delta):
	
	if stun:
		stun -= 1
	else:
		combo_damage = 0
	
	on_ground = false
	#on_wall = false
	
	var collision = move_and_collide(velocity * delta)
	var collision_count = 1
	
	while collision and collision_count < COLLISION_TESTS :
		collision_count += 1;
		
		if stun:
			velocity = velocity.bounce(collision.normal) * .8
			
		else:
			velocity = velocity.slide(collision.normal)
			
			on_ground = Vector2.UP.dot(collision.normal) > 0
			
			#var wall_dot_product = Vector2.RIGHT.dot(collision.normal)
			#on_wall = 1 if wall_dot_product > .65 else -1 if wall_dot_product < -.7 else 0
			
			if on_ground:
				velocity.y = min(velocity.y, 0)
			
		
		collision = move_and_collide(velocity * delta)
		
	
	velocity.y += gravity * delta
	

func damage(attacker, damage: float, launch: Vector2):
	combo_damage += damage
	velocity = launch * clamp(1 + combo_damage / 10, 1, 2) * 100
	emit_signal("damaged", attacker, damage, launch)

func die() :
	queue_free()


