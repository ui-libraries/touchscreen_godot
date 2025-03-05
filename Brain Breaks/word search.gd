extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# Create an empty 13 x 13 grid
# Create a new function that will pass a list of related words and go through each word one by one
# It takes the first word in the list and places it on the grid.
# It randomly decides row and column starting point of the first letter of the word.
# It randomly decides the direction of the word, whether it places and can take on the following possible orientations
# a. horizontal (left-to-right or right-to-left)
# b. vertical (top-to-bottom or bottom-to-top)
# c. diagnol (left-to-right up, right-to-left down)
# d. diagnol (left-to-right down, right-to-left up)
# It determines if its possible to place the word, if it is not possible it repeats steps 4 and 5.
# If it is possible, it places the word according to the randomly selected position and randomly selected orientation.
# When its done placing all the words, it goes ahead and fills in all the empty spots in the grid with random letters.