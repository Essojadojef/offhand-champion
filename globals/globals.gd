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
	var controller = PlayerController.new(id)
	add_child(controller)
	players[id] = controller
	
	emit_signal("player_added", controller)

func get_available_color() -> Color:
	var index = players.size()
	return colors[index] if index < colors.size() else Color.white

func get_player_entity(id: int) -> Node:
	return players[id].focus



