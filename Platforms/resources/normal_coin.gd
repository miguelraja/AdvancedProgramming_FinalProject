extends Area2D
@export var value = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimatedSprite2D.play("idle")
	
func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		Global.add_points(value)
		queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
