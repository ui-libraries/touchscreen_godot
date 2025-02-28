extends Panel

@onready var f1 = $floor1
@onready var f2 = $floor2
@onready var f3 = $floor3
@onready var f4 = $floor4
@onready var f5 = $floor5

func _on_f_1_toggled(toggled_on:bool):
	if toggled_on: f1.visible = true 
	else: f1.visible = false
func _on_f_2_toggled(toggled_on:bool):
	if toggled_on: f2.visible = true 
	else: f2.visible = false
func _on_f_3_toggled(toggled_on:bool):
	if toggled_on: f3.visible = true 
	else: f3.visible = false
func _on_f_4_toggled(toggled_on:bool):
	if toggled_on: f4.visible = true 
	else: f4.visible = false
func _on_f_5_toggled(toggled_on:bool):
	if toggled_on: f5.visible = true 
	else: f5.visible = false