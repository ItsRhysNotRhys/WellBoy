extends KinematicBody2D

var floating_text = preload("res://Interface/Health/FloatingText.tscn")

var dir = 1
var knockback = 1000
var knockup = 200
onready var animation_player = $AnimationPlayer

var aggro = "aggro"
var idle = "idle"
var state = idle

var damage = 4
var player = null
var canJump = true
var friction = 10
var walkingSpeed = 500
var speed = 300
var gravity = 1000
var velocity = Vector2(walkingSpeed, gravity)

var playerPos = 0


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
	#Physics to make slimes slide after jumping
	if velocity.x < 0 and is_on_floor():
		velocity.x += friction
		animation_player.play("Idle")
	elif velocity.x > 0 and is_on_floor():
		velocity.x -= friction
		animation_player.play("Idle")
	velocity.y += gravity * delta
	
	if velocity.x < 0 : 
		dir = -1
	elif velocity.x > 0 :
		dir = 1
		
	act()
	
	move_and_slide(velocity, Vector2.UP)
	

func act():
	if !is_on_floor():
		animation_player.play("Air")
	
	if state == aggro :
		if is_on_floor():
			animation_player.play("Wiggle")
			
		if player and is_on_floor() and canJump :
			canJump = false
			$ChargeUp.start()
			
			playerPos = player.position.x
			
			$JumpCD.start()
	elif state == idle:
		pass #We can add a roaming feature when the player is not in range

func jump():
	if playerPos < position.x:
			velocity.x = -speed
	else:
		velocity.x = speed
	velocity.y = -500

func _on_Hurtbox_area_entered(area):
	
	if area.name == "HurtBox":
		return
	$FlashPlayer.play("hit")
	
	var text = floating_text.instance()
	text.actor = "Slime"
	if area.crit == true:
		text.type = "Crit"
	else:
		text.type = "Damage"
	text.amount = area.damage
	text.position.x -= 8
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
	print(area.damage)
	health.health -= area.damage

func _on_Health_dead():
	queue_free()
	
func _on_DetectionRadius_body_entered(body):
	state = aggro
	player = body

func _on_JumpCD_timeout():
	canJump = true

func _on_DetectionRadius_body_exited(body):
	state = idle
	player = null

func _on_ChargeUp_timeout():
	animation_player.play("Air")
	jump()
