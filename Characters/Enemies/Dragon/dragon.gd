extends CharacterBody2D

var speed = 50.0
var direction = 1
var gravity = 980
var player_on_range = false

@onready var sprite_dragon = $DragonAnimated
@onready var sprite_fire = $DragonAnimated/Fire
@onready var detector = $FloorDetector
@onready var attack_timer = $AttackTimer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite_fire.visible = false

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if is_on_floor() and not detector.is_colliding():
		turnaround()
	
	velocity.x = direction * speed
	move_and_slide()
	
	if velocity.x != 0:
		sprite_dragon.play("walk")
		sprite_dragon.flip_h = (direction < 0)

func turnaround():
	direction *= -1
	detector.position.x *= -1
	# Volteamos todo el nodo de ataque (fuego y su colisión)
	$FireArea.position.x *= -1
	sprite_fire.position.x *= -1
	sprite_fire.flip_h = (direction < 0)

func _on_attack_timer_timeout():
	attack()

func attack():
	if not player_on_range: return
	var last_speed = speed
	speed = 0
	
	sprite_dragon.play("attack")
	
	if player_on_range:
		await get_tree().create_timer(1.0).timeout
		attack() 
	else:
		speed = last_speed

func _process(delta: float) -> void:
	pass

func _on_frame_changed() -> void:
	if sprite_dragon.animation == "attack":

		if sprite_dragon.frame == 3:
			blow_fire()
			
func blow_fire():
	sprite_fire.visible = true
	sprite_fire.play("attack")
	$FireArea.monitoring = true
	
func _on_fire_animation_finished() -> void:
	sprite_fire.visible = false
	$FireArea.monitoring = false

func _on_dragon_damage_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		Global.loose_life()

func _on_fire_area_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		Global.loose_life()

func _on_dragon_body_area_entered(area: Area2D) -> void:
	if area.name == 'PunchArea':
		kill_dragon()

func kill_dragon():
	sprite_dragon.play("death")
	$DragonDamage.monitoring = false
	$FireArea.monitoring = false
	await sprite_dragon.animation_finished
	queue_free()
	Global.add_points(10)

func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.name == 'Player':
		player_on_range = true

func _on_attack_area_body_exited(body: Node2D) -> void:
	if body.name == 'Player':
		player_on_range = false


func _on_dragon_animated_frame_changed() -> void:
	if sprite_dragon.animation == "attack":
		if sprite_dragon.frame == 3:
			sprite_fire.show()
			sprite_fire.play("attack")
			$FireArea.monitoring = true


func _on_dragon_animated_animation_finished() -> void:
	if sprite_dragon.animation == "attack":
		sprite_fire.hide() 
		$FireArea.monitoring = false
		sprite_dragon.play("walk")
