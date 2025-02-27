class_name EffectCheck
extends Resource

# Class that checks for the effect of a given code line
# For each line whose effect must be checked between each
# step done by the player.
# This class must be implemented

var code_line: CodeLine


# Triggered on initialization. It is not an equivalent of _ready
# _ready does not work as expected since this is a Resource, not a node.
func _init():
	code_line = null

# Execute side effect when the code line that contains 
# this effect check is focused
func effect_check_on_focused() -> void:
	return

# Code being executed constantly to check whether the actions
# of the player are correct
func check_actions_correct() -> bool:
	return true


# Code that will be called the first time the actions are correct, but only once 
func _trigger_on_correct_once() -> void:
	deactivate_hint_timer()

# Execute side effect when the code line that contains
# this effect check was executed and the next line is focused
func _trigger_on_next_line_side_effect() -> void:
	pass

func deactivate_hint_timer() -> void:
	# By default, deactivate the hint timer of the instruction
	if not is_instance_valid(code_line):
		printerr("Invalid code line!")
		return

	code_line.deactivate_hint_timer()

# By default, do nothing. This method may be overriden
# Reset to default variables of a given effect check to allow loops
func reset() -> void:
	return


# @param: CodeLine _code_line: the line to be set
# Set the code line of the current effect check
func set_code_line(_code_line: CodeLine) -> void:
	self.code_line = _code_line

# Function called to know the next line index that will be
# Focused after this execution, this is always called
# If the user wants to execute a jump, this method must be
# overriden and its body should call get_jump_line
func get_next_line() -> int:
	_trigger_on_next_line_side_effect()
	if code_line:
		# By default, return just the next line
		return code_line.line_index + 1 
	return -1

# Function called when an instruction should jump, like fors
# gotos, whiles or if-elses
func get_jump_line() -> int:
	if code_line:
		return code_line.jump_index
	return -1

# This should be called in variables which have some highlighting
# This highlighting may be overriden
func _hightlight_code_line() -> void:
	if code_line:
		code_line.hightlight_code_line()

# When the user is stuck a while, this shows the users what to do
# This method should be overriden by the particular effect check that inherits
# from this method.
func _show_hint_to_user() -> void:
	# UserTracker.log("show_hint_to_user")
	return
