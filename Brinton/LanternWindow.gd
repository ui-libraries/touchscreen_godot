extends Control
var numFrames = {"A":2,"B":5,"C":13,"D":11,"E":8,"F":12,"G":2}
var curFrame = 0
var curLantern 

var path = "res://textures/lanterns/lantern%s (%d).jpg"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass





func _on_lantern_atb_pressed():
	curLantern = "A"
	curFrame = 1
	# var lantern = load("res://Brinton/lantern scenes/lantern_a.tscn")
	# var lanternFr = lantern.instantiate()
	# lanternFr.size.y = size.y
	# lanternFr.size.x = size.x
	# #lanternFr.scale = Vector2(size.x/lanternFr.size.x, size.x/lanternFr.size.x)
	# lanternFr.position = Vector2(450,0)
	# add_child(lanternFr)
	


func _on_lantern_btb_pressed():
	curLantern = "B"
	curFrame = 1
	$LanternImage.texture = load(path % [curLantern, curFrame])


func _on_lantern_dtb_pressed():
	curLantern = "D"
	curFrame = 1
	$LanternImage.texture = load(path % [curLantern, curFrame])


func _on_lantern_etb_pressed():
	curLantern = "E"
	curFrame = 1
	$LanternImage.texture = load(path % [curLantern, curFrame])

func _on_lantern_ftb_pressed():
	curLantern = "F"
	curFrame = 1
	$LanternImage.texture = load(path % [curLantern, curFrame])


func _on_lantern_gtb_pressed():
	curLantern = "G"
	curFrame = 1
	$LanternImage.texture = load(path % [curLantern, curFrame])


func _on_lantern_ctb_pressed():
	curLantern = "C"
	curFrame = 1
	$LanternImage.texture = load(path % [curLantern, curFrame])


func _on_left_button_pressed():
	# var lantern = get_children()[-1]
	# var prevFrame = lantern.get_child(curFrame)
	# prevFrame.visible = false
	
	if curFrame == 0: curFrame = numFrames[curLantern]# - 1
	else: curFrame -= 1
	
	$LanternImage.texture = load(path % [curLantern, curFrame])
	# var newFrame = lantern.get_child(curFrame)
	# newFrame.visible = true


func _on_right_button_pressed():
	# var lantern = get_children()[-1]
	# var prevFrame = lantern.get_child(curFrame)
	# prevFrame.visible = false
	
	if curFrame == numFrames[curLantern]: curFrame = 1# 0
	else: curFrame += 1
	
	$LanternImage.texture = load(path % [curLantern, curFrame])
	# var newFrame = lantern.get_child(curFrame)
	# newFrame.visible = true


func _on_exit_pressed():
	# remove_child(get_children()[-1]) we don't want to strain memory too much :/
	pass
