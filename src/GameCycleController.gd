extends Node

var currentClient: ClientData = null;
var cocktailMixingController: CocktailMixingController = null;

func _ready() -> void:
	cocktailMixingController = CocktailMixingController.new();

func initClient():
	var newClient = ClientData.new();
	newClient.clientName = "Innokentii Petrov"
	newClient.initialCocktailRecipe = Resources.getRandomCocktailRecipe();
	currentClient = newClient;
	EventBus.clientInit.emit(newClient);

func startClientInteraction():
	EventBus.clientStart.emit();

func startCocktailMixing():
	EventBus.cocktailOrdered.emit(currentClient.initialCocktailRecipe);
	cocktailMixingController.startMixing(currentClient.initialCocktailRecipe);

func addIngredient(ingredient: IngredientData, miniGameResult: CocktailMixingController.IngredientMiniGameStatus):
	cocktailMixingController.addIngredient(ingredient, miniGameResult);

func deleteCocktail():
	cocktailMixingController.clearCurrentCocktail();

func finishCocktailMixing():
	cocktailMixingController.finishMixing();
	EventBus.cocktailMixingFinished.emit();

func showResults():
	var allResult: Array[ScoreUpdate] = [];
	allResult.append_array(cocktailMixingController.getMixingResult());
	EventBus.clientAnnounceResults.emit(allResult);

func finishClient():
	EventBus.clientFinish.emit();
	
