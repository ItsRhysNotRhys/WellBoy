extends Node2D

onready var dash_cd = $DashCD
onready var dash_duration = $DashDuration
onready var ghost_timer = $GhostTimer
var dash_ghost = preload("res://Attacks_Abilities/Dash/DashGhost.tscn")
var can_dash = true
var sprite

func _ready():
	dash_cd.wait_time = Globals.dash_cooldown
	
func start_dash(sprite, duration):
	self.sprite = sprite
	sprite.material.set_shader_param("mix_weight", 0.7)
	sprite.material.set_shader_param("whiten", true)
	dash_duration.wait_time = duration
	ghost_timer.start()
	dash_duration.start()
	$dasheffect.play()
	instance_ghost()
	
func instance_ghost():
	var ghost: Sprite = dash_ghost.instance()
	get_parent().get_parent().add_child(ghost)
	
	ghost.scale = sprite.scale
	ghost.global_position = global_position
	ghost.texture = sprite.texture
	ghost.hframes = sprite.hframes
	ghost.vframes = sprite.vframes
	ghost.frame  = sprite.frame
	ghost.flip_h = sprite.flip_h

	
	
func is_dashing():
	return !dash_duration.is_stopped()

func end_dash():
	can_dash = false
	ghost_timer.stop()
	sprite.material.set_shader_param("whiten", false)
	dash_cd.start()
	
func _on_DashDuration_timeout():
	end_dash()
	get_parent().canShoot = true


func _on_GhostTimer_timeout():
	instance_ghost()


func _on_DashCD_timeout():
	dash_cd.wait_time = Globals.dash_cooldown
	can_dash = true
