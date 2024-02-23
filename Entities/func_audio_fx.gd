@tool
class_name FuncAudioFX extends ValveIONode

func _apply_entity(e, c):
	super._apply_entity(e, c);

	$Area3D.audio_bus_override = true;
	$Area3D.audio_bus_name = e.busname;

	$Area3D/CollisionShape3D.shape = get_entity_shape();

