@tool
class_name GraphDataManager extends Resource

static var numUnnamedGraphs = 1

var dt: DataTable
var gt: GraphTable
var tm: DataTableMap = DataTableMap.new()

enum null_cmp{
	max, ## consider null values
	min
}


var template_path: NodePath = NodePath()
var template_node: int = 1

var shapeIsReference: bool = false
var positionIsReference: bool = false
var popupIsReference: bool = false

var multiEntry_Popup: bool = false
var multiEntry_Position: bool = false

var labelElement: bool = false
var circular: bool = false
var shape_Scalar: Vector2 = Vector2(1,1)
var position_Scalar: Vector2 = Vector2(1,1)

var n_Stylebox: StyleBox = StyleBoxFlat.new()
var s_Stylebox: StyleBox = StyleBoxFlat.new()

#var n_Color: Color = Color()
#var s_Color: Color = Color()

var idFontSize: int = 14

const POPUP_ABOVE_NODE = "ABOVE_NODE"
const POPUP_SEPARATE = "SEPARATE"
var popupPlacement: String = POPUP_ABOVE_NODE

enum labelPlacementOptions {
	TOP_LEFT,
	TOP_CENTER,
	TOP_RIGHT
}
var labelPlacement: labelPlacementOptions = labelPlacementOptions.TOP_RIGHT

var fileName: String = ""
func getFileName():
	return fileName
func setFileName(fn: String):
	fileName = fn

var name: String:
	set(newName):
		name = newName
	get:
		return String(name)


func _init(datatableData = -1, graphName: String = "", resetIdx: bool = false):
	var baseName: String = ""

	if datatableData is Dictionary:
		if not graphName:
			numUnnamedGraphs += 1
			baseName = "unnamedGraph%d" % numUnnamedGraphs
		else:
			baseName = graphName
		self.dt = DataTable.new(datatableData, "DT" + baseName, resetIdx)
		self.gt = GraphTable.new("GT" + baseName, dt._len())
		self.tm = DataTableMap.new()
		
	elif datatableData is DataTable:
		self.dt = datatableData
		baseName = datatableData.getName()
		self.fileName = datatableData.getFileName()
		self.dt.setName("DT" + baseName)
		self.gt = GraphTable.new("GT" + baseName, dt._len())
		self.tm = DataTableMap.new()
		self.tm.setName("TM" + baseName)

		
	else: 
		print("trying to make a GraphDataManager without interpretable datatable data.")
		print("\t"+str(datatableData))
		self.dt = DataTable.new()
		self.gt = GraphTable.new("GT" + baseName, dt._len())
		self.tm = DataTableMap.new()
		self.numUnnamedGraphs += 1
		baseName = "UnnamedGraph%d" % numUnnamedGraphs
	
	var f = func isNull(variant):
		return variant == null
	if [shapeIsReference, positionIsReference, multiEntry_Position, labelElement, circular, shape_Scalar, position_Scalar, n_Stylebox, s_Stylebox].any(f):
		print("in GDM.init(): the variables i've initialized in script are null T_T ")
		self.shapeIsReference = false
		self.positionIsReference = false
		self.multiEntry_Position = false
		self.labelElement= false
		self.circular = false
		self.shape_Scalar = Vector2(1,1)
		self.position_Scalar = Vector2(1,1)
		self.n_Stylebox = StyleBoxFlat.new()
		self.s_Stylebox = StyleBoxFlat.new()

func numRows() -> int:
	return dt._len()

# 	return GraphDataManager.new({}, "", false)

## set properties of GT, DT, TM, likely via their respective _set()s
func GTset():
	global.NotImplemented()

func hasGTColumn(colName):
	return gt.hasColumn(colName)

func getGTColumn(colName):
	if gt.hasColumn(colName): 							return gt.getColumn(colName)
	elif gt.hasColumn(tm.keyFor(colName)):	return gt.getColumn(tm.keyFor(colName))
	else:																		return []

func setGTColumn(colName: String, col: Array) -> bool:
	return gt.setColumn(colName, col)

func unsetGTColumn(colName: String):
	gt.unsetColumn(colName)

func GTrWhere(expressionString: String, columnNames = [], variableNames = [], variableInputs = []) -> DataTable:
	return gt.rWhere(expressionString, columnNames, variableNames, variableInputs)

func checkDTColLens():
	dt.allColLens()

func DTset():
	pass

func getDTColumn(colName):
	if dt.hasColumn(colName): 					return dt.getColumn(colName)
	elif dt.hasColumn(tm.at(colName)): 	return dt.getColumn(tm.at(colName))
	else: 															return []

func setDTColumn(colName: String, col: Array) -> bool:
	return dt.setColumn(colName, col)

func hasMapping(mapKey):
	return tm.has(mapKey)

func TMAt(mapKey: String):
	return tm.at(mapKey)

func TMset():
	pass

func _setReferenceColumn(prop, val: Array) -> bool:
	## this func exists only to set the columns for position, shape and popup
	if gt.hasColumn(prop): 	return gt.setColumn(prop, val)
	else: 									return false

func _tmMap(prop, val) -> bool:
	if tm.map(prop, val):
		if tm.at(prop) == val:	return true
		else:
			print("BIG ERROR: tm.MAP returned True yet tm.at didn't match the map")
			return false
	else: return false

func _tmUnmap(mapKey: String) -> bool:
	print("gdm._tmUnmap: NOT IMPLEMENTED")
	print(mapKey)
	return false

func numElements():
	return dt._len()

func hasNodeTemplate():
	return template_node != global.NULL_TEMPLATE_NODE or template_path != NodePath()
func getNodeTemplate():
	if template_path != NodePath():
		return template_path
	elif template_node != global.NULL_TEMPLATE_NODE: 
		return template_node
	else: 
		return null

func _set(property, val) -> bool:
	## check f prop is one that applies to all elements
	if property in [
		"shapeIsReference", 
		"positionIsReference", 
		"popupIsReference",
		"multi-entry_Position", 
		"multi-entry_Popup",
		"shape_Scalar", 
		"position_Scalar", 
		"labelElement",
		"circular", 
		"normal_Stylebox", 
		#"normal_color",
		"selected_Stylebox",
		#"selected_color",
		"template_path",
		"template_node",
		"popupPlacement",
		"labelPlacement"
		]:
		match property:
			
			"template_path":
				var correctType = val is NodePath or val is String
				if correctType: 
					if val is String:
						template_path = NodePath(val)
					else:
						template_path = val
				elif val == null: 
					template_path = NodePath()
					correctType = true
				return correctType

			"template_node":
				var correctType = val is int
				if correctType: 
					template_node = val
				elif val == null: 
					template_node = global.NULL_TEMPLATE_NODE
					correctType = true
				return correctType
			
			"shapeIsReference":
				var correctType = val is bool
				if correctType: shapeIsReference = val
				return correctType

			"positionIsReference":
				var correctType = val is bool
				if correctType: positionIsReference = val
				return correctType
			
			"popupIsReference":
				var correctType = val is bool
				if correctType: positionIsReference = val
				return correctType

			"multi-entry_Position":
				var correctType = val is bool
				if correctType: multiEntry_Position = val
				return correctType
			
			"multiEntry_Popup":
				var correctType = val is bool
				if correctType: multiEntry_Popup = val
				return correctType

			"shape_Scalar":
				var correctType = val is Vector2
				if correctType: shape_Scalar = val
				return correctType
			
			"position_Scalar":
				var correctType = val is Vector2
				if correctType: position_Scalar = val
				return correctType
			
			"labelElement":
				var correctType = val is bool
				if correctType: labelElement = val
				return correctType
			
			"ID_Font_Size":
				var correctType = val is int
				if correctType: idFontSize = val
				return correctType

			"circular":
				var correctType = val is bool
				if correctType: circular = val
				return correctType
			
			"normal_Stylebox":
				var correctType = val is StyleBox
				if correctType: n_Stylebox = val
				return correctType
			
			"selected_Stylebox":
				var correctType = val is StyleBox
				if correctType: s_Stylebox = val
				return correctType
			
			"popupPlacement":
				var correctType = val is String or val is StringName
				if correctType:
					if val == POPUP_ABOVE_NODE: popupPlacement = POPUP_ABOVE_NODE
					elif val == POPUP_SEPARATE: popupPlacement = POPUP_SEPARATE
					else:
						print("GDM._set: popupPlacement val %s not regognized/implemented." % val)
						return false
				return correctType
			
			"labelPlacement":
				var correctType = val is int
				if correctType and val in labelPlacementOptions: 
					labelPlacement = val
				return correctType
			_:
				return false

	## try mapping gt name to dt name before proceeding
	elif property in tm.allKeys():
		if not _tmMap(property, val): 
			print("not setting due to unsuccessful mapping")
			return false
		
		elif tm.at(property) != val:
			print("BIG ERROR: in _set, we checked .at after mapping, and change was lost.")
			return false
		
		## we can't set columns without the column from said table, so just mapping was enough
		if property in ["reference_pos", "reference_shape", "reference_popup", "position", "shape", "popup"]: 	return true

		## check if prop is simple column, one that doesn't require any extra work
		elif property in ["ID", "ID_Font_Size", "normal_color", "selected_color"]:	
			var colSet = gt.setColumn(property, dt.getColumn(val))
			if not colSet: 
				print("unsuccessful attempt to set gt column %s equal to dt column %s." % [property, val])
				_tmMap(property, "")
			return colSet

		## check if property is a simple vector column
		elif property in ["x_position", "y_position", "x_shape", "y_shape"]:
			var dtCol = dt.getColumn(val)
			var gtCol 
			var gColName = property.erase(0, 2)
			if gColName != "position" and gColName !="shape":
				print("GDM._set: improper property name. erase attempting to get either position or shape")
			if gt.hasColumn(gColName): 
				gtCol = gt.getColumn(gColName)
			else:
				gtCol = []
				gtCol.resize(len(dtCol))
				gtCol.fill(Vector2(0, 0))
			
			var sCol = []
			sCol.resize(len(dtCol))

			if property.begins_with("x"):		for i in range(len(dtCol)): 	sCol[i] = Vector2(dtCol[i], gtCol[i].y)
			else: 											for i in range(len(dtCol)): 	sCol[i] = Vector2(gtCol[i].x, dtCol[i])

			var colSet = gt.setColumn(property.erase(0, 2), sCol)
			if not colSet: 
				print("unsuccessful attempt to set gt column %s equal to dt column %s." % [property, val])
				_tmMap(property, "")
			return colSet

		else: return false
	
	elif property.begins_with("popupOption"):
		print("idendified popupOption ", property)
		var optNum = int(property.lstrip("popupOption"))
		
		var popupKeys = tm.at("popupData")
		var npk = Array(popupKeys)

		var newCol
		if val: 
			newCol = dt.getColumn(val)
			if not newCol:
				print("adding new column %s to popupData, failed to get from dt" % val)
				return false
		
		if optNum - 1 == popupKeys.size():
			if not val: return true
			
			npk.append(val)
			if not tm.map("popupData", npk):
				print("failed to map popupData to ", npk)
				tm.map("popupData", popupKeys)
				return false 

			var gtCol = []
			if gt.hasColumn("popupData"): 
				gtCol = gt.getColumn("popupData")
				for i in range(numRows()):
					var cv = gtCol[i]
					cv[val] = newCol[i]
					gtCol[i] = cv
			else: 
				gtCol.resize(numRows())
				for i in range(numRows()):
					gtCol[i] = {val: newCol[i]}
			
			var suc = gt.setColumn("popupData", gtCol)
			if not suc: 
				print("unsuccessful setCol")
				tm.map("popupData", popupKeys)
			return suc
		
		elif optNum < popupKeys.size():
			var oldOpt = String(popupKeys[optNum])
			if not val:
				npk.erase(oldOpt)
				if not tm.map("popupData", npk):
					print("couldn't map to unset old option")
					return false

				if not gt.hasColumn("popupData"):
					print("somehow gt doesn't have popupData col despite there being a map and an expectation to set option %d" % optNum)
					tm.map("popupData", popupKeys)
					return false
			
				var gtCol = gt.getColumn("popupData") 
				for i in range(len(gtCol)):
					var dict = gtCol[i]
					dict.erase(oldOpt)
					gtCol[i] = dict
				
				var suc = gt.setColumn("popupData", gtCol)
				if not suc:
					print("couldn't set updated column. resetting mapping.")
					tm.map("popupData", popupKeys)
				
				return suc

			npk[optNum] = val
			if not tm.map("popupData", npk):
				print("failed to map popupData to ", npk)
				return false 
			
			if not gt.hasColumn("popupData"):
				print("somehow gt doesn't have popupData col despite there being a map and an expectation to set option %d" % optNum)
				tm.map("popupData", popupKeys)
				return false
			
			var gtCol = gt.getColumn("popupData")
			for i in range(len(gtCol)):
				var dict = gtCol[i]
				dict.erase(oldOpt)
				dict[val] = newCol[i]
				gtCol[i] = dict
			
			var suc = gt.setColumn("popupData", gtCol) 
			if not suc: tm.map("popupData", popupKeys)
			return suc

		else: 
			print("cannot set option %d for popupData when data only has %d keys" % [optNum, popupKeys.size()])
			return false

	else: return false

func _get(property):
	## request is for class properties
	if property in [
		"shapeIsReference", 
		"positionIsReference", 
		"popupIsReference",
		"multi-entry_Position", 
		"multi-entry_Popup",
		"shape_Scalar", 
		"position_Scalar", 
		"labelElement",
		"circular", 
		"normal_Stylebox", 
		#"normal_color", -- these are columns not specific values
		"selected_Stylebox",
		#"selected_color",
		"popupPlacement",
		"labelPlacement",
		"template_node",
		"template_path"
		]:
		match property:
			"shapeIsReference": return shapeIsReference
			"positionIsReference": return positionIsReference
			"popupIsReference": return popupIsReference
			
			"multi-entry_Position": return multiEntry_Position
			"multi-entry_Popup": return multiEntry_Popup

			"shape_Scalar": return shape_Scalar
			"position_Scalar": return position_Scalar
			
			"labelElement": return labelElement
			"ID_Font_Size": return idFontSize
			"circular": return circular
			
			"normal_Stylebox": return n_Stylebox
			"selected_Stylebox": return s_Stylebox
			
			#"normal_color": return n_Color
			#"selected_color": return s_Color
			
			"popupPlacement": return popupPlacement
			"labelPlacement": 
				match labelPlacement:
					labelPlacementOptions.TOP_LEFT: return "TOP_LEFT"
					labelPlacementOptions.TOP_CENTER: return "TOP_CENTER"
					labelPlacementOptions.TOP_RIGHT: return "TOP_RIGHT"
					

			"template_node": return template_node
			"template_path": return template_path
			_:
				return false
	
	## request is for column mapping - refer to map
	elif property in [
		"ID",
		"ID_Font_Size",
		"x_position",
		"y_position",
		"x_shape",
		"y_shape",
		"reference_pos",
		"position",
		"reference_shape",
		"shape",
		"reference_popup",
		"popup",
		"normal_color",
		"selected_color"
	]: return tm.at(property)

	elif property.begins_with("popupOption"):
		var optNum = int(property.lstrip("popupOption"))
		var popupData = tm.at("popupData")
		if popupData.is_empty() or popupData.size() < optNum:
			return ""
		else: return popupData[optNum - 1]

	## request not found
	else: 
		print("gdm.get: property %s not found" %property)
		return null

func getTableHeads():
	gt.head()
	print(global.miniSeparator)
	dt.head()

func getDTData() -> Dictionary:
	return dt.getData()

func getGTData() -> Dictionary:
	return gt.getData()

func getGraphTableElementInfo() -> Dictionary:
	# get dict array of all values in the GT
	var d = gt.getData()
	# helper func
	var scaleColumn = func scaleVectorArray(arr: Array, scalar: Vector2) -> Array:
		var ret = []
		for a in arr:
			match typeof(a):
				TYPE_VECTOR2:
					ret.append(Vector2(a.x * scalar.x, a.y * scalar.y)) 
				TYPE_VECTOR2I:
					ret.append(Vector2(a.x * scalar.x, a.y * scalar.y)) 
				_:
					ret.append(a) # likely TYPE_NULL or String (gt.NULL_VALUE)
		return ret
	# remove empty columns
	for k in d:
		if d[k][0] is String and (d[k][0] == gt.DEFAULT_VALUE or d[k][0] == gt.NULL_VALUE):
			d.erase(k)
	# scale vector columns where necessary
	if position_Scalar != Vector2.ONE and d.has("position"):
		d["position"] = scaleColumn.call(d["position"], position_Scalar)
	if shape_Scalar != Vector2.ONE and d.has("shape"):
		d["shape"] = scaleColumn.call(d["shape"], shape_Scalar)
	return d

func getGraphProperties() -> Dictionary:
	return {
		"multiEntry_Popup": multiEntry_Popup,
		"multiEntry_Position": multiEntry_Position,
		"labelElement": labelElement,
		"labelPlacement": labelPlacement,
		"circular": circular,
		"shape_Scalar": shape_Scalar,
		"position_Scalar": position_Scalar,
		"n_Stylebox": n_Stylebox,
		"s_Stylebox": s_Stylebox,
		"idFontSize": idFontSize
	}

func getEditedProperties() -> Dictionary:
	var ret = {}
	if multiEntry_Popup:
		ret["multiEntry_Popup"] = multiEntry_Popup
	if multiEntry_Position:
		ret["multiEntry_Position"] = multiEntry_Position
	if labelElement:
		ret["labelElement"] = labelElement
		ret["labelPlacement"] = labelPlacement
	if circular:
		ret["circular"] = circular
	if shape_Scalar != Vector2.ONE:
		ret["shape_Scalar"] = Vector2i.ONE
	if position_Scalar != Vector2.ONE:
		ret["position_Scalar"] = Vector2i.ONE
	ret["template"] = template_node
	ret["popupPlacement"] = popupPlacement
	
	return ret

func _to_string() -> String:
	var retArray = [global.bigSeparator]
	retArray.append("GraphDataManager %s" % name)
	retArray.append("")
	retArray.append(global.miniSeparator)
	retArray.append("properties:")
	retArray.append("\t template_path: %s"%str(template_path))
	retArray.append("\t template_node: %s"%str(template_node))
	retArray.append("\t shapeIsReference: %s"%str(shapeIsReference))
	retArray.append("\t positionIsReference: %s"%str(positionIsReference))
	retArray.append("\t popupIsReference: %s"%str(popupIsReference))
	retArray.append("\t multiEntry_Popup: %s"%str(multiEntry_Popup))
	retArray.append("\t multiEntry_Position: %s"%str(multiEntry_Position))
	retArray.append("\t labelElement: %s"%str(labelElement))
	retArray.append("\t circular: %s"%str(circular))
	retArray.append("\t shape_Scalar: %s"%str(shape_Scalar))
	retArray.append("\t position_Scalar: %s"%str(position_Scalar))
	retArray.append("\t n_Stylebox: %s"%str(n_Stylebox))
	retArray.append("\t s_Stylebox: %s"%str(s_Stylebox))
	retArray.append("\t idFontSize: %s"%str(idFontSize)) 
	retArray.append(global.miniSeparator)
	retArray.append("DataTable:")
	retArray.append(str(dt))
	retArray.append(global.miniSeparator)
	retArray.append("DataTableMap:")
	retArray.append(str(tm))
	retArray.append(global.miniSeparator)
	retArray.append("GraphTable:")
	retArray.append(str(gt))
	return "\n".join(retArray)
