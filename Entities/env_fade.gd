@tool
extends ValveIONode

func Fade(to):
	var alphaTarget = to;
	var targetColor = Color(entity.color.r, entity.color.g, entity.color.b, float(to));
	
	var tween = create_tween();
	tween.tween_property(HUD.instance.fadePanel, "modulate", targetColor, entity.duration);
	tween.finished.connect(func(): tween.call_deferred("kill"));
	tween.play();
