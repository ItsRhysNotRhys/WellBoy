extends Node2D

const bulletScene = preload("res://Attacks_Abilities/RangedAttack/BossBullet.tscn")
onready var shootTimer = $ShootInterval
onready var rotater = $Rotater

const rotateSpeed = 250
const shootWait = 0.5
const spawnPoints = 2
const radius = 100


# Called when the node enters the scene tree for the first time.
func _ready():
	var step = 2 * PI / spawnPoints
	
	for i in range(spawnPoints):
		var spawnPoint = Node2D.new()
		var pos = Vector2(radius, 0).rotated(step * i)
		spawnPoint.position = pos
		spawnPoint.rotation = pos.angle()
		rotater.add_child(spawnPoint)
	
	shootTimer.wait_time = shootWait
	shootTimer.start()
	


func _process(delta):
	var new_rotation =  rotater.rotation_degrees + rotateSpeed * delta
	rotater.rotation_degrees = fmod(new_rotation, 360)


func _on_ShootInterval_timeout():
	for s in rotater.get_children():
		var bullet = bulletScene.instance()
		get_tree().root.add_child(bullet)
		bullet.position = s.global_position
		bullet.rotation = s.global_rotation
