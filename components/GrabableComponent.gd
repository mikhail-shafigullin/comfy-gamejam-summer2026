class_name GrabableComponent
extends Node

@export var boundsSprite: Sprite2D = null

var _isDragging: bool = false
var _dragOffset: Vector2 = Vector2.ZERO

func _ready() -> void:
	var body := _findStaticBody(get_parent())
	if body != null:
		body.input_event.connect(_onBodyInputEvent)

func _onBodyInputEvent(_viewport: Viewport, event: InputEvent, _shapeIdx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var parent := get_parent() as Node2D
		if parent == null:
			return
		_isDragging = true
		_dragOffset = parent.global_position - parent.get_global_mouse_position()
		get_viewport().set_input_as_handled()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		_isDragging = false
		return

	if event is InputEventMouseMotion and _isDragging:
		var parent := get_parent() as Node2D
		if parent != null:
			_updateDragPosition(parent)

func _updateDragPosition(parent: Node2D) -> void:
	var mousePos := parent.get_global_mouse_position()
	var newPos := mousePos + _dragOffset

	if boundsSprite != null:
		var sprite := _findSprite(parent)
		var halfSize := Vector2.ZERO
		if sprite != null and sprite.texture != null:
			halfSize = sprite.texture.get_size() * sprite.scale.abs() / 2.0

		var bRect := boundsSprite.get_rect()
		var bPos := boundsSprite.global_position
		newPos.x = clamp(newPos.x, bPos.x + bRect.position.x + halfSize.x, bPos.x + bRect.end.x - halfSize.x)
		newPos.y = clamp(newPos.y, bPos.y + bRect.position.y + halfSize.y, bPos.y + bRect.end.y - halfSize.y)

	parent.global_position = newPos
	get_viewport().set_input_as_handled()

func _findStaticBody(node: Node) -> StaticBody2D:
	for child in node.get_children():
		if child is StaticBody2D:
			return child as StaticBody2D
	return null

func _findSprite(node: Node) -> Sprite2D:
	for child in node.get_children():
		if child is Sprite2D:
			return child as Sprite2D
	return null
