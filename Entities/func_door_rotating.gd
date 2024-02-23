@tool
extends ValveIONode

@onready var mi = $MeshInstance3D;

const FLAG_USE_OPENS = 256;
const FLAG_REVERSE = 2;

var openValue = 0.0;
var isOpen = false;
var isLocked = false;
var time = 1;
var dir = 1;
var startRot = Vector3(0, 0, 0);

signal interact;

func _entity_ready():
	startRot = mi.rotation;

	if have_flag(FLAG_USE_OPENS): # Use opens
		interact.connect(func():
			if isLocked:
				trigger_output("OnLockedUse");
			else:
				Toggle());

	dir = -1 if have_flag(FLAG_REVERSE) else 1;

func _apply_entity(e, c):
	super._apply_entity(e, c);

	var mesh = get_mesh();
	$MeshInstance3D.set_mesh(mesh);
	$MeshInstance3D/StaticBody3D/CollisionShape3D.shape = mesh.create_convex_shape();

func Open(_param):
	isOpen = true;

	var timer = Anime.Animate(time, ProcessOpen, func(): trigger_output("OnFullyOpen"));

	timer.current = time * openValue;
	trigger_output("OnOpen");

func Close(_param):
	isOpen = false;

	var timer = Anime.Animate(time, ProcessOpen, func(): trigger_output("OnFullyClose"), true);

	timer.current = time * (1.0 - openValue);
	trigger_output("OnClose");

func Toggle(_param = null):
	if isOpen:
		Close(_param);
	else:
		Open(_param);

func ProcessOpen(percent, backwards):
	var p = Anime.EaseInOutQuad(percent);

	if backwards == isOpen:
		return;

	openValue = p;

	mi.rotation = startRot + Vector3(0, PI / 2, 0) * p * dir;

