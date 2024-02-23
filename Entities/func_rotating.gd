@tool
extends ValveIONode

@export var preview = false;

var isOn = false;

var FLAG_START_ON: int = 1;
var FLAG_REVERSE_DIRECTION: int = 2;
var FLAG_X_AXIS: int = 4;
var FLAG_Y_AXIS: int = 8;

# Called when the node enters the scene tree for the first time.
func _process(dt):
	if Engine.is_editor_hint() && not preview:
		return;

	var speed = deg_to_rad(entity.maxspeed) * dt;

	if typeof(entity.spawnflags) != TYPE_INT:
		entity.spawnflags = int(entity.spawnflags);

	if entity.spawnflags & FLAG_REVERSE_DIRECTION:
		speed *= -1;

	if entity.spawnflags & FLAG_X_AXIS:
		rotation_degrees.x += speed;
	elif entity.spawnflags & FLAG_Y_AXIS:
		rotation_degrees.z += speed;
	else:
		rotation_degrees.y += speed;

func _entity_ready():
	if Engine.is_editor_hint():
		return;

	if typeof(entity.spawnflags) != TYPE_INT:
		entity.spawnflags = int(entity.spawnflags);

	if entity.spawnflags & FLAG_START_ON:
		isOn = true;


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _apply_entity(e, c):
	super._apply_entity(e, c);

	$MeshInstance3D.set_mesh(get_mesh());
	$MeshInstance3D.cast_shadow = entity.disableshadows == 0;
