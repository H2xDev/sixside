@tool
extends ValveIONode

func _entity_ready():
	trigger_output("OnMapSpawn");

