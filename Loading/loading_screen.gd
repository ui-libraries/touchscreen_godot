extends Control

@onready var progressBar = $ColorRect/ProgressBar

func updateProgressBar(newVal: float) -> void:
	progressBar.set_value_no_signal(newVal * 100) 

