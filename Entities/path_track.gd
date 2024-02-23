@tool
class_name PathTrack extends ValveIONode

var next:
	get:
		if "target" in entity:
			return get_target(entity.target);

		return null;



