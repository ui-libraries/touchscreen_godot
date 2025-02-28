@tool
class_name DataTableMap extends Resource

## This class is useless now, except to refer to links between DataTable and GraphTable columns
## FUN FACT THIS CLASS TOTALLY HAS USE! HOLDS DATA FOR THE PROPERTY INSPECTOR. NEED FOR _GET IN GRAPH.GD


# labelElement positionIsReference multiEntry_Position shapeIsReference circular shape_Scalar position_Scalar n_Stylebox s_Stylebox

var name
func getName():
	return name
func setName(newName):
	if newName != null and (newName is String or newName is StringName):
		name = newName
	else:
		print("TRYING TO SET MAP'S TABLE NAME TO %s ???" % str(newName))

var _map = {
	"ID": "",
	"ID_Font_Size": "",
	
	"reference_pos": "", ## REFERS TO THE DM WHOSE GRAPHTABLE HAS POSITION SET
	"position": "",

	"x_position": "",
	"y_position": "",	

	"reference_shape": "", ## REFERS TO THE DM WHOSE GRAPHTABLE HAS SHAPE SET
	"shape": "",

	"x_shape": "",
	"y_shape": "",
	
	"reference_popup": "", ## REFERS TO THE DM WHOSE GRAPHTABLE HAS POPUPDATA SET
	"popup": "",

	"normal_color": "",
	"selected_color": "",
	
	"popupData": [],
	## REMOVE, THIS IS A HOT FIX
	# "normal_color": Color("WHITE"),
	# "selected_color": Color("WHITE")
	
} # we could add our class vars to _map using var_to_str


func keys() -> Array:
	var ret = []
	for k in _map.keys():
		if _map[k] is String and _map[k] != "":
			ret.append(k)
		elif _map[k] is Array and _map[k] != []:
			ret.append(k)
	return ret

func allKeys() -> Array:
	return _map.keys().duplicate()

func at(key: String):
	if key == "popupData": return _map["popupData"]
	elif _map.has(key): return str_to_var(_map[key])
	else: 
		print("key %s is not a key in DTM._map" % key)
		print("keys:", _map.keys())
		return ""

func map(key: String, value) -> bool:
	if _map.has(key):
		## this first conditional has to be done so we can track popupData in the inspector.
		if key == "popupData" or value == "": _map[key] = value
		else: _map[key] = var_to_str(value)
		#if (key == "x_position" and has("y_position")) or (key == "y_position" and has("x_position")):
			#vector2Set.emit(at("x_position"), at("y_position"), "position")
			#_map["position"] = var_to_str("position")
		#
		#if (key == "x_shape" and has("y_shape")) or (key == "y_shape" and has("x_shape")):
			#vector2Set.emit(at("x_shape"), at("y_shape"), "shape")
			#_map["shape"] = "shape"
		return true
	else:
		print("DataTableMap does not have key %s" % key)
		return false

func unmap(key: String):
	if _map.has(key):
		## this first conditional has to be done so we can track popupData in the inspector.
		if key == "popupData": _map[key] = []
		else: _map[key] = ""
	else:
		print("DataTableMap does not have key %s" % key)

func has(key: String):
	return _map.has(key) and _map[key] != ""

func replaceMapping(key: String, newValue: String):
	if has(key):
		_map[key] = newValue
	else: 
		_map[key] = newValue 

#func getMappedTable():
	#pass

func keyFor(val) -> String:
	for key in _map:
		if _map[key] == val: return key
	print("TM.keyFor: no val ", str(val), " found.")
	return ""


func _init():
	pass

func _get(prop: StringName):
	#print("trying to get prop %s from tablemap " % prop)
	if has(prop): return at(prop)
	return null

func _set(prop, val) -> bool:
# match prop:
# 	"positionIsReference":
# 		if val is bool:
# 			positionIsReference = val
# 		return val is bool
# 	"shapeIsReference":
# 		if val is bool:
# 			shapeIsReference = val
# 		return val is bool
# 	"multi-entry_Position":
# 		if val is bool:
# 			multiEntry_Position = val
# 		return val is bool
# 	"shape_Scalar":
# 		if val is Vector2:
# 			shape_Scalar = val
# 		return val is Vector2
# 	"position_Scalar":
# 		if val is Vector2:
# 			position_Scalar = val
# 		return val is Vector2
# 		return val is bool
# 	"labelElement":
# 		if val is bool:
# 			labelElement = val
# 		return val is bool
# 	"circular":
# 		if val is bool:
# 			circular = val
# 		return val is bool
# 	"normal_Stylebox":
# 		if val is StyleBox:
# 			n_Stylebox = val
# 		return val is StyleBox
# 	"selected_Stylebox":
# 		if val is StyleBox:
# 			s_Stylebox = val
# 		return val is StyleBox
# 	_:
# 		return false
	if _map.has(prop): return map(prop, val)
	return false

func _to_string() -> String:
	var tn = name
	if not tn:
		tn = "MAP HAS NO CORRESPONDING TABLE NAME"
	var ret = "\n%s\n" % tn
	#ret += "\nlabelElement? %s\npositionIsReference? %s\nmult-entry_Position? %s\nshapeIsReference? %s\ncircular? %s\nshapeScalar: %s\npositionScalar: %s\nnormalStyleboxOverride? %s\nselectedStyleboxOverride? %s\n\n"
	# var nso = false # normal stylebox override
	# var sso = false # selected stylebox override
	# # if not n_Stylebox is StyleBoxEmpty:
	# 	nso = true 
	# if not s_Stylebox is StyleBoxEmpty:
	# 	sso = true
	
	# ret = ret % [str(labelElement), str(positionIsReference), str(multiEntry_Position), str(shapeIsReference), str(circular), str(shape_Scalar), str(position_Scalar), str(nso), str(sso)]
	for key in keys():
		ret += "\t%s: %s\n" % [key, _map[key]]
	return ret

func bool():
	for key in _map.keys():
		if has(key): return true
	return false