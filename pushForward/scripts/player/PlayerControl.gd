# Player.gd
# ------------------------------
# Main Player controller script.
# Handles movement, gravity, attacking, knockback, battle states,
# and connects with PlayerStats for HP/EXP.
# ------------------------------

extends CharacterBody2D

@onready var anim_sprite = $Lancer_AnimSprite
@onready var stats: PlayerStats = $PlayerStatus

@export var gravity: float = 600.0
var has_dealt_damage: bool = false
var is_in_battle: bool = false
var speed: float = 200.0

# Attack state
var is_attacking: bool = false
var attack_duration: float = 0.25
var attack_timer: float = 0.0

# Knockback values
var player_knockback_strength: float = 50.0
var player_hop_strength: float = -150.0   # upward jump

# Death state
var is_dead: bool = false

func _ready():
	stats.connect("died", Callable(self, "_on_player_died"))

func _physics_process(delta):
	if is_dead: return

	var input_direction = Input.get_action_strength("Right") - Input.get_action_strength("Left")

	# Handle attacking timer
	if is_attacking:
		attack_timer -= delta
		if attack_timer <= 0 and is_on_floor():
			is_attacking = false
	else:
		velocity.x = input_direction * speed

	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		if not is_attacking:
			velocity.y = 0

	move_and_slide()

	# Animations depending on state
	if not is_attacking:
		if not is_in_battle:
			_movement_sprite(input_direction)
		else:
			_engage_battle(input_direction)


# ------------------------------
# Sprite Animation helpers
# ------------------------------
func _movement_sprite(input_direction):
	if input_direction != 0:
		anim_sprite.play("walking")
		anim_sprite.flip_h = input_direction < 0
	else:
		anim_sprite.play("idle")

func _attack_sprite():
	if not is_attacking:
		is_attacking = true
		attack_timer = attack_duration
		has_dealt_damage = false

		var facing = -1 if anim_sprite.flip_h else 1
		velocity.x = -facing * player_knockback_strength
		velocity.y = player_hop_strength

func _engage_battle(input_direction):
	if input_direction != 0:
		anim_sprite.play("engage")
		anim_sprite.flip_h = input_direction < 0
	else:
		anim_sprite.play("idle")


# ------------------------------
# Battle Triggers
# ------------------------------
func _on_engage_in_battle(area: Area2D) -> void:
	if area.is_in_group("BattleArea") and not is_in_battle:
		is_in_battle = true

func _on_out_of_battle(area: Area2D) -> void:
	if area.is_in_group("BattleArea") and is_in_battle:
		is_in_battle = false

func _on_attack_entered(area: Area2D) -> void:
	if is_dead: return

	if area.is_in_group("TakeDamage"):
		_attack_sprite()
		var enemy = area.get_parent()

		# Deal damage to enemy
		if enemy.has_method("take_damage") and stats != null:
			enemy.take_damage(stats.attack)
			anim_sprite.play("hurt")
			await anim_sprite.animation_finished
			# Enemy counterattacks
			if enemy.get("attack"):
				var enemy_attack = enemy.get("attack")
				stats.take_damage(enemy_attack)

			# Connect enemy death event
			if enemy.has_signal("died") and not enemy.is_connected("died", Callable(self, "_on_enemy_died")):
				enemy.connect("died", Callable(self, "_on_enemy_died"))


# ------------------------------
# Callbacks
# ------------------------------
func _on_enemy_died(xp_reward: int, gold_reward: int) -> void:
	stats.gain_exp(xp_reward)
	stats.gold_update(gold_reward)

func _on_player_died() -> void:
	is_dead = true
	velocity = Vector2.ZERO
	anim_sprite.play("death")  # Needs "death" animation
	print("Player has died!")
