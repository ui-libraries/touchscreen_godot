extends Control

var brintonPath = "res://Brinton/Brinton.tscn"
var whitmanPath = "res://Whitman/Whitman.tscn"
var tractatusPath = "res://Tractatus/Tractatus.tscn"

func _on_brinton_pressed():
	LoadManager.load_scene(brintonPath)

func _on_whitman_pressed():
	LoadManager.load_scene(whitmanPath)

func _on_tractatus_pressed():
	LoadManager.load_scene(tractatusPath)

