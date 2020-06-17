tool extends Node2D
class_name Weapon, "weapon.png"

var user

var anim_player : AnimationPlayer
var skeleton : Node2D

# properties that can be animated
export var animate_skeleton = false

signal hit(target, damage, launch)
signal clashed(user_hitbox, opponent_hitbox)
signal attack_ended()



func get_attack() -> String: # virtual
	return ""

func attack(attack_name: String):
	if anim_player:
		anim_player.play(attack_name)

func get_current_animation() -> String:
	return anim_player.current_animation if anim_player else ""

func input_released(): # virtual
	pass

func cancel():
	anim_player.seek(anim_player.current_animation.length(), true)
	emit_signal("attack_ended")



func can_hit(node: Node) -> bool:
	return user.can_hit(node)

func hit(target: Entity, damage: int, launch: Vector2):
	emit_signal("hit", target, damage, launch)

func clash(user_hitbox: Hitbox, opponent_hitbox: Hitbox):
	emit_signal("clashed", user_hitbox, opponent_hitbox)
	var opponent_weapon = opponent_hitbox.owner

