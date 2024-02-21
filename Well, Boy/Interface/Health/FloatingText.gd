extends Node2D

onready var label = $Label
onready var tween = $Tween


var velocity = Vector2(0,0)
var amount = 0
var type = ""
var actor = ""
var start_size = Vector2(1.5,1.5)
var max_size_dummy = Vector2(1,1)
var max_size = Vector2(3,3)

func _ready():
	randomize()
	var move = randi() % 81 - 40
	velocity = Vector2(move, 25)
	
	label.set_text(str(amount))
	match type:
		"Heal":
			label.set("custom_colors/font_color", Color("2eff27"))
		"Damage":
			label.set("custom_colors/font_color", Color("ff3131"))
		"Crit":
			max_size_dummy = Vector2(1.5,1.5)
			max_size = Vector2(4,4)
			label.set("custom_colors/font_color", Color("39beff"))
	
	match actor:
		"Player":
			tween.interpolate_property(self, 'scale', start_size, max_size, 0.2, Tween.TRANS_LINEAR, Tween.EASE_OUT)
			tween.interpolate_property(self, 'scale', max_size, Vector2(1,1), 0.3, Tween.TRANS_LINEAR, Tween.EASE_OUT, 0.3)
			
		"Dummy":
			tween.interpolate_property(self, 'scale', scale, max_size_dummy, 0.2, Tween.TRANS_LINEAR, Tween.EASE_OUT)
			tween.interpolate_property(self, 'scale', max_size_dummy, Vector2(0.1,0.1), 0.3, Tween.TRANS_LINEAR, Tween.EASE_OUT, 0.3)
			
		"Slime":
			tween.interpolate_property(self, 'scale', Vector2(start_size.x * 0.8,start_size.x * 0.8), Vector2(max_size.x * 0.8,max_size.x * 0.8), 0.2, Tween.TRANS_LINEAR, Tween.EASE_OUT)
			tween.interpolate_property(self, 'scale', Vector2(max_size.x * 0.8,max_size.x * 0.8), Vector2(0.8,0.8), 0.3, Tween.TRANS_LINEAR, Tween.EASE_OUT, 0.3)
		
		"Bat":
			tween.interpolate_property(self, 'scale', Vector2(start_size.x * 0.8,start_size.x * 0.8), Vector2(max_size.x * 0.8,max_size.x * 0.8), 0.2, Tween.TRANS_LINEAR, Tween.EASE_OUT)
			tween.interpolate_property(self, 'scale', Vector2(max_size.x * 0.8,max_size.x * 0.8), Vector2(0.8,0.8), 0.3, Tween.TRANS_LINEAR, Tween.EASE_OUT, 0.3)
		
		"Wolf":
			tween.interpolate_property(self, 'scale', Vector2(start_size.x * 0.9,start_size.x * 0.9), Vector2(max_size.x * 0.9,max_size.x * 0.9), 0.2, Tween.TRANS_LINEAR, Tween.EASE_OUT)
			tween.interpolate_property(self, 'scale', Vector2(max_size.x * 0.9,max_size.x * 0.9), Vector2(0.9,0.9), 0.3, Tween.TRANS_LINEAR, Tween.EASE_OUT, 0.3)
		
		"Heavy":
			tween.interpolate_property(self, 'scale', start_size, max_size, 0.2, Tween.TRANS_LINEAR, Tween.EASE_OUT)
			tween.interpolate_property(self, 'scale', max_size, Vector2(1,1), 0.3, Tween.TRANS_LINEAR, Tween.EASE_OUT, 0.3)
		
		"Zombie":
			tween.interpolate_property(self, 'scale', start_size, max_size, 0.2, Tween.TRANS_LINEAR, Tween.EASE_OUT)
			tween.interpolate_property(self, 'scale', max_size, Vector2(1,1), 0.3, Tween.TRANS_LINEAR, Tween.EASE_OUT, 0.3)
		
		"Boss":
			pass
			
	tween.start()

func _on_Tween_tween_all_completed():
	self.queue_free()

func _process(delta):
	if type == "Heal":
		pass
	elif type == "Damage" or type == "Crit":
		position -= velocity * delta
