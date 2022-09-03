extends EffectCheck
# graph_edges = sort_edges();


var edges_in_ascending_weight = []
var edges_in_ascending_weight_original = []

# Action expected from player:
# Press edges in ascending order according to weight
func check_actions_correct() -> bool:
	var _edge = StoredData.selected_edge
	# If we selected the least weighting edge, remove it from the edges left:
	if edges_in_ascending_weight.size() > 0 and _edge == edges_in_ascending_weight[0]:
		edges_in_ascending_weight.remove(0)  # CORRECT!
		_edge.set_selected()
		print("Correct!")
	if edges_in_ascending_weight.size() == 0:
		return true
	return false


func effect_check_on_focused():
	# We will use selection sort since it is easier to use in this context
	var edges: Array = StoredData.edges.duplicate(true)  # Create a deep copy
	var min_weight = 9999
	var temp_min_weight_edge
	while edges_in_ascending_weight.size() < StoredData.edges.size():
		min_weight = 9999

		for _edge in edges:
			if _edge.weight < min_weight and not _edge in edges_in_ascending_weight:
				min_weight = _edge.weight
				temp_min_weight_edge = _edge
		# By the end of this for loop, we will have the edge with
		# minimum weight that is NOT in our edges_in_ascending_weight
		edges_in_ascending_weight.append(temp_min_weight_edge)


func reset():
	edges_in_ascending_weight = []
