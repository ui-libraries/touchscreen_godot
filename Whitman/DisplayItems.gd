extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_faces_of_whitman_toggled(toggled_on:bool):
	if toggled_on: $FacesOfWhitman.visible = true 
	else:  $FacesOfWhitman.visible = false 


func _on_the_maps_toggled(toggled_on:bool):
	if toggled_on: $TheMaps.visible = true 
	else:  $TheMaps.visible = false 


func _on_scholarship_at_iowa_toggled(toggled_on:bool):
	if toggled_on: $ScholarshipAtIowa.visible = true 
	else:  $ScholarshipAtIowa.visible = false 


func _on_past_exibit_toggled(toggled_on:bool):
	if toggled_on: $PastExibit.visible = true 
	else:  $PastExibit.visible = false 
