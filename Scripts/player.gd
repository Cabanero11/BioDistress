extends Node3D

# Movimiento jugador y camara

@export var move_speed = 5.0
@export var look_sensitivity = 0.2
@onready var camera_3d: Camera3D = $Camera3D
# Mirar si tiene 1 camara solo, en process
var camara_actual = false

var velocity = Vector3()

# Limitaciones para el eje X de la camara
var max_look_up_angle = deg_to_rad(-80)
var max_look_down_angle = deg_to_rad(80)

func _ready() -> void:
	if is_multiplayer_authority():
		camera_3d.make_current()

func _process(delta):
	# Mirar si esta en multi, sino no moverse
	if not is_multiplayer_authority():
		return
	elif is_multiplayer_authority():
		if not camara_actual:
			camera_3d.make_current()
			camara_actual = true
		
	# Movimiento básico (WASD)
	var direction = Vector3()
	if Input.is_action_pressed("move_forward"):
		direction -= transform.basis.z
	if Input.is_action_pressed("move_backward"):
		direction += transform.basis.z
	if Input.is_action_pressed("move_left"):
		direction -= transform.basis.x
	if Input.is_action_pressed("move_right"):
		direction += transform.basis.x
	direction = direction.normalized()

	# Mover el jugador
	velocity = direction * move_speed * delta
	position += velocity

	# Movimiento del ratón para rotar la cámara (mirar alrededor)
	var mouse_delta = Input.get_last_mouse_velocity() * look_sensitivity * delta
	rotate_y(deg_to_rad(-mouse_delta.x))

	# Limitar la rotación en el eje X (evitar voltear completamente)
	var new_x_rotation = clamp(camera_3d.rotation.x + deg_to_rad(-mouse_delta.y), max_look_up_angle, max_look_down_angle)
	camera_3d.rotation.x = new_x_rotation
	
