class_name ADTMediator
extends Node2D

# Class made to store all data regarding the model so it is in only one place
# This makes sure the StoredData Singleton, DebugBlock and ADTShower
# have only one single source of truth

var adt_shower: ADTShower
var debug_block: DebugBlock
var data : Array = []  # Array of ADTVector <ADT, int, String>
var selected_index: int = 0 setget set_selected_index, get_selected_index


func _ready():
	StoredData.set_adt_mediator(self)

# Update models and views for both ADTShower and DebugBlock
func update() -> void:
	update_models()
	update_views()

func update_models():
	adt_shower.update_models(data)
	debug_block.update_models(data)

func update_views():
	adt_shower.update_views(selected_index)
	debug_block.update_views(selected_index)


func has_variable(var_name: String) -> bool:
	var_name = var_name.to_lower()
	for adt_vector in data:
		if adt_vector.name == var_name:
			return true
	return false

func get_variable(var_name: String) -> ADT:
	var_name = var_name.to_lower()
	for adt_vector in data:
		if adt_vector.name == var_name:
			return adt_vector.get_data()
	return null


func add_or_update_variable(var_name: String, _data) -> void:
	var_name = var_name.to_lower()
	if has_variable(var_name):
		var previous_data = get_variable(var_name)
		previous_data._on_debug_block_free()
		_update_variable(var_name, _data)
	else:
		var new_row: ADTVector = ADTVector.new(_data, self.data.size(), var_name)
		self.data.append(new_row)

	update()


func highlight_variable(var_name: String, loop=false) -> void:
	var_name = var_name.to_lower()
	if has_variable(var_name):
		debug_block.highlight_variable(var_name, loop)
	else:
		printerr("Var name {} doesn't exist!", var_name)

func stop_highlight_variable(var_name: String):
	debug_block.stop_highlight_variable(var_name)

func _update_variable(var_name: String, _data: ADT, update_on_finish = false) -> void:
	var_name = var_name.to_lower()
	for adt_vector in data:
		if adt_vector.name == var_name:
			adt_vector.set_data(_data)  # Modify variable stored in data
	# Update may not be necessary since it is made at the end of other functions
	if update_on_finish:
		update()


func erase_variable_by_name(var_name: String) -> void:
	var_name = var_name.to_lower()
	for adt_vector in data:
		if adt_vector.name == var_name:
			# Reset index if selected index is going to be erased
			if data.find(adt_vector, 0) == selected_index:
				self.selected_index = 0
			# Unhiglight or perform other action if necessary
			adt_vector.get_data()._on_debug_block_free()
			data.erase(adt_vector)
			break

	update()


func add_node_to_adt(object_name: String, incoming_node):
	object_name = object_name.to_lower()
	if has_variable(object_name):
		# Object may be a QueueADT, StackADT...
		var object = get_variable(object_name)
		object.add_data(incoming_node)
		update()

func take_top_from_adt(object_name: String):
	object_name = object_name.to_lower()
	if has_variable(object_name):
		# Object may be a QueueADT, StackADT...
		var object = get_variable(object_name)
		var top_node = object.top()
		update()
		return top_node


### Signals ###

# if the variable was correctly created from the ADT Grid
func _on_correct_variable_creation(variable_name: String):
	variable_name = variable_name.to_lower()
	var generated_object = StoredData.adt_to_be_created
	add_or_update_variable(variable_name, generated_object)
	StoredData.adt_to_be_created = null

# Make sure the changes are also reflected in StoredData
func set_selected_index(_selected_index: int):
	selected_index = _selected_index
	StoredData.selected_variable_index = selected_index

func get_selected_index() -> int:
	return selected_index

# Change focus of variable in debug block and change representation
func _on_variable_index_up():
	if data.size() > 0:
		# We erased circular behavior because some users did not like it
		# Force circular behaviour
		# else: set_selected_index(data.size() - 1)
		if selected_index > 0:
			set_selected_index(selected_index - 1)
		update_views()

# Change focus of variable in debug block and change representation
func _on_variable_index_down():
	if data.size() > 0:
		if selected_index < data.size() - 1:
			set_selected_index(selected_index + 1)

		# We erased circular behavior because some users did not like it
		# else: set_selected_index(0)
		update_views()


const EMPHASIZE_TIME: float = 1.0;

##  These functions are triggered when the user tries to add a node ##
# to the current selected variable. If it allows object adition
# trigger emphasize_current_selected_variable
func emphasize_current_selected_variable() -> void:
	if debug_block:
		# TODO: Replace modified label by a stack for short period requests
		# when there are many movements in short periods of time
		debug_block.emphasize_current_selected_variable()


# if object does not allow object adition, trigger this function
func emphasize_error_on_current_selected_variable() -> void:
	if debug_block:
		debug_block.emphasize_error_on_current_selected_variable()
## ##

func get_selected_variable_name() -> String:
	if not data.empty() and data.size() > selected_index - 1:
		var adt_vector: ADTVector = data[selected_index]
		return adt_vector.get_name()
#	if self.get_selected_index() == -1:
	return "ERROR: no variable selected"


func selected_variable_allows_object_adition() -> bool:
	if not data.empty() and data.size() > selected_index - 1:
		var selected_adt_vector: ADTVector = data[selected_index]
		if selected_adt_vector.get_data() and selected_adt_vector.get_data().has_method("allows_object_adition"):
			return selected_adt_vector.get_data().call("allows_object_adition")
	# TODO: Add a popup message telling the user has made a mistake
	return false

func connect_variable_clicked_signal(variable_in_heap):
	variable_in_heap.connect("variable_clicked", self, "_on_variable_clicked")

func _on_variable_clicked(variable_in_heap_pressed):
	# we know that variable in heap is a child of debug_block
	# allow selecting indexes not only by pressing up or down, but also by clicking
	var variables_labels = debug_block.get_labels()
	var index_of_variable = variables_labels.find(variable_in_heap_pressed)
	if index_of_variable != -1:
		set_selected_index(index_of_variable)
		update_views()
