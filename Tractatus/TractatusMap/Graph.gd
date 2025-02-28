extends Control

var dragging: bool = false
var dragStart: Vector2

func _input(event):
	# handle mouse button
	if event is InputEventMouseButton:
		# recognize left button press as start of drag
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed: dragging = true
		# recognize left button release as end of drag
		elif event.button_index == MOUSE_BUTTON_LEFT and (event.canceled or not event.pressed): dragging = false
	# handle screen touch
	elif event is InputEventScreenTouch:
		# recognize touch as start of drag
		if event.pressed: dragging = true
		# recognize release as end of drag
		else: dragging = false 
	
	# recognize mouse motion with mouse left down as a drag
	elif event is InputEventMouseMotion and dragging:
		# update child positions accordingly
		for child in get_children():
			child.position = child.position + event.relative # screen_relative preferred, but property doesn't actually exist
	# recognize screenDrag as a drag
	elif event is InputEventScreenDrag: # and dragging
		# update child positions accordingly
		for child in get_children():
			child.position = child.position + event.relative # screen_relative preferred, but property doesn't actually exist
