@tool
extends ValveIONode

signal interact();

const FLAG_ONCE = 2;
const FLAG_STARTS_LOCKED = 2048;

var isLocked = false;
var isUsed = false;

var sound = null;
var lockedSound = null;

func Lock(_param = null):
	isLocked = true;

func Unlock(_paran = null):
	isLocked = false;

func _entity_ready():
	isLocked = have_flag(FLAG_STARTS_LOCKED);

	interact.connect(func ():

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


func _apply_entity(e, c):
	super._apply_entity(e, c);

	var mesh = get_mesh();
	$MeshInstance3D.set_mesh(mesh);
	$MeshInstance3D/StaticBody3D/CollisionShape3D.shape = mesh.create_convex_shape();
