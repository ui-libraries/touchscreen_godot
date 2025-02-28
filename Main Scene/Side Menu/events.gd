extends Panel

var last_connection_time = 0.0
var numEvents = 3
var eventMaxTimeFrame = {"days": 0, "hours":4,"minutes":0}

var descriptionVisibleTime = 6.5
@onready var httpRequest = get_parent().get_parent().get_parent().find_child("HTTPRequest")

@onready var animator = $AnimationPlayer 

@onready var e1window = $e1DescBg
@onready var e2window = $e2DescBg
@onready var e3window = $e3DescBg


""" 
for readme:

**current event layout:**
 
<div class=\"row item item-visible\">        
	
	
	
	
	<div class=\"col12 eventBox\">
			<div class=\"eventHeader\">
					<a href=\"/87877\">`Event Name`</a></div>
			<p class=\"date\"><i class=\"far fa-calendar-alt\"></i> `Month Abrev, day, year` </p>
			<p class=\"time\"><i class=\"far fa-clock\"></i>

					
							`Start Time AM|PM`
							
									`- End Time AM|PM`
							
					
					


			</p>
			<!--<p class=\"location\" th:if=\"${instance.parentEvent.location.name != null || instance.parentEvent.location.address != null}\"><i class=\"fas fa-map-marker-alt\"></i>-->
			<div class=\"fpLocationHolder\">
					<i class=\"fas fa-map-marker-alt\"></i>
					<p><a href=\"https://www.facilities.uiowa.edu/building/0046\">`Location Name (abbrev)`, #208</a></p>

					<!--<p class=\"locationAddress\" th:text=\"${instance.parentEvent.location.address}\"></p>-->
			</div>

			

			<!--<a th:href=\"${instance.parentEvent.location.link}\" th:remove=\"${instance.parentEvent.location.link == null}? tag : none\" th:text=\"${instance.parentEvent.location.name}\"></a></p>-->

			
			<p class=\"favorite\">
					<i class=\"fas fa-star\"></i> <a href=\"#\" data-toggle=\"modal\" data-target=\"#loginModal\">Save to My Events</a>
			</p>

			<p class=\"description fpDescription\">`Description Part 1`

Description Continued .|...`</p>
	</div>
</div>
"""


const EVENT_DIV = "<div class=\"col12 eventBox\">"
const TITLE_DIV = "<div class=\"eventHeader\">"

const TITLE_END = "</a"
# title start = line.get_slice(">", n) where n = number of lines the title div spans 
const TITLE_START = ">"

const DATE_DIV = "<p class=\"date\">"
const DATE_START = "</i>"
const DATE_END = "</p>"

const TIME_DIV = "<p class=\"time\">"
const TIME_START = "</i>" # never actually used under current event structure
const TIME_RANGE_SEPERATOR = "-"
const TIME_END = "</p>"
const TIME_AM = "AM"
const TIME_PM = "PM"

const DESCRIPTION_DIV = "<p class=\"description fpDescription\">"
const DESCRIPTION_END = "</p>"



const EVENT_DIV_END = "/div"

func convert_str_date_to_numeric(date):
	return date.split(", ")[0]+", "
	# input example: "May 1, 2024"
	var dateSplit = date.split(" ")
	dateSplit[1]= dateSplit[1].replace(",","")
	var month = dateSplit[0]
	if month == "January":
		dateSplit[0]="1"
	elif month == "February":
		dateSplit[0]="2"
	elif month == "March":
		dateSplit[0]="3"
	elif month == "April":
		dateSplit[0]="4"
	elif month == "May":
		dateSplit[0]="5"
	elif month == "June":
		dateSplit[0]="6"
	elif month == "Jun":
		dateSplit[0]="6"
	elif month == "July":
		dateSplit[0]="7"
	elif month == "August":
		dateSplit[0]="8"
	elif month == "September":
		dateSplit[0]="9"
	elif month == "October":
		dateSplit[0]="10"
	elif month == "November":
		dateSplit[0]="11"
	elif month == "December":
		dateSplit[0]="12"
	
	return "/".join(dateSplit)

func extract_event_data(lines, numLines, limitTimeFrame = false) -> Array: 
	# GO BACK THROUGH AFTER REPLACING STRINGS W CONSTS AND REPLACE REPLACE W LSTRIP AND RSTRIP WHEREVER YOU CAN
	"""
	idea here: we're going to go through each line (sadge, first 2700 worthless) looking for the 
	first numEvents events. when we find an event, we look through its div for title, date, time and 
	description. Once we've found those, we create an event dictionary and add it to our list of 
	events. When we have enough, we're done. 
	
	notes: 
	Current method doesn't check to gather all four variables, rather once we've hit description we're
	assuming we've hit everything else since that's the sequential nature of the file. 
	
	limitTimeFrame isn't implemented, but would force escape the function after a certain period of time. 
	
	the way we pull the time variable(s) could def be improved
	"""
	var events = []
	var i = 0
	while events.size()<numEvents and i < numLines:
		var strippedLine = lines[i].strip_edges()
		#looking for our event class
		#HERE THE STRING IN BEGINS_WITH CAN BE REPLACED W/ A VAR PASSED INTO METHOD
		if strippedLine.begins_with(EVENT_DIV):
			
			var linesRead = 1
			var eventAdded = false
			
			var eDate
			var eTime
			var eStartTime
			var eEndTime
			var eTitle 
			var eDescription

			while not eventAdded:
				var currentLine = lines[i+linesRead].strip_edges()
				if currentLine.begins_with(TITLE_DIV):
					# never happens, title is stored on next line with the <a href> tag
					if currentLine.ends_with(TITLE_END):  
						var titleLineNumTags = 2
						eTitle = lines[i+linesRead].strip_edges().get_slice(TITLE_START,titleLineNumTags).replace(TITLE_END,"")
					# for title to overrun 1 line, would have to be > 415 chars, by which case our app would have already cut the title.
					else:
						var titleLineNumTags = 1
						linesRead+=1
						eTitle = lines[i+linesRead].strip_edges().get_slice(TITLE_START,titleLineNumTags).replace(TITLE_END,"")
				
				elif currentLine.begins_with(DATE_DIV):
					if currentLine.ends_with(DATE_END):
						eDate = currentLine.get_slice(DATE_START,1).replace(DATE_END,"")
					elif currentLine.ends_with(DATE_START):
						linesRead += 1
						eDate = lines[i+linesRead].replace(DATE_END,"")
				
				elif currentLine.begins_with(TIME_DIV):
					if currentLine.ends_with(TIME_END): # time specification on one line - doesn't happen but just in case
						if TIME_RANGE_SEPERATOR in currentLine:
							eStartTime = currentLine.get_slice(TIME_START, 1).get_slice(TIME_RANGE_SEPERATOR,0).strip_edges()
							# eStartTime.replace(TIME_AM, "").replace(TIME_PM, "")

							eEndTime = currentLine.get_slice(TIME_RANGE_SEPERATOR,1).get_slice(TIME_END, 0)
							eEndTime.replace(TIME_AM, "").replace(TIME_PM, "")
						
						else: 
							eStartTime = currentLine.get_slice(TIME_START, 1).get_slice(TIME_END, 0)
					
					else:
						var line = ""
						while line != TIME_END:
							# skip any empty lines between TIME_DIV and TIME_END
							while line == "":
								linesRead+=1
								line = lines[i+linesRead].strip_edges()
							
							if line != TIME_END:
								eStartTime = line.rstrip(TIME_END).strip_edges() #.replace(TIME_AM,"").replace(TIME_PM,"").rstrip(TIME_END)
								line = ""
							
							# skip any empty lines between eStartTime and TIME_END
							while line == "":
								linesRead+=1
								line = lines[i+linesRead].strip_edges()
							
							if line!=TIME_END:
								eEndTime = line.rstrip(TIME_END)
								if line.ends_with(TIME_END):
									line = TIME_END
								else:
									line = ""
							
							# skip any empty lines between eEndTime and TIME_END
							while line == "":
								linesRead+=1
								line = lines[i+linesRead].strip_edges()
				
				elif currentLine.begins_with(DESCRIPTION_DIV):
					var description = currentLine.get_slice(DESCRIPTION_DIV,1)
					while not currentLine.ends_with(DESCRIPTION_END):
						linesRead+=1
						currentLine = lines[i+linesRead].strip_edges()
						description+=" "
						description+=currentLine.replace(DESCRIPTION_END,"")
					eDescription = description.replace(DESCRIPTION_END,"") # the replace is completely useless but imma leave it bc i had it in originally
					
					if eEndTime:
						eTime = eStartTime + eEndTime
					else:
						eTime = eStartTime
					var event = {"date": convert_str_date_to_numeric(eDate.strip_edges()),"time": eTime.strip_edges(), "title":eTitle.strip_edges(),"description":eDescription.strip_edges()}
					events.append(event)
					eventAdded = true
				

				linesRead+=1
			i+=linesRead
		i+=1
	return events

func _on_request_completed(result, response_code, headers, body):
	if response_code == 200:
		#parse data
		var lines = body.get_string_from_utf8().split("\n")
		var numLines = lines.size()
		var events = extract_event_data(lines, numLines)
		#update menu labels
		update_menu_labels(events)
	else:
		print("error: connection to events calander unsuccessful")

func event_exists(events, index):
	return index+1 <= events.size()

func connect_to_site():
	#connect signals
	httpRequest.request_completed.connect(_on_request_completed)
	#set up request
	httpRequest.request("https://events.uiowa.edu") 

func update_menu_labels(events):
	var edt
	var etitle
	var edesc
	var event
	var eventsIndex = 0
	while eventsIndex<numEvents and event_exists(events, eventsIndex):
		if event_exists(events, eventsIndex):
			event = events[eventsIndex]
			var eventNum = "event"+str(eventsIndex+1)
			edt = get_node(eventNum+"Time")
			etitle = get_node(eventNum+"Name")
			edesc = get_node("e"+eventNum.lstrip("event")+"DescBg/"+eventNum+"Desc")
			# edesc = get_node("e"+eventNum.lstrip("event")+"DescBg/"+eventNum+"Desc")
			#edesc = get_node(eventNum+"Desc")
			edt.text = event['date'] + " " + event['time']
			etitle.text = event['title']
			edesc.text = event['description']
		eventsIndex+=1

# Called when the node enters the scene tree for the first time.
func _ready():
	if httpRequest == null:
		print("did not find httpRequest Node.")
		return 
	# unhash the below when u want events list to actually update
	connect_to_site()
	last_connection_time = Time.get_ticks_msec() / 1000.0

	# at some point we should update this every quarter/half hour


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var current_time = Time.get_ticks_msec() / 1000.0
	# Calculate the time difference since the last connection
	var time_diff = current_time - last_connection_time
	# Check if 15 minutes (900 seconds) have passed
	if time_diff >= 900:
			# Call the connect_to_site function
			connect_to_site()
			# Update the last connection time
			last_connection_time = current_time

func _on_event_1_info_button_pressed():
	e1window.visible = true 
	animator.play("E1 Description Fade In")
	await get_tree().create_timer(descriptionVisibleTime).timeout 
	animator.play_backwards("E1 Description Fade In")
	await animator.current_animation_changed
	e1window.visible = false 
func _on_event_2_info_button_pressed():
	e2window.visible = true 
	animator.play("E2 Description Fade in")
	await get_tree().create_timer(descriptionVisibleTime).timeout 
	animator.play_backwards("E2 Description Fade in")
	await animator.current_animation_changed
	e2window.visible = false 
func _on_event_3_info_button_pressed():
	e3window.visible = true 
	animator.play("E3 Description Fade In")
	await get_tree().create_timer(descriptionVisibleTime).timeout 
	animator.play_backwards("E3 Description Fade In")
	await animator.current_animation_changed
	e3window.visible = false 
