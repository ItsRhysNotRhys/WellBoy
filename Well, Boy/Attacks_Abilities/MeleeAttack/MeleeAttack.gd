extends Area2D

var floating_text = preload("res://Interface/Health/FloatingText.tscn")

var lifestealed = false
var dir = 1
var knockback = 1000
var knockup = 200
var damage = 10
var lifesteal = false
var crit = false

onready var animation = $AnimationPlayer

func _ready():

	
	$GreenSprite.visible = false
	$RedSprite.visible = false
	$CritSprite.visible = false
	var scaling = int(get_parent().get_parent().name)
	damage = round(damage + damage*get_parent().curr_level*0.1)
	
	if dir == -1 :
		scale = Vector2(-1,1)
		
	if crit:
		damage *= 2
		
	if lifesteal:
		animation.play("RedMelee")
		$lifestealhit.play()
	elif crit:
		animation.play("CritMelee")
		$crithit.play()
	else:
		animation.play("GreenMelee")
		$greenhit.play()

	
	
func _on_Timer_timeout():
	queue_free()




func _on_MeleeAttack_area_entered(area):
	
	if area.name == "DetectionRadius":
		return 
		
	if get_parent().dash.can_dash == false:
		
		var newCD = get_parent().dash_cooldown.timer.get_time_left() - 0.5
		if newCD < 0:
			newCD = 0.00001
		
		get_parent().dash_cooldown.timer.start(newCD)
		get_parent().dash.dash_cd.start(newCD)
		
	if get_parent().canLifesteal == false and lifesteal == false:
		
		var newCD = get_parent().lifesteal_cooldown.timer.get_time_left() - 0.5
		if newCD < 0:
			newCD = 0.00001
		
		get_parent().lifesteal_cd.start(newCD)
		get_parent().lifesteal_cooldown.timer.start(newCD)
		
	if get_parent().canCrit == false and crit == false:
		
		var newCD = get_parent().crit_cooldown.timer.get_time_left() - 0.5
		if newCD < 0:
			newCD = 0.00001
		
		get_parent().crit_cd.start(newCD)
		get_parent().crit_cooldown.timer.start(newCD)
	
		
	if lifesteal:
		var text = floating_text.instance()
		text.amount = floor(damage * 0.7)
		text.type = "Heal"
		text.actor = "Player"
		text.position.x += 9
		text.position.y -= 80
		get_parent().add_child(text)
		get_parent().health.health += floor(damage * 0.7)
		
