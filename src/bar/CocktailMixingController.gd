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

func finishMixing():
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
	
	for miniGameResult in currentMiniGames:
		if(miniGameResult == IngredientMiniGameStatus.PERFECT):
			resultScoreUpdates.push_back(Resources.scoreUpdateMiniGamePerfect)
		elif(miniGameResult == IngredientMiniGameStatus.GOOD):
			resultScoreUpdates.push_back(Resources.scoreUpdateMiniGameGood)
	
#	need to fix here check of additional ingredients

func getMixingResult() -> Array[ScoreUpdate]:
	return resultScoreUpdates;

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
