extends Node
class_name PlayerStats

@export var level: int = 1
@export var exp: int = 0
@export var exp_to_next_level: int = 100

@export var max_health: int = 50
@export var attack: int = 10
@export var defense: int = 5

var health: int

signal leveled_up(new_level: int)
signal health_changed(new_health: int)
signal exp_changed(new_exp: int, exp_to_next_level: int)

func _ready():
	health = max_health

func take_damage(amount: int) -> void:
	var damage = max(amount - defense, 1)
	health = clamp(health - damage, 0, max_health)
	emit_signal("health_changed", health)

	if health <= 0:
		print("Player died!")  # or handle game over

func gain_exp(amount: int) -> void:
	exp += amount
	emit_signal("exp_changed", exp, exp_to_next_level)
	print("Gained ", amount, " EXP! (", exp, "/", exp_to_next_level, ")")

	if exp >= exp_to_next_level:
		level_up()

func level_up() -> void:
	exp -= exp_to_next_level
	level += 1
	exp_to_next_level = int(exp_to_next_level * 1.5)  # scaling
	emit_signal("leveled_up", level)
	print("Level Up! New level:", level)
