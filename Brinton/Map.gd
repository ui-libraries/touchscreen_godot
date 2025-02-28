extends Control


func _on_map_pressed():
	return 
	
	visible = true


func _on_map_toggled(toggled_on:bool):
	if toggled_on: visible = true 
	else: visible = false
