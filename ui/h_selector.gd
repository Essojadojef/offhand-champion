tool extends Control
class_name HSelection

export var value : int = 0 setget set_value
export var wrap_around : bool = false

export(int, "No", "Value", "Child Name") var display_text : int = 1
export(int, "Top", "Center", "Bottom") var text_valign : int = 1

export var container : NodePath
export var label : NodePath
export var bg_stylebox : StyleBox
export var selected_stylebox : StyleBox

signal value_changed(value)

func _ready():
	connect("resized", self, "update", [], CONNECT_DEFERRED)

func get_minimum_size():
	return Vector2(0, 20)

func _gui_input(event: InputEvent):
	if !event.is_pressed():
		return
	
	if event.is_action("ui_left"):
		set_value(value - 1)
		accept_event()
		
	if event.is_action("ui_right"):
		set_value(value + 1)
		accept_event()
		

func get_max_value() -> int:
	return get_node(container).get_child_count()

func set_value(_value: int):
	if get_max_value() <= 0:
		return
	
	if wrap_around:
		value = posmod(_value, get_max_value())
		
	else:
		value = clamp(_value, 0, get_max_value() - 1)
		
	
	emit_signal("value_changed", value)
	update()

func _draw():
	var node_rect = Rect2(Vector2(), rect_size)
	draw_style_box(bg_stylebox, node_rect)
	
	var rect = get_node(container).get_child(value).get_global_rect()
	rect.position -= get_global_rect().position
	draw_style_box(selected_stylebox, rect)
	
	var contents_rect = node_rect.grow_individual(
		-bg_stylebox.get_margin(MARGIN_LEFT), -bg_stylebox.get_margin(MARGIN_TOP),
		-bg_stylebox.get_margin(MARGIN_RIGHT), -bg_stylebox.get_margin(MARGIN_BOTTOM))
	
	if label and get_node(label):
		match display_text:
			1: get_node(label).text = "%d/%d" % [value + 1, get_max_value()]
			2: get_node(label).text = get_node(container).get_child(value).name
		

