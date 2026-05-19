extends HBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_hearts()
	
	Global.lifes_change.connect(update_hearts)

func update_hearts() -> void:
	var children = get_children()
	
	for i in range(children.size()):
		if i < Global.lifes:
			children[i].visible = true
		else:
			#children[i].visible = false
			children[i].modulate = Color(0, 0, 0, 0.3)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
