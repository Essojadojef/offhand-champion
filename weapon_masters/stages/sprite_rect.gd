tool extends Node2D
class_name SpriteRect

export var texture : Texture setget set_texture
export var rect : Rect2 setget set_rect

func set_texture(value: Texture):
	texture = value
	update()

func set_rect(value: Rect2):
	rect = value
	update()

func _draw():
	draw_texture_rect(texture, rect, true)
