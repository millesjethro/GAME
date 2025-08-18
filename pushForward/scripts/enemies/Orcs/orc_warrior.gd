extends StaticBody2D

@export var max_health: int = 20
@export var attack: int = 5
@export var defense: int = 2
@export var xp_reward: int = 10

var health: int

signal died(xp_reward: int)
signal health_changed(new_health: int)

func _ready():
	health = max_health

func take_damage(amount: int) -> void:
	var damage = max(amount - defense, 1)
	health = clamp(health - damage, 0, max_health)
	emit_signal("health_changed", health)

	print("Enemy took ", damage, " damage! HP left: ", health)

	if health <= 0:
		die()

func die() -> void:
	emit_signal("died", xp_reward)
	queue_free()
