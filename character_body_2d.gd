extends CharacterBody2D

@export var speed: float = 200.0
@export var jump_force: float = -400.0
@export var gravity: float = 900.0
@export var max_jumps: int = 2
@export var max_health: int = 100

@onready var anim = $AnimatedSprite2D
@onready var health_bar = get_node("/root/Cena/HUD/health_bar")  # caminho absoluto para garantir que não seja null

var jumps_remaining: int = 0
var is_attacking: bool = false
var health: int = max_health

func _ready():
	if health_bar == null:
		push_error("Health bar não encontrada! Verifique o caminho.")
		return

	anim.connect("animation_finished", _on_animation_finished)
	_setup_health_bar()
	_ensure_input_actions()

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
	
	# Teste de dano/cura
	if Input.is_action_just_pressed("damage"):
		_take_damage(10)
	if Input.is_action_just_pressed("heal"):
		_heal(10)
	
	# Controle de animação
	if is_attacking:
		move_and_slide()
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

# Configura a barra de vida
func _setup_health_bar():
	health_bar.min_value = 0
	health_bar.max_value = max_health
	health = max_health
	health_bar.value = health

func _take_damage(amount):
	health = max(health - amount, 0)
	health_bar.value = health
	if health <= 0:
		anim.play("death")

func _heal(amount):
	health = min(health + amount, max_health)
	health_bar.value = health

func _on_animation_finished():
	is_attacking = false
	if anim.animation == "death":
		queue_free()

# Configura teclas H (dano) e J (cura)
func _ensure_input_actions():
	if not InputMap.has_action("damage"):
		InputMap.add_action("damage")
		var damage_event = InputEventKey.new()
		damage_event.set_keycode(KEY_H)
		InputMap.action_add_event("damage", damage_event)

	if not InputMap.has_action("heal"):
		InputMap.add_action("heal")
		var heal_event = InputEventKey.new()
		heal_event.set_keycode(KEY_J)
		InputMap.action_add_event("heal", heal_event)
