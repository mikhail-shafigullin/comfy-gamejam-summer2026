extends Control

@onready var client1: AnimatedSprite2D = %ClientAnimSprite;
@onready var clientRestartTimer: Timer = %ClientRestartTimer;
var currentClientData: ClientData;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventBus.clientInit.connect(setClient);
	EventBus.clientFinish.connect(removeClient);
	EventBus.clientAnnounceResults.connect(showDialogueResult);
	EventBus.clientFinish.connect(startTimerUpdateClient);

	Dialogic.signal_event.connect(dialogicEvent);

	pass # Replace with function body.

func setClient(clientData: ClientData):
	currentClientData = clientData;
	client1.animation = getAnim('idle');
	client1.modulate.a = 0.0
	client1.visible = true
	var tween := create_tween()
	tween.tween_property(client1, "modulate:a", 1.0, 0.5)
	tween.finished.connect(startClientDialogue);

func removeClient():
	var tween := create_tween()
	tween.tween_property(client1, "modulate:a", 0.0, 0.5)
	tween.tween_callback(func(): client1.visible = false)

func startTimerUpdateClient():
	clientRestartTimer.timeout.connect(Global.gameCycle.initClient, CONNECT_ONE_SHOT)
	clientRestartTimer.start();

func startClientDialogue():
	Dialogic.start("Greetings");
	pass;
	
func showDialogueResult(scoreUpdates: Array[ScoreUpdate]):
	var result: String = "";
	var resultScore = 0;
	for scoreUpdate in scoreUpdates:
		result = result + scoreUpdate.label + ": " + str(scoreUpdate.amount * scoreUpdate.multiply) + "; ";
		resultScore += scoreUpdate.amount * scoreUpdate.multiply;

	Dialogic.VAR.coctailFullResult = result;
	Dialogic.VAR.cocktailResultScore = str(resultScore);
	Dialogic.start("CocktailResults");

func getAnim(prefix: String) -> String:
	var animSuffix = str(currentClientData.clientNumber + 1);
	return prefix + animSuffix

func dialogicEvent(eventName: String):
	if (eventName == "startTalk"):
		client1.animation = getAnim('talk');
		client1.play();
	elif (eventName == "stopTalk"):
		client1.animation = getAnim('idle');
		client1.play();
	pass;