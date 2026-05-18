extends CharacterBody2D

const SPEED = 450.0
const JUMP_VELOCITY = -550.0
@onready var _animation_player = $Body/AnimatedSprite2D

func _ready() -> void:
	# CORRECCIÓN: Apagamos la colisión física por completo al empezar
	# (Asegúrate de que tu colisión dentro de PunchArea se llame exactamente CollisionShape2D)
	if has_node("Body/PunchArea/CollisionShape2D"):
		$Body/PunchArea/CollisionShape2D.disabled = true

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if (Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_up")) and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED) 

	if direction != 0:
		$Body.scale.x = direction

	# CORRECCIÓN: 'is_action_just_pressed' para que solo golpee UNA vez por clic
	if Input.is_action_just_pressed("action"):
		punch()
		
	# Gestión de animaciones
	if _animation_player.animation == "attack" and _animation_player.is_playing():
		pass
	elif not is_on_floor():
		_animation_player.play("jump")
	elif direction != 0:
		_animation_player.play("walk")
	else:
		_animation_player.play("idle")
				
	move_and_slide()

	# --- LÍMITE DE MUERTE POR CAÍDA ---
	if global_position.y > 800:
		get_tree().change_scene_to_file("res://General/GameOver.tscn")

# CORRECCIÓN: Ahora encendemos y apagamos la colisión real en el momento justo
func punch():
	# Si ya está atacando, no hacemos nada para no romper el ritmo
	if _animation_player.animation == "attack" and _animation_player.is_playing():
		return
		
	_animation_player.play("attack")
	
	# Encendemos el golpe (el dragón ahora sí puede sentirlo)
	$Body/PunchArea/CollisionShape2D.disabled = false
	
	# Esperamos a que la animación de dar el puñetazo termine
	await _animation_player.animation_finished
	
	# Apagamos el golpe (el dragón ya no volverá a sentirlo hasta el próximo clic)
	$Body/PunchArea/CollisionShape2D.disabled = true

func _on_kill_zone_body_entered(body: Node2D) -> void:
	get_tree().change_scene_to_file("res://General/GameOver.tscn")
