@tool
extends Node

@export var zoom_increment: float = .1
@export var zoom: float = 1:
	set(newZoom):
		setZoom(newZoom)
		zoom = newZoom
	get: return zoom 
@export var offset: Vector2 = Vector2.ZERO:
	set(newOffset):
		setOffset(newOffset)
		offset = newOffset
	get: return offset

@onready var infoVb = $InfoPopup/InfoContainer
# @onready var infoVb = $InfoPopup/ScrollContainer/InfoContainer
const infoVbPath: NodePath = NodePath("InfoPopup/InfoContainer")
# const infoVbPath: NodePath = NodePath("InfoPopup/ScrollContainer/InfoContainer")
@onready var graph = $Margin/ContainerOverride/Graph
const graphPath: NodePath = NodePath("Margin/ContainerOverride/Graph")
@onready var zoomLabel = $Margin/ContainerOverride/Menu/ZoomBox/Zoom
const zoomLabelPath: NodePath = NodePath("Margin/ContainerOverride/Menu/ZoomBox/Zoom")

# group names 
const GRAPH_ELEMENTS = "elements"
const VISIBLE_POPUPS = "visiblePopups"
const POPUPS = "popups"
const CONNECTED_NODES = "connectedNodes"
const CONNECTED_POPUPS = "connectedPopups"


const tractatusPath = "res://Tractatus/Tractatus.tscn"
const resource_directory = "res://Tractatus/TractatusMap/"

var _tables: Dictionary = {}
var _properties: Dictionary = {}

var _templates: Dictionary = {}

var resourcesLoaded = false

var elementInfoCloseButtonPath: NodePath

func makeElementGroup():
	if get_tree().has_group(GRAPH_ELEMENTS) and get_tree().get_node_count_in_group() != 0: return
	for child in get_node(graphPath).get_children():
		child.add_to_group(GRAPH_ELEMENTS, true)

func _ready():
	if not get_tree().has_group(GRAPH_ELEMENTS): makeElementGroup()
	loadGraphResources()




func loadGraphResources():
	if not resource_directory:
		print("input save directory before running this scene")
		return 
	
	print("loading element properties ...")
	var p = getDatFileContents(resource_directory+"/element properties.dat")
	if not p:
		print("failed to load property data.")
		return
	_properties = p
	#print(_properties)
	print("loading element templates ...")
	var t = loadTemplates()
	if t.is_empty():
		print("failed loading element templates.")
		return 
	_templates = t

	print("loading element data ...")
	var elemData = getDatFileContents(resource_directory+"/elements.dat")
	if not elemData:
		print("failed getting element file contents.")
		return 
	var tables = makeTables(elemData)
	#print(type_string(typeof(tables["lines"].getRow(0)["position"][0])))
	if not tables:
		print("failed making tables from element data file.")
		return 
	# for tab in tables:
	# 	tables[tab].head(3)
	_tables = tables
	resourcesLoaded = true
	if infoVb == null: infoVb = get_node(infoVbPath)
	if graph == null: graph = get_node(graphPath)
	if zoomLabel == null: zoomLabel = get_node(zoomLabelPath)
	print("resources loaded.")

func getDatFileContents(path):
	var pfile = FileAccess.open(path, FileAccess.READ)
	if pfile == null:
		print("failed to open properties file: %s" % error_string(FileAccess.get_open_error()))
		return 
	var ppstr = pfile.get_pascal_string()
	if not ppstr:
		print("failed to get_pascal_string: %s" % pfile.get_error())
		return 
	
	var props = JSON.parse_string(ppstr)
	if not props:
		print("error in parsing properties pascal string string")
		return 
	elif not props is Dictionary:
		print("parsed pascal string is %s, not Dictionary." % type_string(typeof(props)))
		return 
	else:
		return props 

func loadTemplates() -> Dictionary:
	var path = resource_directory + "/element templates/"
	var loadedTemplates = {}
	for e in _properties:
		var d = _properties[e]
		if not d.has("template"):
			print("table %s has no assigned template" %e)
		elif loadedTemplates.has(d["template"]):
			continue
		var templatePath = path + str(d["template"]) + ".tscn"
		
		var template = load(templatePath)
		if not template:
			print("error loading template %d" %d["template"])
			continue 
		elif not template.can_instantiate():
			print("error: template scene %d cannot instantiate" % d["template"])
			continue
		
		elif not loadedTemplates.has(template): 
			loadedTemplates[str(d["template"])] = template
	return loadedTemplates

func makeTables(nestedDict: Dictionary) -> Dictionary:
	var tables = {}
	for tname in nestedDict:
		var t = DataTable.new(nestedDict[tname], tname)
		if t.hasColumn("position"):
			if getMultiEntry_Position(tname):
				var col = []
				for arr in t.getColumn("position"):
					col.append(array_of_strings_to_vectors(arr))
				t.setColumn("position", col)
			else:
				t.setColumn("position", array_of_strings_to_vectors(t.getColumn("position")))
		if t.hasColumn("shape"):
			if getMultiEntry_Position(tname):
				var col = []
				for arr in t.getColumn("shape"):
					col.append(array_of_strings_to_vectors(arr))
				t.setColumn("shape", col)
			else:
				t.setColumn("shape", array_of_strings_to_vectors(t.getColumn("shape")))
		tables[tname] = t

	return tables

func string_to_vector2(string):
	var parts = string.lstrip("(").rstrip(")").split(",")
	if parts.size() != 2:
		print("parts not valid length D:")
		return Vector2.ZERO 
	var x = float(parts[0].strip_edges())
	var y = float(parts[1].strip_edges())
	return Vector2(x, y)
func array_of_strings_to_vectors(string_array):
	var vector_array = []
	for string in string_array:
		vector_array.append(string_to_vector2(string))
	return vector_array


func propertiesHasTable(tableName) -> bool:
	if not _properties.has(tableName):
		print("_properties doesn't have table %s as a key" % tableName)
		return false 
	return true

func getTemplateNum(tableName) -> int:
	if not propertiesHasTable(tableName): return -1 
	return _properties[tableName]["template"]
func getMultiEntry_Position(tableName) -> bool:
	if not propertiesHasTable(tableName): return false
	return _properties[tableName].has("multiEntry_Position")
func getCircular(tableName) -> bool:
	if not propertiesHasTable(tableName): return false
	return _properties[tableName].has("circular")
func getLabelElement(tableName) -> bool:
	if not propertiesHasTable(tableName): return false
	return _properties[tableName].has("labelElement")
func getLabelPlacement(tableName) -> int:
	if not propertiesHasTable(tableName): return false
	if not _properties[tableName].has("labelPlacement"): return GraphDataManager.labelPlacementOptions.TOP_RIGHT
	return _properties[tableName]["labelPlacement"]
func getPopupPlacement(tableName) -> String:
	if not propertiesHasTable(tableName): return ""
	return _properties[tableName]["popupPlacement"]
func getMultiEntry_Popop(tableName) -> bool:
	if not propertiesHasTable(tableName): return false
	return _properties[tableName].has("multiEntry_Popop")
func getPathInfoToOptionButton(tableName) -> String:
	if not propertiesHasTable(tableName) or not _properties[tableName].has("InfoOptionButtonPath"): return ""
	else: return _properties[tableName]["InfoOptionButtonPath"]
func getPathInfoToContent(tableName) -> String:
	if not propertiesHasTable(tableName) or not _properties[tableName].has("InfoContentPath"): return ""
	else: return _properties[tableName]["InfoContentPath"]


func _on_zoom_in_pressed():
	zoom = zoom + zoom_increment
	#setZoom(zoom + zoom_increment)
func _on_zoom_out_pressed():
	#setZoom(zoom - zoom_increment)
	zoom = zoom - zoom_increment

func setZoom(newZoom: float):
	if not Engine.is_editor_hint() and not is_node_ready(): await ready
	var posScale = Vector2(newZoom/zoom, newZoom/zoom)
	for child in get_node(graphPath).get_children():
		child.scale = Vector2(newZoom, newZoom)
		child.position = child.position * posScale
	get_node(zoomLabelPath).text = str( (round(newZoom*pow(10,5))/pow(10,5)))

func setOffset(newOffset: Vector2):
	if not Engine.is_editor_hint() and not is_node_ready(): await ready
	var realOffset = newOffset - offset 
	for child in get_node(graphPath).get_children():
		child.position = child.position + realOffset

func _on_separated_popup_close_pressed(elementName):
	var info = infoVb.get_node(String(elementName))
	info.visible = false
	info.remove_from_group(VISIBLE_POPUPS)
	# var popupPanelPath = "../../"
	var popupPanelPath = "../"
	if get_tree().get_nodes_in_group(VISIBLE_POPUPS).is_empty():
		infoVb.get_node(popupPanelPath).visible = false

func _on_anchored_popup_close_pressed(elementName):
	var info = graph.get_node("%s/Info" % elementName)
	info.visible = false 

func _on_separated_node_pressed(elementName):
	var info = infoVb.get_node(String(elementName))
	if info.visible: return 
	info.visible = true
	info.add_to_group(VISIBLE_POPUPS, true)
	infoVb.move_child(info, len(get_tree().get_nodes_in_group(VISIBLE_POPUPS)))
	# var popupPanelPath = "../../"
	var popupPanelPath = "../"
	infoVb.get_node(popupPanelPath).visible = true 

func _on_anchored_node_pressed(elementName):
	var info = graph.get_node("%s/Info" % elementName)
	info.visible = true 

func _on_anchored_popup_item_selected(optionIndex, elementName):
	var tableName = elementName.get_slice("_", 0)
	var tableIndex = int(elementName.get_slice("_", 1).rstrip("Info"))
	var popupData = _tables[tableName].getRow(tableIndex)
	var keys = popupData.keys()
	keys.sort()
	keys.reverse()
	var info = graph.get_node("%s/Info" % elementName)
	var rtl = graph.get_node("%s/Info/%s" % [elementName, getPathInfoToContent(tableName)])
	if not rtl: rtl = info.find_child("ContentRTL", true, false)
	var preUpdateSize = rtl.size.y
	rtl.text = global.html_to_bbcode(popupData[keys[optionIndex]])
	info.custom_minimum_size = info.custom_minimum_size + Vector2(0, maxf(0, (rtl.size.y - preUpdateSize)))
	
func _on_separated_popup_item_selected(optionIndex, elementName):
	var tableName = elementName.get_slice("_", 0)
	var tableIndex = int(elementName.get_slice("_", 1).rstrip("Info"))
	var popupData = _tables[tableName].getRow(tableIndex)["popupData"]
	var keys = popupData.keys()
	keys.sort()
	keys.reverse()
	var info = infoVb.get_node(NodePath(elementName))
	var rtl = info.get_node(getPathInfoToContent(tableName))
	if not rtl: rtl = info.find_child("ContentRTL", true, false)
	var preUpdateSize = rtl.size.y
	rtl.text = global.html_to_bbcode(popupData[keys[optionIndex]])
	info.custom_minimum_size = info.custom_minimum_size + Vector2(0, maxf(0, (rtl.size.y - preUpdateSize)))


func _on_mainexit_pressed():
	LoadManager.load_scene(tractatusPath)
