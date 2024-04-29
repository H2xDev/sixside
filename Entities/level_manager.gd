@tool
extends ValveIONode

var isLoaded = false;

func LoadLevel(_param = null):
	GameManager.instance.LoadLevelThreaded(entity.level);
	GameManager.instance.levelLoaded.connect(_OnLoaded);

func PlaceLevel(_param = null):
	GameManager.instance.PlaceLoadedLevel(entity.level, global_position);
	trigger_output("OnLevelPlaced");
	print('placed');

func FreeLevel(n):
	GameManager.instance.FreeLevel(n);

func _OnLoaded(_lname):
	if _lname != entity.level:
		return;

	GameManager.instance.levelLoaded.disconnect(_OnLoaded);
	trigger_output("OnLevelLoaded");
