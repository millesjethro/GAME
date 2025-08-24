extends ProgressBar

@onready var timer = $Timer
@onready var damageBar = $DamageBar
@onready var hide_timer = $HideTimer   # new timer for hiding

var health = 0: set = set_health

func set_health(new_health):
	var prev_health = health 
	health = new_health
	value = health 
	
	show()
	hide_timer.start()
	
	if health < prev_health:
		timer.start() 
	else: 
		damageBar.value = health 

func init_health(_health): 
	health = _health 
	max_value = health 
	value = health 
	damageBar.max_value = health 
	damageBar.value = health 
	
func _on_timer_timeout() -> void:
	var tween := create_tween()
	tween.tween_property(damageBar, "value", health, 0.4)

func _on_hide_timer_timeout() -> void:
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5) # fade alpha to 0 in 0.5s
	await tween.finished
	hide()
	modulate.a = 1.0 # reset alpha for next time
