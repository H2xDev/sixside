@tool
extends TriggerBase
@onready var area = $Area3D;

func _entity_ready():
	area.body_entered.connect(func(_b):
		trigger_output('OnStartTouch');
		trigger_output('OnTrigger');
		trigger_output('OnStartTouch'));

	area.body_exited.connect(func(_b):
		trigger_output('OnEndTouch');
		trigger_output('OnEndTouchAll'));

func _apply_entity(e, c):
	super._apply_entity(e, c);
	$Area3D/SolidCast.shape = get_entity_shape();

