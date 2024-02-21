extends KinematicBody2D

var floating_text = preload("res://Interface/Health/FloatingText.tscn")

var dir = 1 
var knockback = 1000
var knockup = 200

var aggro = "aggro"
var follow = "follow"
var idle = "idle"
var state = idle

var damage = 6
var player = null
var canJump = true
var canAttack = true
var friction = 20
var walkingSpeed = 500
var speed = 300
var attackRange = 500
var jumpHeight = 600
var lungeSpeed = 1500
var gravity = 1300
var velocity = Vector2(walkingSpeed, gravity)



onready var health = $Health
onready var health_bar = $HealthBar


# Called when the node enters the scene tree for the first time.
func _ready():
	$Sprite.material.set_shader_param("hit_opacity", 0)
	var scaling = int(get_parent().get_parent().name)
	health.connect("health_changed", health_bar, "set_value")
	health.connect("max_changed", health_bar, "set_max")
	health.set_max(health.max_health + scaling*0.2*health.max_health)
	health.health = health.max_health + scaling*0.2*health.max_health
	health.initialize()
	damage = round(damage + damage*0.2*scaling)



func _physics_process(delta):
	
	if velocity.x < 0 and is_on_floor():
		canJump = true
		velocity.x += friction
	elif velocity.x > 0 and is_on_floor():
		canJump = true
		velocity.x -= friction
	elif !is_on_floor():
		canJump = false
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
			if player.position.x < position.x:
				$Sprite.flip_h = false
			else:
				$Sprite.flip_h = true
			
			if abs(position.x - player.position.x) > attackRange:
				if player.position.x < position.x:
					velocity.x = -speed
				else:
					velocity.x = speed
					
			elif canAttack and abs(position.x - player.position.x) < attackRange:
				canAttack = false
				$AnimationPlayer.play("dash")
				$AttackCD.start()
				if player.position.x < position.x:
					velocity.x = -lungeSpeed
				else:
					velocity.x = lungeSpeed
				
			if player.position.y - position.y < -50 and canJump and canAttack:
				canJump = false
				velocity.y = -jumpHeight


func _on_Hurtbox_area_entered(area):
	if area.name == "HurtBox":
		return
	
	$FlashPlayer.play("hit")
	
	var text = floating_text.instance()
	text.actor = "Wolf"
	if area.crit == true:
		text.type = "Crit"
	else:
		text.type = "Damage"
	text.amount = area.damage
	text.position.x += 15
	text.position.y -= 65
	add_child(text)
	velocity.x = 0
	velocity.y = 0
	if area.dir == 1:
		velocity.x += lerp(velocity.x, area.knockback, 0.5)
		velocity.y -= lerp(velocity.x, area.knockup, 0.6)
	elif area.dir == -1:
		velocity.x -= lerp(velocity.x, area.knockback, 0.5)
		velocity.y -= lerp(velocity.x, area.knockup, 0.6)
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



func _on_AnimatedSprite_animation_finished():
	$AnimationPlayer.play("idle")
