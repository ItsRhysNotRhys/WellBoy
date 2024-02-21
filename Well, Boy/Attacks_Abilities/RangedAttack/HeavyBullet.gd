extends Area2D

var speed = 20
var damage = 15

func _ready():
	position.y -= 0
	$AnimationPlayer.play("heavyshot")
	$Sprite.flip_h = true
	$Timer.start()
	var scaling = int(get_parent().get_parent().name)
	damage = round(damage + damage*0.2*scaling)
	
func _physics_process(delta):
	
	position += transform.x * speed



func _on_HeavyBullet_area_entered(area):
	
	if area.get_parent().name == "Player":
		queue_free()


func _on_Timer_timeout():
	queue_free()
