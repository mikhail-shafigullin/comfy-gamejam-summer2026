class_name ShakerCap
extends Node2D

@export var shakerObject: ShakerObject
@onready var _grabableComponent: GrabableComponent = %GrabableComponent

var isEnabled: bool

func _ready() -> void:
	setEnabled(false);
	EventBus.cocktailOrdered.connect(cocktailOrdered)
	EventBus.cocktailFinished.connect(func(): setEnabled(false))
	_grabableComponent.dropped.connect(_onDropped)

func _onDropped(cap: Node2D) -> void:
	if shakerObject == null or not shakerObject.isEnabled:
		return
	var spaceState := get_world_2d().direct_space_state
	var query := PhysicsPointQueryParameters2D.new()
	query.position = cap.global_position
	query.collide_with_areas = true
	query.collide_with_bodies = false
	for result in spaceState.intersect_point(query):
		if result["collider"] == shakerObject.get_node("Area2D"):
			visible = false
			_grabableComponent.disableGrab(true)
			shakerObject.closeTheCap()
			return

func cocktailOrdered(_cocktail: CocktailRecipeData) -> void:
	setEnabled(true)

func setEnabled(enabled: bool) -> void:
	visible = enabled
	isEnabled = enabled
