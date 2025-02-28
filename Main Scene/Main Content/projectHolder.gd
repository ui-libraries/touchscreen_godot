extends Control
# box width constraints
var minBoxWidth = 280
var maxBoxWidth = 800
var idealBoxWidth = 480

var minButtonWidth = 65
var maxButtonWidth = 120

var boxHeight = 20

# tools we'll be using to build the box
var navBox = ColorRect.new()

var navButtonTemplate = load("res://Main Scene/Main Content/navBoxButton.tscn")

var minSeparation = 10
var maxSeparation = 48

var visibleProject = 0

var distanceFromBottom = 80

var navButtonGroup: ButtonGroup
@onready var numProjects = $projectLinks.get_child_count()
# Called when the node enters the scene tree for the first time.
func _ready():
	if numProjects <= 1:
		return 
	#first we'll go ahead and customize our navButtonBox
	navBox.color = Color.TRANSPARENT

	# we'll ensure minBoxWidth is a valid width so we don't waste as much time
	minBoxWidth = max(minButtonWidth * numProjects + minSeparation * (numProjects - 1), minBoxWidth)

	var result = calculate_width_and_separation(idealBoxWidth)
	if result.is_empty():
		result = calculate_box_size(minBoxWidth, maxBoxWidth)
		if result.is_empty():
			print("No valid solution found, even after adjusting box size.")
			return 
	#print("Width: ", result["width"], "separation: ", result["separation"], "box_size: ", result["box_size"])
	makeNavButtonBox(result["width"], result["separation"], result["box_size"])

func calculate_width_and_separation(box_size) -> Dictionary:
	"""
	Calculates the width (w) and separation (s) for a given box size and item count.

	Args:
		box_size: The size of the box containing the items.
	Returns:
		A dictionary containing the calculated width (w), separation (s), and 
		the box_size (if any).
	"""
	# Attempt to find a solution with the current box_size
	for i in range(minSeparation, maxSeparation + 1):
		var separation = i
		var width = int((box_size - (numProjects - 1) * separation) / numProjects)
		# Check if width is positive
		if width > minButtonWidth and width < maxButtonWidth and (width * numProjects) + ((numProjects - 1) * separation) == box_size:
			return {"width": width, "separation": separation, "box_size": box_size}
	return {}

func calculate_box_size(minBoxSize, maxBoxSize) -> Dictionary:
	for i in range(minBoxSize, maxBoxSize):
		for j in range(minSeparation, maxSeparation + 1):
			var res = calculate_width_and_separation(i)
			if not res.is_empty():
				return res
	return {} 

func makeNavButtonBox(buttonWidth, buttonSeparation, boxWidth):
	var sceneRoot = get_parent().get_parent().get_parent()
	# add our box to the scene
	self.add_child(navBox)
	navBox.owner = sceneRoot
	# set its appropriate properties 
	navBox.size = Vector2(boxWidth, boxHeight)
	navBox.position = get_parent().position + Vector2((size.x - boxWidth) / 2, size.y - boxHeight - distanceFromBottom)
	
	# make navBox's children
	var nextButtonPosition = Vector2(navBox.position)
	#print(navBox.owner.name, " ", navBox.get_parent().name, " ", navBox.size)
	
	for i in range(numProjects):
		# init button
		var button = navButtonTemplate.instantiate()
		# set relevant button properties
		button.name = "project_nav_button_%d" % i
		button.size = Vector2(buttonWidth, boxHeight)
		#print(Vector2(buttonWidth, boxHeight))
		button.position = Vector2(nextButtonPosition)
		button.idx = i 
		button.top_level = true # for some reason won't show unless this is true. now requires that 
		button.mouse_default_cursor_shape = CURSOR_POINTING_HAND
		#button.set_idx(i)
		#button.toggle_mode = true
		if i == 0:
			button.button_pressed = true
		# connect signal to desired function
		button.toggled.connect(_on_project_nav_button_toggled.bind(button.idx))
		# add to scene
		navBox.add_child(button)
		button.owner = sceneRoot
		# update nextButtonPosition 
		nextButtonPosition += Vector2(buttonWidth + buttonSeparation, 0)
		#print(button.owner.name, " ", button.get_parent().name, " ", button.size, " ", button.position)

func _on_project_nav_button_toggled(on, idx):
	# friggin button groups aren't working so gotta do it old fashoned way
	if on:
		navBox.get_child(visibleProject).set_pressed(false) # hopefully this updates everything		
		$projectLinks.get_child(idx).visible = true 
		visibleProject = idx
	else:
		$projectLinks.get_child(idx).visible = false 

func _on_nav_button_left_pressed():
	var nowVisible = visibleProject - 1
	if nowVisible == -1:
		nowVisible = numProjects - 1
	navBox.get_child(nowVisible).set_pressed(true) # hopefully this updates everything

func _on_nav_button_right_pressed():
	var nowVisible = visibleProject + 1
	if nowVisible == numProjects:
		nowVisible = 0
	navBox.get_child(nowVisible).set_pressed(true) # hopefully this updates everything 
