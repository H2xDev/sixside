@tool
class_name FuncTracktrain extends ValveIONode

var dt = 1.0;

var startSound = null;
var loopSound = null;
var stopSound = null;
var isMoving = false;

const FLAG_LINEAR = 1;

func _entity_ready():
	if "startsound" in entity:
		startSound = load("res://Assets/Sounds/" + entity.startsound);

	if "loopsound" in entity:
		loopSound = load("res://Assets/Sounds/" + entity.loopsound);

	if "stopsound" in entity:
		stopSound = load("res://Assets/Sounds/" + entity.stopsound);

func MoveToPoint(target):
	if isMoving:
		return;

	var targetNode = get_target(target);

	if not targetNode:
		return;

	isMoving = true;

	var startPos = global_position;
	var endPos = targetNode.global_position;
	var time = (endPos - startPos).length() / entity.speed;
	var volume = entity.get('volume', 2) / 10;

	if startSound:
		SoundManager.PlaySound(global_position, startSound, volume);
		
	var loopSnd = SoundManager.PlaySound(global_position, loopSound, volume);
	var isLinear = have_flag(FLAG_LINEAR);

	Anime.Animate(time,
		func(percent, _b):
			percent = Anime.EaseInOutQuad(percent) if not isLinear else percent;
			global_position = startPos.lerp(endPos, percent);
			
			if loopSnd:
				loopSnd.global_position = global_position,
		func():
			isMoving = false;
			trigger_output("OnStop");
			if loopSnd: loopSnd.stop();
			SoundManager.PlaySound(global_position, stopSound, volume));

func _process(_dt):
	self.dt = _dt;

func _apply_entity(e, c):
	super._apply_entity(e, c);

	var mesh = get_mesh();

	$MeshInstance3D.set_mesh(mesh);
	$StaticBody3D/CollisionShape3D.shape = get_entity_shape();

	e.speed = e.speed * config.import.scale;
