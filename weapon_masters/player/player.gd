extends Entity
class_name PlayerEntity

export(Vector2) var spawn_point

var controller : Globals.Player = null

### set by Globals ###

# inputs
var directional_input = Vector2()
var h_tilt = 0 # 1 = forward; -1 = back
var v_tilt = 0 # -1 = up; 1 = down

var was_still = true
var heavy = 0
var heavy_time = 5 # time window in which an attack is considered heavy

var jump = false
var weapon_inputs = [false, false]
var weapon_just_pressed = [false, false]
var throw = false





#var weapons = {"sword": load("res://weapons/sword/nodes.tscn")}
var fallback_weapon : Weapon
var weapons = ["", ""]

var current_weapon : String
var current_attack : String

var buffer_time = 0
var buffered_slot : int
var buffered_attack : String

var aim = 0
var aiming = false

var items = []
var selected_item = 0

var facing = 1
var turn_time = 0

var lives = 3
var health = 100
var max_health = 100

var invulnerability = 0

var dodge_time = 0
var dodge_iframes = 12
var dodge_recovery = 30
var dodge_direction = Vector2()

#var jump_buffer = 0
#var JUMP_BUFFER_TIME = 3

var jump_held = false # true if the player is holding the button after a jump or long jump

var jump_startup = 0 # time before jump
var high_jump = false # changes the jump's height and startup time

var airdodge_available = true # replaces midair jump, gives iframes + momentum in any direction

#var throw_time = 0 # how long the throw button is being pressed

var pickup_target : Node2D



var longest_combo = 0



func _ready():
	add_to_group("player_entities")
	
	team = "players"
	
	if controller:
		$PickupIcon.modulate = controller.color
		$ThrowIcon.modulate = controller.color
		$Weapons/Aim.modulate = controller.color
		$Skeleton.self_modulate = controller.color
	
	$PickupIcon.hide()
	$ThrowIcon.hide()
	
	randomize()
	
	weapons_root = $Weapons
	
	fallback_weapon = add_weapon("bare")
	weapon_nodes[""] = fallback_weapon
	
	set_weapon(0, controller.match_settings.weapon1 if controller.match_settings.has("weapon1") else "")
	set_weapon(1, controller.match_settings.weapon2 if controller.match_settings.has("weapon2") else "")
	#load_item( load("res://weapons/spear/nodes.tscn").instance(), "spear" )
	#load_item( load("res://weapons/knife/nodes.tscn").instance(), "knife" )
	




func set_weapon(slot: int, id: String):
	
	if weapons[slot]:
		remove_weapon(weapons[slot])
	
	if id:
		assert(!weapons.has(id))
		add_weapon(id)
	
	weapons[slot] = id
	

func get_weapon_node(slot: int):
	return  weapon_nodes[weapons[slot]]
	




func damage(intensity, push):
	if invulnerability or dodge_time > dodge_iframes:
		return
	
	health -= intensity
	
	if health <= 0:
		die()
	
	.damage(intensity, push * .5)
	#update() # debugging
	#airdodge_available = true
	

func die():
	$Death.play()
	
	set_physics_process(false)
	yield(get_tree().create_timer(1), "timeout")
	
	respawn()
	

func respawn():
	position = spawn_point
	velocity = Vector2()
	invulnerability = 120
	health = max_health
	aiming = false
	set_physics_process(true)
	


func get_input():
	return controller.get_current_input()

func _physics_process(delta: float):
	
	call_deferred("process_skeleton")
	
	process_inputs()
	
	process_turning()
	
	if dodge_time:
		dodge_time -= 1
		if dodge_time > dodge_recovery:
			velocity = dodge_direction * 400 * dodge_time / (dodge_iframes + dodge_recovery)
		elif on_ground:
			velocity *= .9
	
	if stun or turn_time or dodge_time:
		return
	
	process_throw()
	
	if pickup_target:
		$PickupIcon.global_position = pickup_target.global_position + Vector2(0, -32)
	
	
	if invulnerability :
		invulnerability -= 1
		modulate.a = abs(cos(PI * 100 / (invulnerability + 5) + invulnerability * 2))
	
	
	process_jump()
	process_movement(delta)
	
	process_aim(delta)
	process_attack(delta)
	

func process_inputs():
	
	directional_input = get_input().direction 
	v_tilt = directional_input.y
	h_tilt = directional_input.x * facing
	
	
	var is_still = directional_input == Vector2()
	
	if was_still and !is_still:
		heavy = heavy_time
		
	elif heavy:
		heavy -= 1
		
	
	was_still = is_still
	
	
	weapon_just_pressed = [
		get_input().weapons[0] and !weapon_inputs[0],
		get_input().weapons[1] and !weapon_inputs[1]]
	
	weapon_inputs = get_input().weapons
	

func process_skeleton():
	if !controller:
		return
	
	# color
	var base_color : Color = controller.color
	
	$Skeleton.self_modulate = (
		base_color.darkened(.5) if stun else
		base_color.lightened(.5) if heavy or dodge_time > dodge_recovery else
		base_color)
	
	# animation
	
	if turn_time or dodge_time or jump_startup:
		return
	
	if current_attack:
		
		if weapon_nodes[current_weapon].animate_skeleton:
			var skeleton = weapon_nodes[current_weapon].skeleton
			
			$Skeleton/Head.transform = skeleton.get_node("Head").transform
			$Skeleton/Head/Face.transform = skeleton.get_node("Head/Face").transform
			$Skeleton/BodyTop.transform = skeleton.get_node("BodyTop").transform
			$Skeleton/FootL.transform = skeleton.get_node("FootL").transform
			$Skeleton/FootR.transform = skeleton.get_node("FootR").transform
			
		else:
			$AnimationPlayer.play("stand" if on_ground else "jump")
			
		
	elif !on_ground:
		$AnimationPlayer.play("jump")
		
	elif throw or !h_tilt:
		$AnimationPlayer.play("stand")
		
	else:
		$AnimationPlayer.play("walk" if h_tilt == 1 else "walk_backwards")
		
		#$Skeleton/Head/Face.position.y = tilt * 4 # move face while tilting
		

func process_movement(delta):
	if current_attack or throw:
		if on_ground:
			velocity.x = 0
		
		return
	
	if on_ground:
		velocity.x = directional_input.x * walk_speed * 2
		
	else:
		velocity.x += directional_input.x * max(250 - abs(velocity.x), 0) * 10 * delta
		

func process_jump():
	
	if jump_startup:
		jump_startup -= 1
		
		if !jump_startup:
			velocity.y = -700 if high_jump else -500
		
		return
	
	if on_ground: airdodge_available = true
	
	if current_attack:
		return
	
	if get_input().jump:
		
		if jump_held:
			
			if on_ground:
				jump()
			
		elif on_ground:
			if v_tilt == 1 and !jump_held:
				dodge()
				
			else:
				jump()
				
			
		elif airdodge_available:
			airdodge_available = false
			dodge()
			
		
	else:
		jump_held = false
		
	

func jump():
	jump_held = true
	high_jump = v_tilt == -1
	jump_startup = 6 if high_jump else 3
	$AnimationPlayer.play("jumpsquat")

func dodge():
	if dodge_time:
		return
	dodge_time = dodge_iframes + dodge_recovery
	dodge_direction = directional_input.normalized()
	$AnimationPlayer.play("Dodge Forward" if dodge_direction.x > 0 else "Dodge Back")

func process_aim(delta: float):
	
	if current_attack == "":
		aiming = false
		aim = 0
	
	if aiming :
		aim += v_tilt * PI * delta
		aim = clamp(aim, -PI / 2, PI / 2)
	
	weapons_root.rotation = aim
	$Weapons/Aim.visible = aiming
	

func can_attack():
	return !(stun or current_attack or dodge_time or turn_time or jump_startup)

func process_attack(delta):
	
	if buffered_attack:
		
		
		if can_attack():
			if h_tilt < 0:
				turn()
			else:
				perform_attack(buffered_slot, buffered_attack)
				buffered_attack = ""
			return
			
		else:
			if buffer_time:
				buffer_time -= 1
			else:
				buffered_attack = ""
			
	
	
	if weapon_inputs[0] and weapon_inputs[1]:
		# swap weapons
		return
	
	if h_tilt < 0 and (weapon_inputs[0] or weapon_inputs[1]) and !current_attack:
		turn()
	
	process_attack_slot(0)
	process_attack_slot(1)
	

func process_attack_slot(slot: int):
	
	if !weapon_inputs[slot] and current_attack and current_weapon == weapons[slot]:
		release_attack(slot)
		return
	
	if weapon_just_pressed[slot]:
		
		if pickup_target and weapons[slot] == "" and !weapons.has(pickup_target.weapon_id):
			set_weapon(slot, pickup_target.weapon_id)
			pickup_target.queue_free()
		
		if can_attack():
			perform_attack(slot, weapon_nodes[weapons[slot]].get_attack())
		else:
			buffer_attack(slot)
		


func buffer_attack(slot: int):
	buffered_slot = slot
	buffered_attack = weapon_nodes[weapons[slot]].get_attack()
	buffer_time = 7

func perform_attack(slot: int, attack: String):
	current_weapon = weapons[slot]
	current_attack = attack
	weapon_nodes[weapons[slot]].attack(attack)

func release_attack(slot: int):
	weapon_nodes[weapons[slot]].input_released()

func _on_attack_finished():
	current_attack = ""
	


func process_throw():
	throw = can_attack() and get_input().throw
	$ThrowIcon.visible = throw
	
	if !throw:
		return
	
	#throw_time = min(throw_time + delta, 1)
	
	var direction = Vector2(h_tilt, v_tilt)
	if !direction:
		direction = Vector2(1, -1)
	$ThrowIcon.position = direction.normalized() * 64
	$ThrowIcon.rotation = direction.angle()
	
	if !current_attack:
		if weapon_just_pressed[0]:
			throw_weapon(0)
		if weapon_just_pressed[1]:
			throw_weapon(1)
	

func throw_weapon(slot: int):
	if weapons[slot] == "":
		return
	
	var item = load("res://weapon_masters/item/item_container.tscn").instance()
	item.weapon_id = weapons[slot]
	
	var direction = directional_input.normalized()
	if !direction:
		direction = Vector2(facing, -1).normalized()
	
	spawn_projectile(item, global_position, direction * 500)
	
	set_weapon(slot, "")
	
	#throw_time = 0

func spawn_projectile(projectile: Entity, initial_position : Vector2, projectile_velocity : Vector2):
	projectile.global_position = initial_position
	projectile.set_meta("velocity", projectile_velocity)
	projectile.set_meta("caster", self)
	get_parent().add_child(projectile)

func turn():
	facing *= -1
	turn_time = 8
	$AnimationPlayer.play("turn")

func process_turning():
	if turn_time:
		turn_time -= 1
		
		if !turn_time:
			scale.x = -1
		

func _on_PickupArea_body_entered(body: Node) -> void:
	pickup_target = body
	$PickupIcon.show()

func _on_PickupArea_body_exited(body):
	if pickup_target == body:
		pickup_target = null
		$PickupIcon.hide()


#func _draw():
#	draw_line(Vector2(), velocity, Color.white) # debugging

