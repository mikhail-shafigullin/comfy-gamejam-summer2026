extends Control

@onready var client1: Sprite2D = %Client1;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventBus.clientInit.connect(setClient);
	EventBus.clientFinish.connect(removeClient);
	pass # Replace with function body.

func setClient(clientData: ClientData):
	client1.modulate.a = 0.0
	client1.visible = true
	var tween := create_tween()
	tween.tween_property(client1, "modulate:a", 1.0, 0.5)
	tween.finished.connect(startClientDialogue);

func removeClient():
	var tween := create_tween()
	tween.tween_property(client1, "modulate:a", 0.0, 0.5)
	tween.tween_callback(func(): client1.visible = false)

func startClientDialogue():
	Dialogic.start("Greetings");
	pass;
