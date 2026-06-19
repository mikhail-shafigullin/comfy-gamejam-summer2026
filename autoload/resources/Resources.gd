extends Node

var random: RandomNumberGenerator;

var ingredients: Array[IngredientData];
var ingredientRum: IngredientData;
var ingredientPineappleJuice: IngredientData;
var ingredientMilk: IngredientData;
var ingredientLime: IngredientData;
var ingredientMint: IngredientData;
var ingredientSprite: IngredientData;
var ingredientIce: IngredientData;

var cocktailRecipes: Array[CocktailRecipeData];
var recipePinaKolada: CocktailRecipeData;
var recipeMojito: CocktailRecipeData;
var recipeDajkiri: CocktailRecipeData;
var recipeBountyBreeze: CocktailRecipeData;
var recipePineappleLimonade: CocktailRecipeData;

var scoreUpdateCorrectCocktail: ScoreUpdate;
var scoreUpdateIncorrectCocktail: ScoreUpdate;
var scoreUpdateMiniGamePerfect: ScoreUpdate;
var scoreUpdateMiniGameGood: ScoreUpdate;
var scoreUpdateIceCubesCorrect: ScoreUpdate;
var scoreUpdateIceCubesNotEnough: ScoreUpdate;
var scoreUpdateIceCubesTooMuch: ScoreUpdate;
var scoreUpdateAdditionalRequestSatisfied: ScoreUpdate;
var scoreUpdateDialogueCorrect: ScoreUpdate;
var scoreUpdateDialogueIncorrect: ScoreUpdate;

func _ready() -> void:
	random = RandomNumberGenerator.new();
	_initIngredients();
	_initCocktailRecipes();
	_initScoreUpdates();

func _initIngredients():
	ingredientRum = IngredientData.new("Rum");
	ingredientPineappleJuice = IngredientData.new("Pinapple Juice");
	ingredientMilk = IngredientData.new("Coconut Milk");
	ingredientLime = IngredientData.new("Lime");
	ingredientMint = IngredientData.new("Mint");
	ingredientSprite = IngredientData.new("Sprite");
	ingredientIce = IngredientData.new("Ice Cube");

	ingredients = [ingredientRum, ingredientPineappleJuice, ingredientMilk, 
		ingredientLime, ingredientMint, ingredientSprite, ingredientIce];

func _initCocktailRecipes():
	recipePinaKolada = CocktailRecipeData.new("Pina Colada", 
		[ingredientRum, ingredientPineappleJuice, ingredientMilk])
	recipeMojito = CocktailRecipeData.new("Mojito",
		[ingredientRum, ingredientLime, ingredientMint, ingredientSprite]);
	recipeDajkiri = CocktailRecipeData.new("Dajkiri", 
		[ingredientRum, ingredientMilk, ingredientLime]);
	recipeBountyBreeze = CocktailRecipeData.new("Bounty Breeze", 
		[ingredientPineappleJuice, ingredientMilk, ingredientMint]);
	recipePineappleLimonade = CocktailRecipeData.new("Pineapple Limonade", 
		[ingredientPineappleJuice, ingredientLime, ingredientMint]);

	cocktailRecipes = [recipePinaKolada, recipeMojito, recipeDajkiri,
		recipeBountyBreeze, recipePineappleLimonade];
	pass;

func _initScoreUpdates():
	scoreUpdateCorrectCocktail = ScoreUpdate.new(
		"Correct Cocktail",
		70,
		1.0
	)
	scoreUpdateIncorrectCocktail = ScoreUpdate.new(
		"Incorrect Cocktail",
		50,
		-1.0
	)
	scoreUpdateMiniGamePerfect = ScoreUpdate.new(
		"Perfect Amount of Ingredient",
		40,
		1.0
	)
	scoreUpdateMiniGameGood = ScoreUpdate.new(
		"Good Amount of Ingredient",
		40,
		0.5
	)
	scoreUpdateIceCubesCorrect = ScoreUpdate.new(
		"Cocktail in perfect temperature",
		60,
		1.0
	)
	scoreUpdateIceCubesNotEnough = ScoreUpdate.new(
		"Not Enough Ice In The Cocktail",
		30,
		-1.0
	)
	scoreUpdateIceCubesTooMuch = ScoreUpdate.new(
		"Too Much Ice In The Cocktail",
		30,
		-1.0
	)
	scoreUpdateAdditionalRequestSatisfied = ScoreUpdate.new(
		"Requested Ingredient has been Added",
		60,
		1.0
	)
	scoreUpdateDialogueCorrect = ScoreUpdate.new(
		"Supported the Сonversation",
		60,
		1.0
	)
	scoreUpdateDialogueCorrect = ScoreUpdate.new(
		"Supported the Сonversation",
		60,
		1.0
	)
	scoreUpdateDialogueIncorrect = ScoreUpdate.new(
		"Bad Сonversation",
		40,
		-1.0
	)

func getRandomCocktailRecipe() -> CocktailRecipeData:
	return cocktailRecipes.pick_random();
