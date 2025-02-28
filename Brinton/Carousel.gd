extends ScrollContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	get_h_scroll_bar().rect_min_size.y = 12

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
