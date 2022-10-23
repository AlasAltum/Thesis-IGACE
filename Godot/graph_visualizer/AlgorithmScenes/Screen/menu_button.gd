extends Button

var gameplay_menu_popup: GameplayMenuPopup

# This Button is intended to work only with a GameplayMenuPopup in the same scene

func _ready():
	gameplay_menu_popup = get_tree().get_root().get_node("./Main/CanvasLayer/GameplayMenuPopup")

func _on_Button_pressed():
	if gameplay_menu_popup:
			gameplay_menu_popup.show()
