class_name EdgeRepresentation
extends ADTRepresentation

onready var line: Line2D = $Line2D
var edge


# Called when the node enters the scene tree for the first time.
func _ready():
	line.points = PoolVector2Array([
		edge.joint_end1.position,
		edge.joint_end1.position,
	])
	print(line.points)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
