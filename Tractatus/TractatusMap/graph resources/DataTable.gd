@tool
class_name DataTable extends Resource

static var numUnnamedTables = 0

"""
resource for easily loading json data pertaining to Elements. Stores data in a dataframe, with similar structure and functionality to 
its Python Pandas inspiration, just simplified. This'll ensure every observation/row has matching keys
"""
### path to collection json file
#@export_file("*.json") var file_path
### list of keys that can be ignored. Nested keys should be denoted with _separator (default "/") separating each external
### and internal key.
#@export var ingore: PackedStringArray = PackedStringArray()
#@export var mask: Dictionary = {}

enum nullCompareValue{
	MAX, 
	MIN, 
	ALWAYS_LAST
}
var nullCmp: nullCompareValue = nullCompareValue.ALWAYS_LAST

var fileName: String

func getFileName():
	return fileName
func setFileName(fn: String):
	fileName = fn
	
var _data: Dictionary

var columns: PackedStringArray:
	get:
		return _data.keys()


var name: String
func getName() -> String:
	if name: return name 
	else: return "no name?"
func setName(newName: String):
	name = newName

var dataTypes

## the expected separator used to navigate directories and dictionaries
var _separator = "/" #THIS SHOULD BE IN CONSTANTS FILE

func _init(data: Dictionary = {}, dfName: String = "none", keepIndexCopy: bool = false):
	if keepIndexCopy and data.has("idx"):
		data["prevIdx"] = data["idx"].duplicate()
	data["idx"] = range(len(data.values()[0])) 
	
	_data = data
	
	if not data.is_empty():
		var colLen = len(data.values()[0])
		for arr in data.values():
			if arr.size() != colLen:
				push_warning("error: data arrays must be of equal length.")
				print("error: data arrays must be of equal length.")
				for a in data.keys():
					print("array lengths:")
				_data = {} 

	
	if dfName == "none":
		name = "unnamedTable%d" % numUnnamedTables
		numUnnamedTables += 1
	else:
		name = dfName
	
	if data and not data.is_empty():
		columns = PackedStringArray(data.keys())
	
func dupe() -> DataTable:
	var ret = DataTable.new(getData(), name, false)
	ret.setFileName(getFileName())
	return ret

func _slice(rowIndex, colIndex) -> DataTable:
	global.NotImplemented()
	var ret = {}
	#if colIndex is Vector2 and rowIndex == null:
	#	pass ## this is totally easy to implement
	
	if rowIndex == null:
		ret = _data.duplicate(true)
	elif rowIndex is Array: 
		if rowIndex.all(global.areInts):
			if rowIndex.size() == 3:
				for key in _data.keys():
					ret[key] = _data[key].slice(rowIndex[0], rowIndex[1], rowIndex[2])
			elif rowIndex.size() == 2:
				for key in _data.keys():
					ret[key] = _data[key].slice(rowIndex[0], rowIndex[1])
			elif rowIndex.size() == 1:
				for key in _data.keys():
					ret[key] = [_data[key][rowIndex[0]]]
			else:
				push_warning("ERROR: rowIndex array has invalid number of elements.")
				return DataTable.new(ret)
		## here we'd allow special indexing when that's implemented
		
		else:
			push_warning("rowIndex Array values are unrecognized type.")
			return DataTable.new(ret)
		
	elif rowIndex is int:
		for key in _data.keys():
			ret[key] = _data[key][rowIndex]
	##elif rowIndex is String
	
	else:
		push_warning("unrecognized rowIndex data type")
	

	if colIndex == null:
		return DataTable.new(ret)

	elif colIndex is Array:
		var newKeys: Array
		if colIndex.all(global.areInts):
			if colIndex.size() == 3:
				newKeys = ret.keys().slice(colIndex[0], colIndex[1], colIndex[2])
			elif colIndex.size() == 2:
				newKeys = ret.keys().slice(colIndex[0], colIndex[1])
			
		elif colIndex.all(global.areStrings):
			if not _data.has_all(colIndex):
				push_warning("ERROR: columns %s are not subset of DataTable columns %s" % [colIndex, columns])
				DataTable.new({})
			newKeys = colIndex
		
		else:
			push_warning("ERROR: colIndex array has inconsistent element type")
			return DataTable.new({}, name + "slice", true)
		
		for key in ret:
			if not newKeys.has(key):
				ret.erase(key)
		
		return DataTable.new(ret, name + "slice", true) 

	elif colIndex is int:
		return DataTable.new({ret.keys()[colIndex]: ret[ret.keys()[colIndex]]}, name + "slice", true)
	
	elif colIndex is String:
		return DataTable.new({colIndex: ret[colIndex]}, name + "slice", true)
	else:
		push_warning("unrecognized colIndex data type")
		return DataTable.new({})

"""
returns values found in dataframe at given index:
	null colIndex returns only the row if specified, although maybe just use slice? nah, actually faster this way
	null rowIndex returns column if specified. 

Parameters:
	rowIndex: 
		- int: selects each column value at given index
	colIndex:
		- String: selects value at corresponding String key
		- int: selects all columns' values at given index
"""
## order = x, y
## see there's a reason i put that, I believe it's just to be consistent. At some point I wanted to handle
## Vector2is even tho idk if that'd make sense (are they slices or are you saying col, row?)
func index(colIndex = null, rowIndex = null) -> Variant:
	var ret
	var indexedData = {}
	var cols = []

	var getColumnSlice = func getCols(cIndex) -> Dictionary:
		var gcRet = {}
		if cIndex is String:
			if _data.has(cIndex): return _data[cIndex].duplicate(true)
			else:
				print("column index %s not in columns %s" % [cIndex, ", ".join(_data.keys())])
				return {}
		
		elif cIndex is int:
			if cIndex < _data.size(): return {_data.keys()[cIndex]: _data[_data.keys()[cIndex]].duplicate(true)}
			else:
				print("column index %d not length %d of columns" % [cIndex, _data.size()])
				return {}
		
		elif cIndex is Vector2i or cIndex is Vector2:
			cIndex = Vector2i(cIndex)
			var i = min(cIndex.x, cIndex.y)
			var j = max(cIndex.x, cIndex.y)
			var keys = _data.keys().slice(i, j)
			for key in keys:
				gcRet[key] = _data[key][rowIndex]
			return gcRet
		
		elif cIndex is Array and len(cIndex) == 2:
			var i 
			var j
			if cIndex[0] is int:
				i = min(cIndex[0], cIndex[1])
				j = max(cIndex[0], cIndex[1])
				var keys = _data.keys().slice(i, j)
				for key in keys:
					gcRet[key] = _data[key][rowIndex]
				return gcRet
			elif cIndex[0] is String:
				var a = _data.keys().find(cIndex[0])
				if a == -1:
					print("_index: couldn't find column %s in keys %s" % [cIndex[0], str(_data.keys())])
					return {}
				var b = _data.keys().find(cIndex[1])
				if b == -1:
					print("_index: couldn't find column %s in keys %s" % [cIndex[1], str(_data.keys())])
					return {}
				i = min(a, b)
				j = max(a, b)
				var keys = _data.keys().slice(i, j)
				for key in keys:
					gcRet[key] = _data[key][rowIndex]
				return gcRet
			else: 
				print("DataTable.index: column Array contains invalid types: ",cIndex)
				return {}
		
		else:
			print("col index type %s is invalid. current implementation supports only ints, array(len 2), or Vector2(i)s." % type_string(typeof(cIndex)))
			return {}
	
	var getRowSlice = func getRs(rIndex) -> Dictionary:
		var grRet = {}
		if rIndex is int:
			if rIndex > _len():
				print("row index %d > number of rows %d" %[rIndex, _len()])
				return {}
			for key in _data.keys():
				grRet[key] = _data[key][rIndex].duplicate(true)
			return grRet
		elif rIndex is Vector2i or rIndex is Vector2:
			rIndex = Vector2i(rIndex)
			var i = min(rIndex.x, rIndex.y)
			var j = max(rIndex.x, rIndex.y) 
			for key in _data.keys():
				grRet[key] = _data[key].slice(i, j, 1, true)
			return grRet
		elif rIndex is Array and len(rIndex) == 2:
			if not rIndex[0] is int:
				print("_index: for array rowIndex inputs, array must consist of only integers.")
				return {}
			var i = min(rIndex[0], rIndex[1])
			var j = max(rIndex[0], rIndex[1])
			for key in _data.keys():
				grRet[key] = _data[key].slice(i, j, 1, true)
			return grRet
		else: 
			print("row index type %s is invalid. current implementation supports only ints, array(len 2), or Vector2(i)s." % type_string(typeof(rIndex)))
			return {}

	var getIndexedColumnNames = func getColNames(cIndex) -> Array:
		var gcCols
		if cIndex is String:
			if _data.has(cIndex): 
				gcCols = [cIndex]
			else:
				print("column index %s not in columns %s" % [cIndex, ", ".join(_data.keys())])
				return []
		elif cIndex is int:
			if cIndex < _data.size(): gcCols = [_data.keys()[cIndex]]
			else:
				print("column index %d not length %d of columns" % [cIndex, _data.size()])
				return []
		elif cIndex is Vector2 or cIndex is Vector2i:
			cIndex = Vector2i(cIndex)
			var i = min(cIndex.x, cIndex.y)
			var j = max(cIndex.x, cIndex.y)
			gcCols = _data.keys().slice(i, j)
		elif cIndex is Array and len(cIndex) == 2:
			var i 
			var j
			if cIndex[0] is int:
				i = min(cIndex[0], cIndex[1])
				j = max(cIndex[0], cIndex[1])
				gcCols = _data.keys().slice(i, j)
			elif cIndex[0] is String:
				var a = _data.keys().find(cIndex[0])
				if a == -1:
					print("_index: couldn't find column %s in keys %s" % [cIndex[0], str(_data.keys())])
					return []
				var b = _data.keys().find(cIndex[1])
				if b == -1:
					print("_index: couldn't find column %s in keys %s" % [cIndex[1], str(_data.keys())])
					return []
				i = min(a, b)
				j = max(a, b)
				gcCols = _data.keys().slice(i, j)
		else: 
			print("col index type %s is invalid. current implementation supports only ints, array(len 2), or Vector2(i)s." % type_string(typeof(cIndex)))
			return []
		return gcCols
	
	var getIndexedColumnRows = func getColRows(columnNames) -> Dictionary:
		var gicrIndexedData = {}
		if rowIndex is int: 
			for c in cols:
				#print("_data[c]: ", _data[c])
				gicrIndexedData[c] = _data[c][rowIndex]
			return gicrIndexedData
		elif rowIndex is Vector2 or rowIndex is Vector2i:
			rowIndex = Vector2i(rowIndex)
			var i = min(rowIndex.x, rowIndex.y)
			var j = max(rowIndex.x, rowIndex.y)
			for col in columnNames:
				gicrIndexedData[col] = _data[col].slice(i, j, 1, true)
			return gicrIndexedData
		elif rowIndex is Array and global.areInts(rowIndex):
			match len(rowIndex):
				1:
					for col in columnNames:
						gicrIndexedData[col] = _data[col].slice(rowIndex[0], rowIndex[0]+1, 1, true) 
					return gicrIndexedData 
				2:
					var i = min(rowIndex[0], rowIndex[1])
					var j = max(rowIndex[0], rowIndex[1])
					for col in columnNames:
						gicrIndexedData[col] = _data[col].slice(i, j, 1, true)
					return gicrIndexedData 
				3:
					var i = min(rowIndex[0], rowIndex[1])
					var j = max(rowIndex[0], rowIndex[1])
					for col in columnNames:
						gicrIndexedData[col] = _data[col].slice(i, j, rowIndex[2], true)
					return gicrIndexedData  
				_:
					print("DataTable.index: rowIndex array length must be less than 3.")
					return {}
		else:
			print("row index type %s is not int/invalid. current implementation supports only ints." % type_string(typeof(rowIndex)))
			return {}

	if colIndex == null and rowIndex == null:
		print("error: null index is invalid.")
		return 
	
	if rowIndex == null:
		indexedData = getColumnSlice.call(colIndex)
		if indexedData.is_empty(): return
		ret = DataTable.new(indexedData, getName())
		ret.setFileName(getFileName())
		return ret
	
	elif colIndex == null:
		indexedData = getRowSlice.call(colIndex)
		if indexedData.is_empty(): return
		ret = DataTable.new(indexedData, getName(), true)
		ret.setFileName(getFileName())
		return ret
	
	cols = getIndexedColumnNames.call(colIndex)
	if cols.is_empty(): return 
	
	if rowIndex is int and colIndex is int or colIndex is String: return _data[cols[0]][rowIndex]

	indexedData = getIndexedColumnRows.call(cols)
	if indexedData.is_empty(): return  

	ret = DataTable.new(indexedData, getName())
	ret.setFileName(getFileName())
	return ret

func columnDrop(cols, inplace: bool = false):
	var newData = _data.duplicate(true)
	if cols is String:
		newData.erase(cols)

	elif cols is Array:
		for col in cols:
			
			if col is int:
				if col > _data.size() or col < -1*_data.size():
					print("ERROR DataTable.drop: drop value %d is beyond table size" % col)
					return
				newData.erase(_data.keys()[col])
			
			elif col is String:
				newData.erase(col)

	if inplace: _data = newData
	else:
		var newDT = DataTable.new(newData, self.name)
		newDT.setFileName(getFileName())
		return newDT

func scale(columnName: String, scalar):
	print("%s.scale(%s, %s)" % [name, columnName, scalar])
	global.NotImplemented()
	return 
	# if not _data.has(columnName): 
	# 	print(".scale: %s not a column name" %columnName)
	# 	return
	
	# var t = type(columnName)	
	# if  (scalar is int or scalar is float) and not (t in global.types1DOperable): print(".scale: column %s type %s not scalable in 1 dimension" % [columnName, t])
	# elif ((not (scalar is int or scalar is float)) and typeof(scalar) in global.typesNumeric) and (t in global.typesNumeric and t != typeof(scalar)): print(".scale: it's possible types %s and %s are multiplicable, but operation unimplemented in this function." % [type_string(typeof(scalar)), type_string(t)])
	
	# else:
	# 	var c = getColumn(columnName)
	# 	for e in getColumn(columnName):
	# 		pass

# Pulls a random value from named or unspecified column
func random(colName: String = "") -> Variant:
	if colName and hasColumn(colName): return _data[colName][randi() % _len()]  
	elif colName: return null
	else: return _data[randi() % len(_data)][randi() % _len()]
	
# Function to calculate the minimum run length
func _calc_min_run(n: int) -> int:
	# Minimum size of a run (subarray) for merging
	const MIN_MERGE = 32
	var r := 0
	while n >= MIN_MERGE:
		r |= n & 1
		n = n >> 1
	return n + r

# Custom comparison function to handle null values
func _compare(a, b) -> bool:
	if a == null and b == null:
		return false  # Equal, no swap
	elif a == null:
		# Handle null based on nullCmp
		match nullCmp:
			nullCompareValue.MAX:
				return true  # Null is treated as greater than non-null
			nullCompareValue.MIN:
				return false  # Null is treated as less than non-null
			nullCompareValue.ALWAYS_LAST:
				return true  # Null is always last
			_:
				print("Error in DataTable.compare: unrecognized nullCmp value.")
				return false
	elif b == null:
		# Handle null based on nullCmp
		match nullCmp:
			nullCompareValue.MAX:
				return false  # Non-null is less than null
			nullCompareValue.MIN:
				return true   # Non-null is greater than null
			nullCompareValue.ALWAYS_LAST:
				return false  # Non-null is always before null
			_:
				print("Error in DataTable.compare: unrecognized nullCmp value.")
				return false
	else:
		# Regular comparison for non-null values
		return a < b

# Insertion sort for small runs (with index map and null handling)
func _insertion_sort(arr: Array, indices: Array, left: int, right: int) -> void:
	for i in range(left + 1, right + 1):
		var key = arr[i]
		var key_index = indices[i]
		var j = i - 1
		while j >= left and _compare(key, arr[j]):
			arr[j + 1] = arr[j]
			indices[j + 1] = indices[j]
			j -= 1
		arr[j + 1] = key
		indices[j + 1] = key_index

# Merge function to merge two sorted runs (with index map and null handling)
func _mergeSortedRuns(arr: Array, indices: Array, left: int, mid: int, right: int) -> void:
	var len1 = mid - left + 1
	var len2 = right - mid
	var left_arr = arr.slice(left, mid + 1)
	var right_arr = arr.slice(mid + 1, right + 1)
	var left_indices = indices.slice(left, mid + 1)
	var right_indices = indices.slice(mid + 1, right + 1)

	var i = 0
	var j = 0
	var k = left

	while i < len1 and j < len2:
		if _compare(left_arr[i], right_arr[j]):
			arr[k] = left_arr[i]
			indices[k] = left_indices[i]
			i += 1
		else:
			arr[k] = right_arr[j]
			indices[k] = right_indices[j]
			j += 1
		k += 1

	while i < len1:
		arr[k] = left_arr[i]
		indices[k] = left_indices[i]
		i += 1
		k += 1

	while j < len2:
		arr[k] = right_arr[j]
		indices[k] = right_indices[j]
		j += 1
		k += 1

# TimSort implementation with index map and null handling
func _timsort_with_indices(arr: Array) -> Dictionary:
	var n = arr.size()
	var min_run = _calc_min_run(n)

	# Create an index map to track original positions
	var indices = []
	for i in range(n):
		indices.append(i)

	# Sort individual runs using insertion sort
	for start in range(0, n, min_run):
		var end = min(start + min_run - 1, n - 1)
		_insertion_sort(arr, indices, start, end)

	# Merge runs
	var size = min_run
	while size < n:
		for left in range(0, n, 2 * size):
			var mid = min(left + size - 1, n - 1)
			var right = min(left + 2 * size - 1, n - 1)
			if mid < right:
				_mergeSortedRuns(arr, indices, left, mid, right)
		size *= 2

	# Return the sorted array and the index map
	return {
			"sorted_array": arr,
			"index_map": indices
	}

func sortBy(by: String, ascending: bool = true) -> DataTable:
	if not hasColumn(by):
		print("DataTable does not have column ",by)
		return DataTable.new()
	var res = _timsort_with_indices(_data[by].duplicate(true))
	if res == null: 
		print("error sorting by column ",by)
		return DataTable.new()
	
	var sortedArr = res.sorted_array
	var indexMap = res.index_map
	if not ascending: 
		sortedArr.reverse()
		indexMap.reverse()
	var newTableData = {by: sortedArr}
	
	for colName in _data.keys():
		if colName == "idx" or colName == by: continue 
		var colArr = _data[colName]
		var sortedCol = []
		sortedCol.resize(len(colArr))
		for i in range(len(colArr)):
			sortedCol[i] = colArr[indexMap[i]]
		newTableData[colName] = sortedCol
	
	var ret = DataTable.new(newTableData, self.name)
	ret.setFileName(self.getFileName())
	return ret


func split():
	pass

func isEmpty():
	return _data.is_empty()

## rWhere stands for columns where, because the return includes all columns from the original
## I implemented this method to locate specific IDs. Essentially the way it works 

 ##requirements:
 	##Iterates over table, plugs in variable values to the expression and returns a table consisting of the same columns, but
 	##only the rows in which the expression evaluates to true.
	#
#
 ##Sample cases:
 	##We wanna grab specifically the observation/row with a specific ID:
 		##var idDT = dt.rWhere("ID == %s" % specificID, ["ID"])
	## Grab the rows corresponding to specific IDs:
		## var referencedRows = dt.rWhere("ID == ref", ["ID"], ["ref"], [references])
 	##Find where revenue surpassed projected in the last 30 observations(days or wtv):
 		##var beatProjected = dt.rWhere("revenue > projected and idx > %d" % dt.size(true), ["revenue", "projected", "idx"])

## note:
	## if you're trying to find a numeric string, the Expression class will parse the expression string and assume
	## the number is an int/float. That's the reason i added variableNames and variableInputs, so you can replace specific 
	## values for references 
func rWhere(expressionString: String, columnNames: Array = [], variableNames: Array = [], variableInputs: Array = []) -> DataTable:
	if not columnNames:
		return DataTable.new({}) 
	if not _data.has_all(columnNames):
		for varName in columnNames:
			if not _data.has(varName):
				var e = "error: %s is not a column name.\n\tColumns: %s" % [
					varName, 
					str(_data.keys()).lstrip("[").rstrip("]")
					]
				print(e)
				return DataTable.new({})
	var ret = {}

	var xp = Expression.new()
	xp.parse(expressionString, columnNames + variableNames)
	if xp.has_execute_failed():
		print("error parsing expression string:\nstring: %s\nerror: %s" % [expressionString, xp.get_error_text()])
		return DataTable.new({})
	for rowNum in range(size(true)):
		
		var row = getRow(rowNum)
		var inputVals = []
		inputVals.resize(len(columnNames))
		var result 
		for colIndex in range(len(columnNames)):
			inputVals[colIndex] = row[columnNames[colIndex]]
		result = xp.execute(inputVals + variableInputs, self) ## DO WE EXECUTE ON SELF OR ROW??? 
		if xp.has_execute_failed():
			print("error in cwhere executing expression string: %s" % xp.get_error_text())
			return DataTable.new({})
		
		elif result == null: continue 
		
		elif result is bool and result:
			if ret.is_empty():
				for key in row.keys():
					ret[key] = [row[key]]
			else:
				for key in row.keys():
					ret[key] = ret[key] + [row[key]]
		
		elif result is Dictionary:
			for key in result.keys():
				ret[key] = ret[key] + [result[key]]
		
		else: 
			print("DataTable.rWhere: Expression.execute return type %s not recognized" %type_string(typeof(result)))
			return DataTable.new({})
			
	return DataTable.new(ret, "none", true)
	
func getMappedTable(map) -> DataTable:
	var dt = {'idx': range(int(shape().y))}
	
	for colName in map.keys():
		var icn = map.at(colName)
		if icn is Array: ## this is implementation specifically for popup_data
			dt[colName] = []
			for i in dt['idx']:
				var newColVal = {}
				for c in icn:
					newColVal[c] = _data[c][i]
				dt[colName] = dt[colName] + [newColVal]
		
		elif icn is String:
			dt[colName] = _data[icn].duplicate()
		else:
			push_warning("%s/%s map value is %s - not expected" % [getFileName(), getName(), str(icn)])
			print("%s/%s map value is %s - not expected" % [getFileName(), getName(), str(icn)])
	
	return DataTable.new(dt, name + " Mapped Table")
	
func rename(columnName: String, newName: String):
	if columnName in _data.keys():
		_data[newName] = _data[columnName].duplicate()
		_data.erase(columnName)
		return true

## takes table containing a subset of the keys in _data, adds arrays for each column
func appendTable(table: DataTable, columnNameMap: Dictionary = {}) -> void:
	var columnsMatch = func checkDataColumnsAgainstTableColumns() -> bool:
		var tableColumns = table.columns.duplicate()
		var mappedTableColumns = columnNameMap.values()
		var dataColumns = columns 

		for col in tableColumns: 
			if not col in dataColumns and not col in mappedTableColumns:
				print("ERROR DataTable.append_table: not all keys")
				return false 
		return true
	
	if columnsMatch.call():
		for i in range(table.shape().y):
			for col in _data.keys():
				
				if col == 'idx':
					_data[col] = _data[col] + [len(_data[col])]
				
				elif table.hasColumn(col):
					_data[col] = _data[col] + table[col][i]
				
				elif columnNameMap.has(col) and table.hasColumn(columnNameMap[col]):
					_data[col] = _data[col] + table[columnNameMap[col]][i]
				
				else:
					_data[col] = _data[col] + [null]

func uniqueAndIndices(a1: Array, a2: Array) -> Array:
		global.NotImplemented()
		return []

		var sa1 = {}
		var sa2 = {}

		for i in range(len(a1)):
			var elem = str(a1[i])
			if sa1.has(elem): 
				print(".merge: table1 values must be unique")
				return []
			else: sa1[elem] = i
		## checking table 2
		for i in range(len(a2)):
			var elem = str(a2[i])
			if sa2.has(elem): 
				print(".merge: table2 values must be unique")
				return []
			else: sa2[elem] = i

#func appened(entry: Dictionary):
	#for key in entry.keys():
		#if not 
## takes table containing the same index/row length, adds keys from new table to current
static func merge(table1: DataTable, table2: DataTable, on1: String, on2: String, overwriteDuplicateColumnNames = false, mergeName = "merged table") -> DataTable:
	global.NotImplemented()
	return 
	var e = func errors() -> bool:
		
		if not (table1 and table2 and table1.to_bool() and table2.to_bool()):	print("error: input tables are empty or null.")
		elif table1.size(true) != table2.size(true):												print("error: tables have mismatching value array: if %i == %i (respective len()), one or both tables have an internal length mismatch." % [table1.len(), table2.len()])
		elif not table1.hasColumn(on1): 																		print("error: table1 doesn't have column %s" % on1)
		elif not table2.hasColumn(on2): 																		print("error: table2 doesn't have column %s" % on2)
		
		else: return false
		print("uniqueAndIndices not implemented.")
		return true

	
	if e.call(): return DataTable.new()

	var d1 = table1.getData()
	var d2 = table2.getData()

	return DataTable.new()

func convertType(columnName: String, newType: Variant.Type, internal: bool = true) -> void:
	if hasColumn(columnName):
		var col = _data[columnName].duplicate()
		for i in range(len(col)):
			if col[i] != null:
				if col[i] is Array and internal:
					var arr = col[i]
					for j in range(len(arr)):
						arr[j] = type_convert(arr[j], newType)
					col[i] = arr
				elif col[i] is Dictionary and internal:
					var dict = col[i].duplicate(true)
					for key in dict.keys():
						dict[key] = type_convert(dict[key], newType)
					col[i] = dict
				else: col[i] = type_convert(col[i], newType)
		_data[columnName] = col
	else: print(".convertColumn: column %s does not exist." % columnName)

func type(columnName) -> int:
	if not hasColumn(columnName): print(".type: column %s does not exist" % columnName)
	else:
		for input in _data[columnName]:
			if input != null: return typeof(input)
	return TYPE_NIL
	
func hasColumn(columnName: String) -> bool:
	var r = _data.has(columnName)
	#if not r:	print(".hasColumn: Table %s does not have column %s" % [name, columnName])
	return r

func setColumn(columnName: String, columnValues: Array = []) -> bool:
	var s = _len()
	if len(columnValues) == s:
		_data[columnName] = columnValues
		return true
	else: 
		print(".setColumn: columnValues has length %d, doesn't match size(true) %d." %[len(columnValues), s])
		return false

func replaceColumn(columnName: String, newColumnName: String, newColValues: Array) -> bool:
	if not _data.has(columnName):											print("error in dt.replaceColumn: column %s not found " % columnName)
	elif len(_data[columnName]) != len(newColValues):	print("error in dt.replaceColumn: new column has mismatching number of entries %i " % len(newColValues))
	else: 
		_data.erase(columnName)
		_data[newColumnName] = newColValues
		return true
	return false

func getColumn(columnName) -> Array:
	if not _data.has(columnName): 
		print(".getColumn: column %s not found" % columnName)
		return []
	return _data[columnName].duplicate(true)
	
func addColumn(newColumnName: String, columnValues: Array = []) -> bool:
	
	if _data.has(newColumnName):
		push_warning(".addColumn: table %s already has column %s" % [name, newColumnName])
		print(".addColumn: table %s already has column %s" % [name, newColumnName])
		return false
	elif len(columnValues) != size(true):
		push_warning(".addColumn: new column contains %d values when table %s has %d values." % [len(columnValues), name, shape().y])
		print(".addColumn: new column contains %d values when table %s has %d values." % [len(columnValues), name, shape().y])
		return false
	
	if columnValues == []:
		var col = []
		col.resize(size(true))
		col.fill("NAV")
		_data[newColumnName] = col
		return true
	
	else:
		_data[newColumnName] = columnValues
		return true

func removeColumn(columnName: String):
	if _data.has(columnName):
		_data.erase(columnName)

func getRow(rowNum: int) -> Dictionary:
	var ret = {}
	if rowNum >= size(true):
		return ret
	for key in _data.keys():
		ret[key] = _data[key][rowNum]
	return ret

func setRow(rowNum: int, newRow: Dictionary) -> bool:
	if _data.has_all(newRow.keys()):
		for key in newRow.keys():
			if key == "idx":
				continue
			var arr = _data[key]
			arr[rowNum] = newRow[key]
			_data[key] = arr
		return true
	return false

static func _split_path(path: String, separator = "/"):
	return path.split(separator)

func _columns():
	return _data.keys()

func _rows(numRows = 0, random = false):
	var rows = []
	var max
	
	if numRows > 0:
		max = numRows
	else:
		max = size()
	
	for i in range(0,max-1):
		var row = []
		if random:
			var randIndex = randi_range(0, size()-1)
			for key in _data.keys():
				row.append(_data[key][randIndex])
			rows.append(row)
		else:
			for key in _data.keys():
				row.append(_data[key][i])
			rows.append(row)
	return rows

func _len() -> int:
	## for speed if you just want a guarenteed int  
	if _data.is_empty():
		return 0
	else:
		return _data[_data.keys()[0]].size()
func allColLens() -> void:
	print("\t".join(_data.keys()))
	var lens = []
	for key in _data.keys():
		lens.append(str(len(_data[key])))
	print("\t".join(lens))
		
func size(getRowSize = false):
	if _data.size() == 0:
		if getRowSize:
			return 0
		else: 
			return Vector2i.ZERO
	var i = max(randi_range(0, _data.size() - 1), 0)
	if getRowSize:
		return _data[_data.keys()[i]].size()
	else:
		return Vector2(_data.size(), _data[_data.keys()[i]].size())

func shape() -> Vector2i:
	## for speed and if you want a guarenteed V2
	return Vector2i(_data.size(), len(_data['idx']))

func head(numRows: int = 5) -> void:
	if _data.is_empty():
		print("%s:\nEmpty Table" % name)
	else:
		var keys = _data.keys()
		print("\t\t".join(keys))
		
		if numRows > 0:
			for i in range(numRows):
				var p = ""
				for key in keys:
					var val = str(_data[key][i])
					p += val
					var vlen = len(val)
					for j in range(max(int(len(key) / 4) - int(vlen/4) + 2, 1)):
						p += "\t"
				print(p)
		else:
			for i in range(-1, numRows-1, -1):
				var p = ""
				for key in keys:
					var val = str(_data[key][i])
					p += val
					var vlen = len(val)
					for j in range(max(int(len(key) / 4) - int(vlen/4) + 2, 1)):
						p += "\t"
				print(p)

func getVectorZip(xColName: String, yColName: String) -> Array:
	var ret = []
	if not _data.has(xColName):
		print("error in zipColumns: column name %s not recognized." % xColName)
		return ret
	elif not _data.has(yColName):
		print("error in zipColumns: column name %s not recognized." % yColName)
		return ret
	ret.resize(size(true))
	for i in range(len(ret)):
		var xval 
		var yval 
		if _data[xColName][i] == null: xval = 0 
		if _data[yColName][i] == null: yval = 0 
		ret[i] = Vector2(xval, yval)
	return ret

func _onVectorSet(xColName, yColName, newColName):
	print("VECTOR SETTING RECOGNIZED!")
	var col = getVectorZip(xColName, yColName)
	addColumn(newColName, col)

func saveAsJson(filepath: String) -> void:
	# t = {
	#"p": [(0,1), (1,1), (1,2)]
	#"s": [(1,1), (2,1), (3,2)]
	#"f": [3, 2, 1]
	#"p": [{
		#"hi": "my name is",
		#"what": "my name is"}, 
		
		#{"hi": "who?",
		#"what": "my name is"}, 
		
		#{"hi": "slicka-slicka,
		#"what": "slim shady"}]
	#}
	var ret = {}
	var valuesDictArray = []
	# i in range(3)
	for i in range(size(true)):
		var instanceDict = {}
		for key in _data.keys():
			if key == "idx":
				continue 
			instanceDict[key] = _data[key][i]
		valuesDictArray.append(instanceDict)
	ret[name] = valuesDictArray
	#ret[t.name] = [
	#{"p": (0,1), "s": (1,1), "f": 3, "p": {"hi": my name is", "what": "my name is"}}, 
	#{}
	#{}]
	var file = FileAccess.open(filepath, FileAccess.WRITE_READ)
	
	file.store_string(JSON.stringify(ret, "\t"))
	file.close()

func _to_string() -> String:
	var keys = _data.keys()
	if _data.is_empty():
		return "%s:\nEmpty Table" % name
	var prevVal = 0
	var ret: String = name + "\n" + "\t\t".join(keys) +"\n"
	for i in range(len(_data[keys[0]])):
		for key in keys:
			if key in ["ger", "ogd", "pmc"]:
				continue
			var val = str(_data[key][i])
			ret += val + "\t\t"
			var vlen = len(val)
			for j in range(max((len(key) / 4) - prevVal, 1)):
				ret += "\t"
			prevVal = int(vlen/4)
		ret += "\n"
		
	return ret

func getData():
	return _data.duplicate(true)

func _set(prop, val) -> bool:
	match prop:
		# "positionIsReference":
		# 	var correctType = val is bool
		# 	if correctType: positionIsReference = val
		# 	return correctType
		
		# "shapeIsReference":
		# 	var correctType = val is bool
		# 	if val is bool: shapeIsReference = val
		# 	return correctType
		
		# "multi-entry_Position":
		# 	var correctType = val is bool
		# 	if correctType: multiEntry_Position = val
		# 	return correctType
		
		_: return false

func _get(property):
	match property:
		# "positionIsReference": 	return positionIsReference
		
		# "shapeIsReference": 	return shapeIsReference
		
		# "multi-entry_Position": return multiEntry_Position
		
		# "popupIsReference": 	return popupIsReference
		
		_: return null

func to_bool() -> bool:
	return (_data.size() != 0)
