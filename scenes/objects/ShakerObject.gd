extends Node2D

signal minigame_requested(ingredient: Node2D)

const AddIngredientMinigame = preload("res://scenes/minigames/AddIngredientMinigame.tscn")

var isEnabled: bool
@onready var _area: Area2D = %Area2D

func _ready() -> void:
	setEnabled(false);
	EventBus.cocktailOrdered.connect(cocktailOrdered);
	EventBus.cocktailMixingFinished.connect(func(): setEnabled(false))

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
		if result["collider"] == _area:
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

func addIngredientFinish(ingredient: Node2D, result: String) -> void:
	print("Ingredient added to shaker: ", ingredient.name, " (", result, ")")
