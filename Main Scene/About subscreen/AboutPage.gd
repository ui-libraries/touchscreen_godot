extends Control

var brintonPath = "res://Brinton/Brinton.tscn"
var whitmanPath = "res://Whitman/Whitman.tscn"
var tractatusPath = "res://Tractatus/Tractatus.tscn"	


func _on_porject_1_picture_pressed():
	LoadManager.load_scene(brintonPath)

func _on_porject_2_picture_pressed():
	LoadManager.load_scene(whitmanPath)

func _on_porject_3_picture_pressed():
	LoadManager.load_scene(tractatusPath)
