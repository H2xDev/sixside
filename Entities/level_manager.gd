@tool
extends ValveIONode


func LoadLevel(_param = null):
	GameManager.instance.LoadLevelThreaded(entity.level);
	GameManager.instance.levelLoaded.connect(_PlaceLevel);

func FreeLevel(lname):
	GameManager.instance.FreeLevel(lname);

func _PlaceLevel(_lname):
	GameManager.instance.PlaceLoadedLevel(global_position);
	GameManager.instance.levelLoaded.disconnect(_PlaceLevel);

	trigger_output("OnLevelLoaded");
