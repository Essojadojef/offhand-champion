tool extends Control
class_name HSelection

export var value : int = 0 setget set_value
export var wrap_around : bool = false

export(int, "No", "Value", "Child Name") var display_text : int = 1
export(int, "Top", "Center", "Bottom") var text_valign : int = 1

export var bg_stylebox : StyleBox
export var selected_stylebox : StyleBox

signal value_changed(value)

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
	return $HBox.get_child_count()

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
	
	if $HBox.get_child_count() > value:
		var rect = $HBox.get_child(value).get_global_rect()
		rect.position -= get_global_rect().position
		draw_style_box(selected_stylebox, rect)
	
	var contents_rect = node_rect.grow_individual(
		-bg_stylebox.get_margin(MARGIN_LEFT), -bg_stylebox.get_margin(MARGIN_TOP),
		-bg_stylebox.get_margin(MARGIN_RIGHT), -bg_stylebox.get_margin(MARGIN_BOTTOM))
	
	if !display_text:
		return
	
	var font = get_font("")
	var string = "%d/%d" % [value + 1, get_max_value()]
	
	var pos = contents_rect.position
	pos.x += (contents_rect.size.x - font.get_string_size(string).x) / 2
	match text_valign:
		0: pos.y += font.get_ascent()
		1: pos.y = (contents_rect.size.y + font.get_string_size(string).y) / 2
		2: pos.y = contents_rect.end.y
	
	draw_string(font, pos, string)
	

