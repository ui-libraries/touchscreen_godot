extends ColorRect


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_lantern_atb_pressed():
	visible = true

func _on_lantern_btb_pressed():
	visible = true

func _on_lantern_dtb_pressed():
	visible = true

func _on_lantern_etb_pressed():
	visible = true

func _on_lantern_ftb_pressed():
	visible = true

func _on_lantern_gtb_pressed():
	visible = true

func _on_lantern_ctb_pressed():
	visible = true

func _on_exit_pressed():
	print("lantern exit pressed")
	visible = false
