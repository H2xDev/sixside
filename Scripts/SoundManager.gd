extends Node

var WIND = preload("res://Assets/Sounds/wind.mp3");
var JETPACK = preload("res://Assets/Sounds/player-dash.wav");
var WALLJUMP = preload("res://Assets/Sounds/ricochet.wav");

var playMap = {};

var _ftGround = [];

var FootstepsSounds = {
	"GROUND": _ftGround,
}

func _ready():
	var files = DirAccess.get_files_at("res://Assets/Sounds/footsteps");

	for file in files:
		file = file.replace(".import", "");

		if file.get_extension() != "wav":
			continue;

		var sound = load("res://Assets/Sounds/footsteps/" + file.get_file());
		_ftGround.append(sound);

func PlaySound(position: Vector3, sound: AudioStream, volume: float = 1.0, pitch: float = 1.0) -> AudioStreamPlayer3D:
	var soundPlayer = AudioStreamPlayer3D.new();
	get_tree().get_current_scene().add_child(soundPlayer);
	soundPlayer.global_transform.origin = position;

	soundPlayer.stream = sound;
	soundPlayer.volume_db = linear_to_db(volume);
	soundPlayer.pitch_scale = pitch;
	soundPlayer.connect("finished", soundPlayer.queue_free);
	soundPlayer.play(0.0);
	return soundPlayer;

func PlayRandomSound(position: Vector3, sounds: Array, volume: float = 1.0, pitch: float = 1.0, playHash = null) -> AudioStreamPlayer3D:
	var wave = sounds.pick_random();

	if playHash != null:
		if not playHash in playMap:
			playMap[playHash] = null;

		if playMap[playHash] == wave:
			return PlayRandomSound(position, sounds, volume, pitch, playHash);

		playMap[playHash] = wave;

	return PlaySound(position, wave, volume, pitch);
