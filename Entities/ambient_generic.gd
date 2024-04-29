@tool
class_name AmbientGeneric extends ValveIONode

var FLAG_PLAY_EVERYWHERE = 1;
var FLAG_START_SILENT = 16;
var FLAG_IS_NOT_LOOPED = 32;

@export var radius = 0.0;
@export var targetVolume = 1.0;
@export var targetPitch = 1.0;


var audioStream;
var fadingOut = false;

func FadeIn(time):
	if not audioStream:
		return;

	fadingOut = false;

	audioStream.play(0.0);
	audioStream.volume_db = linear_to_db(0.0);
	audioStream.pitch_scale = targetPitch;

	Anime.Animate(float(time), func(percent, _b):
		if fadingOut:
			return true;

		audioStream.volume_db = linear_to_db(percent * targetVolume);
	);

func FadeOut(time):
	if not audioStream:
		return;

	fadingOut = true;

	Anime.Animate(
		float(time),
		func(percent, _b):
			if not fadingOut:
				return true;

			audioStream.volume_db = linear_to_db((1.0 - percent) * targetVolume),
		func():
			audioStream.stop()
	);

func PlaySound(_param = null):
	if not audioStream:
		return;

	audioStream.volume_db = linear_to_db(targetVolume);
	audioStream.pitch_scale = targetPitch;
	audioStream.play(0.0);

func StopSound(_param = null):
	if not audioStream:
		return;

	audioStream.stop();

func _entity_ready():
	if Engine.is_editor_hint():
		return;

	var stream = load("res://Assets/Sounds/" + entity.message);

	if stream == null:
		print("AmbientGeneric: Could not load sound: " + entity.message);
		return;

	if have_flag(FLAG_PLAY_EVERYWHERE):
		audioStream = AudioStreamPlayer.new();
	else:
		audioStream = AudioStreamPlayer3D.new();

	add_child(audioStream);

	stream = stream.duplicate();

	if have_flag(FLAG_IS_NOT_LOOPED):
		if stream is AudioStreamWAV:
			stream.set_loop_mode(0);

		if stream is AudioStreamOggVorbis:
			stream.loop = false;

	else:
		if stream is AudioStreamOggVorbis:
			stream.loop = true;

	audioStream.stream = stream;

	if audioStream is AudioStreamPlayer3D:
		audioStream.max_distance = radius;

	if not have_flag(FLAG_START_SILENT):
		PlaySound();
	else:
		audioStream.stop();
	

func _apply_entity(e, c):
	super._apply_entity(e, c);
	radius = e.radius * config.import.scale;
	targetVolume = float(e.health) / 10.0 if "health" in e else 1.0;
	targetPitch = float(e.pitch / 100) if "pitch" in e else 1.0;
