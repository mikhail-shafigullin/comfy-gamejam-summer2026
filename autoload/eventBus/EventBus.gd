extends Node

signal gameStarted;

# clients events
signal clientInit(client: ClientData);
signal clientStart();
signal clientAnnounceResults(results: Array[ScoreUpdate]);
signal clientFinish();

# cocktails events
signal cocktailOrdered(cocktailData: CocktailRecipeData);
signal cocktailMixingFinished();
signal cocktailShakeCancelled();
signal cocktailFinished();

# buztalks
signal buztalkStart(dialogue: BuztalkDialogue)
signal buztalkFinish();
