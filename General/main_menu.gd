extends CanvasLayer
@export var score = preload("res://General/score_text.tscn")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var ptr = $PointToWrite.get_child(0)
	write_scores(ptr.global_position)
	
func write_scores(pos: Vector2):
	var text
	text = score.instantiate()
	add_child(text)
	text.global_position = pos


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	Global.lifes = 3
	Global.points = 0
	get_tree().change_scene_to_file("res://General/main.tscn")
