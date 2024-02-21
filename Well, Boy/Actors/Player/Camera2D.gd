extends Camera2D


var cameraSway = 125
var cameraSpeed = 0.5
var cameraSnap = 0.5
var dirX = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	dirX = 0
	
	#Get what direction the player is inputing, if they are holding both directions, the character will not move
	if Input.is_action_pressed("move_left"):
		dirX -= 1
	if Input.is_action_pressed("move_right"):
		dirX += 1
	
	if dirX > 0 and position.x < cameraSway:
		if position.x < 0:
			position.x += cameraSpeed*2
		else:
			position.x += cameraSpeed
	elif dirX < 0 and position.x > -cameraSway:
		if position.x > 0:
			position.x -= cameraSpeed*2
		else:
			position.x -= cameraSpeed
	elif dirX != 0:
		pass
	elif position.x < 0:
		position.x += cameraSnap
	elif position.x > 0:
		position.x -= cameraSnap
