extends Node

var mods = ["weapon_masters"] # [ String mod_id ]
var weapons = {} # { String id : WeaponResource weapon }

var colors = [Color.crimson, Color.royalblue, Color.gold, Color.orchid, Color.dimgray]


### stage ###

const stage_center = Vector2( 0, 0 )
const stage_radius = 800

### PLAYERS ###

var players = {}

var accept_new_players = true

signal player_added(controller)
signal player_removed(id)

signal player_(controller)
#signal all_ready()


func _init() -> void:
	load_mods()
	load_weapons()
	randomize()

func load_mods():
	print("loading mods:")
	var dir : Directory = Directory.new()
	
	dir.open("user://mods")
	dir.list_dir_begin(true, true)
	var file = dir.get_next()
	
	while file:
		
		if file.get_extension() == ".pck":
			print(" " + file)
			ProjectSettings.load_resource_pack("user://mods/" + file)
		
		file = dir.get_next()
	
	pass

func load_weapons():
	print("loading weapons:")
	
	var dir : Directory = Directory.new()
	
	for mod in mods:
		if !dir.dir_exists("res://%s/weapons/" % mod):
			return
		
		var base_dir = "res://%s/weapons/" % mod
		
		dir.open(base_dir)
		dir.list_dir_begin(true, true)
		var file = dir.get_next()
		
		while file:
			
			if file.get_extension() == "tres":
				var id = mod + ":" + file.get_basename()
				print(" ", id)
				weapons[id] = load(base_dir + file)
			
			file = dir.get_next()
	

func get_weapon(id: String) -> WeaponResource:
	if id.find(":") != -1:
		return weapons[id]
	else:
		return weapons["weapon_masters:" + id]


func _unhandled_input(event: InputEvent) -> void:
	
	if event is InputEventKey and event.scancode == KEY_P and !event.is_pressed():
		Engine.time_scale = -1
		for i in 10:
			#get_viewport().propagate_call("_physics_process", [get_physics_process_delta_time() * 60])
			get_viewport().propagate_notification(NOTIFICATION_INTERNAL_PHYSICS_PROCESS)
			get_viewport().propagate_notification(NOTIFICATION_PHYSICS_PROCESS)
			
		Engine.time_scale = 1
		return
	
	var id = get_event_player(event)
	
	if !players.has(id) and accept_new_players:
		add_player(id)
	

func get_event_player(event: InputEvent) -> int:
	if event is InputEventJoypadButton or event is InputEventJoypadMotion :
		return event.device
	else :
		return -1


### PLAYERS MANAGEMENT

func add_player(id):
	var controller = Player.new(id)
	add_child(controller)
	players[id] = controller
	
	emit_signal("player_added", controller)

func get_available_color() -> Color:
	var index = players.size()
	return colors[index] if index < colors.size() else Color.white

func get_player_entity(id: int) -> Node:
	return players[id].focus



### PLAYER_INPUT

class Player extends Node2D:
	# Holds the controller settings, player settings and controller inputs
	
	var device : int
	var keyboard = false
	
	var color : Color
	signal color_changed(color)
	
	var focus : Node # is Control while in menus, is KinematicBody2D while playing
	signal focus_changed(new_focus)
	
	var controls = {}
	signal controls_changed(controls)
	
	var match_settings = {}
	
	var input_buffer_frames = 3
	var input_buffer = []
	var input_buffer_index = 0
	var just_pressed = []
	var just_released = []
	
	var input_frames = 0
	
	
	func _init(_device: int):
		process_priority = -1 # callbacks are executed first in this node
		
		device = _device
		keyboard = device == -1
		color = Globals.get_available_color()
		
		# set dafault controls
		controls = {
				"left": KEY_LEFT,
				"right": KEY_RIGHT,
				"up": KEY_UP,
				"down": KEY_DOWN,
				"heavy_time": 5,
				"jump": KEY_W,
				"guard": KEY_Q,
				"weapon_1": KEY_D,
				"weapon_2": KEY_E,
				"item": KEY_A,
				"throw": KEY_SHIFT
			} if keyboard else {
				"stick_x": JOY_AXIS_0,
				"stick_y": JOY_AXIS_1,
				"deadzone": .8,
				"heavy_time": 5,
				"jump": JOY_L,
				"guard": JOY_R,
				"weapon_1": JOY_XBOX_B,
				"weapon_2": JOY_XBOX_A,
				"item": JOY_XBOX_X,
				"throw": JOY_R2
			}
		
		z_index = 10
		name = str(device)
		
		clear_input_buffer()
	
	func clear_input_buffer():
		for i in input_buffer_frames:
			input_buffer.append({
				"direction": Vector2(),
				"jump": false,
				"weapons": [false, false],
				"item": false,
				"throw": false})
	
	
	
	func is_event_allowed(event: InputEvent) -> bool:
		return event is InputEventKey if keyboard else event.device == device
	
	func _unhandled_input(event: InputEvent) -> void:
		if !is_event_allowed(event): return
		
		if focus is Control:
			gui_input(event)
		
	
	
	
	func get_current_input() -> Dictionary:
		return input_buffer[input_buffer_index]
	
	func _physics_process(delta):
		if !focus is KinematicBody2D: return
		
		input_buffer_index += 1
		if input_buffer_index >= input_buffer_frames:
			input_buffer_index = 0
		
		var current_input = input_buffer[input_buffer_index]
		
		#var was_still = focus.tilt == 0 and focus.movement == 0
		
		#focus.movement = current_input.direction.x
		#focus.tilt = current_input.direction.y
		
		#if was_still and (focus.tilt != 0 or focus.movement != 0):
		#	focus.heavy = controls.heavy_time
		
		focus.weapon_inputs = current_input.weapons
		#focus.item_input = current_input.item
		focus.throw = current_input.throw
		
		
		
		input_buffer[input_buffer_index] = {
			"direction": get_directional_input(),
			"jump": get_button_input("jump"),
			"weapons": [
				get_button_input("weapon_1"), get_button_input("weapon_2")],
			"item": get_button_input("item"),
			"throw": get_button_input("throw")}
			#"just_pressed": just_pressed,
			#"just_released": just_released}
			#"swap": both_weapon_inputs}
		
		if input_buffer[input_buffer_index].weapons.has(true):
			input_frames += 1
			print("input_frames: ", input_frames)
		else:
			input_frames = 0
		
		#just_pressed = []
		#just_released = []
		
	
	# x_axis: -1 = left, 1 = right
	# y_axis: -1 = up, 1 = down
	func get_directional_input() -> Vector2:
		if keyboard:
			var left = Input.is_key_pressed(controls.left)
			var right = Input.is_key_pressed(controls.right)
			var up = Input.is_key_pressed(controls.up)
			var down = Input.is_key_pressed(controls.down)
			return Vector2(int(right) - int(left), int(down) - int(up))
		else:
			var value = Vector2(
				Input.get_joy_axis(device, controls.stick_x),
				Input.get_joy_axis(device, controls.stick_y))
			
			if value.length() < controls.deadzone:
				return Vector2()
			
			return value.round()
	
	func get_button_input(action: String) -> bool:
		return Input.is_key_pressed(controls[action]) if keyboard else (
			Input.is_joy_button_pressed(device, controls[action]))
	
	
	
	func gui_input(event: InputEvent):
		if focus.has_method("_gui_input"):
			focus._gui_input(event)
			
			if get_tree().is_input_handled() or !event.is_pressed():
				return
		
		var next_focus
		
		if event.is_action("ui_left"):
			next_focus = focus.focus_neighbour_left
		elif event.is_action("ui_up"):
			next_focus = focus.focus_neighbour_top
		elif event.is_action("ui_right"):
			next_focus = focus.focus_neighbour_right
		elif event.is_action("ui_down"):
			next_focus = focus.focus_neighbour_bottom
		
		if next_focus:
			focus = focus.get_node(next_focus)
			emit_signal("focus_changed", focus)
			update()
	
	func _process(delta):
		update()
	
	func _draw() -> void:
		if focus and focus is Control:
			draw_rect(focus.get_global_rect(), color, false, 2)
	

