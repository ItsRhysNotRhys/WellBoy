extends KinematicBody2D

#Changeble variables to our liking
var rangedAttack = preload("res://Attacks_Abilities/RangedAttack/RangedAttack.tscn")
var meleeAttack = preload("res://Attacks_Abilities/MeleeAttack/MeleeAttack.tscn")

onready var player_animations = $Sprites/PlayerAnimations
onready var blast_animations = $Sprites/BlastAnimations
onready var ranged_cooldown = get_parent().get_node("CanvasLayer").get_node("RangedCooldown")
onready var melee_cooldown = get_parent().get_node("CanvasLayer").get_node("MeleeCooldown")
onready var dash_cooldown = get_parent().get_node("CanvasLayer").get_node("DashCooldown")
onready var sprite = $Sprites/PlayerSprite
onready var blast_sprite = $Sprites/BlastSprite
onready var dash = $Dash

var canMelee = true
var canShoot = true
var velocity = Vector2(0,0)
var slideCollisions = 0
var screen_size

onready var health = $Health

func _ready():

	$RunningCollision.disabled = true
	$IdleCollision.disabled = false
	screen_size = get_viewport_rect().size

func _process(delta):
	#Calling specific methodes to keep organization when problems happen
	_animations()


func _physics_process(delta):
	#Gravity is constantly acting on the player
	
	
	if dash.is_dashing():
		set_collision_mask_bit(2,false)
		$HurtBox/Area.disabled = true
		canShoot = false
	else: 
		set_collision_mask_bit(2,true)	
		$HurtBox/Area.disabled = false
		
	velocity.y += delta * Globals.grav
	velocity = move_and_slide(velocity, Vector2.UP)
	
	Globals.speed = Globals.dash_speed if dash.is_dashing() else Globals.walkSpeed
	Globals.grav = Globals.dash_grav if dash.is_dashing() else Globals.gravity
	#Globals.grav = Globals.dash_grav if dash.is_dashing() and not is_on_floor() else Globals.gravity
	
	#Getting inputs and moving left and right
	if Input.is_action_pressed("move_left"):
		velocity.x = -Globals.speed
	elif Input.is_action_pressed("move_right"):
		velocity.x = Globals.speed
	else:
		velocity.x = 0

	if Input.is_action_just_pressed("move_up") and is_on_floor():
		velocity.y = -Globals.jumpHeight


	elif Input.is_action_pressed("move_down"):
		pass #This is going to be for passing through platforms later on
	
	if Input.is_action_just_pressed("attack_ranged") and canShoot:
		canShoot = false
		$Cooldowns/RangedAttackCD.wait_time = Globals.ranged_cooldown
		$Cooldowns/RangedAttackCD.start()
		var bullet = rangedAttack.instance()
		if (sprite.flip_h == true):
			bullet.dir = -1
		add_child(bullet)
		bullet.global_position = global_position
		blast_animations.play("GreenBlast")
		ranged_cooldown.initiate_cooldown()
		
	if Input.is_action_just_pressed("attack_melee") and canMelee:
		canMelee = false
		$Cooldowns/MeleeAttackCD.wait_time = Globals.melee_cooldown
		$Cooldowns/MeleeAttackCD.start()
		var melee = meleeAttack.instance()
		if (sprite.flip_h == true):
			melee.dir = -1
		add_child(melee)
		melee.global_position = global_position
		if melee.dir == -1:
			melee.position.x -= 100
		melee_cooldown.initiate_cooldown()
	
	
	if Input.is_action_just_pressed("dash") and dash.can_dash and !dash.is_dashing():
		dash.start_dash(sprite, Globals.dash_duration)
		dash_cooldown.initiate_cooldown()
		
	
	if Input.is_action_just_pressed("interact"):
		print(self.position)

func _animations():
	#Getting movement state and setting the animation to that state
	
	if not is_on_floor():
		player_animations.play("Air")
	elif is_on_floor() and (velocity.x != 0):
		player_animations.play("Run")
		$IdleCollision.disabled = true
		$RunningCollision.disabled = false
	else:
		player_animations.play("Idle")
		$IdleCollision.disabled = false
		$RunningCollision.disabled = true


	#Checking what direction the player is moving (Left or Right) and flipping the player accordingly 
	if velocity.x < 0 : 
		sprite.flip_h = true
		blast_sprite.flip_h = true
		blast_sprite.position.x = sprite.position.x - 55
	elif velocity.x > 0 :
		sprite.flip_h = false
		blast_sprite.flip_h = false
		blast_sprite.position.x = sprite.position.x + 55

func _on_HurtBox_area_entered(area):
	
	health.health -= area.get_parent().damage


func _on_MeleeAttackCD_timeout():
	canMelee = true


func _on_RangedAttackCD_timeout():
	canShoot = true
