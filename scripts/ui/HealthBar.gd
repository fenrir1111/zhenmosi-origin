extends ProgressBar
class_name HealthBar
## 血条UI组件
## Week 5添加 - 显示玩家生命值，支持平滑动画

@export var delay_bar_color: Color = Color(0.5, 0.0, 0.0, 0.8)  # 延迟条颜色
@export var smooth_duration: float = 0.3  # 平滑动画时长
@export var damage_flash_color: Color = Color(1, 1, 1, 0.5)  # 受伤闪烁颜色

var current_value: float = 100.0
var target_value: float = 100.0
var tween: Tween

# 延迟血条（显示受伤前的血量）
var delay_bar: ProgressBar

func _ready():
	# 创建延迟血条
	delay_bar = ProgressBar.new()
	delay_bar.show_percentage = false
	delay_bar.mouse_filter = MOUSE_FILTER_IGNORE
	delay_bar.add_theme_stylebox_override("fill", create_delay_style())
	add_child(delay_bar)
	move_child(delay_bar, 0)  # 放在主血条下方
	
	# 设置延迟血条的属性
	delay_bar.min_value = min_value
	delay_bar.max_value = max_value
	delay_bar.value = value
	delay_bar.size = size
	delay_bar.position = Vector2.ZERO

func create_delay_style() -> StyleBoxFlat:
	"""创建延迟血条样式"""
	var style = StyleBoxFlat.new()
	style.bg_color = delay_bar_color
	return style

func set_health(current: float, maximum: float):
	"""设置血量"""
	max_value = maximum
	target_value = current
	
	if delay_bar:
		delay_bar.max_value = maximum
	
	# 平滑过渡
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.tween_property(self, "value", target_value, smooth_duration)
	
	# 延迟血条晚一点跟上
	if delay_bar and target_value < current_value:
		tween.parallel().tween_property(delay_bar, "value", target_value, smooth_duration * 2)
	elif delay_bar:
		delay_bar.value = target_value
	
	current_value = target_value

func take_damage(amount: float):
	"""受到伤害时触发闪烁"""
	var original_modulate = modulate
	modulate = damage_flash_color
	
	await get_tree().create_timer(0.1).timeout
	modulate = original_modulate

func _notification(what):
	if what == NOTIFICATION_RESIZED and delay_bar:
		delay_bar.size = size
