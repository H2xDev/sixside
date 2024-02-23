@tool
extends TriggerBase;

@onready var area = $Area3D;

func OnBodyEnter(body):
	print(body.name);
	if not body.is_in_group("Player"):
		return;

	if body.has_signal("ladderEntered"):
		body.ladderEntered.emit();

func OnBodyExit(body):
	if not body.is_in_group("Player"):
		return;

	if body.has_signal("ladderExited"):
		body.ladderExited.emit();

func _entity_ready():
	area.body_entered.connect(OnBodyEnter);
	area.body_exited.connect(OnBodyExit);

func _apply_entity(e, c):
	super._apply_entity(e, c);
	apply_shape_to(e, $Area3D/CollisionShape3D);
