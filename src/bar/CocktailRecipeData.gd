class_name CocktailRecipeData
extends Resource

var cocktailName: String;
var ingredients: Array[IngredientData];

func _init(_name: String, _ingredients: Array[IngredientData]) -> void:
	cocktailName = _name;
	ingredients = _ingredients;
