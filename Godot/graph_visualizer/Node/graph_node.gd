class_name AGraphNode
extends KinematicBody2D


var selected : bool = false
export var index : int = 0
var edges : Array setget set_edges, get_edges
var pressed: bool = false
var aux_position: Vector2
var clickable = false
var node_color: Color setget set_color, get_color

onready var node_name: Label = $Sprite/Node2D/NodeName
onready var node_action_menu: Popup = $Popup
onready var select_unselect_button: Button = $Popup/PanelContainer/VBoxContainer/SelectUnselectButton
onready var add_to_object_button: Button = $Popup/PanelContainer/VBoxContainer/AddToObjectButton
onready var variable_label: Node2D = $Variable
onready var variable_label_internal: Label = $Variable/Sprite/VariableHighlight
onready var sprite_texture : Sprite = $Sprite/SpriteTexture
onready var station_texture: Sprite = $Sprite/StationSimple
onready var mouse_button_left_animation: Sprite = $MouseButtonLeft

var variable_highlighted: bool = false
var floating_variable_radius: float = 0.0
var accumulated_angle: float = 0.0
onready var animation_player : AnimationPlayer = $AnimationPlayer

const representation_prefab = preload("res://Node/NodeRepresentation.tscn")
var adt_type = load("res://AlgorithmScenes/Code/ADTs/node_adt.gd")

var representation #: NodeRepresentation
var adt  #: NodeADT

var can_grab: bool = false
var grabbed_offset: Vector2 = Vector2()
var radius_distance: float = 0.0

const NORMAL_COLOR = Color(1.0, 1.0, 1.0, 1.0)
const ITERATED_COLOR = Color(0.7, 0.4, 0.2)
const SELECTED_COLOR = Color(1.0, 1.0, 0.0, 0.8)
const SELECTED_LABEL_COLOR = Color(0.0, 1.0, 0.0, 1.0)


signal node_add_to_object_request(node)
signal node_selected(node)


var is_dragging = false


# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("Nodes")
	self.representation = self.get_representation()
	self.adt = adt_type.new(self)
	self.radius_distance = $Sprite/SpriteTexture.get_rect().size.x / 2
	randomize()
	call_deferred("set_texture_randomly")


func set_texture_randomly():
	if StoredData.world_node:
		sprite_texture.texture = StoredData.world_node.planets_textures[randi() % len(StoredData.world_node.planets_textures)]
		StoredData.world_node.planets_textures.erase(sprite_texture.texture)
		var desired_size = Vector2(80,80)
		var size = sprite_texture.texture.get_size()
		var scale_factor = desired_size/size
		sprite_texture.scale = scale_factor


func get_adt():
	return self.adt

func get_representation():
	self.representation = representation_prefab.instance()
	self.representation.set_index(self.index)
	if self.selected:
		self.representation.set_selected()

	return self.representation


const FACTOR_TO_KEEP_NODES_IN_CONTAINER = 0.9
# Initializes the position of a node inside the node container considering its dimensions
# So nodes are better spacially distributed in the container
# node_container_positions contains: [center_position, container_size]
func init_position_regarding_container(total_nodes: int, node_container_key_properties: Array):
	var angle = 2 * PI / (total_nodes + 1) * (self.index + 1)
	var radius_x = node_container_key_properties[1].x  # X size
	var radius_y = node_container_key_properties[1].y  # Y size
	aux_position = node_container_key_properties[0]  # Start at center position
	# We add this 0.9 so nodes are not out of the container
	aux_position += Vector2(
		cos(angle) * radius_x * FACTOR_TO_KEEP_NODES_IN_CONTAINER,
		sin(angle) * radius_y * FACTOR_TO_KEEP_NODES_IN_CONTAINER
	)
	self.position = to_local(aux_position)
	aux_position = to_global(aux_position)


func set_index(_index: int):
	self.index = _index
	representation.set_index(_index)
	node_name.text = str(_index)

# Edges type is:
# pairs<node_index <int>, weight <float>>
func set_edges(_edges: Array) -> void:
	edges = _edges

# Returns an array of pairs with type:
# pairs<node_index <int>, weight <float>>:
func get_edges() -> Array:
	return edges

# Get all node neighbors of this node
func get_neighbors() -> Array:
	var neighbors = []
	# Edge is a pair<node_index <int>, weight <float>>
	for _edge in edges:
		var neighbor_index: int = _edge[0]
		var neighbor = StoredData.nodes[neighbor_index]
		neighbors.append(neighbor)

	return neighbors

func get_non_selected_neighbors() -> Array:
	var neighbors = []
	# Edge is a pair<node_index <int>, weight <float>>
	for _edge in edges:
		var neighbor_index: int = _edge[0]
		var neighbor = StoredData.nodes[neighbor_index]
		if not neighbor.selected:
			neighbors.append(neighbor)

	return neighbors



func mark_as_iterated():
	self.select_node()
	station_texture.texture = StoredData.world_node.station_iterated_texture
	if not self in StoredData.iterated_nodes: 
		StoredData.iterated_nodes.append(self)

func is_iterated_or_explored():
	return self in StoredData.iterated_nodes or self.selected

## Right click menu related methods ##
func as_string() -> String:
	return "(" + str(self.index) + ")"

# When using the hover menu and pressing Q, or when clicking the node
# To  toggle select/unselect a node
func _on_Select_UnselectButton_pressed():
	# Unselect
	if self.selected:
		pass
		# self.unselect_node() # A node may not be unselected
	else:
		self.select_node()
	self.hide_node_action_menu()

func unselect_node():
	self.selected = false
	representation.set_unselected()
	node_action_menu.hide()
	node_action_menu.visible = false

func select_node(emit_signal=true):
	if self.index in StoredData.selectable_nodes:
		self.selected = true
		AudioPlayer.play_element_selected()
		self.animation_player.play("NodeBeingSelected")
		representation.set_selected()
		# TODO: play animation of the station appearing
		if emit_signal:
			emit_signal("node_selected", self)
		return

	else:
		# TODO: Add animation: Error, not selectable node!
		print("Not selectable Node")


func _on_AddToObjectButton_pressed():
	get_added_to_focused_object_in_variables()
	node_action_menu.visible = false

func get_added_to_focused_object_in_variables():
	emit_signal("node_add_to_object_request", self)


func _input(event):
	# Menu must be open to allow these options
	if is_dragging:
		if StoredData.world_node.dragging_node and event is InputEventMouseMotion:
			# User is dragging the sprite
			StoredData.world_node.set_dragging_node_global_pos()
		# Relase event
		elif event is InputEventMouseButton and event.button_index == BUTTON_LEFT and !event.pressed:
			# if node is dropped on the ADTShower, add it to the variables		
			if StoredData.adt_shower and StoredData.adt_shower.get_rect().has_point(get_global_mouse_position()):
				get_added_to_focused_object_in_variables()
				StoredData.world_node.dragging_node.call_deferred("queue_free")
				StoredData.world_node.start_release_dragging_node()

			# if node is dropped out of the ADTshower, delete it
			else:
				# User has released the mouse button
				StoredData.world_node.start_release_dragging_node()

			is_dragging = false

	else:
		# Case click on the node, no dragging. check with radial distance
		if event is InputEventKey and is_mouse_inside_node():
			# E action corresponds to add select the node
			if Input.is_action_just_pressed("NodeSelect"):
				_on_Select_UnselectButton_pressed()
			# R Action
			elif Input.is_action_just_pressed("NodeAddToObject"):
				get_added_to_focused_object_in_variables()

func is_mouse_inside_node() -> bool:
	return get_global_mouse_position().distance_to(self.global_position) < self.radius_distance

# Show hover menu
func _on_Area2D_mouse_entered() -> void:
	node_action_menu.set_position(get_global_mouse_position())
	node_action_menu.popup()

# Hide hover menu
func _on_Area2D_mouse_exited() -> void:
	self.hide_node_action_menu()

# Click on the node = Press select/unselect node
func _on_Area2D_input_event(_viewport, event, _shape_idx):
	if _event_is_left_click(event):
		if StoredData.allow_nodes_dragging:
			is_dragging = true
			StoredData.world_node.set_dragging_node($Sprite/SpriteTexture, self)

		else:
			_on_Select_UnselectButton_pressed()

func _event_is_left_click(event):
	return (event is InputEventMouseButton and
		event.button_index == BUTTON_LEFT and
		event.pressed)


# This method must be repeated, because a click can be considered as a mouse exited from the area2D.
func hide_node_action_menu():
	node_action_menu.hide()
	self.clickable = false

func set_color(in_color: Color) -> void:
	node_color = in_color
	$Sprite.material.set_shader_param("assigned_color", in_color)

func get_color() -> Color:
	return $Sprite.material.get_shader_param("assigned_color")

func get_class() -> String:
	return "AGraphNode"

func highlight_node():
	$Sprite.material.set_shader_param("highlight", 1.0)

func stop_highlight_node():
	$Sprite.material.set_shader_param("highlight", 0.0)

# Show the variable close to this node and let it float towards this node
# We use a Node2D as parent of the variable label because the label has a rect
# whose "center" starts at the top left corner of the label, and we want the centerS
func highlight_variable(variable_name):
	if variable_label:
		variable_highlighted = true
		variable_label.visible = true
		variable_label.material.set_shader_param("frequency", 0.0)
		variable_label_internal.text = variable_name
		var difference: Vector2 = variable_label.global_position - self.global_position
		floating_variable_radius = difference.length()


const GOOD_LOOKING_FREQUENCY_FOR_HIGHLIGHT_LABEL: float = 10.0

# Stops the variable from floating around the node and hides it
func unhighlight_variable():
	if variable_label:
		variable_highlighted = false
		variable_label.visible = false
		variable_label.material.set_shader_param("frequency", GOOD_LOOKING_FREQUENCY_FOR_HIGHLIGHT_LABEL)

func _deferred_goto_scene(path):
	var s = ResourceLoader.load(path)
	var current_scene = s.instance()
	StoredData.get_tree().root.add_child(current_scene)
	StoredData.get_tree().current_scene = current_scene
	
func show_animation_of_clicking_mouse():
	mouse_button_left_animation.visible = true
	animation_player.play("ClickNode")
