extends KinematicBody2D

var damage = 0
var floating_text = preload("res://Interface/Health/FloatingText.tscn")

onready var health = $Health
onready var health_bar = $HealthBar

func _ready():
	$Sprite.material.set_shader_param("hit_opacity", 0)
	$AnimationPlayer.play("Idle")
	health.connect("health_changed", health_bar, "set_value")
	health.connect("max_changed", health_bar, "set_max")
	health.initialize()
	health.set_max(150)
	health.health = 150
	
func _process(delta):
	
	if health.health == 0:
		queue_free()
	health.health += 100 * delta

func _on_Hurtbox_area_entered(area):
	
	if area.name == "HurtBox":
		return
	$FlashPlayer.play("hit")
	
	var text = floating_text.instance()
	
	text.actor = "Dummy"
	if area.crit == true:
		text.type = "Crit"
	else:
		text.type = "Damage"
	
	text.amount = area.damage
	text.position.x += 10
	text.position.y -= 40
	
	add_child(text)
	
	health.health -= area.damage
