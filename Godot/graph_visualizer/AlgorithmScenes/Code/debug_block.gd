class_name DebugBlock
extends ScrollContainer

# Contains the variables displayed in the left panel of the screen
# The labels have a format: var_name: var_data

const label_template : PackedScene = preload("res://AlgorithmScenes/Code/variable_in_heap_template.tscn")

const focused_style: StyleBox = preload("res://AlgorithmScenes/Screen/DebugBlock/focus_line_stylebox.stylebox")
const focused_material: Material = preload("res://AlgorithmScenes/Screen/DebugBlock/debug_block_line_focus.material")
const unfocused_style: StyleBox = preload("res://AlgorithmScenes/Screen/DebugBlock/unfocus_line_stylebox.stylebox")

# This lines container will have the Labels with format var_name: var_data
onready var lines_container: VBoxContainer = $LinesContainer


var mouse_inside_area: bool = false
var names_to_label = {}  # Type<String, Label>
var map_int_to_name = {} # Type<int, String>
var curr_label: Label
# We use names_to_label[map_int_to_name[0]] to get the label object from an integer

func _ready():
	StoredData.adt_mediator.debug_block = self

func _reset_data():
	for line in lines_container.get_children():
		if line.name != "DebuggerTitle":
			line.queue_free()
	names_to_label.clear()
	map_int_to_name.clear()
	curr_label = null


func update_models(data: Array) -> void:
	_reset_data()
	for adt_vector in data:
		var var_name: String = adt_vector.get_name()
		var var_data: ADT = adt_vector.get_data()
		self._add_variable(var_name, var_data)

# Add a variable to the heap
func _add_variable(var_name: String, var_data: ADT):
	var new_label : Label = self.label_template.instance() as Label
	_set_data_to_label(new_label, var_name, var_data)
	lines_container.add_child(new_label)
	if not var_data.is_new:
		call_deferred("_play_anim", new_label, "emphasize_modification") #_play_anim(new_label, "emphasize_modification")
		var_data.is_new = true

func _set_data_to_label(label: Label, var_name: String, var_data):
	label.text = str(var_name + " : " + str(var_data.as_string()))
	self.names_to_label[var_name] = label
	# New variables receive the count of labels as key to keep an order
	self.map_int_to_name[self.names_to_label.size() - 1] = var_name
	label.clip_text = true


func update_views(selected_index: int) -> void:
	_unfocus_current_label()
	curr_label = names_to_label[map_int_to_name[selected_index]]
	_focus_current_label()

func get_current_label() -> Label:
	if curr_label:
		return curr_label
	return null

func _unfocus_current_label():
	if curr_label:
		curr_label.add_stylebox_override("normal", unfocused_style)
		curr_label.material = null


# This is done to focus the variable shown in the ADTShower
func _focus_current_label():
	if curr_label:
		curr_label.add_stylebox_override("normal", focused_style)
		curr_label.material = focused_material

func highlight_variable(var_name: String) -> void:
	var corresponding_label: Label = names_to_label[var_name]
	_play_anim(corresponding_label, "emphasize_modification")


func _play_anim(input_label: Label, anim_name: String) -> void:
	if input_label:
		var anim: AnimationPlayer = input_label.get_node("./AnimationPlayer")
		anim.stop(true)
		anim.play(anim_name)

# To emphasize that a recent action has happened on selected variable
func emphasize_current_selected_variable():
	_play_anim(curr_label, "emphasize_modification")

func emphasize_error_on_current_selected_variable():
	_play_anim(curr_label, "emphasize_error")

func get_labels() -> Array:
	var return_array = []
	for variable_label in lines_container.get_children():
		if variable_label.name != "DebuggerTitle":
			return_array.append(variable_label)
	return return_array
