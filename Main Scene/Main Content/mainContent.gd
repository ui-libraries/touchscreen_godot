extends Panel

var brintonPath = "res://Brinton/Brinton.tscn"
var whitmanPath = "res://Whitman/Whitman.tscn"
var tractatusPath = "res://Tractatus/Tractatus.tscn"

@onready var aboutPage = $infoPages/AboutPage
@onready var projectsPage = $infoPages/ProjectsPage
@onready var pdhPage = $infoPages/PDHPage


func _on_studio_button_toggled(toggled_on):
	if toggled_on:
		$projectHolder.visible = true
		$infoPages.visible = false
	else:
		$projectHolder.visible = false
		$infoPages.visible = true

func _on_about_button_toggled(toggled_on):
	if toggled_on: aboutPage.visible = true
	else: aboutPage.visible = false

func _on_projects_button_toggled(toggled_on):
	if toggled_on: projectsPage.visible = true
	else: projectsPage.visible = false

func _on_pdh_button_toggled(toggled_on):
	if toggled_on: pdhPage.visible = true
	else: pdhPage.visible = false

func _on_brinton_pressed():
	LoadManager.load_scene(brintonPath)

func _on_whitman_pressed():
	LoadManager.load_scene(whitmanPath)

func _on_tractatus_pressed():
	LoadManager.load_scene(tractatusPath)



