@tool
extends TriggerBase

@onready var area = $Area3D;

var isActivated = false;

func _entity_ready():
	area.body_entered.connect(func(_node):
		if not _node.is_in_group("Player"):
			return;

		if isActivated:
			return;

		isActivated = true;
		trigger_output("OnTrigger"));

func _apply_entity(e, c):
	super._apply_entity(e, c);
	apply_shape_to(e, $Area3D/SolidCast);

