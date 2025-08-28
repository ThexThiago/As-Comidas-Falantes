extends CharacterBody2D

@export var speed: float = 200.0
@export var jump_force: float = -400.0
@export var gravity: float = 900.0
@export var max_jumps: int = 2

@onready var anim = $AnimatedSprite2D

var jumps_remaining: int = 0
var is_attacking: bool = false

func _ready():
	anim.connect("animation_finished", _on_animation_finished)

func _physics_process(delta):
	# Gravidade
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		jumps_remaining = max_jumps

	# Movimento horizontal
	var direction = Input.get_axis("ui_left", "ui_right")
	velocity.x = direction * speed
	
	# Pulo
	if Input.is_action_just_pressed("ui_accept") and jumps_remaining > 0:
		velocity.y = jump_force
		jumps_remaining -= 1
		anim.play("Jump")
		is_attacking = false

	# Ataque
	if Input.is_action_just_pressed("ui_attack") and is_on_floor() and not is_attacking:
		is_attacking = true
		anim.play("Attack")
	
	# Controle de animação
	if is_attacking:
		return
	
	if not is_on_floor():
		anim.play("Jump")
		if direction != 0:
			anim.flip_h = direction < 0
	else:
		if direction != 0:
			anim.play("run")
			anim.flip_h = direction < 0
		else:
			anim.play("Parado")

	move_and_slide()

# Esta função é chamada quando qualquer animação termina.
# Apenas redefinimos o estado de ataque.
func _on_animation_finished():
	is_attacking = false
