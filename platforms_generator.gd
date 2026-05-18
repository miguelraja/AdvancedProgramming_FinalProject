extends Node2D

@export var platform_types: Array[PackedScene]
@export var player: CharacterBody2D
@export var primer_empujon_x: float = 1

# --- CONFIGURACIÓN DE TAMAÑO Y DISTANCIA ---
@export var platform_width: float = 1050.0

# Huecos en X ajustados a tu SPEED de 450 y salto
@export var min_gap_x: float = 50.0   
@export var max_gap_x: float = 250.0  

# --- CONFIGURACIÓN DE CARRILES ---
@export var lane_top_y: float = 450.0   # Carril Alto
@export var lane_mid_y: float = 530.0   # Carril Medio 
@export var lane_bot_y: float = 610.0   # Carril Bajo  

var lanes: Array[float] = []
var current_lane_index: int = 1 
var last_position_x: float = 0.0

func _ready():
	print("--- INICIANDO GENERADOR DE CARRILES ---")
	lanes = [lane_top_y, lane_mid_y, lane_bot_y]
	
	if player:
		# Primer empujón para saltar la plataforma manual inicial
		last_position_x = player.global_position.x + primer_empujon_x
		
	# Generamos las 5 iniciales
	for i in range(5):
		spawn_platform()

func spawn_platform():
	if platform_types.is_empty(): return
	
	var random_platform_scene = platform_types.pick_random()
	if random_platform_scene == null: return
	
	var new_platform = random_platform_scene.instantiate()
	
	# --- 1. LÓGICA DE CARRILES (FORZAR CAMBIO SIEMPRE / ZIG-ZAG) ---
	if current_lane_index == 0: 
		# Si está en el carril Alto, OBLIGAMOS a que baje al Medio
		current_lane_index = 1
	elif current_lane_index == 2: 
		# Si está en el carril Bajo, OBLIGAMOS a que suba al Medio
		current_lane_index = 1
	else: 
		# Si está en el carril Medio, decidimos al azar si va al Alto (0) o al Bajo (2)
		current_lane_index = [0, 2].pick_random()
	
	var new_y = lanes[current_lane_index]
	
	# --- 2. CÁLCULO DE DISTANCIA X ---
	# Como siempre hay salto diagonal, usamos el multiplicador de 0.7 para que el hueco sea alcanzable
	var gap_x = randf_range(min_gap_x, max_gap_x) * 0.7
	var new_x = last_position_x + platform_width + gap_x
	
	# --- 3. POSICIONAR ---
	# CRÍTICO: Primero añadimos la plataforma al juego (add_child)
	add_child(new_platform)
	# Y DESPUÉS le damos su posición global.
	new_platform.global_position = Vector2(new_x, new_y)
	
	# Guardamos la posición actual para la siguiente
	last_position_x = new_x
	print("Plataforma en Carril: ", current_lane_index, " | X: ", int(new_x), " Y: ", int(new_y))

func _process(_delta):
	# CHIVATO: Comprobar si se perdió la conexión con el jugador
	if player == null: 
		print("WARNING! The generator does not know who is the player.")
		return
	
	var distancia_al_borde = last_position_x - player.global_position.x
	
	# Si el final del camino está a menos de 4000 píxeles, creamos una nueva
	if distancia_al_borde < 4000:
		spawn_platform()
