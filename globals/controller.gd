extends Node2D
class_name PlayerController

# Holds the controller settings, player settings and controller inputs

var device : int
var keyboard = false

var color : Color
signal color_changed(color)

var focus : Node # is Control while in menus, is KinematicBody2D while playing
signal focus_changed(new_focus)

var stick_settings = {}
var button_settings = {}
var heavy_time = .5
signal controls_changed(controls)

var match_settings = {}

var input_buffer_frames = 3
var input_buffer = []
var input_buffer_index = 0
var just_pressed = []
var just_released = []

var input_frames = 0

var current_input = {} # inputs state delayed by input_buffer_frames

func _init(_device: int):
	process_priority = -1 # callbacks are executed first in this node
	set_physics_process(false) # _physics_process will be activated when a game starts
	
	device = _device
	keyboard = device == -1
	color = Globals.get_available_color()
	
	# set dafault controls
	stick_settings = {
			"stick_x": JOY_ANALOG_LX,
			"stick_y": JOY_ANALOG_LY,
			"deadzone": .5
		}
	button_settings = {
			#"left": [KEY_LEFT],
			#"right": [KEY_RIGHT],
			#"up": [KEY_UP],
			#"down": [KEY_DOWN],
			#"jump": [KEY_KP_0],
			#"weapon_1": [KEY_KP_5],
			#"weapon_2": [KEY_KP_1],
			#"item": [KEY_KP_2],
			#"guard": [KEY_KP_6],
			#"throw": [KEY_KP_ADD]
			"left": [KEY_A],
			"right": [KEY_D],
			"up": [KEY_W],
			"down": [KEY_S],
			"jump": [KEY_SPACE],
			"weapon_1": [KEY_I],
			"weapon_2": [KEY_J],
			"item": [KEY_K],
			"guard": [KEY_O],
			"throw": [KEY_P]
		} if keyboard else {
			"left": [],
			"right": [],
			"up": [],
			"down": [],
			"jump": [JOY_L, JOY_L2],
			"weapon_1": [JOY_XBOX_B],
			"weapon_2": [JOY_XBOX_A],
			"item": [JOY_XBOX_X],
			"guard": [JOY_R],
			"throw": [JOY_R2]
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

func get_button_name(value: int) -> String:
	if keyboard:
		return OS.get_scancode_string(value)
	
	match value:
		JOY_XBOX_B: return "B"
		JOY_XBOX_A: return "A"
		JOY_XBOX_X: return "X"
		JOY_XBOX_Y: return "Y"
		JOY_L: return "LB"
		JOY_L2: return "LT"
		JOY_L3: return "Left Stick"
		JOY_R: return "RB"
		JOY_R2: return "RT"
		JOY_R3: return "Right Stick"
		_ : return "?"

func list_buttons(action: String):
	if button_settings[action].empty():
		return "None"
	
	var text = ""
	for i in button_settings[action]:
		text += get_button_name(i) + "/"
	
	return text.left(text.length() - 1)

func get_stick_axis_name(axis: int) -> String:
	match axis:
		JOY_ANALOG_LX: return "Left Stick L/R"
		JOY_ANALOG_LY: return "Left Stick U/D"
		JOY_ANALOG_RX: return "Right Stick L/R"
		JOY_ANALOG_RY: return "Right Stick U/D"
		JOY_ANALOG_L2: return "Left Trigger"
		JOY_ANALOG_R2: return "Right Trigger"
		_ : return "?"



func is_event_allowed(event: InputEvent) -> bool:
	return keyboard if event is InputEventKey else event.device == device

func _unhandled_input(event: InputEvent) -> void:
	if !is_event_allowed(event): return
	
	if focus is Control:
		gui_input(event)
	



func get_current_input() -> Dictionary:
	return current_input

func _physics_process(delta):
	input_buffer_index += 1
	if input_buffer_index >= input_buffer_frames:
		input_buffer_index = 0
	
	current_input = input_buffer[input_buffer_index]
	
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
	
	#just_pressed = []
	#just_released = []
	

# x_axis: -1 = left, 1 = right
# y_axis: -1 = up, 1 = down
func get_directional_input() -> Vector2:
	var left = false
	var right = false
	var up = false
	var down = false
	
	var stick = get_stick_input()
	
	if stick:
		right = abs(stick.angle()) < 3*PI/8
		left = abs(stick.angle()) > 5*PI/8
		if abs(stick.angle()) > PI/8 and abs(stick.angle()) < 7*PI/8:
			up = sign(stick.angle()) < 0
			down = sign(stick.angle()) > 0
	
	if button_settings.left:
		left = get_button_input("left")
	if button_settings.right:
		right = get_button_input("right")
	if button_settings.up:
		up = get_button_input("up")
	if button_settings.down:
		down = get_button_input("down")
	
	return Vector2(int(right) - int(left), int(down) - int(up))

func get_stick_input() -> Vector2:
	if keyboard:
		return Vector2()
	
	var value = Vector2(
		Input.get_joy_axis(device, stick_settings.stick_x),
		Input.get_joy_axis(device, stick_settings.stick_y))
	
	return value if value.length() >= stick_settings.deadzone else Vector2()

func get_button_input(action: String) -> bool:
	for i in button_settings[action]:
		if Input.is_key_pressed(i) if keyboard else Input.is_joy_button_pressed(device, i):
			return true
	return false



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
