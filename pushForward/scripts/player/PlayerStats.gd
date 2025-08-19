extends Node
class_name PlayerStats

@export var level: int = 1
@export var experience: int = 0
@export var exp_to_next: int = 100

@export var max_health: int = 50
@export var attack: int = 10
@export var defense: int = 5

var health: int

signal health_changed(new_health: int)
signal leveled_up(new_level: int)
signal exp_changed(experience: int, exp_to_next: int)
signal died  # <- NEW

func _ready():
	health = max_health

func take_damage(amount: int) -> void:
	var damage = max(amount - defense, 1)
	health = clamp(health - damage, 0, max_health)
	emit_signal("health_changed", health)

	if health <= 0:
		emit_signal("died")  # Notify the Player node

func gain_exp(amount: int):
	emit_signal("exp_changed", experience, exp_to_next)

	while experience >= exp_to_next:
		experience -= exp_to_next
		level += 1
		exp_to_next = int(exp_to_next * 1.5) # simple scaling
		emit_signal("leveled_up", level)
		print("Level Up! Now level:", level)
