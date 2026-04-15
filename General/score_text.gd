extends Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	text = ""
	Global.high_scores.sort()
	Global.high_scores.reverse()
	for score in Global.high_scores:
		text += "\n \n" + str(score)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
