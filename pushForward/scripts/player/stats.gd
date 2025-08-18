extends Node

@export var data: StatsResource
var health: int
var level: int = 1
var xp: int = 0

signal health_changed(new_value)
signal died
signal leveled_up(new_level)  # renamed signal

func _ready():
	if data:
		health = data.max_health
	else:
		push_error("No StatsResource assigned to this Stats node!")

func take_damage(amount: int) -> void:
	var damage = max(amount - data.defense, 1)
	health = clamp(health - damage, 0, data.max_health)
	emit_signal("health_changed", health)

	if health <= 0:
		emit_signal("died")

func heal(amount: int) -> void:
	health = clamp(health + amount, 0, data.max_health)
	emit_signal("health_changed", health)

func is_alive() -> bool:
	return health > 0

# --- Leveling system ---
func add_xp(amount: int) -> void:
	xp += amount
	while xp >= xp_needed():
		xp -= xp_needed()
		_level_up()

func xp_needed() -> int:
	# Formula: level + (1.5 * level)
	return int(level + (1.5 * level))

func _level_up() -> void:     # renamed function
	if level < data.max_level:
		level += 1
		# Increase stats
		data.max_health += data.growth_health
		data.attack += data.growth_attack
		data.defense += data.growth_defense
		# Restore health on level up
		health = data.max_health
		emit_signal("level_up", level)
		print("Level up! Now level %d (XP needed for next: %d)" % [level, xp_needed()])
