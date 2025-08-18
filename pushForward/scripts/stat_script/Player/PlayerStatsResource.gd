extends Resource
class_name PlayerStatsResource

@export var max_health: int = 100
@export var attack: int = 10
@export var defense: int = 5
@export var speed: int = 200

# Level system
@export var level: int = 1
@export var max_level: int = 100
@export var experience: int = 0
@export var experience_to_next: int = 100  # XP needed for next level

# Growth per level
@export var growth_health: int = 10
@export var growth_attack: int = 2
@export var growth_defense: int = 1

func add_experience(amount: int) -> void:
	experience += amount
	while experience >= experience_to_next and level < max_level:
		experience -= experience_to_next
		level += 1
		# Increase stats
		max_health += growth_health
		attack += growth_attack
		defense += growth_defense
		# Next level requirement grows (simple curve)
		experience_to_next = int(experience_to_next * 1.15)
