extends Node
class_name PlayerStats

## PlayerStats.gd
# Handles player health, damage, experience, and level progression.
# Emits signals for UI updates and interaction with the Player node.

@export var level: int = 1
@export var experience: int = 0
@export var exp_to_next: int = 100

# Base stats (these will scale with level-ups)
@export var base_health: int = 150
@export var base_attack: int = 10
@export var base_defense: int = 5
@export var base_gold: int = 0

var max_health: int
var attack: int
var defense: int
var health: int
var gold: int
# Signals for UI / game flow
signal health_changed(new_health: int)
signal leveled_up(new_level: int)
signal exp_changed(experience: int, exp_to_next: int)
signal died

func _ready():
	_update_stats()
	health = max_health
	gold = base_gold
# -------------------
# Damage & Death
# -------------------
func take_damage(amount: int) -> void:
	var damage = max(amount - defense, 1)
	health = clamp(health - damage, 0, max_health)
	emit_signal("health_changed", health)

	if health <= 0:
		emit_signal("died")  # Notify Player node

# -------------------
# Experience & Leveling
# -------------------
func gain_exp(amount: int):
	experience += amount
	emit_signal("exp_changed", experience, exp_to_next)

	while experience >= exp_to_next:
		experience -= exp_to_next
		level += 1
		_update_stats()
		exp_to_next = int(exp_to_next * 1.5)  # EXP scaling
		emit_signal("leveled_up", level)
		print("Level Up! Now level:", level)

# -------------------
# Stat Scaling (per level)
# -------------------
func _update_stats():
	max_health = base_health + (level - 1) * 10
	attack = base_attack + (level - 1) * 2
	defense = base_defense + (level - 1) * 1
	health = max_health
	
func gold_update(goldAmount: int):
	gold += goldAmount
