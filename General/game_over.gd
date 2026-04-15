extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.high_scores.append(Global.points)
	
	Global.high_scores.sort()
	Global.high_scores.reverse()
	
	if Global.high_scores.size() > 5:
		Global.high_scores.resize(5)

func _on_restart_pressed() -> void:
	Global.lifes = 3;
	Global.points = 0;
	get_tree().change_scene_to_file("res://General/main.tscn");
	
func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://General/MainMenu.tscn");

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
