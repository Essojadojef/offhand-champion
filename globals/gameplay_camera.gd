extends Camera2D
class_name GameplayCamera

func _process(delta):
	var entities = []
	
	for i in get_tree().get_nodes_in_group("player_entities"):
		if get_viewport() == i.get_viewport():
			entities.append(i)
	
	if entities.empty():return
	
	var target_pos = Vector2()
	for i in entities:
		target_pos += i.position
	target_pos /= entities.size()
	
	position = target_pos # * 0.8
	
	var max_distance = 0
	for i in entities:
		max_distance = max(max_distance, position.distance_to(i.position))
	
	max_distance = clamp(max_distance / 500, .3, 2)
	
	zoom = Vector2(1, 1) * max_distance
	
