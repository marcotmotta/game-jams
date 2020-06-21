extends Control

func _on_TextureRect_gui_input(event):
	if event is InputEventMouseButton and event.is_pressed():
		get_tree().change_scene("res://Menu.tscn")
