extends KinematicBody2D
class_name Entity

const COLLISION_TESTS = 4

var velocity = Vector2()
var forced_velocity = Vector2()
var initial_forced_velocity = Vector2()

var hitlag : int = 0

var walk_speed = 100

var on_ground = false
#var on_wall = false

var gravity = 1500


signal damaged(attacker, damage, launch)

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
	if hitlag:
		process_hitlag()
		return
	
	on_ground = false
	#on_wall = false
	
	var collision = move_and_collide(velocity * delta)
	var collision_count = 1
	
	while collision and collision_count < COLLISION_TESTS :
		collision_count += 1;
		
		process_collision(collision)
		
		collision = move_and_collide(velocity * delta)
		
	
	velocity.y += gravity * delta
	

func process_hitlag():
	hitlag -= 1

func process_collision(collision: KinematicCollision2D):
	
	velocity = velocity.slide(collision.normal)
	
	on_ground = Vector2.UP.dot(collision.normal) > 0
	
	#var wall_dot_product = Vector2.RIGHT.dot(collision.normal)
	#on_wall = 1 if wall_dot_product > .65 else -1 if wall_dot_product < -.7 else 0
	
	if on_ground:
		velocity.y = min(velocity.y, 0)
	

func damage(attacker, damage: int, launch: Vector2):
	velocity = launch * 100
	hitlag = damage * launch.length() * .2
	emit_signal("damaged", attacker, damage, launch)

func die() :
	queue_free()


