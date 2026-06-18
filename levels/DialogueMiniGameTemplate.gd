class_name DialogueMiniGameTemplate
extends Control

signal succeeded()
signal failed()

@export var duration: float = 2.0

@onready var progressBar: ProgressBar = %ProgressBar

var _timeLeft: float = 0.0
var _active: bool = false

func start() -> void:
	_timeLeft = duration
	_active = true

func _process(delta: float) -> void:
	if not _active:
		return
	_timeLeft -= delta
	progressBar.value = (_timeLeft / duration) * 100.0
	if _timeLeft <= 0.0:
		fail()

func _gui_input(event: InputEvent) -> void:
	if not _active:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		success()

func success() -> void:
	_active = false
	succeeded.emit()
	queue_free()

func fail() -> void:
	_active = false
	failed.emit()
	queue_free()
