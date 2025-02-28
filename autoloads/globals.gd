@tool
extends Node

const theme_unexpected = "color theme not implemented for this class (I expected this to be empty when I first developed and can't say what to do with it)"

const datetimeConstructorStringFormat = "%Y%m%d %H%M%S"

const miniSeparator = "********************"
const methodOutputSeparator = "****************************************"
const bigSeparator = "********************************************************************************"

const NULL_TEMPLATE_NODE = -1
const GRAPH_TABLE_DEFAULT_VALUE = "NAV"

func html_to_bbcode(html: String) -> String:
	var bbcode := html

	# Substitute brackets
	bbcode = bbcode.replace("[", "[lb]")
	bbcode = bbcode.replace("]", "[rb]")

	# Replace basic tags
	bbcode = bbcode.replace("<b>", "[b]").replace("</b>", "[/b]")
	bbcode = bbcode.replace("<strong>", "[b]").replace("</strong>", "[/b]")
	bbcode = bbcode.replace("<i>", "[i]").replace("</i>", "[/i]")
	bbcode = bbcode.replace("<em>", "[i]").replace("</em>", "[/i]")
	bbcode = bbcode.replace("<u>", "[u]").replace("</u>", "[/u]")
	bbcode = bbcode.replace("<s>", "[s]").replace("</s>", "[/s]")
	bbcode = bbcode.replace("<del>", "[s]").replace("</del>", "[/s]")
	bbcode = bbcode.replace("<code>", "[code]").replace("</code>", "[/code]")

	# Replace paragraph and alignment tags
	bbcode = bbcode.replace("<p>", "[p]").replace("</p>", "[/p]")
	bbcode = bbcode.replace('<p style="text-align:center;">', "[center]").replace("</p>", "[/center]")
	bbcode = bbcode.replace('<p style="text-align:left;">', "[left]").replace("</p>", "[/left]")
	bbcode = bbcode.replace('<p style="text-align:right;">', "[right]").replace("</p>", "[/right]")
	bbcode = bbcode.replace('<p style="text-align:justify;">', "[fill]").replace("</p>", "[/fill]")

	# Replace lists
	bbcode = bbcode.replace("<ul>", "[ul]").replace("</ul>", "[/ul]")
	bbcode = bbcode.replace("<ol>", "[ol]").replace("</ol>", "[/ol]")
	bbcode = bbcode.replace("<li>", "[*]").replace("</li>", "")

	# Replace hyperlinks
	var url_regex := RegEx.new()
	url_regex.compile('<a href="([^"]+)">([^<]+)</a>')
	bbcode = url_regex.sub(bbcode, '[url=$1]$2[/url]', true)

	# Replace images
	var img_regex := RegEx.new()
	img_regex.compile('<img src="([^"]+)"(?: width="([^"]+)")?(?: height="([^"]+)")?\\s*/?>')
	bbcode = img_regex.sub(bbcode, '[img$2x$3]$1[/img]', true)

	# Replace colors
	var color_regex := RegEx.new()
	color_regex.compile('<span style="color:([^;]+);">([^<]+)</span>')
	bbcode = color_regex.sub(bbcode, '[color=$1]$2[/color]', true)

	# Replace line breaks
	bbcode = bbcode.replace("<br>", "\n").replace("<br/>", "\n").replace("<br />", "\n")

	# Remove any remaining HTML tags
	var tag_regex := RegEx.new()
	tag_regex.compile("<[^>]+>")
	bbcode = tag_regex.sub(bbcode, "", true)

	return bbcode

func lcm(a, b) -> float:
	if not ((a is int or a is float) and (b is int or b is float)):
		print("not getting gcd of this")
		return 0.0
	else: 
		if a == b: return a
		elif a == 0 or b == 0: return 0
		var ascale = 10 ** 6
		a = int(a * ascale)
		b = int(b * ascale)
		return float(a * b / gcd(a, b)) / ascale

func areInts(val) -> bool:
	if val is Array:
		for v in val:
			if v != null and not v is int:
				return false
	else: return typeof(val) == TYPE_INT
	return true

func areStrings(val):
	if val is Array:
		for v in val:
			if v != null and not v is String:
				return false
	else: return typeof(val) == TYPE_STRING
	return true

func gcd(a, b):
	while b != 0:
		var s = int(b)
		b = a % b
		a = s 
	return a 

func ensurePathExists(path: String) -> bool:
	# ensure we have directories in which to store all our files
	var absPath = ProjectSettings.globalize_path(path)
	var dirPath = absPath.get_base_dir()
	# if this path leads to a directory
	if dirPath == path:
		if not DirAccess.dir_exists_absolute(absPath):
			var er = DirAccess.make_dir_recursive_absolute(absPath)
			if er != OK:
				print("DirAccess.make_dir_recursive_absolute: %s" % error_string(er))
				return false 
	elif not DirAccess.dir_exists_absolute(dirPath):
		var er = DirAccess.make_dir_recursive_absolute(dirPath)
		if er != OK:
			print("DirAccess.make_dir_recursive_absolute: %s" % error_string(er))
			return false 
	return true 

func deepChildSetOwner(parent, newOwner):
	for c in parent.get_children():
		c.owner = newOwner 
		deepChildSetOwner(c, newOwner)

func _strs(v) -> bool:
	if typeof(v) in iterableTypes:
		
		if v is String: return true

		elif v is Dictionary: 
			for k in v:							if not v[k] is String: return false
			return true

		else:
			for i in range(len(v)): if not v[i] is String: return false
			return true
	return false

func ridConnections(obj: Object):
	for signalDict in obj.get_signal_list():
		for connectionDict in obj.get_signal_connection_list(StringName(signalDict.name)):
			connectionDict.signal.disconnect(connectionDict.callable)

func numSecondsIn(unit: String):
	match unit:
		"year":
			return 31536000
		"month":
			return 2628288
		"week":
			return 604800
		"day":
			return 86400
		"hour":
			return 3600
		"minute":
			return 60
		"second":
			return 1
		_:
			return -1

func add(d1: Dictionary, d2: Dictionary):
	for key in d2:
		if d1.has(key):
			d1[key] = d1[key] + d2[key]
		else:
			d1[key] = d2[key]
	return d1

func nullArray(length: int) -> Array:
	var ret = []
	for i in range(length):
		ret.append(null)
	return ret

const types1DOperable = [2, 3, 5, 6, 9, 10, 11, 12, 13, 15, 17, 18]
const typesNumeric = [2, 3, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19]
const typesNumericSelfMultiblicable = [2, 3, 5, 6, 9, 10, 11, 12, 13, 15, 17, 18, 19]
const notImplemented = "function not implemented."

const iterableTypes = [4, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38]
const arrayTypes = [28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38]

const MAX_NUM_POPUP_OPTIONS = 5

func NotImplemented():
	print(notImplemented)

enum ELEMENT_REFERENCE_NAMES {
	LINE,
	NODE,
	LABEL,
	POPUP
}

enum LABEL_ALLIGNMENT_SIDE {
	LEFT, 
	TOP,  
	CENTER,
	RIGHT, 
	BOTTOM
	}

enum LABEL_SIDE_POSITIONING {
	BEFORE_BEGIN, 
	AT_BEGIN, 
	CENTER, 
	AT_END, 
	AFTER_END
	}

enum CUSTOM_CLASS_CODES {
	LABEL_ELEMENT_LABEL,
	ELEMENT_LABEL,
	
	TITLE_LABEL_POPUP,
	SEPARATOR_TITLEBAR_CONTENT_POPUP,
	CONTENT_RTL_POPUP,
	OPTION_BUTTON_POPUP,
	CLOSE_BUTTON_POPUP,
	POPUP_ELEMENT,
	
	ELEMENT,
	
	
	POPUP_CONTAINER_GRAPH,
	FILTER_GRAPH,
	OPTION_BUTTON_GRAPH,
	
	LABEL_SLIDER_GRAPH,
	SLIDER_GRAPH,
	
	GRAPH
}
