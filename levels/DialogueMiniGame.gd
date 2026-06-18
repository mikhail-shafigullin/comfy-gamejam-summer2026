class_name DialogueMiniGame
extends Control

@onready var dialogueBorders: Control = %DialogueBorders
@onready var spawnTimer: Timer = %SpawnTimer

func _ready() -> void:
	spawnTimer.timeout.connect(spawnTemplate)

func spawnTemplate() -> DialogueMiniGameTemplate:
	var template := preload("res://levels/dialogueMiniGameTemplate.tscn").instantiate() as DialogueMiniGameTemplate
	add_child(template)
	var bordersRect := dialogueBorders.get_rect()
	var templateSize := template.size
	var randomX := randf_range(bordersRect.position.x, bordersRect.position.x + bordersRect.size.x - templateSize.x)
	var randomY := randf_range(bordersRect.position.y, bordersRect.position.y + bordersRect.size.y - templateSize.y)
	template.position = Vector2(randomX, randomY)
	print("12312")
	template.start()
	return template
