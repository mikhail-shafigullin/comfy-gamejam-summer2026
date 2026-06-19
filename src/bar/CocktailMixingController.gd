class_name CocktailMixingController
extends Node;

var orderedCocktail: CocktailRecipeData;
var additionalRequestedIngredients: Array[IngredientData] = [];

var currentIngredients: Array[IngredientData] = [];
var currentMiniGames: Array[IngredientMiniGameStatus] = [];
var resultScoreUpdates: Array[ScoreUpdate] = [];
enum IngredientMiniGameStatus {PERFECT, GOOD, OK};

func startMixing(_orderedCocktail: CocktailRecipeData):
	orderedCocktail = _orderedCocktail;

func addIngredient(ingredient: IngredientData, miniGameStatus: IngredientMiniGameStatus):
	currentIngredients.push_back(ingredient);
	currentMiniGames.push_back(miniGameStatus);

func finishCocktail():
	var allRequestedIngredients: Array[IngredientData] = [];
	allRequestedIngredients.append_array(orderedCocktail.ingredients);
	allRequestedIngredients.append_array(additionalRequestedIngredients);
	var requestedIceCubes = allRequestedIngredients.filter(func(elem:IngredientData): return elem == Resources.ingredientIce)
	var requestedNormalIngredients = allRequestedIngredients.filter(func(elem:IngredientData): return elem != Resources.ingredientIce)
	
	var currentMixedIngredients: Array[IngredientData] = [];
	currentMixedIngredients.append_array(currentIngredients);
	var currentIceCubes = currentMixedIngredients.filter(func(elem:IngredientData): return elem == Resources.ingredientIce)
	var currentMixedNormalIngredients = currentMixedIngredients.filter(func(elem:IngredientData): return elem != Resources.ingredientIce)
	
	if(areAllNormalIngredientsCorrect(requestedNormalIngredients, currentMixedNormalIngredients)):
		resultScoreUpdates.push_back(Resources.scoreUpdateCorrectCocktail);
	else:
		resultScoreUpdates.push_back(Resources.scoreUpdateIncorrectCocktail);
	
	if(currentIceCubes.size() == requestedIceCubes.size()):
		resultScoreUpdates.push_back(Resources.scoreUpdateIceCubesCorrect)
	elif(currentIceCubes.size() > requestedIceCubes.size()):
		resultScoreUpdates.push_back(Resources.scoreUpdateIceCubesTooMuch)
	elif(currentIceCubes.size() < requestedIceCubes.size()):
		resultScoreUpdates.push_back(Resources.scoreUpdateIceCubesNotEnough)
	
	var recipeIngredients: Array[IngredientData] = []
	recipeIngredients.append_array(orderedCocktail.ingredients)

	for i in range(currentIngredients.size()):
		var ingredient := currentIngredients[i]
		if not recipeIngredients.has(ingredient):
			continue
		recipeIngredients.erase(ingredient)
		var miniGameResult := currentMiniGames[i]
		if(miniGameResult == IngredientMiniGameStatus.PERFECT):
			resultScoreUpdates.push_back(Resources.scoreUpdateMiniGamePerfect)
		elif(miniGameResult == IngredientMiniGameStatus.GOOD):
			resultScoreUpdates.push_back(Resources.scoreUpdateMiniGameGood)

func getMixingResult() -> Array[ScoreUpdate]:
	return resultScoreUpdates;

func getMaxPossibleScore() -> float:
	var allRequestedIngredients: Array[IngredientData] = []
	allRequestedIngredients.append_array(orderedCocktail.ingredients)
	allRequestedIngredients.append_array(additionalRequestedIngredients)

	var normalIngredientsCount := allRequestedIngredients.filter(
		func(elem: IngredientData): return elem != Resources.ingredientIce
	).size()

	var total := 0.0
	total += Resources.scoreUpdateCorrectCocktail.amount * Resources.scoreUpdateCorrectCocktail.multiply
	total += Resources.scoreUpdateIceCubesCorrect.amount * Resources.scoreUpdateIceCubesCorrect.multiply
	total += normalIngredientsCount * Resources.scoreUpdateMiniGamePerfect.amount * Resources.scoreUpdateMiniGamePerfect.multiply
	return total;

func areAllNormalIngredientsCorrect(requestedIngredients: Array, currentMix: Array) -> bool:
	if(requestedIngredients.size() != currentMix.size()):
		return false;
	for requestedIngredient in requestedIngredients:
		if(currentMix.has(requestedIngredient)):
			currentMix.erase(requestedIngredient);
		else:
			return false;
	return true;

func clearCurrentCocktail():
	currentIngredients.clear();
	currentMiniGames.clear();
	resultScoreUpdates.clear();

func clear():
	orderedCocktail = null;
	additionalRequestedIngredients.clear();
	clearCurrentCocktail();

static func getStatusName(status: IngredientMiniGameStatus) -> String:
	if(status == IngredientMiniGameStatus.PERFECT):
		return "Perfect";
	elif(status == IngredientMiniGameStatus.GOOD):
		return "Good";
	else:
		return "OK";
	
func getCookedCocktail() -> CocktailRecipeData:
	var currentNonIce: Array = currentIngredients.filter(
		func(elem: IngredientData): return elem != Resources.ingredientIce
	)
	for recipe in Resources.cocktailRecipes:
		var recipeNonIce: Array = recipe.ingredients.filter(
			func(elem: IngredientData): return elem != Resources.ingredientIce
		)
		if areAllNormalIngredientsCorrect(recipeNonIce, currentNonIce.duplicate()):
			return recipe
	return null;