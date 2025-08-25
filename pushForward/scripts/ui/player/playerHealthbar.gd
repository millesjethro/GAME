extends ProgressBar

@onready var timer = $damageTimer
@onready var damageBar = $DamageBar
@onready var healthIndicator = $Label
var health = 0: set = set_health

func set_health(new_health):
	var prev_health = health 
	health = new_health
	value = health 
	show()
	if health < prev_health:
		timer.start() 
	else: 
		damageBar.value = health 
	healthIndicator.text = "HEALTH: "+str(value)+"/"+str(max_value)

func init_health(_health): 
	health = _health 
	max_value = health 
	value = health 
	damageBar.max_value = health 
	damageBar.value = health
	healthIndicator.text = "HEALTH: "+str(value)+"/"+str(max_value)
	
func _on_timer_timeout() -> void:
	var tween := create_tween()
	tween.tween_property(damageBar, "value", health, 0.4)
