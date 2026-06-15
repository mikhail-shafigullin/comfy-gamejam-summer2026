class_name AddIngredientMiniGame
extends Control

signal finished

@export var duration: float = 2.0

@onready var timer: Timer = $Timer;
@onready var progressBar: ProgressBar = $Panel/VBoxContainer/ProgressBar

func _ready() -> void:
	timer.wait_time = duration
	timer.timeout.connect(_on_timer_timeout)

func start():
	self.visible = true;
	timer.start()
	progressBar.value = 0.0

func _process(delta: float) -> void:
	var elapsed = duration - timer.time_left
	progressBar.value = (elapsed / duration) * 100.0

func _on_timer_timeout() -> void:
	finished.emit();
	restart();

func restart():
	self.visible = false;
	progressBar.value = 0.0;
