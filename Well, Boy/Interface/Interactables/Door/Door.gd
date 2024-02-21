extends Node2D

export(String, FILE) var scene
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


onready var root = get_tree().current_scene
onready var current_level_name = get_parent().name
onready var next = str("res://Levels/Stages/Level" +  str(int(current_level_name) + 1) + ".tscn")
onready var next_level = load(next)

var next_level_instance = null

var in_door_area = false
# Called when the node enters the scene tree for the first time.

func _ready():
	$AnimationPlayer.play("animation")
	if next_level != null:
		next_level_instance = next_level.instance()
	
func _process(delta):
	if (in_door_area):
		$Label.visible = true
		if Input.is_action_just_pressed("interact"):
			if next_level != null:
				var current_level = root.get_node(current_level_name)
				root.remove_child(current_level)
				current_level.call_deferred("free")
				root.add_child(next_level_instance)
				root.get_node("Player").set_global_position(Vector2(0,0)) 
				root.get_node("Player").health.set_max(root.get_node("Player").health.max_health + 10)
				root.get_node("Player").curr_level += 1
			
	else:
		$Label.visible = false

func _on_Area2D_body_entered(body: KinematicBody2D):
	if (body!= null and body.name == "Player"):
		in_door_area = true
		
		

func _on_Area2D_body_exited(body):
	if (body!= null and body.name == "Player"):
		in_door_area = false
		
