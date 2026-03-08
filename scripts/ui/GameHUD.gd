extends CanvasLayer
class_name GameHUD
## 游戏HUD主界面
## Week 5添加 - 整合所有UI元素

@onready var health_bar: HealthBar = $MarginContainer/VBoxContainer/HealthBar
@onready var exp_bar: ExperienceBar = $MarginContainer/VBoxContainer/ExperienceBar
@onready var combo_label: Label = $MarginContainer/VBoxContainer/ComboCounter

var player: CharacterBody2D = null

func _ready():
	# 查找玩家
	player = get_tree().get_first_node_in_group("player")
	
	if player:
		# 连接玩家信号
		if player.has_signal("health_changed"):
			player.health_changed.connect(_on_player_health_changed)
		if player.has_signal("combo_changed"):
			player.combo_changed.connect(_on_player_combo_changed)
		if player.has_signal("level_up"):
			player.level_up.connect(_on_player_level_up)
		
		# 初始化显示
		if health_bar and player.has("current_health") and player.has("max_health"):
			health_bar.set_health(player.current_health, player.max_health)
	
	# 初始化连击显示
	if combo_label:
		combo_label.visible = false

func _on_player_health_changed(current: float, maximum: float):
	"""玩家血量变化"""
	if health_bar:
		health_bar.set_health(current, maximum)
		if current < maximum:
			health_bar.take_damage(maximum - current)

func _on_player_combo_changed(combo_count: int):
	"""连击数变化"""
	if not combo_label:
		return
	
	if combo_count > 0:
		combo_label.text = "%d Hit Combo!" % combo_count
		combo_label.visible = true
		
		# 根据连击数改变颜色和大小
		if combo_count >= 5:
			combo_label.modulate = Color(1, 0, 0)  # 红色
			combo_label.scale = Vector2(1.5, 1.5)
		elif combo_count >= 3:
			combo_label.modulate = Color(1, 0.5, 0)  # 橙色
			combo_label.scale = Vector2(1.3, 1.3)
		else:
			combo_label.modulate = Color(1, 1, 1)  # 白色
			combo_label.scale = Vector2(1.0, 1.0)
	else:
		combo_label.visible = false

func _on_player_level_up(new_level: int):
	"""玩家升级"""
	print("[GameHUD] 玩家升级到 Lv.%d！" % new_level)
	# 可以添加升级提示动画
