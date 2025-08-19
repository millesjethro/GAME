extends StaticBody2D

@export var level: int = randf_range(1, 20)  # Enemy level
@export var base_health: int = 20
@export var base_attack: int = 5
@export var base_defense: int = 2
@export var base_xp_reward: int = 15

var max_health: int
var attack: int
var defense: int
var xp_reward: int
var health: int

signal died(xp_reward: int)

func _ready():
	apply_level_stats(level)
	health = max_health

func apply_level_stats(lv: int) -> void:
	# Scaling formulas (you can tweak multipliers for balance)
	max_health = base_health + (lv - 1) * 10   # +10 HP per level
	attack = base_attack + int((lv - 1) * 2)  # +2 ATK per level
	defense = base_defense + int((lv - 1) * 1) # +1 DEF per level
	xp_reward = base_xp_reward + (lv - 1) * 5  # +5 XP per level

	print(name, " | Level:", lv, " | HP:", max_health, " | ATK:", attack, " | DEF:", defense, " | XP:", xp_reward)

func take_damage(amount: int) -> void:
	var damage = max(amount - defense, 1)
	health = clamp(health - damage, 0, max_health)
	print(name, " HP:", health)
	if health <= 0:
		die()

func die():
	emit_signal("died", xp_reward)
	queue_free()
