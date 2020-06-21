extends Control

func _on_Play_gui_input(event):
	if event is InputEventMouseButton and event.is_pressed():
		get_tree().change_scene("res://ConquestDialogue.tscn")

func _on_Quit_gui_input(event):
	if event is InputEventMouseButton and event.is_pressed():
		get_tree().quit()
