@tool
class_name PointLight extends ValveIONode

enum Appearance {
	NORMAL,
	FAST_STROBE = 4,
	SLOW_STROBE = 9,
	FLUORESCENT_FLICKER = 10,
};

@export var style: Appearance = Appearance.NORMAL; # normal
@export var defaultLightEnergy = 0.0;
@export var preview = false;
@onready var light = $OmniLight3D if has_node("OmniLight3D") else $SpotLight3D;

func _entity_ready():
	## Initially dark flag
	if "spawnflags" in entity and entity.spawnflags == 1:
		light.visible = false;

func _process(_delta):
	if Engine.is_editor_hint() and not preview:
		if light.light_energy != defaultLightEnergy:
			light.light_energy = defaultLightEnergy;
		return;

	var newLightEnergy = defaultLightEnergy;

	match style:
		Appearance.NORMAL:
			pass;
		Appearance.FAST_STROBE:
			newLightEnergy = defaultLightEnergy - randf() * defaultLightEnergy * 0.2;
			pass;
		Appearance.SLOW_STROBE:
			newLightEnergy = defaultLightEnergy - Engine.get_frames_drawn() % 2 * defaultLightEnergy * 0.1;
			pass;
		Appearance.FLUORESCENT_FLICKER:
			newLightEnergy = 0.0 if randf() > 0.05 else defaultLightEnergy;
		_:
			pass;

	light.light_energy = newLightEnergy;

func TurnOff(_param):
	light.visible = false;

func TurnOn(_param):
	light.visible = true;

func _apply_entity(ent, c):
	super._apply_entity(ent, c);

	var importScale = config.importScale;
	var color = ent._light;

	var radius = ent._fifty_percent_distance if "_fifty_percent_distance" in ent else 0;
	var radius2 = ent._zero_percent_distance if "_zero_percent_distance" in ent else 0;
	radius = radius if radius > 0 else radius2;
	radius = radius if radius > 0 else 15 / importScale;

	radius *= importScale;

	if color is Vector3:
		light.set_color(Color(color.x, color.y, color.z));
		light.light_energy = 1.0;
	else: if "r" in color:
		light.set_color(Color(color.r, color.g, color.b));
		light.light_energy = color.a * radius * radius;
	else:
		VMFLogger.error('Invalid light: ' + str(ent.id));
		get_parent().remove_child(self);
		queue_free();
		return;

	if "omni_range" in light:
		light.omni_range = radius

	light.shadow_enabled = true;

	defaultLightEnergy = light.light_energy;

	style = ent.style if "style" in ent else Appearance.NORMAL;
	pass;

