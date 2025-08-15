extends CharacterBody2D

@export var speed: float = 200.0
@onready var anim_sprite = $player_sprite

func _physics_process(delta):
	var input_direction = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	
	# Movement (sideways only)
	velocity.x = input_direction * speed
	velocity.y = 0

	move_and_slide()
	movement_sprite(input_direction)

func movement_sprite(input_direction):
	# Animation control
	if input_direction != 0:
		anim_sprite.play("walking")
		anim_sprite.flip_h = input_direction < 0  # Flip when moving left
	else:
		anim_sprite.play("idle")
