# class_name NotificationManager 
extends Node2D

## Code execution popups ##
var finished_popup : WindowDialog; 
var u_is_explored_popup : WindowDialog # = $UNodeIsExploredPopup
var adt_is_empty_popup : WindowDialog # = $QIsNotEmptyPopup
var add_node_popup : AddNodePopup 
var object_creation_popup: WindowDialog # PopupForObjectCreation
var length_c_is_1_popup: WindowDialog # = LengthCIsOnePopup

## Continue conditions ##
var u_is_explored: bool = false
var adt_is_empty: bool = false
var length_c_is_1: bool = false
var hint_label

func reset_data():
	finished_popup = null
	u_is_explored_popup = null
	adt_is_empty_popup = null
	add_node_popup = null
	u_is_explored = false
	adt_is_empty = false
	object_creation_popup = null  # = get_tree().get_root().get_node("Main/PopUpForObjectCreation")


func _on_variable_creation_popup():
	object_creation_popup.popup()


const NOT_YET_SELECTED_VARIABLE = -1
# node: AGraphNode
# Commented to avoid Ciclyc dependencies
func _on_node_add_to_object(node):
	# Selected variable index has not been selected yet
	if StoredData.selected_variable_index == NOT_YET_SELECTED_VARIABLE:
		# TODO: Show popup with error message
		print("There is no selected variable in the variables stack!")

	if StoredData.selected_variable_allows_object_adition():
		add_node_popup.set_incoming_node(node)
		add_node_popup.popup()
		StoredData.emphasize_current_selected_variable()

	else:
		# TODO: show popup with error message
		StoredData.emphasize_error_on_current_selected_variable()
		print("You cannot add this object to the current selected variable")

func _on_AllowGraphMovementButton_pressed():
	StoredData.set_status("DRAG")

func _on_SelectNodeButton_pressed():
	StoredData.set_status("SELECT")
	

func on_code_finished_popup(_msg: String) -> void:
	InputRecorder.send_requests_with_records()
	finished_popup.show()
## Node related functions ##

## Hint related methods ##
func set_hint_text(new_text: String) -> void:
	hint_label.bbcode_text = new_text
## Hint related methods ##

## BFS Finished Popup signals ##

func reset_game():
	StoredData.reset_data()
	self.reset_data()
	get_tree().reload_current_scene()

func _on_ResetButton_pressed() -> void:
	reset_game()

func _on_MenuButton_pressed() -> void:
	pass # TODO: Add Menu for different algorithms

## BFS Finished Popup signals ##

## U.is_explored() popup signals ##
# Show popup 
func ask_user_if_graph_node_is_explored(u, condition_value: bool):
	u_is_explored_popup.show()
	u_is_explored_popup.get_node("Explanation").text = (
		"Is the U node (" + str(u.index) + ") explored?"
	)
	 # This stablishes whether yes or no should be pressed
	self.u_is_explored = condition_value

func notify_u_is_explored_correct_answer():
	StoredData.u_is_explored_right_answer = true
	u_is_explored_popup.hide()
	# TODO: Add sound effect
	# TODO: Add visual effect

func notify_u_is_explored_wrong_answer():
	u_is_explored_popup.notify_u_is_explored_wrong_answer()

func _on_YesButton_pressed() -> void:
	if self.u_is_explored:  # Expected answer
		notify_u_is_explored_correct_answer()
	else: # Wrong answer
		notify_u_is_explored_wrong_answer()


func _on_NoButton_pressed() -> void:
	if self.u_is_explored:  # Wrong answer
		notify_u_is_explored_wrong_answer()
	else:  # Expected answer
		notify_u_is_explored_correct_answer()

## U.is_explored() popup signals ##

## adt.is_not_empty() popup signals ##
func ask_user_if_adt_is_empty(is_adt_empty: bool):
	adt_is_empty_popup.show()
	 # This stablishes whether yes or no should be pressed
	self.adt_is_empty = is_adt_empty

func _on_adt_is_empty_YesButton_pressed() -> void:
	if self.adt_is_empty:  # Wrong
		self.notify_adt_is_empty_wrong_answer()
	else:  # Right!
		self.notify_adt_is_empty_correct_answer()

func _on_adt_is_empty_NoButton_pressed() -> void:
	# if q is empty, expected answer is yes
	if self.adt_is_empty:
		self.notify_adt_is_empty_correct_answer()
	else:  # Wrong
		self.notify_adt_is_empty_wrong_answer()

func notify_adt_is_empty_correct_answer():
	StoredData.adt_is_empty_right_answer = true
	adt_is_empty_popup.hide()

func notify_adt_is_empty_wrong_answer():
	# TODO: Visual effect
	adt_is_empty_popup.play_wrong_animation()
#	$ADTIsNotEmptyPopup/ErrorNotification/AnimationPlayer.play("message_modulation")
	# TODO: Add sound effect

## adt.is_not_empty() popup signals ##

## Length C is 1 popup signals ##
func ask_user_if_lenth_c_is_1(_length_c_is_1: bool) -> void:
	if length_c_is_1_popup:
		length_c_is_1_popup.show()
		self.length_c_is_1 = _length_c_is_1


func _on_YesButton_length_c_is_1_popup_pressed():
	if self.length_c_is_1:  # Right!
		self.notify_length_c_is_one_correct_answer()
	else:  # Wrong!
		self.notify_length_c_is_one_wrong_answer()

func _on_NoButton_length_c_is_1_popup_pressed():
	if self.length_c_is_1:  # Wrong
		self.notify_length_c_is_one_wrong_answer()
	else:  # Right
		self.notify_length_c_is_one_correct_answer()

func notify_length_c_is_one_correct_answer():
	StoredData.length_c_is_one_correct_answer = true
	if length_c_is_1_popup:
		length_c_is_1_popup.hide()

func notify_length_c_is_one_wrong_answer():
	# TODO: Visual effect
	if length_c_is_1_popup:
		length_c_is_1_popup.play_wrong_animation()
