@tool
class_name GraphTable extends DataTable
# HOT FIX - REMOVE
# var labelElement = false
# var circular = true
# var shape_Scalar = Vector2(1, 1)
# var position_Scalar = Vector2(1, 1)
# var n_Stylebox = StyleBoxEmpty.new()
# var s_Stylebox = StyleBoxEmpty.new()

#var _pReferenceReplaced: bool = false ## prevent redundant calls
#var _sReferenceReplaced: bool = false ## prevent redundant calls

const NULL_VALUE = "NAV"
const DEFAULT_VALUE = global.GRAPH_TABLE_DEFAULT_VALUE

func _init(DTname: String = "", numRows: int = -1): ## only setting defaults just in case but rly you shldnt init without a Table to refer to
	var dtname = DTname 
	if dtname.begins_with("DT"):
		dtname = "GT" + dtname.get_slice("DT", 0)
	self.name = dtname
	
	for key in ["ID", "ID_Font_Size", "position", "shape", "normal_color", "selected_color", "popupData"]:
		var col = []
		if numRows > 0: 
			col.resize(numRows)
			col.fill(DEFAULT_VALUE)
		_data[key] = col

func addColumn(_newColumnName: String, _columnValues: Array = []) -> bool:
	push_warning("GraphTable keys are supposed to be immutable.")
	print("GraphTable keys are supposed to be immutable.")
	return false

func naCol(colName: String):
	if not _data.has(colName): 
		print("GT.naCol: col %s not in gt column data" % colName)
		return true 
	else: 
		# below is unnecessary because we're setting entire columns, so DEFAULT_VALUE and NULL_VALUE will be overwritten
		# for e in _data[colName]:
		# 	if typeof(e) != TYPE_STRING or e != NULL_VALUE:
		# 		return false
		# 	pass
		return (typeof(_data[colName][0]) == TYPE_STRING and (_data[colName][0] == DEFAULT_VALUE or _data[colName][0] == NULL_VALUE))

func hasColumn(colName: String) -> bool:
	return _data.has(colName) and not (typeof(_data[colName][0]) == TYPE_STRING and (_data[colName][0] == DEFAULT_VALUE or _data[colName][0] == NULL_VALUE))

static func fromDataTable(table: DataTable, map: DataTableMap = DataTableMap.new()) -> GraphTable:
	var gt = GraphTable.new(table.getName(), table._len())
	if map.bool():
		for cn in table._columns():	## returns columnNames, should rename func
			pass

	# "ID": "",
	# "position": "",
	# "reference_pos": "",
	# "x_position": "",
	# "y_position": "",
	# "position_Scalar": "",
	
	# "shape": "",
	# "reference_shape": "",
	# "x_shape": "",
	# "y_shape": "",
	# "shape_Scalar": "",
	# "popupData": [],
	# "reference_popup": "",
	# "popup": ""
	print("GT.FROM_DT NOT IMPLEMENTED")
	#if "reference_pos" in k and "position" in k:
	#	pass
	# if "reference_pos" in k and "position" in k:
	# 	pass
	# if "reference_pos" in k and "position" in k:
	# 	pass
	# if "reference_pos" in k and "position" in k:
	# 	pass
	# if "reference_pos" in k and "position" in k:
	# 	pass
	# if "reference_pos" in k and "position" in k:
	#	pass
	return gt

## don't wanna overwrite, also don't wanna have to enforce GT rules (i.e. empty cols full of NULL_VALUE)
# static func fromJsonString(jstr: String):
# 	pass

static func cols() -> Array:
	return ["ID", "ID_Font_Size", "position", "shape", "normal_color", "selected_color", "popupData"]

func type(columnName):
	if not _data.has(columnName):
		push_warning("GraphTable line 44: column %s does not exist" % columnName)
	elif typeof(_data[columnName][0]) == typeof(DEFAULT_VALUE) and _data[columnName][0] != DEFAULT_VALUE:
		return TYPE_NIL
	else:
		for input in _data[columnName]:
			if input: ## and input != DEFAULT_VALUE: 	-CURRENTLY UNNECESSARY 
				return typeof(input)

func unsetColumn(colName):
	if _data.has(colName): 
		var unsetCol = []
		unsetCol.resize(size(true))
		unsetCol.fill(DEFAULT_VALUE)		
		_data[colName] = unsetCol

func _get(prop):
	#print("trying to get prop %s from tablemap " % prop)
	var iDontLikeYellowLines = prop 
	iDontLikeYellowLines.strip_edges(" ")
	print(global.notImplemented)
	return null

	# # HOT FIX REMOVE 	
	# match prop:
	# 	"shape_Scalar": return shape_Scalar
		
	# 	"position_Scalar": return position_Scalar
		
	# 	"labelElement": return labelElement
		
	# 	"normal_Stylebox": return n_Stylebox
		
	# 	"selected_Stylebox": return s_Stylebox
		
	# 	"circular": return circular
		
	# 	_: return null

func _set(prop, val) -> bool:
	match prop:
		
		# "template":
		# 	var correctType = val is Vector2
		# 	if correctType: template = val
		# 	return correctType
		##############################################################
		# HOT FIX REMOVE 		
				# "shape_Scalar":
				# 	var correctType = val is Vector2
				# 	if correctType: shape_Scalar = val
				# 	return correctType
				
				# "position_Scalar":
				# 	var correctType = val is Vector2
				# 	if correctType: position_Scalar = val
				# 	return correctType
				
				# "labelElement":
				# 	var correctType = val is bool
				# 	if correctType: labelElement = val
				# 	return correctType
				
				# "circular":
				# 	var correctType = val is bool
				# 	if correctType: circular = val
				# 	return correctType
				
				# "normal_Stylebox":
				# 	var correctType = val is StyleBox
				# 	if correctType: n_Stylebox = val
				# 	return correctType
				
				# "selected_Stylebox":
				# 	var correctType = val is StyleBox
				# 	if correctType: s_Stylebox = val
				# 	return correctType
		##############################################################
		"position":
			var correctType = val is Array
			if correctType: return setColumn("position", val)
			else: return false
		
		"x_position": ## We're gonna have to check if dt.has(value) before we call gt._set(x_position, wtv)
			var correctType = val is Array
			if correctType: return setColumn("x_position", val)
			else: return false
		
		"y_position": ## We're gonna have to check if dt.has(value) before we call gt._set(x_position, wtv)
			var correctType = val is Array
			if correctType: return setColumn("y_position", val)
			else: return false
		
		"shape":
			var correctType = val is Array
			if correctType: return setColumn("shape", val)
			else: return false
		
		"x_shape":
			var correctType = val is Array
			if correctType: return setColumn("x_shape", val)
			else: return false
				#if y_shape != "":
					#vector2Set.emit(x_shape, y_shape, "shape")
		
		"y_shape":
			var correctType = val is Array
			if correctType: return setColumn("y_shape", val)
			else: return false
				#if x_shape != "":
					#vector2Set.emit(x_shape, y_shape, "shape")
		
		"popupData":
			var correctType = val is Array
			if correctType: return setColumn("popupData", val)
			else: return false
		
		_:
			return false

func getData() -> Dictionary:
	var ret = {}
	for col in _data:
		if not naCol(col):
			ret[col] = _data[col].duplicate(true)
	return ret