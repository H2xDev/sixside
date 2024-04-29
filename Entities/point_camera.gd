@tool
extends ValveIONode

var camera;

func SetOn(_param):
	$Camera3D.make_current();
	$Camera3D/AudioListener3D.make_current();
	
func _entity_ready():
	camera = $Camera3D;

func _apply_entity(e, c):
	super._apply_entity(e, c);
	$Camera3D.fov = e.FOV;
