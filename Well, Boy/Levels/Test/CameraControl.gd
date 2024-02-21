extends Camera2D


onready var player = get_node("/root/Main/Player")

func _process(delta):
	player.align()
