@tool
extends TriggerBase

var waterSurfaceY = 0.0;

func _entity_ready():
	var area = $Area3D;
	area.position.y -= 0.5;
	area.body_entered.connect(OnBodyEntered);
	area.body_exited.connect(OnBodyExited);

func OnBodyEntered(body):
	if body.has_signal("waterEntered"):
		body.emit_signal("waterEntered", $MeshInstance3D);

func OnBodyExited(body):
	if body.has_signal("waterExited"):
		body.emit_signal("waterExited");

func _apply_entity(e, c):
	print('pisechka');
	super._apply_entity(e, c);
	apply_shape_to(e, $Area3D/CollisionShape3D);

	var mesh = get_mesh();
	$MeshInstance3D.set_mesh(mesh);
