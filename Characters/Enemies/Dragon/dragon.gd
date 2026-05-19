extends CharacterBody2D

var speed = 50.0
var direction = 1
var gravity = 980
var player_on_range = false
var is_attacking = false # Controla si el dragón está en medio de un ataque

@onready var sprite_dragon = $body/DragonAnimated
@onready var sprite_fire = $body/DragonAnimated/Fire
@onready var detector = $body/FloorDetector
@onready var attack_timer = $body/AttackTimer # Si no lo usas, puedes borrar esta línea

func _ready() -> void:
	# Nos aseguramos de que el fuego empiece apagado
	sprite_fire.visible = false
	$body/FireArea.monitoring = false

func _physics_process(delta):
	# 1. Gravedad
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# 2. Movimiento e IA (Solo funciona si NO está atacando y NO está muerto)
	if not is_attacking and sprite_dragon.animation != "death":
		# Comprobamos si hay suelo
		if is_on_floor() and not detector.is_colliding():
			turnaround()
		
		velocity.x = direction * speed
		sprite_dragon.play("walk")
	else:
		# Si está atacando o muriendo, se queda quieto
		velocity.x = 0

	move_and_slide()

# Función para dar la vuelta al dragón
func turnaround():
	# Girar el nodo padre "body" gira TODO (sensor, áreas, dibujos)
	$body.scale.x *= -1
	direction *= -1

# --- LÓGICA DE DETECCIÓN DEL JUGADOR ---

func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.name == 'Player':
		player_on_range = true
		
		# 1. Calculamos de qué lado está el jugador
		# Si da 1, está a la derecha. Si da -1, está a la izquierda.
		var direccion_jugador = sign(body.global_position.x - global_position.x)
		
		# 2. Si la dirección del jugador es diferente a la dirección del dragón... ¡Gira!
		if direccion_jugador != direction and direccion_jugador != 0:
			turnaround()
			
		# 3. Ahora que ya te está mirando a los ojos, ataca
		if not is_attacking:
			attack()

func _on_attack_area_body_exited(body: Node2D) -> void:
	if body.name == 'Player':
		player_on_range = false

# --- LÓGICA DE ATAQUE ---

func attack():
	# Si está muerto o el jugador no está, cancelamos
	if not player_on_range or sprite_dragon.animation == "death": 
		return
	
	is_attacking = true
	sprite_dragon.play("attack")

# Sincronizamos el fuego para que salga en el frame 3 del ataque
func _on_dragon_animated_frame_changed() -> void:
	if sprite_dragon.animation == "attack":
		if sprite_dragon.frame == 3:
			sprite_fire.show()
			sprite_fire.play("attack")
			$body/FireArea.monitoring = true

# Cuando termina la animación del dragón, evaluamos qué hacer
func _on_dragon_animated_animation_finished() -> void:
	if sprite_dragon.animation == "attack":
		sprite_fire.hide() 
		$body/FireArea.monitoring = false
		
		if player_on_range:
			# Pausa antes del siguiente ataque
			await get_tree().create_timer(0.5).timeout
			# ¡COMPROBAMOS DE NUEVO! Porque el jugador pudo haberse ido durante la pausa
			if player_on_range:
				attack()
			else:
				is_attacking = false
				sprite_dragon.play("walk")
		else:
			# Si se fue, volvemos a patrullar inmediatamente
			is_attacking = false
			sprite_dragon.play("walk")

# (Opcional) Por si la animación del fuego tiene su propia señal
func _on_fire_animation_finished() -> void:
	sprite_fire.hide()
	$body/FireArea.monitoring = false

# --- LÓGICA DE RECIBIR DAÑO Y MORIR ---

# El dragón recibe un golpe
func _on_dragon_body_area_entered(area: Area2D) -> void:
	if area.name == 'PunchArea':
		kill_dragon()

func kill_dragon():
	# Evitamos que entre código de ataque o movimiento
	is_attacking = true 
	
	sprite_dragon.play("death")
	
	# Apagamos sus colisiones dañinas de forma segura (set_deferred es obligatorio aquí)
	$body/DragonDamage.set_deferred("monitoring", false)
	$body/FireArea.set_deferred("monitoring", false)
	
	# Esperamos que acabe de caer y lo eliminamos
	await sprite_dragon.animation_finished
	queue_free()
	Global.add_points(10)

# --- LÓGICA DE HACER DAÑO AL JUGADOR ---

# Daño por contacto físico
func _on_dragon_damage_body_entered(body: Node2D) -> void:
	if body.name == "Player" and sprite_dragon.animation != "death":
		Global.loose_life()

# Daño por el fuego
func _on_fire_area_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		Global.loose_life()
