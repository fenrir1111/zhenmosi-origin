extends Node
## 震屏效果管理器（AutoLoad单例）
## Week 4添加 - 战斗时屏幕抖动，增强打击感

var camera: Camera2D = null
var shake_strength = 0.0
var shake_decay = 5.0

func _ready():
	set_process(false)

func _process(delta):
	if shake_strength > 0:
		shake_strength = max(shake_strength - shake_decay * delta, 0)
		
		if camera:
			camera.offset = Vector2(
				randf_range(-shake_strength, shake_strength),
				randf_range(-shake_strength, shake_strength)
			)
		
		if shake_strength == 0:
			if camera:
				camera.offset = Vector2.ZERO
			set_process(false)

func shake(strength: float = 10.0, decay: float = 5.0):
	"""
	触发震屏效果
	strength: 震动强度（像素）
	decay: 衰减速度
	"""
	shake_strength = strength
	shake_decay = decay
	set_process(true)

func set_camera(cam: Camera2D):
	"""设置要抖动的摄像机"""
	camera = cam
