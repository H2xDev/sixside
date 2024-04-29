@tool
extends PointLight

signal interact();

func _add_connection(output, target, input, param, delay, _times):
	var callback = func():
		call_target_input(target, input, param, delay);

	match output:
		"OnPressed":
			interact.connect(callback);

func _apply_entity(e, _c):
	super._apply_entity(e, _c);
	var aspect = (25.0 * get_value("rangeMultiplier", 1)) / 45.0;
	light.spot_angle = e._cone;
	light.spot_range = e._cone * aspect;
	light.light_energy = e._light.a;
	light.light_volumetric_fog_energy = get_value("venergy", 1);
	defaultLightEnergy = light.light_energy;
	rotation = Vector3(e.angles.z, e.angles.y, e.angles.x) / 180.0 * PI;


