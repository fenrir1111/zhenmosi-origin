extends CharacterBody2D
## 玩家控制器 - 苏云萝
## Week 1-6完整实现：移动、跳跃、攻击、闪避、死亡重生、连击、信号系统

# ============ 移动参数 (Week 1) ============
const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const ACCELERATION = 1500.0
const FRICTION = 1200.0
const DASH_SPEED = 500.0  # Week 5：闪避速度
const DASH_DURATION = 0.2  # Week 5：闪避持续时间
const DASH_COOLDOWN = 1.0  # Week 5：闪避冷却

# 重力
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# ============ 生命值系统 (Week 2) ============
var current_health: int = 100
var max_health: int = 100

# ============ 经验值系统 (Week 5) ============
var current_exp: int = 0
var current_level: int = 1

# ============ 战斗系统 (Week 3-4) ============
var attack_damage: int = 20
var combo_count: int = 0
var combo_timer: float = 0.0
const COMBO_WINDOW = 1.5  # 连击窗口时间

# ============ 闪避系统 (Week 5) ============
var dash_timer: float = 0.0
var can_dash: bool = true
var dash_cooldown_timer: float = 0.0

# ============ 死亡重生系统 (Week 5) ============
var respawn_position: Vector2 = Vector2(100, 300)
var is_respawning: bool = false

# ============ 玩家状态 (Week 1-5) ============
enum State { IDLE, MOVE, JUMP, FALL, ATTACK, HURT, DEAD, DASH }
var current_state = State.IDLE

# ============ 信号系统 (Week 5) ============
signal health_changed(current, maximum)
signal combo_changed(combo_count)
signal level_up(new_level)
signal player_died
signal player_respawned

# ============ 节点引用 ============
@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer if has_node("AnimationPlayer") else null
@onready var attack_area: Area2D = $AttackArea if has_node("AttackArea") else null
@onready var camera: Camera2D = $Camera2D if has_node("Camera2D") else null

func _ready():
	add_to_group("player")
	respawn_position = global_position
	
	# 注册摄像机到ScreenShake
	if camera and ScreenShake:
		ScreenShake.set_camera(camera)
	
	# 发射初始血量信号
	health_changed.emit(current_health, max_health)
	
	print("[Player] 玩家初始化完成 - 血量: %d/%d" % [current_health, max_health])

func _physics_process(delta):
	# 死亡状态不处理输入
	if current_state == State.DEAD:
		return
	
	# 更新连击计时器
	if combo_timer > 0:
		combo_timer -= delta
		if combo_timer <= 0:
			reset_combo()
	
	# 更新闪避冷却
	if not can_dash:
		dash_cooldown_timer -= delta
		if dash_cooldown_timer <= 0:
			can_dash = true
	
	# 根据状态处理
	match current_state:
		State.IDLE, State.MOVE, State.JUMP, State.FALL:
			process_normal_movement(delta)
		State.ATTACK:
			process_attack_state(delta)
		State.HURT:
			process_hurt_state(delta)
		State.DASH:
			process_dash_state(delta)
	
	# 应用移动
	move_and_slide()
	
	# 更新动画
	update_animation()

func process_normal_movement(delta):
	"""处理正常移动状态"""
	# 应用重力
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# 跳跃 (Week 1)
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		current_state = State.JUMP
		# AudioManager.play_sfx("player_jump")
	
	# 闪避 (Week 5)
	if Input.is_action_just_pressed("dash") and can_dash:
		start_dash()
		return
	
	# 攻击 (Week 3)
	if Input.is_action_just_pressed("attack") and is_on_floor():
		start_attack()
		return
	
	# 水平移动 (Week 1)
	var direction = Input.get_axis("move_left", "move_right")
	
	if direction != 0:
		velocity.x = move_toward(velocity.x, direction * SPEED, ACCELERATION * delta)
		
		# 翻转精灵
		if direction > 0:
			sprite.flip_h = false
		else:
			sprite.flip_h = true
		
		if is_on_floor():
			current_state = State.MOVE
	else:
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
		
		if is_on_floor() and abs(velocity.x) < 10:
			current_state = State.IDLE
	
	# 更新下落状态
	if not is_on_floor() and velocity.y > 0:
		current_state = State.FALL

func process_attack_state(delta):
	"""处理攻击状态"""
	velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
	
	if not is_on_floor():
		velocity.y += gravity * delta

func process_hurt_state(delta):
	"""处理受伤状态"""
	velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
	
	if not is_on_floor():
		velocity.y += gravity * delta

func process_dash_state(delta):
	"""处理闪避状态 (Week 5)"""
	dash_timer -= delta
	
	if dash_timer <= 0:
		# 闪避结束
		set_collision_layer_value(1, true)  # 恢复碰撞
		current_state = State.IDLE
	
	# 闪避期间维持速度
	if not is_on_floor():
		velocity.y += gravity * delta

func start_dash():
	"""开始闪避 (Week 5)"""
	current_state = State.DASH
	dash_timer = DASH_DURATION
	can_dash = false
	dash_cooldown_timer = DASH_COOLDOWN
	
	# 闪避方向
	var dash_direction = 1 if not sprite.flip_h else -1
	velocity.x = dash_direction * DASH_SPEED
	
	# 无敌帧（禁用玩家碰撞层）
	set_collision_layer_value(1, false)
	
	# AudioManager.play_sfx("dash")
	print("[Player] 闪避！")

func start_attack():
	"""开始攻击 (Week 3)"""
	current_state = State.ATTACK
	
	# 增加连击计数
	combo_count += 1
	combo_timer = COMBO_WINDOW
	combo_changed.emit(combo_count)
	
	# AudioManager.play_sfx("player_attack")
	print("[Player] 攻击！连击: %d" % combo_count)
	
	# 触发顿帧效果 (Week 4)
	if HitStop:
		HitStop.hit_stop(0.05, 0.3)
	
	# 延迟检测攻击命中（等待动画帧）
	await get_tree().create_timer(0.1).timeout
	
	if current_state != State.ATTACK:
		return
	
	# 检测攻击范围内的敌人
	if attack_area:
		attack_area.monitoring = true
		
		var hit_any = false
		for body in attack_area.get_overlapping_bodies():
			if body.is_in_group("enemies") and body.has_method("take_damage"):
				var attack_direction = 1 if not sprite.flip_h else -1
				body.take_damage(attack_damage, attack_direction)
				hit_any = true
				print("[Player] 命中敌人: %s，连击: %d" % [body.name, combo_count])
		
		# 命中时的反馈效果 (Week 4)
		if hit_any:
			if HitStop:
				HitStop.hit_stop(0.1, 0.1)
			if ScreenShake:
				ScreenShake.shake(5.0, 10.0)
		
		attack_area.monitoring = false
	
	# 攻击动画结束后恢复状态
	await get_tree().create_timer(0.3).timeout
	if current_state == State.ATTACK:
		current_state = State.IDLE

func reset_combo():
	"""重置连击 (Week 4)"""
	if combo_count > 0:
		print("[Player] 连击重置")
		combo_count = 0
		combo_changed.emit(combo_count)

func take_damage(amount: int, knockback_direction: int = 0):
	"""受到伤害 (Week 2)"""
	if current_state == State.DEAD or current_state == State.DASH:
		return  # 死亡或闪避时无敌
	
	current_health -= amount
	health_changed.emit(current_health, max_health)
	
	print("[Player] 受伤 -%d，剩余: %d/%d" % [amount, current_health, max_health])
	
	# 击退效果
	if knockback_direction != 0:
		velocity.x = knockback_direction * 200
	
	# 受伤状态
	current_state = State.HURT
	
	# 受伤闪烁
	sprite.modulate = Color(1, 0.3, 0.3, 1)
	await get_tree().create_timer(0.2).timeout
	sprite.modulate = Color(1, 1, 1, 1)
	
	if current_state == State.HURT:
		current_state = State.IDLE
	
	# AudioManager.play_sfx("player_hurt")
	
	# 检查死亡
	if current_health <= 0:
		die()

func die():
	"""玩家死亡 (Week 5)"""
	if current_state == State.DEAD:
		return
	
	print("[Player] 死亡")
	current_state = State.DEAD
	velocity = Vector2.ZERO
	
	# 禁用碰撞
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	
	# 精灵变暗
	sprite.modulate = Color(0.5, 0.5, 0.5, 1)
	
	# 发射死亡信号
	player_died.emit()
	
	# AudioManager.play_sfx("death")
	
	# 震屏效果
	if ScreenShake:
		ScreenShake.shake(15.0, 8.0)
	
	# 3秒后重生
	await get_tree().create_timer(3.0).timeout
	respawn()

func respawn():
	"""重生 (Week 5)"""
	print("[Player] 重生")
	is_respawning = true
	
	# 恢复血量
	current_health = max_health
	health_changed.emit(current_health, max_health)
	
	# 恢复状态
	current_state = State.IDLE
	global_position = respawn_position
	
	# 恢复碰撞
	set_collision_layer_value(1, true)
	set_collision_mask_value(1, true)
	
	# 恢复精灵颜色
	sprite.modulate = Color(1, 1, 1, 1)
	
	# 重置连击
	reset_combo()
	
	# 发射重生信号
	player_respawned.emit()
	
	is_respawning = false

func add_exp(amount: int):
	"""添加经验值 (Week 5)"""
	current_exp += amount
	print("[Player] 获得经验: +%d" % amount)
	
	# 通知经验条UI
	var hud = get_tree().get_first_node_in_group("hud")
	if hud and hud.has_node("MarginContainer/VBoxContainer/ExperienceBar"):
		hud.get_node("MarginContainer/VBoxContainer/ExperienceBar").add_exp(amount)

func heal(amount: int):
	"""治疗"""
	current_health = min(current_health + amount, max_health)
	health_changed.emit(current_health, max_health)
	print("[Player] 治疗: +%d，当前: %d/%d" % [amount, current_health, max_health])

func update_animation():
	"""更新动画"""
	if not animation_player:
		return
	
	match current_state:
		State.IDLE:
			if animation_player.has_animation("idle"):
				animation_player.play("idle")
		State.MOVE:
			if animation_player.has_animation("walk"):
				animation_player.play("walk")
		State.JUMP:
			if animation_player.has_animation("jump"):
				animation_player.play("jump")
		State.FALL:
			if animation_player.has_animation("fall"):
				animation_player.play("fall")
		State.ATTACK:
			if animation_player.has_animation("attack"):
				animation_player.play("attack")
		State.HURT:
			if animation_player.has_animation("hurt"):
				animation_player.play("hurt")
		State.DEAD:
			if animation_player.has_animation("dead"):
				animation_player.play("dead")
		State.DASH:
			if animation_player.has_animation("dash"):
				animation_player.play("dash")
			elif animation_player.has_animation("walk"):
				animation_player.play("walk")
