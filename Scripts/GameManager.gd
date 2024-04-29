class_name GameManager 
extends Node3D

static var instance: GameManager;
static var presave = [];

signal levelLoaded(levelName);

@onready var thread = Thread.new();
@export var startLevel: String = "level0";

var isActive = false;
var saveableEntities = [];
var levelsOnStage = [];
var levels = {};

func _ready():
	GameManager.instance = self;
	
	ValveIONode.define_alias('!world', self);

	LoadLevel(startLevel);
	PlaceLoadedLevel(startLevel, Vector3.ZERO);

	for node in presave:
		MakeSaveable(node);

func LoadLevelThreaded(levelName: String):
	thread.start(LoadLevel.bind(levelName));
	
func LoadLevel(levelName: String):
	var level = load("res://Levels/" + levelName + '.tscn');
	levels[levelName] = level;

	call_deferred('emit_signal', 'levelLoaded', levelName);

func FreeLevel(levelName: String):
	var root = get_tree().get_root().get_node(NodePath('Gameplay'));
	var levelNode = root.get_node_or_null(levelName);

	if levelNode:
		levelNode.queue_free();
		levelsOnStage.erase(levelName);
		levels.erase(levelName);

func PlaceLoadedLevel(levelName: String, origin: Vector3):
	if not levelName in levels:
		return;

	var node = levels[levelName].instantiate();

	add_child(node);
	levelsOnStage.append(levelName);

	node.name = levelName;
	node.global_position = origin;

func MakeSaveable(entity: Node3D):
	if saveableEntities.has(entity):
		return;

	saveableEntities.append(entity);

func SaveGame():
	var saveData = {};

	for entity in saveableEntities:
		if not "get_save_data" in entity:
			continue;

		saveData[entity.name] = {
			"position": entity.global_position,
			"data": entity.get_save_data(),
		};

	var saveFile = FileAccess.open("user://savegame.save", FileAccess.WRITE);
	saveFile.store_string(JSON.stringify(saveData));
	saveFile.close();

func LoadGame():
	if not FileAccess.file_exists("user://savegame.save"):
		return;
		
	var saveFile = FileAccess.open("user://savegame.save", FileAccess.WRITE);
	var saveData = JSON.parse_string(saveFile.get_as_text());
	saveFile.close();

	for entity in saveableEntities:
		if not entity.name in saveData:
			continue;

		entity.global_position = saveData[entity.name].position;
		entity.set_save_data(saveData[entity.name].data);
		
func Call(method):
	for n in levelsOnStage:
		var level = get_node_or_null(NodePath(n));
		
		if not level: continue;
		if method in level:
			level[method].call();
