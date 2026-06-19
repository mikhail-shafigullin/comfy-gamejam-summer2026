class_name GrabableComponent
extends Node

signal dropped(node: Node2D)
signal hovered()
signal unhovered()

@export var boundsSprite: Sprite2D = null
@export var grabableRotate: bool = false
@export var rotateMaxAngle: float = 2
@export var rotateTiltFactor: float = 0.02
@export var rotateRestoreSpeed: float = 12
@export var isGrabDisabled: bool = false
@export var hoverScale: float = 1.08
@export var hoverScaleDuration: float = 0.15

var _isDragging: bool = false
var _isHovered: bool = false
var _originalScale: Vector2 = Vector2.ONE
var _scaleTween: Tween = null
var _dragOffset: Vector2 = Vector2.ZERO
var _clickLocalOffset: Vector2 = Vector2.ZERO
var _originalRotation: float = 0.0
var _positionBeforeGrab: Vector2 = Vector2.ZERO
var _lastMousePos: Vector2 = Vector2.ZERO
var _velocityX: float = 0.0


func _ready() -> void:
	var parent := get_parent() as Node2D
	if parent != null:
		_originalRotation = parent.rotation
		_originalScale = parent.scale

func _process(delta: float) -> void:
	if not grabableRotate:
		return

	var parent := get_parent() as Node2D
	if parent == null:
		return

	_velocityX = lerpf(_velocityX, 0.0, rotateRestoreSpeed * delta)

	var targetRotation := _originalRotation
	if _isDragging:
		targetRotation += clamp(_velocityX * rotateTiltFactor, -rotateMaxAngle, rotateMaxAngle)

	parent.rotation = lerp_angle(parent.rotation, targetRotation, rotateRestoreSpeed * delta)

	if _isDragging:
		parent.global_position = _getClampedMousePos(parent) - _clickLocalOffset.rotated(parent.rotation)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_tryStartDrag()
		else:
			if _isDragging:
				_isDragging = false
				var parent := get_parent() as Node2D
				if parent != null:
					dropped.emit(parent)
			else:
				_isDragging = false
		return

	if event is InputEventMouseMotion:
		var parent := get_parent() as Node2D
		if parent != null:
			if _isDragging:
				_updateDragPosition(parent)
			_updateHoverState(parent)

func _tryStartDrag() -> void:
	if isGrabDisabled:
		return

	var parent := get_parent() as Node2D
	if parent == null:
		return

	var body := _findStaticBody(parent)
	if body == null:
		return

	var mousePos := parent.get_global_mouse_position()
	var spaceState := parent.get_world_2d().direct_space_state
	var query := PhysicsPointQueryParameters2D.new()
	query.position = mousePos
	query.collide_with_bodies = true

	for result in spaceState.intersect_point(query):
		if result["collider"] == body:
			_isDragging = true
			_positionBeforeGrab = parent.global_position
			_dragOffset = parent.global_position - mousePos
			_clickLocalOffset = parent.to_local(mousePos)
			_lastMousePos = mousePos
			get_viewport().set_input_as_handled()
			return

func _getClampedMousePos(parent: Node2D) -> Vector2:
	var mousePos := parent.get_global_mouse_position()
	var rect := get_viewport().get_visible_rect()
	mousePos.x = clamp(mousePos.x, rect.position.x, rect.end.x)
	mousePos.y = clamp(mousePos.y, rect.position.y, rect.end.y)
	return mousePos

func _updateDragPosition(parent: Node2D) -> void:
	var mousePos := _getClampedMousePos(parent)

	if grabableRotate:
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

func startDragAt(mousePos: Vector2) -> void:
	var parent := get_parent() as Node2D
	if parent == null:
		return
	_isDragging = true
	_positionBeforeGrab = parent.global_position
	_dragOffset = parent.global_position - mousePos
	_clickLocalOffset = parent.to_local(mousePos)
	_lastMousePos = mousePos

func _updateHoverState(parent: Node2D) -> void:
	if isGrabDisabled:
		if _isHovered:
			_isHovered = false
			onUnhover()
		return

	var body := _findStaticBody(parent)
	if body == null:
		return

	var mousePos := parent.get_global_mouse_position()
	var spaceState := parent.get_world_2d().direct_space_state
	var query := PhysicsPointQueryParameters2D.new()
	query.position = mousePos
	query.collide_with_bodies = true

	var nowHovered := false
	for result in spaceState.intersect_point(query):
		if result["collider"] == body:
			nowHovered = true
			break

	if nowHovered and not _isHovered:
		_isHovered = true
		onHover()
	elif not nowHovered and _isHovered:
		_isHovered = false
		onUnhover()

func onHover() -> void:
	hovered.emit()
	_tweenScale(_originalScale * hoverScale)

func onUnhover() -> void:
	unhovered.emit()
	_tweenScale(_originalScale)

func _tweenScale(targetScale: Vector2) -> void:
	var parent := get_parent() as Node2D
	if parent == null:
		return
	if _scaleTween != null:
		_scaleTween.kill()
	_scaleTween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_scaleTween.tween_property(parent, "scale", targetScale, hoverScaleDuration)

func disableGrab(disable: bool) -> void:
	isGrabDisabled = disable

func resetToPreGrabPosition() -> void:
	var parent := get_parent() as Node2D
	if parent != null:
		parent.global_position = _positionBeforeGrab
