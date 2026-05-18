extends StaticBody2D
@export var coin_normal = preload("res://Platforms/resources/normal_coin.tscn")
@export var coin_special = preload("res://Platforms/resources/special_coin.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var points = $SpawnPoints.get_children()
	points.shuffle()
	var amount = 2
	
	for i in range(amount):
		spawn_coin(points[i].global_position)

func spawn_coin(pos: Vector2):
	var new_coin
	if randf() < 0.2:
		new_coin = coin_special.instantiate()
	else:
		new_coin = coin_normal.instantiate()
	
	add_child(new_coin)
	new_coin.global_position = pos

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
