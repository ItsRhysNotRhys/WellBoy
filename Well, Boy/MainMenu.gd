extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var t = Timer.new()
var count = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	
	$VBoxContainer/StartButton.grab_focus()
	$AnimationPlayer.play("animation")
	$Sprites/PlayerAnimations.play("Idle")
	$FadeInAudio.play("Audio")
	$options/VolumeSlider.hide()
	$options/VolumeSlider.value = -30
	$options/RichTextLabel.hide()
	$options/goback.hide()

func _on_StartButton_pressed():
	#Change this when tutorial is made
		get_tree().change_scene("res://Levels/Test/Main.tscn")
	#						 ^^^^^^^^^^^^^^^^^^^^^^^^^^^^

func _on_QuitButton_pressed():
	get_tree().quit()

func _on_HSlider_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), value)

func _on_OptionsButton_pressed():
	$options/goback.grab_focus()
	$titlesprites.hide()
	$VBoxContainer.hide()
	$options/VolumeSlider.show()
	$options/RichTextLabel.show()
	$options/goback.show()

func _on_goback_pressed():
	$VBoxContainer/OptionsButton.grab_focus()
	$options/VolumeSlider.hide()
	$options/goback.hide()
	$options/RichTextLabel.hide()
	$titlesprites.show()
	$VBoxContainer.show()
