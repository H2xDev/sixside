@tool
extends ValveIONode;

@onready var mi = $MeshInstance3D;

@export var moveDirection = Vector3(0, 0, 0);
@export var moveDistance = Vector3(0, 0, 0);
@export var speed = 0.0;
@export var lip3 = Vector3(0, 0, 0);
@export var volume = 1.0;

const FLAG_RANDOM_SOUND_PITCH = 2;

var openValue = 0.0;
var isOpen = false;
var isLocked = false;
var startPos = Vector3(0, 0, 0);
var openSound = null;
var closeSound = null;

var time:
	get:
		lip3 = lip3 if lip3 != null else Vector3(0, 0, 0);
		return (moveDistance.length() - lip3.length()) / speed;

func _entity_ready():
	startPos = position;

	isOpen = entity.spawnpos == 1;
	ProcessOpen(entity.spawnpos, false);

	if "noise1" in entity:
		openSound = load("res://Assets/Sounds/" + entity.noise1);

	if "startclosesound" in entity:
		closeSound = load("res://Assets/Sounds/" + entity.startclosesound);

func Open(_param):
	isOpen = true;

	var pitch = 1.0 if not have_flag(FLAG_RANDOM_SOUND_PITCH) else randf_range(0.9, 1.1);
	
	trigger_output("OnOpen");
	
	if openSound:
		var snd = SoundManager.PlaySound(global_transform.origin, openSound, volume, pitch);
		snd.max_distance = entity.radius;

	var timer = Anime.Animate(time, ProcessOpen, OnFullyOpen);

	timer.current = time * openValue;

func Close(_param):
	isOpen = false;

	var pitch = 1.0 if not have_flag(FLAG_RANDOM_SOUND_PITCH) else randf_range(0.9, 1.1);

	trigger_output("OnClose");

	var snd: AudioStreamPlayer3D;

	if closeSound:
		snd = SoundManager.PlaySound(global_transform.origin, closeSound, volume, pitch);
	else: if openSound:
		snd = SoundManager.PlaySound(global_transform.origin, openSound, volume, pitch);

	if snd:
		snd.max_distance = entity.radius;

	var timer = Anime.Animate(time, ProcessOpen, OnFullyClosed, true);

	timer.current = time * (1.0 - openValue);

func OnFullyOpen():
	trigger_output("OnFullyOpen");

func OnFullyClosed():
	trigger_output("OnFullyClosed");

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
	
	print(startPos, moveDistance, p, lip3, p);
	position = startPos + moveDistance * p - lip3 * p;

func _apply_entity(e, c):
	super._apply_entity(e, c);

	var _basis = Basis.from_euler(Vector3(e.movedir.x, -e.movedir.y, -e.movedir.z) / 180.0 * PI);

	var mesh = get_mesh();
	$MeshInstance3D.set_mesh(mesh);
	$MeshInstance3D/StaticBody3D/CollisionShape3D.shape = get_entity_shape();

	moveDirection = _basis.z;
	moveDirection = Vector3(moveDirection.z, moveDirection.y, moveDirection.x);
	moveDistance = mesh.get_aabb().size * moveDirection;

	speed = e.speed * config.importScale;
	lip3 = moveDirection * e.lip * config.importScale;
	volume = e.volume / 10.0;
	e.radius = e.radius * config.importScale if "radius" in e else 100.0;

