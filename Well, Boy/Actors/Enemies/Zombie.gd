extends KinematicBody2D

var floating_text = preload("res://Interface/Health/FloatingText.tscn")

var dir = 1 
var knockback = 1000
var knockup = 200

var follow = "follow"
var idle = "idle"
var state = idle

var isDamaged = false
var damage = 5
var regen = 5
var player = null
var canJump = true
var prevVel = 0
var walkingSpeed = 500
var tunnelRange = 200
var speed = 300
var jumpHeight = 400
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
	elif velocity.x > 0 and is_on_floor():
		canJump = true
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
		if state == follow:
			$AnimationPlayer.play("Walk")
			if player.position.x < position.x:
				$Sprite.flip_h = true
			else:
				$Sprite.flip_h = false
			
			if abs(player.position.x - position.x) < tunnelRange:
				velocity.x = prevVel
			elif player.position.x < position.x:
				velocity.x = -speed
			else:
				velocity.x = speed
				
			prevVel = velocity.x
				
			if is_on_wall():
				canJump = false
				velocity.y = -jumpHeight


func _on_Hurtbox_area_entered(area):
	if area.name == "HurtBox":
		return
	
	$FlashPlayer.play("hit")
	
	$Damaged.start()
	$Regen.stop()
	isDamaged = true
	
	var text = floating_text.instance()
	text.actor = "Zombie"
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
	state = follow
	player = body



func _on_DetectionRadius_body_exited(body):
	state = idle
	player = null



func _on_AnimatedSprite_animation_finished():
	$AnimationPlayer.stop()


func _on_Regen_timeout():
	if health.health != health.max_health:
		var text = floating_text.instance()
		text.amount = regen
		text.actor = "Zombie"
		text.type = "Heal"
		text.position.x += 18
		text.position.y -= 18
		add_child(text)
		health.health += regen


func _on_Damaged_timeout():
	isDamaged = false
	$Regen.start()
