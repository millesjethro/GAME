extends CharacterBody2D

@onready var anim_sprite = $Lancer_AnimSprite
@onready var stats: PlayerStats = $PlayerStatus

@export var gravity: float = 600.0
var has_dealt_damage: bool = false
var IsBattleArea = false
var speed: float

# Attack state
var is_attacking: bool = false
var attack_duration: float = 0.25
var attack_timer: float = 0.0

# Knockback values
var player_knockback_strength: float = 20.0
var player_hop_strength: float = -150.0   # upward jump

# NEW: player death state
var is_dead: bool = false

func _ready():
	speed = 200
	# Connect death signal
	stats.connect("died", Callable(self, "_on_player_died"))

func _physics_process(delta):
	if is_dead:
		return  # Stop all player control if dead

	var input_direction = Input.get_action_strength("Right") - Input.get_action_strength("Left")

	if is_attacking:
		attack_timer -= delta
		if attack_timer <= 0 and is_on_floor():
			is_attacking = false
	else:
		velocity.x = input_direction * speed

	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		if not is_attacking:
			velocity.y = 0

	move_and_slide()

	if not is_attacking:
		if IsBattleArea == false:
			movement_sprite(input_direction)
		else:
			engage_battle(input_direction)

func movement_sprite(input_direction):
	if input_direction != 0:
		anim_sprite.play("walking")
		anim_sprite.flip_h = input_direction < 0
	else:
		anim_sprite.play("idle")

func attack_sprite():
	if not is_attacking:
		is_attacking = true
		attack_timer = attack_duration
		has_dealt_damage = false

		var facing = -1 if anim_sprite.flip_h else 1
		velocity.x = -facing * player_knockback_strength
		velocity.y = player_hop_strength

func engage_battle(input_direction):
	if input_direction != 0:
		anim_sprite.play("engage")
		anim_sprite.flip_h = input_direction < 0
	else:
		anim_sprite.play("idle")

func _on_engage_in_battle(area: Area2D) -> void:
	if area.is_in_group("BattleArea") and not IsBattleArea:
		print("Entered battle area:", area.name)
		IsBattleArea = true

func _on_out_of_battle(area: Area2D) -> void:
	if area.is_in_group("BattleArea") and IsBattleArea:
		print("Exited battle area:", area.name)
		IsBattleArea = false

func _on_attack_entered(area: Area2D) -> void:
	if is_dead:
		return  # Dead player can't attack

	if area.is_in_group("TakeDamage"):
		attack_sprite()
		var enemy = area.get_parent()

		if enemy.has_method("take_damage") and stats != null:
			enemy.take_damage(stats.attack)

			if enemy.get("attack"):
				var enemy_attack = enemy.get("attack")
				print("Enemy Attack:", enemy_attack)
				stats.take_damage(enemy_attack)
				print("Player HP:", stats.health)

			if enemy.has_signal("died") and not enemy.is_connected("died", Callable(self, "_on_enemy_died")):
				enemy.connect("died", Callable(self, "_on_enemy_died"))

func _on_enemy_died(xp_reward: int) -> void:
	stats.gain_exp(xp_reward)

# 🔹 NEW death handler
func _on_player_died() -> void:
	is_dead = true
	velocity = Vector2.ZERO
	anim_sprite.play("death")  # You need a "death" animation in your AnimatedSprite2D
	print("Player has died!")
