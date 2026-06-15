class_name IngredientData
extends Resource

var name: String;

func _init(_name: String):
	name = _name;

func _to_string() -> String:
	return str(name);
