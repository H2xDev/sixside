@tool
class_name TriggerSave extends TriggerBase;

@onready var area = $Area3D;

func _entity_ready():
	area.body_entered.connect(
		func(_node):
			if not _node.is_in_group("Player"):
				return;

			GameManager.instance.SaveGame();
			call_deferred("queue_free"));

func _apply_entity(e, c):
	super._apply_entity(e, c);

	apply_shape_to(e, $Area3D/SolidCast);
