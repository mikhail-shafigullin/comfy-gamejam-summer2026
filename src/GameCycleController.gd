class_name GameCycleController
extends Node

var currentClient: ClientData = null;
var cocktailMixingController: CocktailMixingController = null;
var initClientTimer: Timer

func _ready() -> void:
	Global.gameCycle = self;
	cocktailMixingController = CocktailMixingController.new();
	initClientTimer = Timer.new()
	initClientTimer.one_shot = true;
	initClientTimer.wait_time = 1.0;
	initClientTimer.timeout.connect(initClient);
	add_child(initClientTimer)
	initClientTimer.start();

func initClient():
	var newClient = ClientData.new();
	newClient.clientName = "Innokentii Petrov"
	newClient.initialCocktailRecipe = Resources.recipePinaKolada;
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

func startDialogue():
	var dialogue = currentClient.getNextBuzTalk();

func finishCocktailMixing():
	cocktailMixingController.finishMixing();
	EventBus.cocktailMixingFinished.emit();

func showResults():
	var allResult: Array[ScoreUpdate] = [];
	allResult.append_array(cocktailMixingController.getMixingResult());
	EventBus.clientAnnounceResults.emit(allResult);

func finishClient():
	EventBus.clientFinish.emit();
	
