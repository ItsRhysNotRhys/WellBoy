extends Node

var player = null
var player_instance = null

###PHYSICS###
var grav = 2500
var speed = 900
var walkSpeed = 900
var gravity = 2500
const dash_speed = 2500
const dash_grav = 2500
var jumpHeight = 1000

###ATTACKSTATS###
var playerRanged = 5
var playerMelee = 10

###COOLDOWNS###
var lifesteal_cooldown = 4.0
var crit_cooldown = 4.0
var melee_cooldown = 0.5
var ranged_cooldown = 1.0
var dash_cooldown = 3.0
var dash_duration = 0.2

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
