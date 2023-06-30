extends EffectCheck

# Press Enter
var has_enter_been_pressed : bool = false

func _ready():
	pass # Replace with function body.

func _input(event):
	if event.is_action_pressed("code_advance") and NotificationManager.allow_code_advance:
		has_enter_been_pressed = true


func check_actions_correct() -> bool:
	return has_enter_been_pressed
