extends Sprite

onready var timer = $Timer
onready var time_label = $Counter/Value
onready var lifesteal = $Lifesteal
onready var crit = $Crit
export var cooldown = 0.0
export var ability = 0.0
export(String, "dash", "melee", "ranged", "lifesteal", "crit") var ability_type = "dash"

func _ready():
	if ability_type == "dash":
		print("dashing")
		ability = Globals.dash_cooldown + 0.2
	elif ability_type == "melee":
		ability = Globals.melee_cooldown
	elif ability_type == "lifesteal":
		ability = Globals.lifesteal_cooldown
	elif ability_type == "crit":
		ability = Globals.crit_cooldown
	else:
		ability = Globals.ranged_cooldown
		
	cooldown = ability
	$Timer.wait_time = cooldown
	time_label.hide()
	$Sweep.texture_progress = texture
	$Sweep.value = 0
	

func _process(delta):
	if cooldown == 0:
		return
	time_label.text = "%3.1f" % $Timer.time_left
	$Sweep.value = int(($Timer.time_left / cooldown) * 100)


func initiate_cooldown():
	set_process(true)
	$Timer.start()
	time_label.show()


func _on_Timer_timeout():
	$Sweep.value = 0
	time_label.hide()
	$Timer.wait_time = cooldown
	
