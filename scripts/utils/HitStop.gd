extends Node
## 顿帧效果管理器（AutoLoad单例）
## Week 4添加 - 战斗时短暂暂停，增强打击感

var time_scale = 1.0

func hit_stop(duration: float = 0.1, time_scale_value: float = 0.0):
	"""
	触发顿帧效果
	duration: 持续时间（秒）
	time_scale_value: 时间缩放（0.0 = 完全暂停，0.5 = 慢动作）
	"""
	time_scale = time_scale_value
	Engine.time_scale = time_scale
	
	await get_tree().create_timer(duration, true, false, true).timeout
	
	time_scale = 1.0
	Engine.time_scale = 1.0
