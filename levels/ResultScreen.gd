class_name ResultScreen
extends Control

@export var scoreUpdateElementScene: PackedScene

@onready var scoreUpdates: VBoxContainer = %ScoreUpdates
@onready var scoreScrollContainer: ScrollContainer = %ScrollContainer
@onready var fullAmount: Label = %FullAmount
@onready var progressBars: Control = %ProgressBars
@onready var finalLettersScore: Label = %FinalLettersScore
@onready var currentCocktailLabel: Label = %CurrentCocktailLabel;
@onready var resultScreenDetails: Control = %ResultScreenDetails;

var _resultsShown: bool = false
var _barTween: Tween = null
var _pulseTween: Tween = null
var _labelPulseTween: Tween = null
var _currentFilledBars: int = 0

const RANK_TEXTS := ["C", "B", "A", "S", "SS", "SSS"]
const RANK_SCALES := [1.0, 1.05, 1.12, 1.22, 1.35, 1.5]
const RANK_PULSE_AMPS := [0.0, 0.04, 0.07, 0.11, 0.16, 0.22]
const RANK_PULSE_SPEEDS := [0.0, 0.6, 0.5, 0.45, 0.4, 0.35]

func _ready() -> void:
	EventBus.clientAnnounceResults.connect(showResults)
	EventBus.clientFinish.connect(_onClientFinish)
	EventBus.cocktailOrdered.connect(_cocktailShow)
	Dialogic.timeline_started.connect(dialogueStarted);

func _cocktailShow(cocktailData: CocktailRecipeData):
	currentCocktailLabel.show();
	currentCocktailLabel.text = "Ordered cocktail: " + cocktailData.cocktailName;

func dialogueStarted():
	currentCocktailLabel.hide();

func _onClientFinish() -> void:
	resultScreenDetails.visible = false
	_resultsShown = false
	_currentFilledBars = 0
	if _barTween and _barTween.is_valid():
		_barTween.kill()
	if _pulseTween and _pulseTween.is_valid():
		_pulseTween.kill()
	if _labelPulseTween and _labelPulseTween.is_valid():
		_labelPulseTween.kill()
	progressBars.scale = Vector2.ONE
	finalLettersScore.scale = Vector2.ONE
	finalLettersScore.modulate = Color.WHITE
	finalLettersScore.text = "C"

func _input(event: InputEvent) -> void:
	if _resultsShown and event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		Global.gameCycle.finishClient()

func _getRankColor(idx: int) -> Color:
	var colors := [Color.WHITE, Color("#367c50"), Color("#549a8d"), Color("#D1505B"), Color("#F6A8B3"), Color("#FBC697")]
	return colors[idx]

func _updateRankLabel(filledCount: int) -> void:
	if _labelPulseTween and _labelPulseTween.is_valid():
		_labelPulseTween.kill()

	var idx: int = clamp(filledCount, 0, RANK_TEXTS.size() - 1)
	var baseScale: float = RANK_SCALES[idx]
	var amplitude: float = RANK_PULSE_AMPS[idx]
	var speed: float = RANK_PULSE_SPEEDS[idx]

	finalLettersScore.text = RANK_TEXTS[idx]
	finalLettersScore.modulate = _getRankColor(idx)
	finalLettersScore.pivot_offset = finalLettersScore.size / 2.0

	_labelPulseTween = finalLettersScore.create_tween()
	_labelPulseTween.tween_property(finalLettersScore, "scale",
		Vector2(baseScale * 1.35, baseScale * 1.35), 0.1) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_labelPulseTween.tween_property(finalLettersScore, "scale",
		Vector2(baseScale, baseScale), 0.35) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	if amplitude > 0.0:
		_labelPulseTween.tween_callback(func() -> void:
			_labelPulseTween = finalLettersScore.create_tween().set_loops()
			_labelPulseTween.tween_property(finalLettersScore, "scale",
				Vector2(baseScale + amplitude, baseScale + amplitude), speed) \
				.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
			_labelPulseTween.tween_property(finalLettersScore, "scale",
				Vector2(baseScale - amplitude, baseScale - amplitude), speed) \
				.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		)

func _pulseProgressBars() -> void:
	progressBars.pivot_offset = progressBars.size / 2.0
	if _pulseTween and _pulseTween.is_valid():
		_pulseTween.kill()
	_pulseTween = progressBars.create_tween()
	_pulseTween.tween_property(progressBars, "scale", Vector2(1.2, 1.2), 0.1) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_pulseTween.tween_property(progressBars, "scale", Vector2.ONE, 0.35) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _onBarFilled(barIndex: int) -> void:
	_currentFilledBars = barIndex + 1
	_pulseProgressBars()
	_updateRankLabel(_currentFilledBars)

func _getActiveBars() -> Array[Node]:
	var result: Array[Node] = []
	for b in progressBars.get_children():
		if b.name != "placeholder":
			result.append(b)
	return result

func _animateProgressBars(runningTotal: float, maxScore: float) -> void:
	if _barTween and _barTween.is_valid():
		_barTween.kill()

	var bars: Array[Node] = _getActiveBars()
	var count: int = bars.size()
	var fraction: float = clamp(runningTotal / maxScore, 0.0, 1.0)

	_barTween = create_tween()
	for i in count:
		var bar := bars[i] as ProgressBar
		var targetValue: float = clamp((fraction - float(i) / count) * float(count), 0.0, 1.0) * 100.0
		var delta: float = abs(targetValue - bar.value)
		if delta > 0.01:
			var duration: float = delta / 100.0 * 0.4
			_barTween.tween_property(bar, "value", targetValue, duration) \
				.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		if targetValue >= 99.99 and i >= _currentFilledBars:
			_barTween.tween_callback(_onBarFilled.bind(i))

func showResults(results: Array[ScoreUpdate]) -> void:
	for child in scoreUpdates.get_children():
		child.queue_free()

	fullAmount.text = ""
	resultScreenDetails.visible = true
	_resultsShown = false
	_currentFilledBars = 0

	progressBars.scale = Vector2.ONE
	for bar in progressBars.get_children():
		bar.value = 0.0

	if _labelPulseTween and _labelPulseTween.is_valid():
		_labelPulseTween.kill()
	finalLettersScore.text = "C"
	finalLettersScore.modulate = Color.WHITE
	finalLettersScore.scale = Vector2.ONE

	var maxScore: float = Global.gameCycle.cocktailMixingController.getMaxPossibleScore()
	var cumulativeTotals: Array[float] = []
	var running := 0.0
	var elements: Array[Control] = []

	for scoreUpdate in results:
		var element: Control = scoreUpdateElementScene.instantiate()
		scoreUpdates.add_child(element)
		element.setData(scoreUpdate)
		running += scoreUpdate.amount * scoreUpdate.multiply
		cumulativeTotals.append(running)
		elements.append(element)

	await get_tree().process_frame

	for i in elements.size():
		var element := elements[i]
		if not is_instance_valid(element):
			return
		element.playAppear()
		_animateProgressBars(cumulativeTotals[i], maxScore)
		if i >= 4:
			var tween := create_tween()
			tween.tween_property(scoreScrollContainer, "scroll_vertical",
				scoreScrollContainer.get_v_scroll_bar().max_value, 0.35) \
				.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		await get_tree().create_timer(0.5).timeout

	fullAmount.text = str(running)
	_resultsShown = true
