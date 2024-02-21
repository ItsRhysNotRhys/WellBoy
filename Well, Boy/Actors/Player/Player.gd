extends KinematicBody2D

#Changeble variables to our liking
var rangedAttack = preload("res://Attacks_Abilities/RangedAttack/RangedAttack.tscn")
var meleeAttack = preload("res://Attacks_Abilities/MeleeAttack/MeleeAttack.tscn")
var doubleJump = preload("res://Actors/Player/DoubleJump.tscn")
var run_sprite = preload("res://art/Actions/Run/RunBoy_1.png")
var floating_text = preload("res://Interface/Health/FloatingText.tscn")

onready var player_animations = $Sprites/PlayerAnimations
onready var blast_animations = $Sprites/BlastAnimations
onready var dust_animations = $Sprites/DustParticleAnimation
onready var double_jump_animations = $Sprites/DoubleJumpAnimation
onready var ranged_cooldown = get_parent().get_node("CanvasLayer").get_node("RangedCooldown")
onready var melee_cooldown = get_parent().get_node("CanvasLayer").get_node("MeleeCooldown")
onready var dash_cooldown = get_parent().get_node("CanvasLayer").get_node("DashCooldown")
onready var lifesteal_cooldown = get_parent().get_node("CanvasLayer").get_node("LifestealCooldown")
onready var crit_cooldown = get_parent().get_node("CanvasLayer").get_node("CritCooldown")
onready var lifesteal_cd = $Cooldowns/LifestealCD
onready var crit_cd = $Cooldowns/CritCD
onready var sprite = $Sprites/PlayerSprite
onready var run = $Sprites/RunningSprite
onready var blast_sprite = $Sprites/BlastSprite
onready var dust_sprite = $Sprites/DustParticles
onready var dash = $Dash
onready var main = $Main
onready var bullet_scale = $Scale
onready var screen_shake = $Camera2D/ScreenShake

var bullet_crit_bonus = 15
var curr_level = 0
var canCrit = true
var canLifesteal = true
var stunned = false
var lifesteal = false
var crit = false
var hitstunned = false
var jumps = 2
var canMelee = true
var canShoot = true
var velocity = Vector2(0,0)
var slideCollisions = 0
var t = 0
var screen

onready var health = $Health

func _ready():
	health.health -= 20 
	$RunningCollision.disabled = true
	$IdleCollision.disabled = false
	screen = get_viewport_rect().size

func _process(delta):
	#Calling specific methodes to keep organization when problems happen
	_animations()
	
func _physics_process(delta):
	#Gravity is constantly acting on the player
	
	
	if !dash.is_dashing() and !stunned:
		set_collision_mask_bit(2,true)
		$HurtBox/Area.disabled = false
		
	#Get what direction the player is inputing, if they are holding both directions, the character will not move
	var dir = get_direction()
	
	Globals.speed = Globals.dash_speed if dash.is_dashing() else Globals.walkSpeed
	
	if dir.y > 0:
		Globals.grav = 6000
	else:
		Globals.grav = Globals.gravity
	
	if dir.x == -1:
		velocity.x = -Globals.speed
	elif dir.x == 1:
		velocity.x = Globals.speed
	else:
		velocity.x = 0
		
	velocity.y += delta * Globals.grav
	velocity = move_and_slide(velocity, Vector2.UP)
	
	if is_on_floor():
		jumps = 2
	
	if (Input.is_action_just_pressed("lifesteal")) and crit == false and canLifesteal:
		$Sprites/Lifesteal.emitting = true
		lifesteal_cd.wait_time = Globals.lifesteal_cooldown
		lifesteal_cd.start()
		canLifesteal = false
		canMelee = true
		lifesteal = true
	
	if (Input.is_action_just_pressed("crit")) and lifesteal == false and canCrit:
		$Sprites/Crit.emitting = true
		crit_cd.wait_time = Globals.crit_cooldown
		crit_cd.start()
		canCrit = false
		crit = true
		canMelee = true
		bullet_scale.start()
		
	if (Input.is_action_just_pressed("move_jump") or Input.is_action_just_pressed("move_up")) and jumps > 0:
		var poof = doubleJump.instance()
		poof.position = global_position
		
		if !is_on_floor():
			poof.position.y -= 100
		
		if velocity.x > 0:
			poof.position.x += 80
		elif velocity.x < 0:
			poof.position.x -= 80
	
		get_parent().add_child(poof)
		velocity.y = -Globals.jumpHeight
		jumps -= 1

	#Start dash process by getting starting posiiton and end position of dash based on direction the player wants to go
	if Input.is_action_just_pressed("dash") and dash.can_dash and !dash.is_dashing() and velocity.x != 0:
		if velocity.x != 0 and is_on_floor():
			sprite.set_texture(run_sprite)
			dash.start_dash(sprite,Globals.dash_duration)
		else:
			dash.start_dash(sprite, Globals.dash_duration)
		dash_cooldown.initiate_cooldown()
		set_collision_mask_bit(2,false)
		$HurtBox/Area.disabled = true
		
	#Attack stuff
	if Input.is_action_just_pressed("attack_ranged") and canShoot:
		canShoot = false
		$Cooldowns/RangedAttackCD.wait_time = Globals.ranged_cooldown
		$Cooldowns/RangedAttackCD.start()
		$boltsound.play()
		$BoltTimer.start()
		var bullet = rangedAttack.instance()
		if lifesteal == true:
			bullet.lifesteal = true
			lifesteal = false
			$Sprites/Lifesteal.emitting = false
			lifesteal_cooldown.initiate_cooldown()
		elif crit == true:
			bullet.crit = true
			crit = false
			$Sprites/Crit.emitting = false
			bullet.damage += bullet_crit_bonus
			bullet_scale.stop()
			bullet_crit_bonus = 15
			crit_cooldown.initiate_cooldown()
		if (sprite.flip_h == true):
			bullet.dir = -1
		get_parent().add_child(bullet)
		bullet.global_position = global_position
		blast_animations.play("GreenBlast")
		ranged_cooldown.initiate_cooldown()
	
	if Input.is_action_just_pressed("attack_melee") and canMelee:
		
		canMelee = false
		$Cooldowns/MeleeAttackCD.wait_time = Globals.melee_cooldown
		$Cooldowns/MeleeAttackCD.start()
		var melee = meleeAttack.instance()
		if sprite.flip_h == true:
			melee.dir = -1
		if lifesteal == true:
			melee.lifesteal = true
			lifesteal = false
			$Sprites/Lifesteal.emitting = false
			lifesteal_cooldown.initiate_cooldown()
			screen_shake.start()
			
		elif crit == true:
			melee.crit = true
			crit = false
			$Sprites/Crit.emitting = false
			bullet_scale.stop()
			bullet_crit_bonus = 15
			crit_cooldown.initiate_cooldown()
			screen_shake.start()
	
		add_child(melee)
		
		melee.global_position = global_position
		
	
		melee_cooldown.initiate_cooldown()

	#Interaction stuff
	if Input.is_action_just_pressed("interact"):
		print(self.position)
	
	
func _animations():
	#Getting movement state and setting the animation to that state
	
	if not is_on_floor():
		player_animations.play("Air")
		dust_animations.play("no_dust")
		sprite.visible = true
		run.visible = false
	elif is_on_floor() and (velocity.x != 0):
		player_animations.play("Run")
		dust_animations.play("dust")
		run.visible = true
		sprite.visible = false
		$IdleCollision.disabled = true
		$RunningCollision.disabled = false
	else:
		player_animations.play("Idle")
		dust_animations.play("no_dust")
		run.visible = false
		sprite.visible = true
		$IdleCollision.disabled = false
		$RunningCollision.disabled = true

	
	#Checking what direction the player is moving (Left or Right) and flipping the player accordingly
	#left 
	if velocity.x < 0 : 
		sprite.flip_h = true
		run.flip_h = true
		blast_sprite.flip_h = true
		dust_sprite.flip_h = true
		run.position.x = sprite.position.x - 20
		dust_sprite.position.x = sprite.position.x + 40
		blast_sprite.position.x = sprite.position.x - 55
	#right
	elif velocity.x > 0 :
		sprite.flip_h = false
		run.flip_h = false
		blast_sprite.flip_h = false
		dust_sprite.flip_h = false
		dust_sprite.position.x = sprite.position.x - 85
		blast_sprite.position.x = sprite.position.x + 55

func get_direction():
	return Vector2(
		int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left")),
		int(Input.is_action_pressed("move_down")) - int(Input.is_action_just_pressed("move_up"))
	)

func _on_HurtBox_area_entered(area):
	if !stunned:
		var text = floating_text.instance()
		
		if area.get_parent().name == "Main" :
			text.amount = area.damage
			health.health -= area.damage
		else:
			text.amount = area.get_parent().damage
			health.health -= area.get_parent().damage
		if health.health == 0:
			
			get_tree().reload_current_scene()
			
		text.type = "Damage"
		text.actor = "Player"
		text.position.x += 9
		text.position.y -= 80
		add_child(text)
		knockback(area)
	
func knockback(area):
	stunned = true
	
	$HurtBox/Area.disabled = true
	set_collision_mask_bit(2,false)
	$Hitstun.start()

func _on_MeleeAttackCD_timeout():
	canMelee = true

func _on_RangedAttackCD_timeout():
	canShoot = true

func _on_Hitstun_timeout():
	stunned = false
	
func _on_Scale_timeout():
	bullet_crit_bonus *= 2

func _on_LifestealCD_timeout():
	canLifesteal = true
	lifesteal_cd.wait_time = Globals.lifesteal_cooldown
	

func _on_CritCD_timeout():
	canCrit = true
	crit_cd.wait_time = Globals.crit_cooldown
	print(crit_cd.wait_time)
	print("TimedOut")


func _on_BoltTimer_timeout():
	$boltsound.stop()
