extends TextureButton


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func navButtonPressed(toggled):
	if toggled:
		self.visible = true
	else: 
		self.visible = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
