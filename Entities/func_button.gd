@tool
extends ValveIONode

signal interact();

const FLAG_ONCE = 2;
const FLAG_STARTS_LOCKED = 2048;

var isLocked = false;
var isUsed = false;
@export var moveDirection = Vector3.UP;
@export var moveDistance = Vector3.UP;
@export var forward = Vector3.UP;

var sound = null;
var lockedSound = null;
var isAnimating = false;
var startPos = Vector3.ZERO;

@onready var tmesh = $MeshInstance3D;

func Lock(_param = null):
	isLocked = true;

func Unlock(_paran = null):
	isLocked = false;

func _entity_ready():
	startPos = position;

	isLocked = have_flag(FLAG_STARTS_LOCKED);

	interact.connect(func ():
		if isAnimating:
			return;

		AnimateMovement();
		if isLocked:
			if lockedSound:
				SoundManager.PlaySound(global_position, lockedSound, 0.05);
			trigger_output("OnUseLocked")
		else:
			if have_flag(FLAG_ONCE) and isUsed:
				return;

			if sound:
				SoundManager.PlaySound(global_position, sound, 0.05);
			trigger_output("OnPressed")
			isUsed = true);

	if "sound" in entity:
		sound = load("res://Assets/Sounds/" + entity.sound);

	if "locked_sound" in entity and typeof(entity.locked_sound) == TYPE_STRING:
		lockedSound = load("res://Assets/Sounds/" + entity.locked_sound);

	HUD.instance.AppendInteractive(self);

func AnimateMovement():
	isAnimating = true;
	Anime.Animate(
		0.25,
		func(process, _b):
			position = startPos + moveDistance * 0.5 * sin(PI * process),
		func ():
			isAnimating = false);

func _exit_tree():
	if Engine.is_editor_hint():
		return;
	HUD.instance.RemoveInteractive(self);

func _apply_entity(e, c):
	super._apply_entity(e, c);

	var mesh = get_mesh();
	$MeshInstance3D.set_mesh(mesh);
	$MeshInstance3D/StaticBody3D/CollisionShape3D.shape = mesh.create_convex_shape();

	moveDirection = -get_movement_vector(e.movedir);
	moveDistance = mesh.get_aabb().size * moveDirection;
	forward = moveDirection.normalized();
