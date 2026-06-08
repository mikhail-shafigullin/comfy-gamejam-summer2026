class_name GrabableComponent
extends Node

@export var boundsSprite: Sprite2D = null
@export var grabableRotate: bool = false
@export var rotateMaxAngle: float = 2
@export var rotateTiltFactor: float = 0.02
@export var rotateRestoreSpeed: float = 12

var _isDragging: bool = false
var _dragOffset: Vector2 = Vector2.ZERO
var _clickLocalOffset: Vector2 = Vector2.ZERO
var _originalRotation: float = 0.0
var _lastMousePos: Vector2 = Vector2.ZERO
var _velocityX: float = 0.0

func _ready() -> void:
	var parent := get_parent() as Node2D
	if parent != null:
		_originalRotation = parent.rotation

	var body := _findStaticBody(get_parent())
	if body != null:
		body.input_event.connect(_onBodyInputEvent)

func _process(delta: float) -> void:
	if not grabableRotate:
		return

	var parent := get_parent() as Node2D
	if parent == null:
		return

	# Decay velocity — when mouse stops, tilt returns to zero
	_velocityX = lerpf(_velocityX, 0.0, rotateRestoreSpeed * delta)

	var targetRotation := _originalRotation
	if _isDragging:
		targetRotation += clamp(_velocityX * rotateTiltFactor, -rotateMaxAngle, rotateMaxAngle)

	parent.rotation = lerp_angle(parent.rotation, targetRotation, rotateRestoreSpeed * delta)

	# Keep the exact grab point under the cursor as the object rotates
	if _isDragging:
		parent.global_position = parent.get_global_mouse_position() - _clickLocalOffset.rotated(parent.rotation)

func _onBodyInputEvent(_viewport: Viewport, event: InputEvent, _shapeIdx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var parent := get_parent() as Node2D
		if parent == null:
			return
		var mousePos := parent.get_global_mouse_position()
		_isDragging = true
		_dragOffset = parent.global_position - mousePos
		_clickLocalOffset = parent.to_local(mousePos)
		_lastMousePos = mousePos
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

	if grabableRotate:
		# Raw delta becomes the velocity; _process decays it each frame
		_velocityX = mousePos.x - _lastMousePos.x
		_lastMousePos = mousePos
	else:
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
