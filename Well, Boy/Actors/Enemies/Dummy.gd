extends KinematicBody2D

var floating_text = preload("res://Interface/Health/FloatingText.tscn")
onready var health = $Health
onready var health_bar = $HealthBar
onready var heal = $Heal

var damage = 0

func _ready():
	$Sprite.material.set_shader_param("hit_opacity", 0)
	heal.start()
	health.connect("health_changed", health_bar, "set_value")
	health.connect("max_changed", health_bar, "set_max")
	health.initialize()


func _on_Hurtbox_area_entered(area):
	if area.name == "HurtBox":
		return
	
	$AnimationPlayer.play("Hit")
	var text = floating_text.instance()
	
	text.actor = "Dummy"
	if area.crit == true:
		text.type = "Crit"
	else:
		text.type = "Damage"
	
	text.amount = area.damage
	text.position.x += 18
	text.position.y -= 18
	
	add_child(text)
	
	health.health -= area.damage


func _on_Heal_timeout():
	if health.health != health.max_health:
		var text = floating_text.instance()
		text.amount = 15
		text.actor = "Dummy"
		text.type = "Heal"
		text.position.x += 18
		text.position.y -= 18
		add_child(text)
		health.health += 15
