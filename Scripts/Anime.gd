extends Node;
static var instance = null;
static var NO_FUNC = func(): pass;
static var NO_FUNC_CB = func(_p, _b): pass;

var currentTimers = [];

class AnimateInstance:
	var duration = 0;
	var current = 0;
	var callback = null;
	var index = 0;
	var onEnd = null;
	var backwards = false;

	func _init(d, cb, e = func(): pass, bw = false):
		self.duration = d;
		self.callback = cb;
		self.onEnd = e;
		self.backwards = bw;

func EaseOutElastic(x: float):
	var c4 = (2 * PI) / 3;

	return pow(2, -10 * x) * sin((x * 10 - 0.75) * c4) + 1;

func EaseOutBack(x: float):
	var c1 = 1.70158;
	var c3 = c1 + 1;

	return 1 + c3 * pow(x - 1, 3) + c1 * pow(x - 1, 2);

func EaseInOutCubic(x: float):
	if x < 0.5:
		return 4 * x * x * x
	else:
		return 1 - pow(-2 * x + 2, 3) / 2;

func EaseInOutQuad(x: float):
	if x < 0.5:
		return 2 * x * x
	else:
		return 1 - pow(-2 * x + 2, 2) / 2;

func EaseOutQuint(x: float):
	return 1 - pow(1 - x, 5);

func EaseOutCircle(x: float):
	return sqrt(1 - pow(x - 1, 2));


func EaseInCircle(x: float):
	return 1 - sqrt(1 - pow(x, 2));

func Animate(duration: float, callback: Callable, onEnd: Callable = NO_FUNC, backwards = false):
	var timer = AnimateInstance.new(duration, callback, onEnd, backwards);
	timer.index = currentTimers.size();
	currentTimers.append(timer);

	return timer;

func _init():
	instance = self;

func _process(delta):
	for timer in currentTimers:
		if not timer:
			continue;
		timer.current += delta;
		var percent = min(1.0, timer.current / timer.duration);

		if timer.backwards:
			percent = 1.0 - percent;

		var needBreak = timer.callback.call(min(1.0, percent), timer.backwards);

		if timer.current >= timer.duration or needBreak:
			timer.onEnd.call();
			currentTimers.remove_at(currentTimers.find(timer));


