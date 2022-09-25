class_name AddNodePopup
extends WindowDialog
# Popup that appears when we want to add a node to a ADT
# By making right click on a node and selecting to add to an ADT

var incoming_node #: AGraphNode
onready var error_label: Label = $ErrorNotification
onready var error_anim: AnimationPlayer = $ErrorNotification/AnimationPlayer

func _ready():
	NotificationManager.add_node_popup = self

func _close_popup():
	self.visible = false

func _on_EnterButton_pressed():
	# TODO: REPLACE THIS. We do not need to enter any text
	_on_NameAssign_text_entered(StoredData.get_selected_variable_name())
	# _on_NameAssign_text_entered($NameAssign.text)
	_close_popup()

func _on_NameAssign_text_entered(object_name):
	if incoming_node:
		if StoredData.has_variable(object_name):
			StoredData.add_node_to_adt(object_name, incoming_node)

		else: # Case a node was tried to be added to a non-existing object
			show_error()
			return

func set_incoming_node(node):
	self.incoming_node = node

func show_error():
	error_label.visible = true
	error_anim.stop()
	error_anim.play("message_modulation")
