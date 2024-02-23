@tool
extends ValveIONode

@export var startDisabled = false;

func _entity_ready():
	if startDisabled:
		Disable();
		return;

	trigger_output("OnSpawn");

func Trigger(_param = null):
	if flags & 1 == 1:
		Kill();
	
	print("Triggering");

	trigger_output("OnTrigger");

func _apply_entity(e, c):
	super._apply_entity(e, c);
	flags = int(e.spawnflags) if "spawnflags" in e else 0;
	startDisabled = e.StartDisabled == 1 if "StartDisabled" in e else false;
