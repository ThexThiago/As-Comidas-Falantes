extends StaticBody2D

@export var speed: float = 100.0       # Velocidade da plataforma
@export var distance: float = 500.0    # Distância máxima esquerda/direita

var start_position: Vector2 
var direction: int = 1
var player: Node = null  # Referência ao player

func _ready():
	start_position = position

func _process(delta):
	# Guarda posição antiga
	var old_position = position

	# Move a plataforma no eixo X
	position.x += direction * speed * delta

	# Verifica limite esquerdo/direito
	if position.x > start_position.x + distance:
		direction = -1
	elif position.x < start_position.x - distance:
		direction = 1

	# Se o player está em cima, move ele junto
	if player != null:
		var movement = position - old_position
		player.position += movement

# Chamado quando o player entra na área da plataforma
func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
		player = body

# Chamado quando o player sai da área
func _on_area_2d_body_exited(body):
	if body == player:
		player = null
