class_name BuztalkDialogue
extends Node

var controller: BuztalkController;
var dialoguePath: String;
var type: BuzTalkType;

enum BuzTalkType{ COMMON, OPTION_CHOOSE, ADDITIONAL_INGREDIENT }
enum BuzTalkResult{ SUCCESS, NO_OPTION, FAILURE }

func finishDialogue(result: BuzTalkResult) -> ScoreUpdate:
	var scoreUpdate: ScoreUpdate = null;
	if(result == BuzTalkResult.SUCCESS):
		scoreUpdate = Resources.scoreUpdateDialogueCorrect;
	elif(result == BuzTalkResult.FAILURE):
		scoreUpdate = Resources.scoreUpdateDialogueIncorrect;
	
	return scoreUpdate;
