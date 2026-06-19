extends Control

@onready var successFlagLabel: Label = %SuccessFlag
@onready var descriptionLabel: Label = %Description

var _targetColor: Color

func setData(scoreUpdate: ScoreUpdate) -> void:
	if scoreUpdate.multiply > 0:
		successFlagLabel.text = "+"
		_targetColor = Color("#6ED6A4")
	else:
		successFlagLabel.text = "-"
		_targetColor = Color("#F7738E")
	descriptionLabel.text = scoreUpdate.label
	modulate = Color(_targetColor.r, _targetColor.g, _targetColor.b, 0.0)

func playAppear() -> void:
	pivot_offset = size / 2.0
	scale = Vector2(1.3, 1.3)
	rotation_degrees = randf_range(-6.0, 6.0)

	var tween := create_tween().set_parallel(true)
	tween.tween_property(self, "modulate", _targetColor, 0.1)
	tween.tween_property(self, "scale", Vector2.ONE, 0.6).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "rotation_degrees", 0.0, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
