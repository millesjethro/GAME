extends Node
class_name PlayerStats

@export var level: int = 1
@export var exp: int = 0
@export var exp_to_next: int = 100

@export var max_health: int = 50
@export var attack: int = 10
@export var defense: int = 5

var health: int

signal health_changed(new_health: int)
signal leveled_up(new_level: int)
signal exp_changed(exp: int, exp_to_next: int)

func _ready():
	health = max_health

func take_damage(amount: int) -> void:
	var damage = max(amount - defense, 1)
	health = clamp(health - damage, 0, max_health)
	emit_signal("health_changed", health)

	if health <= 0:
		print("Player died!")

func gain_exp(amount: int) -> void:
	exp += amount
	emit_signal("exp_changed", exp, exp_to_next)

	while exp >= exp_to_next:
		exp -= exp_to_next
		level += 1
		exp_to_next = int(exp_to_next * 1.5) # simple scaling
		emit_signal("leveled_up", level)
		print("Level Up! Now level:", level)
