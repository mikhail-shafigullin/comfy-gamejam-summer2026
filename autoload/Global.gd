extends Node

var gameCycle: GameCycleController;

func startClientInteraction():
	gameCycle.startClientInteraction();
	gameCycle.startCocktailMixing();

func finishCocktail():
	gameCycle.finishCocktail();

func finishClient():
	gameCycle.finishClient();
