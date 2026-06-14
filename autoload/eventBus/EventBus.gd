extends Node

signal gameStarted;

# clients events
signal clientInit(client: ClientData);
signal clientStart();
signal clientAnnounceResults(results: ScoreUpdate);
signal clientFinish();

# cocktails events
signal cocktailOrdered(cocktailData: CocktailRecipeData);
signal cocktailMixingFinished();

# buztalks
signal buztalkStart(dialogue: BuztalkDialogue)
signal buztalkFinish();
