class_name AddIngredientMiniGame
extends Control

signal finished(result: CocktailMixingController.IngredientMiniGameStatus)

@export var duration: float = 2.0

@onready var progress_bar: ProgressBar = $Panel/VBoxContainer/BarArea/ProgressBar
@onready var result_label: Label = $Panel/VBoxContainer/ResultLabel

var is_running: bool = false
var current_value: float = 0.0

func start() -> void:
	visible = true
	current_value = 0.0
	progress_bar.value = 0.0
	result_label.text = ""
	is_running = true

func _process(delta: float) -> void:
	if not is_running:
		return
	current_value = minf(current_value + (delta / duration) * 100.0, 100.0)
	progress_bar.value = current_value
	if current_value >= 100.0:
		_finish(CocktailMixingController.IngredientMiniGameStatus.OK)

func _input(event: InputEvent) -> void:
	if not visible or not is_running:
		return
	if event is InputEventMouseButton and event.pressed:
		_finish(_get_result())

func _get_result() -> CocktailMixingController.IngredientMiniGameStatus:
	if current_value >= 85.0 and current_value <= 90.0:
		return CocktailMixingController.IngredientMiniGameStatus.PERFECT
	if current_value >= 80.0 and current_value <= 95.0:
		return CocktailMixingController.IngredientMiniGameStatus.GOOD
	return CocktailMixingController.IngredientMiniGameStatus.OK

func _finish(result: CocktailMixingController.IngredientMiniGameStatus) -> void:
	is_running = false
	result_label.text = CocktailMixingController.getStatusName(result)
	await get_tree().create_timer(1.0).timeout
	visible = false
	current_value = 0.0
	progress_bar.value = 0.0
	finished.emit(result)
