class_name DataOrganizer extends Node

var dfs = [] #array of "dataframes", collections of instances pretaining to a singular class


## get file contents as Godot built-in structures
static func readJson(filePath):
	
	## our return if parsing process is successful
	var parsedJson
	
	## making a JSON instance so we can see any parsing errors later
	var json = JSON.new()
	
	## get file contents as string
	var contentString = FileAccess.get_file_as_string(filePath)
	## ensure file opened properly
	if not contentString:
		print("error occurred while opening file at " + filePath)
		print(error_string(FileAccess.get_open_error()))
		return 
	
	## parse json string
	else:
		var parseError = json.parse(contentString)
		## ensure parse successful
		if parseError != OK:
			print("parsing error on line %d: %s" % [json.get_error_line(), json.get_error_message()])
			return
		## upon success, set our return to the parsed data
		parsedJson = json.get_data()
	return parsedJson


static func _dlist(l: Array, dfName = "none"): ###WE'RE GONNA TAKE NAME ARGUMENT AS WELL TO GET THIS OUTPUT MATCHING THE COMPANY OUTPUT
	#print("in _dlist")
	var df = {'idx': range(l.size())}
	for i in df['idx']:
		var dict = l[i]
		if not dict is Dictionary:
			if df.size() != 1: # basically if we've been building a df, let's try to finish building rather than abandon on mis-input
				continue
			else:
				return false
		else:
			#var dfKeys = Array(df.keys())
			#dfKeys.erase('idx')
			## for each key in this instance dictionary
			for key in dict.keys():
				## if val is dict, extract: make internal dict keys a property of the class
				if dict[key] is Dictionary:
					for k in dict[key].keys():
						var uk = "%s.%s" % [key, k]
						if not uk in df.keys():
							df[uk] = [] 
							for j in range(0, i):
								df[uk] = df[uk] + [null]
						#else:
							#dfKeys.erase(uk)
						df[uk] = df[uk] + [dict[key][k]]
				
				## elif! makes total sense, pretty sure
				elif not key in df.keys():
					df[key] = [] 
					for j in range(0,i):
						df[key] = df[key] + [null] ## adds null for the array up to i
					df[key] = df[key] + [dict[key]] ## then adds the dict value
				
				else:
					df[key] = df[key] + [dict[key]]
					#dfKeys.erase(key)
				## this list checks for the keys in df that don't have a value in the current Dict and adds a null for their arrays
			for nk in df.keys():
				if nk == 'idx' or dict.has(nk):
					continue
				else:
					#print(dict)
					#print("adding a null to our df bc this dict in the array doesn't have key %s" % nk)
					df[nk] = df[nk] + [null]
			## now, for any keys present in the DataTable that weren't mentioned in the instance, add null
			#for key in dfKeys:
				#df[key] = df[key] + [null]
	#return df
	#print(df)
	#for k in df.keys():
		#print("%s: %s len %d" % [k, type_string(typeof(df[k])), len(df[k])])
	var ret = DataTable.new(df, dfName)
	#print(ret)
	return ret

static func _extractObjects(content, path: String = "", r: bool = false) -> Array:
	#print("in _extract.")
	var result = []
	if content is Dictionary:
		
		## original
		#if not path:
			#result.append({path: {}})
		## i find that weird, flipping conditional
		if path:
			result.append({path: {}})
		
		for key in content.keys():
			var value = content[key]
			
			var curPath
			if not path:
				curPath = key
			else:
				curPath = "%s.%s" % [path, key]
			
			if value is Dictionary:
				
				if r:
					push_warning("warning: nested dictionaries found within collection (dict or array). proper implementation missing.")
					var df = {'index': range(value.size()-1)}
					for k in value.keys():
						var v = value[k]
						if v is Dictionary:
							for nk in v.keys():
								df["%s.%s" % [k, nk]] = v[nk]
						else:
							df[k] = v
					var found = false
					if path:
						for i in range(result.size()-1,0,-1):
							if path in result[i].keys():
								var d = result[i]
								var intd = d[path]
								intd[key] = value
								d[path] = intd
								result[i] = d
								found = true
								break
						if not found:
							result.append(df)
					else:
						result.append(df)
				else:
					result.append_array(_extractObjects(value, curPath, not r))
			
			elif value is Array:
				var df = _dlist(value, key) ## remember we're gonna pass key in here too when implemented
				if df is bool:
					result.append_array(_extractObjects(value, curPath, not r))
				else:
					result.append(df)
					
			
			elif path:
				for i in range(result.size()-1, 0, -1):
					if path in result[i].keys():
						var d = result[i]
						var intd = d[path]
						intd[key] = value
						d[path] = intd
						result[i] = d
						break
			else:
				result.append({curPath: value})
	
	elif content is Array:
		print("WOW CONTENT IS FUCKING ARRAY")
		var df = _dlist(content, path) ## remember we're gonna pass key in here too when implemented
		
		if df is bool:
			for i in range(content.size()-1):
				var item = content[i]
				var curPath
				if path == "":
					curPath = "[%d]" % i
				else:
					curPath = "%s[%d]" % [path, i]
				if item is Dictionary:
					result.append_array(_extractObjects(item, curPath, not r))
				else:
					result.append({curPath: item})
		else:
			result.append(df)
	for i in range(len(result)):
		if not result[i] is DataTable:
			print("this result in _extract was not a Data Table:\n\t" + str(result[i]))
			result[i] = DataTable.new(result[i], "dict that wasn't dict list")
	return result


# Function to simulate a DataFrame-like structure
#static func dlist(l: Array):
	#var df = {"index": range(l.size())}
	#for i in df["index"]:
		#var known_keys = df.keys()
		#known_keys.erase("index")
		#var d = l[i]
		#if typeof(d) != TYPE_DICTIONARY:
			#return false
		#else:
			#for key in d.keys():
				#var value = d[key]
				#if typeof(value) == TYPE_DICTIONARY:
					#for k in value.keys():
						#var v = value[k]
						#var nk = key + "." + k
						#if not df.has(nk):
							#df[nk] = []
							#for j in range(0, i):
								#df[nk] = df[nk] + [null]
							#df[nk] = df[nk] + [v]
						#else:
							#df[nk].append(v)
							#known_keys.erase(nk)
				#elif not df.has(key):
					#df[key] = [] 
					#for j in range(0, i):
						#df[key] = df[key] + [null]
					#df[key] = df[key] + [value]
				#else:
					#known_keys.erase(key)
					#df[key].append(value)
		#if known_keys.size() > 0:
			#for nk in known_keys:
				#df[nk].append(null)
	#return df

# Function to extract objects from a JSON structure
#static func extract_objects(content, path: String = '', r: bool = false) -> Array:
	#var result = []
	#
	#if typeof(content) == TYPE_DICTIONARY:
		#
		#if path != '':
			#result.append({path: {}})
		#
		#for key in content.keys():
			#var value = content[key]
			#var current_path
			#
			#if path != "":
				#current_path = path + "." + key
			#else:
				#current_path = key
			#
			#if typeof(value) == TYPE_DICTIONARY:
				#if r:
					#var df = {"index": [0]}
					#for k in value.keys():
						#var v = value[k]
						#if typeof(v) == TYPE_DICTIONARY:
							#for nk in v.keys():
								#var nv = v[nk]
								#df[k + "." + nk] = nv
						#else:
							#df[k] = v
					#
					#var found = false
					#if path != '':
						#for i in range(result.size() - 1, -1, -1):
							#if result[i].has(path):
								#var d = result[i]
								#var intd = d[path]
								#intd.merge(df)
								#d[path] = intd
								#result[i] = d
								#found = true
								#break
						#if not found:
							#result.append(df)
					#else:
						#result.append(df)
				#else:
					#result += extract_objects(value, current_path, not r)
#
			#elif typeof(value) == TYPE_ARRAY:
				#var df = dlist(value)
				#if df is Dictionary:
					#result.append(df)
				#else:
					#result += extract_objects(value, current_path, not r)
#
			#elif path != '':
				#for i in range(result.size() - 1, -1, -1):
					#if result[i].has(path):
						#var d = result[i]
						#var intd = d[path]
						#intd[key] = value
						#d[path] = intd
						#result[i] = d
						#break
			#else:
				#result.append({current_path: value})
		#
	#elif typeof(content) == TYPE_ARRAY:
		#var df = dlist(content)
		#if df is Dictionary:
			#result.append(df)
		#else:
			#for index in range(content.size()):
				#var item = content[index]
				#var current_path = path + "[" + str(index) + "]"
				#if typeof(item) in [TYPE_DICTIONARY, TYPE_ARRAY]:
					#result += extract_objects(item, current_path)
				#else:
					#result.append({current_path: [item]})
#
	#return result

# Function to populate an array of dictionaries from a JSON string
static func populate_array_of_dicts(content) -> Array:
	var extracted_objects = _extractObjects(content)
	
	# Populate the structured data with values from the extracted objects
	for obj in extracted_objects:
		print(obj)
		print("\n")
	
	print("\n")
	return extracted_objects

#func processParsedData(result):
	#var nodesData = Dictionary()
	#var linesData = Dictionary()
	#var ret = Dictionary()
	#
	#
	#if result is Dictionary:
		#if collection_name_nodes and result.has(collection_name_nodes):
			#nodesData = deepMerge(getNodesData(result[collection_name_nodes]), nodesData, true)
			#
			#
		#
		#if result.has(collection_name_lines):
			#linesData = deepMerge(getLinesData(result[collection_name_lines]), linesData, true)
		#
		#ret[collection_name_nodes] = nodesData
		#ret[collection_name_lines] = linesData
		#return ret
	#
	#elif result is Array:
		## check which has more keys
		#if elementKeysResembleNode(result[0], getInputKeys()):
			#nodesData = deepMerge(getNodesData(result), nodesData, true)
		#else:
			#linesData = deepMerge(getLinesData(result), linesData, true)
		#
		#ret[collection_name_nodes] = nodesData
		#ret[collection_name_lines] = linesData
		#return ret
	#else:
		#push_error("error: haven't implemented inferred class array parsing !!!!!!!!")
		#return null
#
#
#func getLinesData(dataLines):
	#
	#var getInteractDict = func keyNestedKVPair(instance, key):
		#"""takes nested dict and key, where internal keys are separated by \\, returns internal kv pair"""
		#var ret = instance
		#for subKey in key.split("\\"):
			#ret = {subKey: ret[subKey]}
		#return ret
	#var lineData = {}
	#for instance in dataLines:
		#var line = {}
		#
		#if instance.has(id_line):
			#line.id = str(instance[id_line])
			#if font_size_id_line and instance.has(font_size_id_line):
				#if instance[font_size_id_line] is String:
					#line.fontSize = instance[font_size_id_line].to_int()
				#else:
					#line.fontSize = instance[font_size_id_line]
				#
		#else:
			#line.id = str(defaultLineID)
			#defaultLineID += 1
		#
		#if instance.has(node_start):
			#if instance.has("actualStart"):
				#line.start = instance["actualStart"]
			#else:
				#line.start = instance[node_start]
		#
		#elif instance.has_all([start_x, start_y]) and (line_positioning == LINE_POSITIONING.QUARDINATE or not line.has("start")):
			#if start_x == start_y:
				#line.start = Vector2(instance[start_x][0], instance[start_x][1])
			#else:
				#line.start = Vector2(instance[start_x], instance[start_y])
		#else:
			#push_error("ERROR: Line description does not describe starting position.\nLine:\t"+str(instance))
		#
		#if instance.has(node_end):
			#line.end = instance[node_end]
		#
		#if instance.has_all([end_x, end_y]) and (line_positioning == LINE_POSITIONING.QUARDINATE or not line.has("end")):
			#if end_x == end_y:
				#line.end = Vector2(instance[end_x][0], instance[end_x][1])
			#else:
				#line.end = Vector2(instance[end_x], instance[end_y])
		#
		#if instance.has(line_path):
			#line.path = instance[line_path]
		#
		#if instance.has_all([length, rotation_line]):
			#line.len = Vector2(instance[length], 0)
			#if angle_units_line == ANGLE_UNITS.DEGREES:
				#line.rot = deg_to_rad(instance[rotation_line])
			#else:
				#line.rot = instance[rotation_line]
#
		#if instance.has(thickness):
			#line.thickness = instance[thickness]
		#
		#
		#if instance.has(color_line):
			#line.color = instance[color_line]
		#
		#var interact_data = {}
		#for interaction_key in interaction_keys_nodes:
			#deepMerge(interact_data, getInteractDict.call(instance, interaction_key))
		#line.interaction = interact_data
		#
		#lineData[line.id] = line
	#return lineData
