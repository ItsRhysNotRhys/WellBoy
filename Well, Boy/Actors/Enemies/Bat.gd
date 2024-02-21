extends KinematicBody2D

var floating_text = preload("res://Interface/Health/FloatingText.tscn")
var bullet_instance = preload("res://Attacks_Abilities/RangedAttack/BatBullet.tscn")

var dir = 1 
var knockback = 1000
var knockup = 200

var aggro = "aggro"
var follow = "follow"
var idle = "idle"
var state = idle

var rng = RandomNumberGenerator.new()
export var damage = 2
var player = null
var canAttack = true
var friction = 20
var walkingSpeed = 500
var acceleration = 8
var speed = 200
var attackRange = 700
var followRange = 600
var flightPower = 40
var gravity = 1300
var velocity = Vector2(walkingSpeed, gravity)



onready var health = $Health
onready var health_bar = $HealthBar


# Called when the node enters the scene tree for the first time.
func _ready():
	$Sprite.material.set_shader_param("hit_opacity", 0)
	$AnimationPlayer.play("fly")
	var scaling = int(get_parent().get_parent().name)
	print(scaling)
	health.connect("health_changed", health_bar, "set_value")
	health.connect("max_changed", health_bar, "set_max")
	health.set_max(health.max_health + scaling*0.2*health.max_health)
	health.health = health.max_health + scaling*0.2*health.max_health
	health.initialize()
	damage = damage + damage*0.2*scaling



func _physics_process(delta):
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
			rng.randomize()
			if player.position.x < position.x:
				$Sprite.flip_h = false
			else:
				$Sprite.flip_h = true
			if abs(position.x - player.position.x) > followRange :
				if abs(velocity.x) <= speed:
					if player.position.x < position.x:
						velocity.x -= rng.randf_range(acceleration/2, acceleration)
					elif player.position.x > position.x:
						velocity.x += rng.randf_range(acceleration/2, acceleration)
				else:
					velocity.x = velocity.x/abs(velocity.x) * speed
			else:
				if abs(velocity.x) <= speed:
					if player.position.x < position.x:
						velocity.x += rng.randf_range(acceleration/2, acceleration)
					elif player.position.x > position.x:
						velocity.x -= rng.randf_range(acceleration/2, acceleration)
				else:
					velocity.x = velocity.x/abs(velocity.x) * speed
				
				
			if canAttack and abs(position.x - player.position.x) < attackRange:
				canAttack = false
				var bullet = bullet_instance.instance()
				bullet.position = get_global_position()
				bullet.player = player
				get_tree().get_root().get_node("Main").add_child(bullet)
				$AttackCD.start()
				
				
			if is_on_floor():
				velocity.y = 0
			
			if player.position.y < global_position.y + 100:
				velocity.y -= flightPower
			
			if abs(velocity.y) > 400:
				velocity.y = velocity.y/abs(velocity.y) * 400


func _on_Hurtbox_area_entered(area):
	if area.name == "HurtBox":
		return
	
	$FlashPlayer.play("hit")
	var text = floating_text.instance()
	text.actor = "Bat"
	if area.crit == true:
		text.type = "Crit"
	else:
		text.type = "Damage"
	text.amount = area.damage
	text.position.x += 0
	text.position.y -= 40
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

