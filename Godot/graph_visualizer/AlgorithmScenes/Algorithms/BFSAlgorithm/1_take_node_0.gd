extends EffectCheck


func check_actions_correct() -> bool:
	var selected_nodes = StoredData.get_selected_nodes()
	if selected_nodes.size() == 1 && selected_nodes[0].index == 0:
		StoredData.add_variable("t", selected_nodes[0].get_adt())
		return true
	return false

# Once we are in this line, node 0 may be added
func effect_check_on_focused():
	StoredData.selectable_nodes_indexes.append(0)
	var node_t = StoredData.get_node_by_index(0) # AGraphNode
	if node_t:
		node_t.highlight_variable("t")
		node_t.show_animation_of_clicking_mouse()
		node_t.highlight_node()
		node_t.show_ship_flying_around()
