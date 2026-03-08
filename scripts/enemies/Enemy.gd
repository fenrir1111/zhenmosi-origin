extends CharacterBody2D
class_name Enemy
## 敌人基类 - 所有敌人继承此类
## 提供基础属性、状态机和通用方法

# 基础属性
@export var max_health: int = 50
@export var current_health: int = 50
@export var move_speed: float = 100.0
@export var attack_damage: int = 10
@export var detection_range: float = 200.0
@export var attack_range: float = 50.0
@export var exp_value: int = 10  # Week 6：经验值掉落

# 重力
var gravity: float = 800.0

# 引用
@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var health_bar: ProgressBar = $HealthBar
@onready var visible_notifier: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D if has_node("VisibleOnScreenNotifier2D") else null

# 状态机
enum State { IDLE, PATROL, CHASE, ATTACK, HURT, DEAD }
var current_state: State = State.IDLE

# 玩家引用
var player: CharacterBody2D = null

# 击退相关
var knockback_velocity: Vector2 = Vector2.ZERO
var is_processing_hurt: bool = false

func _ready():
	# 添加到敌人组
	add_to_group("enemies")
	
	# 获取玩家引用
	player = get_tree().get_first_node_in_group("player")
	
	# 初始化血条
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = current_health
	
	# Week 6：屏幕外优化
	if visible_notifier:
		visible_notifier.screen_exited.connect(_on_screen_exited)
		visible_notifier.screen_entered.connect(_on_screen_entered)
	
	print("%s 初始化完成" % name)

func _physics_process(delta: float):
	# 应用重力
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# 状态机处理
	match current_state:
		State.IDLE:
			process_idle(delta)
		State.PATROL:
			process_patrol(delta)
		State.CHASE:
			process_chase(delta)
		State.ATTACK:
			process_attack(delta)
		State.HURT:
			process_hurt(delta)
		State.DEAD:
			process_dead(delta)

# ========== 状态处理方法（子类重写） ==========

func process_idle(_delta: float):
	# 待机逻辑 - 子类重写
	velocity.x = 0
	move_and_slide()

func process_patrol(_delta: float):
	# 巡逻逻辑 - 子类重写
	pass

func process_chase(_delta: float):
	# 追逐逻辑 - 子类重写
	pass

func process_attack(_delta: float):
	# 攻击逻辑 - 子类重写
	pass

func process_hurt(_delta: float):
	# 受伤逻辑 - 应用击退
	if is_processing_hurt:
		return
	
	velocity.x = knockback_velocity.x
	move_and_slide()

func process_dead(_delta: float):
	# 死亡逻辑 - 停止移动
	velocity = Vector2.ZERO

# ========== 通用方法 ==========

func take_damage(amount: int, from_direction: float = 0.0):
	if current_state == State.DEAD:
		return
	
	current_health -= amount
	print("%s 受到 %d 点伤害，剩余 %d HP" % [name, amount, current_health])
	
	# 更新血条
	if health_bar:
		health_bar.value = current_health
	
	# 计算击退方向（从攻击者方向被击退）
	knockback_velocity.x = -sign(from_direction) * 200 if from_direction != 0 else 0
	
	# 受伤反馈
	current_state = State.HURT
	
	# 受伤闪烁效果
	if sprite:
		sprite.modulate = Color(1, 0.3, 0.3, 1)
	
	# 检查死亡
	if current_health <= 0:
		die()
	else:
		# 启动受伤恢复计时
		start_hurt_recovery()

func start_hurt_recovery():
	is_processing_hurt = true
	
	# 0.3秒后恢复
	await get_tree().create_timer(0.3).timeout
	
	# 恢复颜色
	if sprite:
		sprite.modulate = Color(1, 1, 1, 1)
	
	is_processing_hurt = false
	
	if current_state == State.HURT and current_health > 0:
		current_state = State.PATROL

func die():
	current_state = State.DEAD
	print("%s 死亡" % name)
	
	# Week 6：通知GameManager
	if GameManager:
		GameManager.on_enemy_killed(exp_value)
	
	# 恢复颜色
	if sprite:
		sprite.modulate = Color(1, 1, 1, 1)
	
	# 禁用碰撞
	set_collision_layer_value(2, false)
	set_collision_mask_value(1, false)
	
	# 播放死亡动画
	if animation_player and animation_player.has_animation("death"):
		animation_player.play("death")
	
	# Week 5：掉落经验值给玩家
	if player and player.has_method("add_exp"):
		player.add_exp(exp_value)
	
	# 1秒后移除
	await get_tree().create_timer(1.0).timeout
	
	emit_signal("enemy_died")
	queue_free()

# 信号
signal enemy_died

# ========== 辅助方法 ==========

func get_distance_to_player() -> float:
	if player:
		return global_position.distance_to(player.global_position)
	return INF

func get_direction_to_player() -> float:
	if player:
		return sign(player.global_position.x - global_position.x)
	return 0.0

func is_player_in_detection_range() -> bool:
	return get_distance_to_player() < detection_range

func is_player_in_attack_range() -> bool:
	return get_distance_to_player() < attack_range

# Week 6：屏幕外优化
func _on_screen_exited():
	"""离开屏幕时停止物理计算"""
	set_physics_process(false)
	print("%s 离开屏幕，暂停AI" % name)

func _on_screen_entered():
	"""进入屏幕时恢复物理计算"""
	set_physics_process(true)
	print("%s 进入屏幕，恢复AI" % name)

