extends CharacterBody2D


const SPEED = 450.0
const JUMP_VELOCITY = -400.0
@onready var _animation_player = $Body/AnimatedSprite2D

func _ready() -> void:
	$Body/PunchArea.monitoring = false

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if (Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_up"))and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED) 

	if direction != 0:
		$Body.scale.x = direction

	if Input.is_action_pressed("action"):
		punch()
	if _animation_player.animation == "attack" and _animation_player.is_playing():
		pass
	elif not is_on_floor():
		_animation_player.play("jump")
	elif direction != 0:
		_animation_player.play("walk")
	else:
		_animation_player.play("idle")
				

	move_and_slide()

func punch():
	_animation_player.play("attack")
	$Body/PunchArea.monitoring = true
	await _animation_player.animation_finished
	$Body/PunchArea.monitoring = false

func _on_kill_zone_body_entered(body: Node2D) -> void:
	get_tree().change_scene_to_file("res://General/GameOver.tscn")
