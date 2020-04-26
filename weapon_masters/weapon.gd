extends Node2D
class_name Weapon

var user

var anim_player : AnimationPlayer

signal hit(weapon, attack_name)

signal attack_finished()

func _ready() -> void:
	if Engine.editor_hint :
		pass
	
	anim_player
	$AnimationPlayer.connect("animation_finished", self, "_on_animation_finished")

# warning-ignore:unused_argument

func attack(attack_name: String):
	$AnimationPlayer.play(attack_name)

func get_current_animation() -> String:
	return $AnimationPlayer.current_animation





func aim():
	user.aiming = true


func input_released(): pass # virtual


func is_locked() -> bool:
	return $AnimationPlayer.is_playing()

"""func can_cancel(current_weapon, tilt: int, heavy: bool) -> bool:
	# returns if this weapon can cancel the attack of current_weapon
	var attack : String = get_attack(tilt, heavy)
	
	if current_weapon.name == name and current_attack == attack and repeating_attacks.has(attack):
		return true
	
	return false"""

func cancel():
	$AnimationPlayer.stop()


func get_attack() -> String: # virtual
	return ""

func _on_animation_finished(anim_name: String):
	emit_signal("attack_finished")


func can_hit(node: Node) -> bool:
	return user.can_hit(node)
