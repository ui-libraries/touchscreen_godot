extends Control

var mapPath = "res://Tractatus/TractatusMap/tractatusMap.tscn"
var homeScreenPath = "res://Main Scene/home_screen.tscn"

func _on_tractatus_map_link_pressed():
	LoadManager.load_scene(mapPath)

func _on_mainexit_pressed():
	LoadManager.load_scene(homeScreenPath)
