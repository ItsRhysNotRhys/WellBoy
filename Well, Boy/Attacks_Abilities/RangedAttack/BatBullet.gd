extends Area2D

var player = null
var target = Vector2.ZERO
var move = Vector2.ZERO
var speed = 20
var damage = 5

# Called when the node enters the scene tree for the first time.
func _ready():
	target = player.position - global_position
	$AnimationPlayer.play("batshot")
	var scaling = int(get_parent().get_parent().name)
	print(scaling)
	damage = round(damage + damage*0.2*scaling)
	
func _physics_process(delta):
	
	move = move.move_toward(target, delta)
	move = move.normalized() * speed
	position += move


func _on_Bullet_area_entered(area):
	
	if area.get_parent().name == "Player":
		queue_free()


func _on_Timer_timeout():
	queue_free()
