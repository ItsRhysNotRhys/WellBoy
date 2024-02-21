extends Node

signal max_changed(new_max)
signal health_changed(new_health)
signal dead

var initialized = false

export(int) var max_health = 10 setget set_max
onready var health = max_health setget set_current

func _ready():
	initialize()
	
func set_max(new_max):
	max_health = new_max
	max_health = max(1,new_max)
	emit_signal("max_changed", max_health)
	
func set_current(new_health):
	health = new_health
	health = clamp(health, 0, max_health)
	emit_signal("health_changed", health)
	
	if health == 0:
		emit_signal("dead")

func initialize():
	emit_signal("max_changed", max_health)
	emit_signal("health_changed", health)
	initialized = true
