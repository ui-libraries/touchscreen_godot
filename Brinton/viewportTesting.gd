extends Control

var time = 0.0
var numcalls = 0.0
var path = "res://textures/lanterns/lanternC (%d).jpg"
var current = 0
var max = 13
# Called when the node enters the scene tree for the first time.
func _ready():
	await get_tree().create_timer(.5).timeout


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_pressed():
	current += 1 
	if current > max: 
		current = 1
	$TextureRect.texture = load(path % current)
