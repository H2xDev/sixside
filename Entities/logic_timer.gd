@tool
class_name LogicTimer extends ValveIONode

func _entity_ready():
	$Timer.timeout.connect(func():
		trigger_output("OnTimer"));

func Enable(_param = null):
	$Timer.start();

func _apply_entity(e, c):
	super._apply_entity(e, c);

	$Timer.set_wait_time(e.LowerRandomBound);

