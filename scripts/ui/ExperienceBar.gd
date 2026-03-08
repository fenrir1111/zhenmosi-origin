extends ProgressBar
class_name ExperienceBar
## 经验条UI组件
## Week 5添加 - 显示经验值和等级

@onready var level_label: Label = $LevelLabel

var current_level: int = 1
var current_exp: float = 0.0
var exp_to_next_level: float = 100.0

func _ready():
	min_value = 0
	max_value = exp_to_next_level
	value = current_exp
	
	if not level_label:
		level_label = Label.new()
		level_label.name = "LevelLabel"
		add_child(level_label)
	
	update_display()

func add_exp(amount: float):
	"""添加经验值"""
	current_exp += amount
	
	# 检查升级
	while current_exp >= exp_to_next_level:
		level_up()
	
	update_display()

func level_up():
	"""升级"""
	current_level += 1
	current_exp -= exp_to_next_level
	exp_to_next_level = int(exp_to_next_level * 1.5)  # 指数增长
	max_value = exp_to_next_level
	
	print("[ExperienceBar] 升级到 Lv.%d！下一级需要: %d EXP" % [current_level, exp_to_next_level])
	
	# 播放升级特效
	play_level_up_effect()
	
	# 发射升级信号
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_signal("level_up"):
		player.level_up.emit(current_level)

func play_level_up_effect():
	"""播放升级特效"""
	# 金色闪光动画
	var original_modulate = modulate
	modulate = Color(2, 2, 0, 1)  # 金色高亮
	
	var tween = create_tween()
	tween.tween_property(self, "modulate", original_modulate, 0.5)
	
	# AudioManager.play_sfx("ui_level_up", 3.0)

func update_display():
	"""更新显示"""
	value = current_exp
	
	if level_label:
		level_label.text = "Lv.%d" % current_level
		level_label.position = Vector2(size.x + 10, -5)  # 放在经验条右侧

func set_level(level: int):
	"""设置等级"""
	current_level = level
	current_exp = 0
	exp_to_next_level = 100 * pow(1.5, level - 1)
	max_value = exp_to_next_level
	update_display()
