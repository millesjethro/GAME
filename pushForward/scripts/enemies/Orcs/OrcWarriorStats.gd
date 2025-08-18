extends Node   # or Node2D
class_name Enemy

@export var level: int = 1
@export var base_health: int = 50
@export var base_attack: int = 5
@export var base_defense: int = 2
@export var base_exp: int = 100

@export var health_per_level: float = 15.0
@export var attack_per_level: float = 4.5
@export var defense_per_level: float = 9.5
@export var exp_formula_mult: float = 1.5

var health: int
var attack: int
var defense: int
var exp_reward: int

signal died(exp_reward)

func _ready():
	_calculate_stats()

func _calculate_stats():
	health = int(base_health + (level * health_per_level))
	attack = int(base_attack + (level * attack_per_level))
	defense = int(base_defense + (level * defense_per_level))
	exp_reward = int((level * exp_formula_mult) + base_exp)

func take_damage(amount: int) -> void:
	var damage = max(amount - defense, 1)
	health = max(health - damage, 0)
	if health <= 0:
		emit_signal("died", exp_reward)
		queue_free()
