extends KinematicBody2D
class_name Entity

const COLLISION_TESTS = 8

var velocity = Vector2()
var forced_velocity = Vector2()
var initial_forced_velocity = Vector2()

var walk_speed = 100

var on_ground = false
var on_wall = false

export var gravity = 1500


var team = ""

var attack_animation_player
var weapons_root : Node
var weapon_nodes = {} # {weapon_id: node}


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



func add_weapon(id: String) -> Node:
	assert(!weapon_nodes.has(id))
	
	var weapon = Globals.get_weapon(id).entity_scene.instance()
	weapon_nodes[id] = weapon
	
	weapon.user = self
	weapon.connect("hit", self, "_on_hit")
	weapon.connect("attack_finished", self, "_on_attack_finished")
	
	weapons_root.add_child(weapon, true)
	
	return weapon

func remove_weapon(id: String):
	assert(weapon_nodes.has(id))
	
	weapons_root.remove_child(weapon_nodes[id])
	weapon_nodes[id].queue_free()
	weapon_nodes.erase(id)



func blink(times: int = 1, node: Node2D = self):
	while(times):
		node.modulate.a = 1 - (times % 2)
		yield(get_tree(), "idle_frame")
		times -= 1
	node.modulate.a = 1

func _physics_process(delta):
	
	if stun:
		stun = max(stun - 1, 0)
		
		on_ground = false
		on_wall = false
		
		velocity += Vector2(0, delta * gravity)
		#velocity *= .99
		
		var collision = move_and_collide(velocity * delta)
		
		var collision_count = 0
		while collision and collision_count < COLLISION_TESTS :
			
			collision_count += 1;
			
			velocity = velocity.bounce(collision.normal) * .8
			
			collision = move_and_collide(velocity * delta)
			
		
		#move_and_slide( velocity, Vector2( 0, -1 ), 5, 4, PI/4 )
		
	else:
		combo_damage = 0
		
		on_ground = false
		on_wall = false
		
		var collision = move_and_collide(velocity * delta)
		
		if collision:
			#update()
			
			velocity = velocity.slide(collision.normal)
			
			on_ground = Vector2.UP.dot(collision.normal) > 0
			
			var wall_dot_product = Vector2.RIGHT.dot(collision.normal)
			on_wall = 1 if wall_dot_product > .65 else -1 if wall_dot_product < -.7 else 0
			#if on_wall : walljump
			
			if on_ground:
				velocity.y = min(velocity.y, 0)
				#velocity.x *= 1 - Vector2( 0, -1 ).dot( collision.normal )
				#velocity.x *= .5
				#if abs(velocity.x) < 1 :
				#	velocity.x = 0
			
			collision = move_and_collide(velocity * delta)
			
		
		velocity.y += gravity * delta
		
		velocity.x *= .99
		
	

func damage(intensity, push):
	
	combo_damage += intensity
	
	velocity = push * combo_damage * 200
	
	stun = 60
	
	if $"Hurt" and !$"Hurt".playing :
		$"Hurt".play()
	

func _on_hit(target: Entity, damage_dealt: float, push: Vector2): 
	target.damage(damage_dealt, push)

func can_hit(target: Entity):
	return target != self


func die() :
	queue_free()



func _on_attack_finished(): pass
func _on_attack_inputed(weapon: Weapon, attack: String): pass


