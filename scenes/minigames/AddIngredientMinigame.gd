class_name AddIngredientMiniGame
extends Control

signal finished(result: CocktailMixingController.IngredientMiniGameStatus)

@export var duration: float = 1.0

@onready var progress_bar: ProgressBar = %ProgressBar
@onready var result_label: Label = %ResultLabel
@onready var iconAnimationPlayer: AnimationPlayer = %IconAnimationPlayer;
@onready var panel: PanelContainer = %Panel;

var is_running: bool = false
var current_value: float = 0.0
var _pulse_tween: Tween;
var pulseDirection = 1.0;

func start() -> void:
	visible = true
	current_value = 0.0
	progress_bar.value = 0.0
	result_label.text = ""
	is_running = true
	iconAnimationPlayer.play("iconAnim")
	_startPulse()

func _startPulse() -> void:
	if _pulse_tween:
		_pulse_tween.kill()
	pulseDirection = 1.0 if pulseDirection < 0 else -1.0
	_pulse_tween = create_tween().set_loops().set_parallel()
	_pulse_tween.tween_property(panel, "scale", Vector2(1.05, 1.05), 0.6).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	_pulse_tween.tween_property(panel, "scale", Vector2(1.0, 1.0), 0.6).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE).set_delay(0.6)
	_pulse_tween.tween_property(panel, "rotation", deg_to_rad(pulseDirection * 2.0), 0.3).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	_pulse_tween.tween_property(panel, "rotation", deg_to_rad(pulseDirection * -2.0), 0.3).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE).set_delay(0.3)
	_pulse_tween.tween_property(panel, "rotation", deg_to_rad(0.0), 0.3).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE).set_delay(0.6)
	_pulse_tween.tween_property(panel, "rotation", deg_to_rad(pulseDirection * 2.0), 0.3).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE).set_delay(0.9)

func _stopPulse() -> void:
	if _pulse_tween:
		_pulse_tween.kill()
		_pulse_tween = null
	panel.scale = Vector2.ONE
	panel.rotation = 0.0

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
	_stopPulse()
	result_label.text = CocktailMixingController.getStatusName(result)
	await get_tree().create_timer(1.0).timeout
	visible = false
	current_value = 0.0
	progress_bar.value = 0.0
	finished.emit(result)
