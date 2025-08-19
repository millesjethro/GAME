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

func _ready():
	speed = 200

func _physics_process(delta):
	var input_direction = Input.get_action_strength("Right") - Input.get_action_strength("Left")

	if is_attacking:
		attack_timer -= delta
		if attack_timer <= 0 and is_on_floor():
			# Attack ends only when both timer done AND landed
			is_attacking = false
	else:
		# Player can move normally only when not attacking
		velocity.x = input_direction * speed

	# Gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		# Reset vertical velocity when on ground (unless mid-knockback)
		if not is_attacking:
			velocity.y = 0

	move_and_slide()

	# Animations
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
		has_dealt_damage = false   # reset damage flag at start of attack

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
	if area.is_in_group("TakeDamage"):
		attack_sprite()

		# Get the enemy node (usually the parent of the hitbox)
		var enemy = area.get_parent()

		# Make sure enemy has stats & methods
		if enemy.has_method("take_damage") and stats != null:
			# Enemy takes damage equal to player attack
			enemy.take_damage(stats.attack)

			# Player ALSO takes damage equal to enemy attack
			if enemy.get("attack"): # you used this before, but better to use `get()`
				var enemy_attack = enemy.get("attack")
				print("Enemy Attack:", enemy_attack)
				stats.take_damage(enemy_attack)
				print("Player HP:", stats.health)
				
			# Connect enemy death event for EXP
			if enemy.has_signal("died") and not enemy.is_connected("died", Callable(self, "_on_enemy_died")):
				enemy.connect("died", Callable(self, "_on_enemy_died"))

func _on_enemy_died(xp_reward: int) -> void:
	stats.gain_exp(xp_reward)
