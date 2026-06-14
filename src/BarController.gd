extends Node

var currentClient: ClientData = null;

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
