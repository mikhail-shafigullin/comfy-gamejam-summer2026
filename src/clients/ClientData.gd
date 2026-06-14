class_name ClientData
extends Resource

var clientName: String;
var initialCocktailRecipe: CocktailRecipeData;
var buzTalkDialogues: Array[BuztalkDialogue];

func getNextBuzTalk():
	return buzTalkDialogues.pop_front();
