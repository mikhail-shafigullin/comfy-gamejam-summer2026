extends Control

const AddIngredientMinigame = preload("res://scenes/minigames/AddIngredientMinigame.tscn")

@onready var _subviewport: SubViewport = $SubViewportContainer/SubViewport
@onready var _shaker: Node2D = $SubViewportContainer/SubViewport/Shaker
@onready var addIngredientMiniGame: AddIngredientMiniGame = %AddIngredientMinigame;

func _ready() -> void:
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
	addIngredientMiniGame.finished.connect(func(result: String): _shaker.addIngredientFinish(ingredient, result), CONNECT_ONE_SHOT)
