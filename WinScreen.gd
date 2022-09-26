extends Control

func _on_PlayAgain_pressed():
	get_tree().change_scene("res://Root.tscn")

func _on_Quit_pressed():
	get_tree().quit()

func _on_ObjectsDestroyed_wincondition():
	show() # Replace with function body.
