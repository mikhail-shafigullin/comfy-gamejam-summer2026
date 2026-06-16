extends Control

const AddIngredientMinigame = preload("res://scenes/minigames/AddIngredientMinigame.tscn")

@onready var _subviewport: SubViewport = $SubViewportContainer/SubViewport
@onready var _shaker: ShakerObject = $SubViewportContainer/SubViewport/Shaker
@onready var _shakerCap: ShakerCap = $SubViewportContainer/SubViewport/ShakerCap
@onready var addIngredientMiniGame: AddIngredientMiniGame = %AddIngredientMinigame;
@onready var curtain: ColorRect = %Curtain


func _ready() -> void:
	_shakerCap.shakerObject = _shaker

	var ingredients: Array[Node2D] = [
		$SubViewportContainer/SubViewport/MilkBottle,
		$SubViewportContainer/SubViewport/PineappleBottle,
		$SubViewportContainer/SubViewport/Rum,
	]
	for ingredient in ingredients:
		var grab := ingredient.get_node("GrabableComponent") as GrabableComponent
		grab.dropped.connect(_shaker.onIngredientDropped)

	_shaker.minigame_requested.connect(_on_minigame_requested)

func _on_minigame_requested(ingredient: Node2D) -> void:
	addIngredientMiniGame.start();
	addIngredientMiniGame.finished.connect(func(result: CocktailMixingController.IngredientMiniGameStatus): _shaker.addIngredientFinish(ingredient, result), CONNECT_ONE_SHOT)
