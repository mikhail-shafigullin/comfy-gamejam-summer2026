class_name BuztalkController
extends Node

var currentBuztalk: BuztalkDialogue;

func startBuzTalkDialogue(dialogue: BuztalkDialogue):
	currentBuztalk = dialogue;
	currentBuztalk.controller = self;
	EventBus.buztalkStart.emit(dialogue);

func finishDialogue(result: BuztalkDialogue.BuzTalkResult) -> ScoreUpdate:
	EventBus.buztalkFinish.emit();
	return currentBuztalk.finishDialogue(result);
	
