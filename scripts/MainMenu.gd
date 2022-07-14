extends Control

func _on_PlayButton_pressed():
	get_tree().change_scene("res://scenes/Root.tscn")

func _on_QuitGame_pressed():
	get_tree().quit()

func _on_OptionsButton_pressed():
	$PauseMenu.visible = true
