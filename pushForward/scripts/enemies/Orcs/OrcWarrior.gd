extends StaticBody2D

@onready var anim_sprite = $Orc_AnimSprite
@onready var hp_bar = $HealthBar
@export var level: int = randi_range(1, 3)  # Enemy level
@export var base_health: int = 20
@export var base_attack: int = 5
@export var base_defense: int = 2
@export var base_xp_reward: int = 15
@export var base_gold_reward: int = 7

var max_health: int
var attack: int
var defense: int
var xp_reward: int
var gold_reward: int
var health: int

signal died(xp_reward: int)

func _ready():
	apply_level_stats(level)
	health = max_health
	hp_bar.init_health(health)
	
func apply_level_stats(lv: int) -> void:
	# Scaling formulas (you can tweak multipliers for balance)
	max_health = base_health + (lv - 1) * 10   # +10 HP per level
	attack = base_attack + int((lv - 1) * 2)  # +2 ATK per level
	defense = base_defense + int((lv - 1) * 1) # +1 DEF per level
	xp_reward = base_xp_reward + (lv - 1) * 5  # +5 XP per level
	gold_reward = base_gold_reward * pow(1.15, lv) + randi_range(5, 15)
	print(name, " | Level:", lv, " | HP:", max_health, " | ATK:", attack, " | DEF:", defense, " | REWRARD XP:", xp_reward, " | REWRARD GOLD:", gold_reward)

func take_damage(amount: int) -> void:
	anim_sprite.play("hurt")

	var damage = max(amount - defense, 1)
	health = clamp(health - damage, 0, max_health)
	hp_bar.set_health(health)

	# Wait for "hurt" animation to finish before idle
	await anim_sprite.animation_finished

	if health > 0:  # Only return to idle if not dead
		anim_sprite.play("idle")
	else:
		die()

func die():
	emit_signal("died", xp_reward, gold_reward)
	anim_sprite.play("die")
	await anim_sprite.animation_finished
	queue_free()
