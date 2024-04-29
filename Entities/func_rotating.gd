@tool
extends ValveIONode

@export var preview = false;

const FLAG_START_ON: int = 1;
const FLAG_REVERSE_DIRECTION: int = 2;
const FLAG_X_AXIS: int = 4;
const FLAG_Y_AXIS: int = 8;

var rotTween = null;

# Called when the node enters the scene tree for the first time.
func _process(dt):
	if Engine.is_editor_hint() && not preview:
		return;

	if not enabled:
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

	enabled = have_flag(FLAG_START_ON);

func RotateBy(deg):
	if rotTween:
		return;

	deg = float(deg);

	rotTween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN);
	var target = Vector3.ZERO;

	if have_flag(FLAG_X_AXIS):
		target.x = deg;
	elif have_flag(FLAG_Y_AXIS):
		target.z = deg;
	else:
		target.y = deg;
	
	var endRot = rotation_degrees + target;

	rotTween.tween_property(self, "rotation_degrees", endRot, 2.0);
	rotTween.play();
	rotTween.finished.connect(func():
		rotTween = null);


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _apply_entity(e, c):
	super._apply_entity(e, c);

	$MeshInstance3D.set_mesh(get_mesh());
	$MeshInstance3D.cast_shadow = entity.disableshadows == 0;


