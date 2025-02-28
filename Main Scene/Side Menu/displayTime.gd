extends Label

var time = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	update_time()

func update_time():
	# Get current time
	var current_time = Time.get_time_dict_from_system()
	
	# We're going to put time in meridian format
	var meridian
	
	# Take hour and format, setting meridian conditionally
	var hour = current_time.hour
	var formatted_hour = hour % 12
	if formatted_hour == 0:
		formatted_hour = 12
	
	if formatted_hour == hour:
		meridian = "am"
	else:
		meridian = "pm"
	
	# Format the time
	var pre_formatted_time = "%d:%02d " % [formatted_hour, current_time.minute]
	var formatted_time = pre_formatted_time + meridian
	# Update the Label text
	text = formatted_time

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += 1
	if time>= 60:
		update_time()
		time = 0
