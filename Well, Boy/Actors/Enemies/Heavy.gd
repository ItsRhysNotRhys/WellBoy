extends KinematicBody2D

var floating_text = preload("res://Interface/Health/FloatingText.tscn")
var bullet_instance = preload("res://Attacks_Abilities/RangedAttack/HeavyBullet.tscn")

var dir = 1 
var knockback = 1000
var knockup = 200
 
var aggro = "aggro"
var follow = "follow"
var idle = "idle"
var state = idle

var damage = 2
var isAttacking = false
var player = null
var canJump = false
var canAttack = true
var friction = 50
var prevState = true
var curState = true
var walkingSpeed = 500
var speed = 300
var attackRange = 450
var jumpHeight = 900
var jumpSpeed = 400
var gravity = 1700
var velocity = Vector2(walkingSpeed, gravity)



onready var health = $Health
onready var health_bar = $HealthBar


# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("idle")
	$Sprite.material.set_shader_param("hit_opacity", 0)
	var scaling = int(get_parent().get_parent().name)
	damage = damage + damage*0.2*scaling
	health.connect("health_changed", health_bar, "set_value")
	health.connect("max_changed", health_bar, "set_max")
	health.set_max(health.max_health + scaling*0.2*health.max_health)
	health.health = health.max_health + scaling*0.2*health.max_health
	health.initialize()
	



func _physics_process(delta):
	if velocity.x < 0 and is_on_floor() and !canAttack:
		velocity.x += friction
	elif velocity.x > 0 and is_on_floor() and !canAttack:
		velocity.x -= friction

	velocity.y += gravity * delta
	
	if velocity.x < 0 : 
		dir = -1
	elif velocity.x > 0 :
		dir = 1
		
	act()
	
	move_and_slide(velocity, Vector2.UP)
	

func act():
	if player:
		if state == aggro:
			if canAttack and is_on_floor():
				$ChargeUp.start()
				isAttacking = true
				canAttack = false
				
			if canJump and is_on_floor():
				isAttacking = true
				canJump = false
				$AnimationPlayer.play("gointoair")
				if player.position.x < position.x:
					velocity.x = -jumpSpeed
				else:
					velocity.x = jumpSpeed
				
				velocity.y = -jumpHeight
			
			curState = is_on_floor()
			if (curState != prevState and prevState == false and isAttacking):
				isAttacking = false
				$AnimationPlayer.play("land")
				$Land.start()
				var bullet1 = bullet_instance.instance()
				var bullet2 = bullet_instance.instance()
				bullet1.speed = bullet1.speed * -1
				bullet1.position = get_global_position()
				bullet2.position = get_global_position()
				get_tree().get_root().get_node("Main").add_child(bullet1)
				get_tree().get_root().get_node("Main").add_child(bullet2)
				$AttackCD.start()
				
			prevState = curState


func _on_Hurtbox_area_entered(area):
	if area.name == "HurtBox":
		return
	$FlashPlayer.play("hit")
	
	var text = floating_text.instance()
	text.actor = "Heavy"
	if area.crit == true:
		text.type = "Crit"
	else:
		text.type = "Damage"
	text.amount = area.damage
	text.position.x += 0
	text.position.y -= 200
	add_child(text)
	
	velocity.x = 0
	velocity.y = 0
	if area.dir == 1:
		pass
		#velocity.x += lerp(velocity.x, area.knockback, 0.5)
		#velocity.y -= lerp(velocity.x, area.knockup, 0.6)
	elif area.dir == -1:
		pass
		#velocity.x -= lerp(velocity.x, area.knockback, 0.5)
		#velocity.y -= lerp(velocity.x, area.knockup, 0.6)
	health.health -= area.damage
	
func _on_Health_dead():
	queue_free()
	
func _on_DetectionRadius_body_entered(body):
	state = aggro
	player = body


func _on_AttackCD_timeout():
	canAttack = true


func _on_DetectionRadius_body_exited(body):
	state = idle
	player = null



func _on_ChargeUp_timeout():
	canJump = true


func _on_Land_timeout():
	$AnimationPlayer.play("idle")
