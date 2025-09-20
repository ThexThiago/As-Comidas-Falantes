extends CanvasLayer

@onready var health_bar = $health_bar

func _ready() -> void:
	var player = get_tree().get_root().get_node("Cena/CharacterBody2D")
	if player:
		player.connect("health_changed", _on_player_health_changed)

func _on_player_health_changed(current: int, max: int) -> void:
	health_bar.min_value = 0
	health_bar.max_value = max
	health_bar.value = current
