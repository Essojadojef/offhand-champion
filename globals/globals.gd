extends Node

var mods = ["vanilla"] # [ String mod_id ]
var resources = {}
var weapons = {} # { String id : WeaponResource weapon }
var items = {} # { String id : WeaponResource item }

var colors = [Color.crimson, Color.royalblue, Color.gold, Color.orchid, Color.dimgray]


### stage ###

const stage_center = Vector2( 0, 0 )
const stage_radius = 800

### PLAYERS ###

var players = {}

var accept_new_players = true

signal player_added(controller)
signal player_removed(controller)



func _init() -> void:
	Input.connect("joy_connection_changed", self, "_on_joy_connection_changed")
	
	load_mods()
	load_resources("vanilla")
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
			ProjectSettings.load_resource_pack("user://mods/" + file, false)
		
		file = dir.get_next()
	

func load_resources(folder: String):
	print("loading resources from %s:" % folder)
	
	var dir : Directory = Directory.new()
	
	var base_dir = "res://%s/" % folder
	
	var error = dir.open(base_dir)
	if error:
		return
	
	dir.list_dir_begin(true, true)
	var file = dir.get_next()
	
	while file:
		
		if file.get_extension() == "tres":
			var id = folder + ":" + file.get_basename()
			print(" ", id)
			var res = load(base_dir + file)
			resources[id] = res
			
			if res is WeaponResource:
				if res.is_item:
					items[id] = res
				else:
					weapons[id] = res
			
		
		file = dir.get_next()


func get_weapon(id: String) -> WeaponResource:
	if id.find(":") == -1:
		id = "vanilla:" + id
	return weapons[id]

func get_item(id: String) -> WeaponResource:
	if id.find(":") == -1:
		id = "vanilla:" + id
	return items[id]

func get_resource(id: String):
	if id.find(":") == -1:
		id = "vanilla:" + id
	return resources[id]


func _unhandled_input(event: InputEvent) -> void:
	
	#if event is InputEventKey and event.scancode == KEY_P and !event.is_pressed():
	#	fast_forward(10)
	
	var device = get_event_player(event)
	
	if !players.has(device) and accept_new_players:
		add_player(device)
	

func _on_joy_connection_changed(device: int, connected: bool):
	print("_on_joy_connection_changed: ", device, ", ", connected)
	if players.has(device) and !connected:
		remove_player(device)


func fast_forward(frames: int):
	for i in frames:
		#get_viewport().propagate_call("_physics_process", [get_physics_process_delta_time() * 60])
		get_viewport().propagate_notification(NOTIFICATION_INTERNAL_PHYSICS_PROCESS)
		get_viewport().propagate_notification(NOTIFICATION_PHYSICS_PROCESS)

func get_event_player(event: InputEvent) -> int:
	if event is InputEventJoypadButton or event is InputEventJoypadMotion :
		return event.device
	else :
		return -1


### PLAYERS MANAGEMENT

func add_player(device: int):
	var controller = PlayerController.new(device)
	add_child(controller)
	players[device] = controller
	
	emit_signal("player_added", controller)

func remove_player(device: int):
	var controller: PlayerController = players[device]
	players.erase(device)
	remove_child(controller)
	emit_signal("player_removed", controller)

func get_available_color() -> Color:
	var index = players.size()
	return colors[index] if index < colors.size() else Color.white

func get_player_entity(device: int) -> Node:
	return players[device].focus



