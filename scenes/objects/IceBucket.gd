class_name IceBucket
extends Node2D

@export var shakerObject: ShakerObject

const _iceCubeScene: PackedScene = preload("res://scenes/objects/IceCube.tscn")

@onready var _staticBody: StaticBody2D = $StaticBody2D

func _input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed):
		return
	var mousePos := get_global_mouse_position()
	var spaceState := get_world_2d().direct_space_state
	var query := PhysicsPointQueryParameters2D.new()
	query.position = mousePos
	query.collide_with_bodies = true
	for result in spaceState.intersect_point(query):
		if result["collider"] == _staticBody:
			_spawnIceCube(mousePos)
			get_viewport().set_input_as_handled()
			return

func _spawnIceCube(mousePos: Vector2) -> void:
	var iceCube: IngredientObject = _iceCubeScene.instantiate()
	get_parent().add_child(iceCube)
	iceCube.global_position = mousePos
	iceCube.grabableComponent.startDragAt(mousePos)
	iceCube.grabableComponent.dropped.connect(_onIceCubeDropped)

func _onIceCubeDropped(iceCube: Node2D) -> void:
	if shakerObject != null:
		shakerObject.onIngredientDropped(iceCube)
	if is_instance_valid(iceCube) and iceCube.visible:
		iceCube.queue_free()
