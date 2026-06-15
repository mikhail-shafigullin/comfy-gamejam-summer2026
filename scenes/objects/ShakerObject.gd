extends Node2D

signal minigame_requested(ingredient: Node2D)

const AddIngredientMinigame = preload("res://scenes/minigames/AddIngredientMinigame.tscn")

@onready var _area: Area2D = %Area2D

func onIngredientDropped(ingredient: Node2D) -> void:
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

func addIngredientIntent(ingredient: Node2D) -> void:
	minigame_requested.emit(ingredient)

func addIngredientFinish(ingredient: Node2D) -> void:
	print("Ingredient added to shaker: ", ingredient.name)
