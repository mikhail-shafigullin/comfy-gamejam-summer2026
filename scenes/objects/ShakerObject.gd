class_name ShakerObject
extends Node2D

signal minigame_requested(ingredient: Node2D)
signal shake_minigame_completed()

const SHAKE_GAIN = 15.0
const SHAKE_DECAY = 6.0
const SHAKE_DIRECTION_THRESHOLD = 0.5

var isEnabled: bool
@onready var _area: Area2D = %Area2D
@onready var capSprite: Sprite2D = %CapSprite
@onready var grabableComponent: GrabableComponent = $GrabableComponent
@onready var shakeMiniGameControl: Control = %ShakeMiniGameControl
@onready var shakeProgressBar: ProgressBar = %ShakeProgressBar
@onready var shakeFinishTimer: Timer = %ShakeFinishTimer

@export var shakerRestartPositionMarker: Marker2D;

var _shakeMiniGameActive: bool = false
var _lastY: float = 0.0
var _lastYVelocity: float = 0.0

func _ready() -> void:
	clear();
	EventBus.clientStart.connect(clear);
	EventBus.cocktailOrdered.connect(cocktailOrdered);
	EventBus.cocktailFinished.connect(showCocktailResult);

func onIngredientDropped(ingredient: Node2D) -> void:
	if(!isEnabled): 
		return;
	# StaticBody2D moved via code doesn't reliably trigger body_entered,
	# so we query the physics space directly at the moment of drop.
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = ingredient.global_position
	query.collide_with_areas = true
	query.collide_with_bodies = false

	for result in space_state.intersect_point(query):
		if result["collider"] == _area && ingredient is IngredientObject :
			addIngredientIntent(ingredient)
			return

func cocktailOrdered(cocktail: CocktailRecipeData):
	print("Ordered cocktail ", cocktail.cocktailName, " : ", cocktail.ingredients)
	setEnabled(true)

func setEnabled(enabled: bool):
	visible = enabled;
	isEnabled = enabled

func addIngredientIntent(ingredient: Node2D) -> void:
	minigame_requested.emit(ingredient)

func addIngredientFinish(ingredient: IngredientObject, result: CocktailMixingController.IngredientMiniGameStatus) -> void:
	Global.gameCycle.addIngredient(ingredient.data, result);
	print("Ingredient added to shaker: ", ingredient.name, " (", result, ")")

func closeTheCap() -> void:
	capSprite.visible = true;
	grabableComponent.disableGrab(false);
	startShakeMiniGame();

func _process(delta: float) -> void:
	if not _shakeMiniGameActive:
		return

	var currentY := global_position.y
	var yVelocity := currentY - _lastY
	print(yVelocity)

	if absf(yVelocity) > SHAKE_DIRECTION_THRESHOLD and absf(_lastYVelocity) > SHAKE_DIRECTION_THRESHOLD:
		if sign(yVelocity) != sign(_lastYVelocity):
			shakeProgressBar.value += SHAKE_GAIN

	_lastYVelocity = yVelocity
	_lastY = currentY

	shakeProgressBar.value = clampf(shakeProgressBar.value, 0.0, shakeProgressBar.max_value)

	if shakeProgressBar.value >= shakeProgressBar.max_value:
		_completeShakeMiniGame()

func startShakeMiniGame() -> void:
	_shakeMiniGameActive = true
	_lastY = global_position.y
	_lastYVelocity = 0.0
	shakeProgressBar.value = 0.0
	shakeMiniGameControl.visible = true

func _completeShakeMiniGame() -> void:
	_shakeMiniGameActive = false
	shakeMiniGameControl.visible = false
	shakeFinishTimer.start();
	shake_minigame_completed.emit()

func showCocktailResult():
	setEnabled(false);
	Global.gameCycle.showResults();
	

func _on_shake_finish_timer_timeout() -> void:
	Dialogic.start("CocktailFinished")
	pass # Replace with function body.

func clear():
	setEnabled(false);
	capSprite.visible = false;
	position = shakerRestartPositionMarker.position;
	grabableComponent.disableGrab(true);
	pass;
