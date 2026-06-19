class_name ShakerObject
extends Node2D

signal minigame_requested(ingredient: Node2D)
signal shake_minigame_completed()

const SHAKE_GAIN = 15.0
const SHAKE_DECAY = 6.0
const SHAKE_DIRECTION_THRESHOLD = 0.7

var isEnabled: bool
@onready var _area: Area2D = %Area2D
@onready var capSprite: Sprite2D = %CapSprite
@onready var grabableComponent: GrabableComponent = $GrabableComponent
@onready var shakeMiniGameControl: Control = %ShakeMiniGameControl
@onready var shakeProgressBar: ProgressBar = %ShakeProgressBar
@onready var shakeFinishTimer: Timer = %ShakeFinishTimer
@onready var animationPlayer: AnimationPlayer = %AnimationPlayer;

@onready var ingredientPineappleJuice: Sprite2D = %PineappleJuice;
@onready var ingredientCocoJuice: Sprite2D = %CocoJuice;
@onready var ingredientRum: Sprite2D = %Rum;
@onready var ingredientSprite: Sprite2D = %Sprite;

@onready var cocktailDaikiri: Sprite2D = %Daikiri;
@onready var cocktailMohito: Sprite2D = %Mohito;
@onready var cocktailPinocolada: Sprite2D = %Pinocolada;
@onready var cocktailAnanasLimonad: Sprite2D = %AnanasLimonad;
@onready var cocktailBauntiBriz: Sprite2D = %BauntiBriz;

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
			var ingredientObj: IngredientObject = ingredient;
			addIngredientIntent(ingredientObj)
			return

func cocktailOrdered(cocktail: CocktailRecipeData):
	print("Ordered cocktail ", cocktail.cocktailName, " : ", cocktail.ingredients)
	clearCocktails();
	match cocktail:
		Resources.recipeDajkiri:
			cocktailDaikiri.visible = true;
		Resources.recipeMojito:
			cocktailMohito.visible = true;
		Resources.recipePinaKolada:
			cocktailPinocolada.visible = true;
		Resources.recipePineappleLimonade:
			cocktailAnanasLimonad.visible = true;
		Resources.recipeBountyBreeze:
			cocktailBauntiBriz.visible = true;
	setEnabled(true)

func setEnabled(enabled: bool):
	visible = enabled;
	isEnabled = enabled

func addIngredientIntent(ingredient: IngredientObject) -> void:
	clearIngredients()
	ingredient.hide();
	match ingredient.data.name:
		Resources.ingredientPineappleJuice.name:
			ingredientPineappleJuice.visible = true;
			animationPlayer.play("pourLiquidIngredient");
		Resources.ingredientMilk.name:
			ingredientCocoJuice.visible = true;
			animationPlayer.play("pourLiquidIngredient");
		Resources.ingredientRum.name:
			ingredientRum.visible = true;
			animationPlayer.play("pourLiquidIngredient");
		Resources.ingredientSprite.name:
			ingredientSprite.visible = true;
			animationPlayer.play("pourLiquidIngredient");
		Resources.ingredientMint.name:
			animationPlayer.play("mintAnimation");
		Resources.ingredientLime.name:
			animationPlayer.play("limeAnimation");
	
	animationPlayer.animation_finished.connect(func(_anim): animationPlayer.play("pourLiquidIngredient2"), CONNECT_ONE_SHOT); 
	minigame_requested.emit(ingredient)

func addIngredientFinish(ingredient: IngredientObject, result: CocktailMixingController.IngredientMiniGameStatus) -> void:
	animationPlayer.play("RESET")
	Global.gameCycle.addIngredient(ingredient.data, result);
	ingredient.grabableComponent.resetToPreGrabPosition();
	ingredient.show();
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

func _on_shake_finish_timer_timeout() -> void:
	animationPlayer.play("pourCocktail");
	animationPlayer.animation_finished.connect(func(_animeName): Dialogic.start("CocktailFinished"), CONNECT_ONE_SHOT);

func showCocktailResult():
	setEnabled(false);
	Global.gameCycle.showResults();

func clearIngredients():
	ingredientPineappleJuice.visible = false;
	ingredientCocoJuice.visible = false;
	ingredientRum.visible = false;
	ingredientSprite.visible = false;

func clearCocktails():
	cocktailDaikiri.visible = false;
	cocktailMohito.visible = false;
	cocktailPinocolada.visible = false;
	cocktailAnanasLimonad.visible = false;
	cocktailBauntiBriz.visible = false;

func clear():
	clearIngredients()
	clearCocktails()
	animationPlayer.play("RESET")
	setEnabled(false);
	capSprite.visible = false;
	position = shakerRestartPositionMarker.position;
	grabableComponent.disableGrab(true);
	pass;
