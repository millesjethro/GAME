extends StaticBody2D

@export var max_health: int = 20
@export var attack: int = 5
@export var defense: int = 2
@export var xp_reward: int = 15

var health: int

signal died(xp_reward: int)

func _ready():
	health = max_health

func take_damage(amount: int) -> void:
	var damage = max(amount - defense, 1)
	health = clamp(health - damage, 0, max_health)
	print(name, " HP:", health)  # auto prints Player or Enemy HP
	if health <= 0:
		die()

func die():
	emit_signal("died", xp_reward)
	queue_free()
