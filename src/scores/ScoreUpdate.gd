class_name ScoreUpdate
extends Resource

var label: String;
var amount: float;
var multiply: float;

func _init(_label: String, _amount: float, _multiply: float):
	label = _label
	amount = _amount;
	multiply = _multiply;
