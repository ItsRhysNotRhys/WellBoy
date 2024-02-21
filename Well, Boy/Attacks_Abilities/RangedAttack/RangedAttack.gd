extends Area2D

var floating_text = preload("res://Interface/Health/FloatingText.tscn")

var curr_enemy = null
var lifestealed = false
var dir = 1
var speed = 2500
var damage = 15
var knockback = 750
var knockup = 250
var lifesteal = false
var crit = false

onready var scale_ = $Scale
onready var bolt_animations = $BoltPlayer

func _ready():
	var scaling = int(get_parent().get_parent().name)
	damage = round(damage + damage*get_parent().get_node("Player").curr_level*0.1)
	
	
	if lifesteal:
		bolt_animations.play("Bolt")
	elif crit:
		bolt_animations.play("Bolt")
	else:
		bolt_animations.play("Bolt")
		
func _physics_process(delta):
	
	if dir == -1 :
		$BoltSprite.flip_v = true

	position += transform.x * speed * delta * dir
	
func _on_Timer_timeout():
	queue_free()

	
func _on_RangedAttack_body_entered(body):
	if lifesteal:
		var text = floating_text.instance()
		text.amount = floor(damage * 0.3)
		text.type = "Heal"
		text.actor = "Player"
		text.position.x += 9
		text.position.y -= 75
		get_parent().get_node("Player").add_child(text)
		get_parent().get_node("Player").health.health += floor((damage * 0.3)/2)

func _on_RangedAttack_area_entered(area):
	
	if lifesteal and area.name != "DetectionRadius":
		var text = floating_text.instance()
		text.amount = floor(damage * 0.3)
		text.type = "Heal"
		text.actor = "Player"
		text.position.x += 9
		text.position.y -= 80
		get_parent().get_node("Player").add_child(text)
		get_parent().get_node("Player").health.health += floor(damage * 0.3)
		
	if crit and area.name != "DetectionRadius":
		if area.get_parent().name != "Main":
			queue_free()
