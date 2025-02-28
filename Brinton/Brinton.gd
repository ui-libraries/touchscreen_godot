extends Control


func _on_texture_button_pressed():
	print("main exit pressed!")
	LoadManager.load_scene("res://Main Scene/home_screen.tscn")
	#get_tree().change_scene_to_file("res://HomeScreen.tscn")
