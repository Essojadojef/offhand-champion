tool extends Node2D
class_name Weapon, "weapon.png"

var user

var anim_player : AnimationPlayer
var idle_animation_name : String = "idle"
var skeleton : Node2D

# properties that can be animated
export var animate_skeleton = false

signal hit(target, hitbox)
signal clashed(user_hitbox, opponent_hitbox)
signal attack_ended()



func _ready():
	if !anim_player and has_node("AnimationPlayer"):
		anim_player = get_node("AnimationPlayer")
		anim_player.connect("animation_finished", self, "_on_animation_finished")

func get_attack() -> String: # virtual
	return ""

func attack(attack_name: String):
	anim_player.play(attack_name)

func input_released(): # virtual
	pass

func cancel():
	end_attack()

func _on_animation_finished(anim_name: String):
	if anim_name != idle_animation_name:
		end_attack()

func end_attack():
	anim_player.play(idle_animation_name)
	emit_signal("attack_ended")


# functions called by hitboxes

func can_hit(node: Node) -> bool:
	return user.can_hit(node)

func hit(target, hitbox: Hitbox):
	target.damage(hitbox)
	emit_signal("hit", target, hitbox)

func clash(user_hitbox: Hitbox, opponent_hitbox: Hitbox):
	emit_signal("clashed", user_hitbox, opponent_hitbox)

func get_attack_attributes(hitbox: Hitbox):
	return user.get_attack_attributes(hitbox)
