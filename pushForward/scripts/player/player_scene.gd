extends CharacterBody2D

@onready var anim_sprite = $Lancer_AnimSprite
@export var gravity: float = 600.0
@onready var stats = $Stats

var IsBattleArea = false
var speed: float

# Attack state
var is_attacking: bool = false
var attack_duration: float = 0.25
var attack_timer: float = 0.0

# Knockback values
var player_knockback_strength: float = 200.0
var player_hop_strength: float = -100.0   # upward jump
var enemy_knockback_strength: float = 50.0

func _ready():
	speed = stats.data.speed

func _physics_process(delta):
	var input_direction = Input.get_action_strength("Right") - Input.get_action_strength("Left")
	
	if is_attacking:
		attack_timer -= delta
		if attack_timer <= 0:
			is_attacking = false
	else:
		velocity.x = input_direction * speed

	# Gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
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
		anim_sprite.play("attack")

		# Determine facing direction (flip_h = true means facing left)
		var facing = -1 if anim_sprite.flip_h else 1

		# Apply knockback to PLAYER (push backward)
		velocity.x = -facing * player_knockback_strength
		# Apply hop
		velocity.y = player_hop_strength

func engage_battle(input_direction):
	if input_direction != 0:
		anim_sprite.play("engage")
		anim_sprite.flip_h = input_direction < 0
	else:
		anim_sprite.play("idle")

func _on_engage_in_battle(area: Area2D) -> void:
	if area.is_in_group("BattleArea"):
		print("Entered battle area:", area.name)
		IsBattleArea = true

func _on_out_of_battle(area: Area2D) -> void:
	if area.is_in_group("BattleArea"):
		print("Exited battle area:", area.name)
		IsBattleArea = false

func _on_attack_entered(area: Area2D) -> void:
	if area.is_in_group("TakeDamage"):
		attack_sprite()

		# Push the enemy away (opposite of player’s facing direction)
		var facing = -1 if anim_sprite.flip_h else 1
		if area.has_method("apply_knockback"):
			area.apply_knockback(facing * enemy_knockback_strength)
