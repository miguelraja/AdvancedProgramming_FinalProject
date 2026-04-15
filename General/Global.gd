extends Node

var points = 0
var lifes = 3
var high_scores = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func add_points(quantity):
	points += quantity
	print("Total points: ", points)

func loose_life():
	lifes -=1
	print("Current lifes: ", lifes)
	if lifes <= 0:
		get_tree().change_scene_to_file("res://General/GameOver.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
