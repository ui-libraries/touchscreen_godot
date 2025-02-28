extends Node

signal progress_changed(progress)
signal load_done 

var loadScreenPath: String = "res://Loading/loading_screen.tscn"
var loadScreen = load(loadScreenPath)
var loadedScene: PackedScene 
var newScenePath: String 
var progress: Array = [] 

var use_sub_threads: bool = true 

func load_scene(scene_path: String) -> void:
	newScenePath = scene_path
	
	var newLoadingScreen = loadScreen.instantiate()
	get_tree().get_root().add_child(newLoadingScreen)
	
	self.progress_changed.connect(newLoadingScreen.updateProgressBar)

	startLoad()

func startLoad():
	var loadState = ResourceLoader.load_threaded_request(newScenePath, "", use_sub_threads)

	if loadState == OK:
		set_process(true)
	else:
		print(error_string(loadState))
	
func _process(delta):
	if not newScenePath:
		set_process(false)
		return 
	
	var loadStatus = ResourceLoader.load_threaded_get_status(newScenePath, progress)
	match loadStatus:
		0: #ResourceLoader.THREAD_LOAD_INVALID_RESOURCE
			print("The resource is invalid, or has not been loaded with load_threaded_request.")
			set_process(false)
			return 
		2: #ResourceLoader.THREAD_LOAD_FAILED
			print("Some error occurred during loading and it failed.")
			set_process(false)
			return 
		1: #ResourceLoader.THREAD_LOAD_IN_PROGRESS
			emit_signal("progress_changed", progress[0])
		3: #ResourceLoader.THREAD_LOAD_LOADED
			var loadedResource = ResourceLoader.load_threaded_get(newScenePath)
			emit_signal("progress_changed", 1.0)
			load_done.emit()
			get_tree().change_scene_to_packed(loadedResource)
			set_process(false)