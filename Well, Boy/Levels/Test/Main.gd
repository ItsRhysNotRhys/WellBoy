extends Node

var slime = preload("res://Actors/Enemies/Slime.tscn")
var wolf = preload("res://Actors/Enemies/Wolf.tscn")
var heavy = preload("res://Actors/Enemies/Heavy.tscn")
var bat = preload("res://Actors/Enemies/Bat.tscn")

var spawn_start = 8500

var melee = preload("res://art/HUD/k.png")
var ranged = preload("res://art/HUD/J.png")

var lifesteal_melee = preload("res://art/HUD/K (BUT RED).png")
var lifesteal_ranged = preload("res://art/HUD/J (BUT RED).png")

var crit_melee = preload("res://art/HUD/K (BUT PINK).png")
var crit_ranged = preload("res://art/HUD/J (BUT PINK).png")

func _ready():
	var player_health = $Player/Health
	var player_healthbar = $CanvasLayer/HealthBar
	
	player_health.connect("health_changed", player_healthbar, "set_value")
	player_health.connect("max_changed", player_healthbar, "set_max")
	player_health.initialize()
	
	for n in 0:
		var slime_instance = slime.instance()
		slime_instance.global_position.x = spawn_start - (n*500)
		add_child(slime_instance)
		
	for n in 0:
		var wolf_instance = wolf.instance()
		wolf_instance.global_position.x = spawn_start - (n*500)
		add_child(wolf_instance)
	
	for n in 1:
		print("Spawned heavy")
		var heavy_instance = heavy.instance()
		heavy_instance.global_position.x = spawn_start - (n*500)
		add_child(heavy_instance)
	
func _process(delta):
	if $Player.lifesteal == true:
		get_node("CanvasLayer/MeleeCooldown").set_texture(lifesteal_melee)
		get_node("CanvasLayer/RangedCooldown").set_texture(lifesteal_ranged)
		get_node("CanvasLayer/MeleeCooldown").lifesteal.emitting = true
		get_node("CanvasLayer/RangedCooldown").lifesteal.emitting = true
		get_node("CanvasLayer/LifestealCooldown").lifesteal.emitting = true
		get_node("CanvasLayer/HealthBar").lifesteal.emitting = true
		
	elif $Player.crit == true:
		get_node("CanvasLayer/MeleeCooldown").set_texture(crit_melee)
		get_node("CanvasLayer/RangedCooldown").set_texture(crit_ranged)
		get_node("CanvasLayer/MeleeCooldown").crit.emitting = true
		get_node("CanvasLayer/RangedCooldown").crit.emitting = true
		get_node("CanvasLayer/CritCooldown").crit.emitting = true
		get_node("CanvasLayer/HealthBar").crit.emitting = true
		
	else:
		get_node("CanvasLayer/MeleeCooldown").set_texture(melee)
		get_node("CanvasLayer/RangedCooldown").set_texture(ranged)
		get_node("CanvasLayer/MeleeCooldown").lifesteal.emitting = false
		get_node("CanvasLayer/RangedCooldown").lifesteal.emitting = false
		get_node("CanvasLayer/MeleeCooldown").crit.emitting = false
		get_node("CanvasLayer/RangedCooldown").crit.emitting = false
		get_node("CanvasLayer/LifestealCooldown").lifesteal.emitting = false
		get_node("CanvasLayer/CritCooldown").crit.emitting = false
		get_node("CanvasLayer/HealthBar").lifesteal.emitting = false
		get_node("CanvasLayer/HealthBar").crit.emitting = false

	
