extends Enemy
class_name PaperDoll
## 纸人妖魅 - 第一个敌人
## 行为：巡逻 + 检测玩家 + 追逐 + 攻击

# 巡逻参数
var patrol_direction: int = 1  # 1=右，-1=左
var patrol_timer: float = 0.0
var patrol_change_interval: float = 3.0  # 3秒换方向

# 攻击冷却
var attack_cooldown: float = 0.0
var attack_cooldown_time: float = 1.0  # 攻击间隔1秒

# 是否正在执行攻击动画
var is_attacking: bool = false

func _ready():
	super._ready()
	
	# 纸人妖魅属性
	max_health = 50
	current_health = 50
	move_speed = 100.0
	attack_damage = 10
	detection_range = 200.0
	attack_range = 50.0
	
	# 更新血条
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = current_health
	
	# 初始状态：巡逻
	current_state = State.PATROL
	
	print("纸人妖魅 %s 已生成" % name)

func _physics_process(delta: float):
	# 更新攻击冷却
	if attack_cooldown > 0:
		attack_cooldown -= delta
	
	# 调用父类的状态机处理
	super._physics_process(delta)

# ========== 状态实现 ==========

func process_idle(delta: float):
	velocity.x = 0
	move_and_slide()
	
	# 检测玩家
	if is_player_in_detection_range():
		current_state = State.CHASE
	else:
		# 一段时间后恢复巡逻
		await get_tree().create_timer(1.0).timeout
		if current_state == State.IDLE:
			current_state = State.PATROL

func process_patrol(delta: float):
	# 巡逻移动
	velocity.x = patrol_direction * move_speed
	move_and_slide()
	
	# 更新精灵朝向
	if sprite:
		sprite.flip_h = (patrol_direction < 0)
	
	# 播放行走动画
	if animation_player and animation_player.has_animation("walk"):
		if animation_player.current_animation != "walk":
			animation_player.play("walk")
	
	# 定时换方向
	patrol_timer += delta
	if patrol_timer >= patrol_change_interval:
		patrol_direction *= -1
		patrol_timer = 0.0
	
	# 碰到墙壁换方向
	if is_on_wall():
		patrol_direction *= -1
		patrol_timer = 0.0
	
	# 检测边缘（防止掉落）
	check_edge()
	
	# 检测玩家
	if is_player_in_detection_range():
		current_state = State.CHASE

func process_chase(delta: float):
	if not player:
		current_state = State.PATROL
		return
	
	var distance = get_distance_to_player()
	
	# 超出检测范围，返回巡逻
	if distance > detection_range * 1.5:
		current_state = State.PATROL
		return
	
	# 进入攻击范围且冷却完毕
	if distance < attack_range and attack_cooldown <= 0:
		current_state = State.ATTACK
		return
	
	# 追逐玩家
	var direction = get_direction_to_player()
	velocity.x = direction * move_speed * 1.5  # 追逐时速度更快
	move_and_slide()
	
	# 更新精灵朝向
	if sprite:
		sprite.flip_h = (direction < 0)
	
	# 更新巡逻方向（用于受伤击退计算）
	patrol_direction = int(direction)
	
	# 播放追逐动画
	if animation_player and animation_player.has_animation("chase"):
		if animation_player.current_animation != "chase":
			animation_player.play("chase")
	elif animation_player and animation_player.has_animation("walk"):
		if animation_player.current_animation != "walk":
			animation_player.play("walk")

func process_attack(delta: float):
	if is_attacking:
		return
	
	is_attacking = true
	velocity.x = 0
	
	# 播放攻击动画
	if animation_player and animation_player.has_animation("attack"):
		animation_player.play("attack")
	
	# 攻击延迟（模拟蓄力）
	await get_tree().create_timer(0.2).timeout
	
	# 检测玩家是否仍在攻击范围内
	if player and is_player_in_attack_range():
		if player.has_method("take_damage"):
			player.take_damage(attack_damage)
			print("%s 攻击玩家，造成 %d 点伤害" % [name, attack_damage])
	
	# 攻击结束
	await get_tree().create_timer(0.3).timeout
	
	is_attacking = false
	attack_cooldown = attack_cooldown_time
	
	# 攻击后退回巡逻状态
	if current_state == State.ATTACK:
		if is_player_in_detection_range():
			current_state = State.CHASE
		else:
			current_state = State.PATROL

func process_hurt(delta: float):
	# 应用击退
	velocity.x = knockback_velocity.x
	move_and_slide()
	
	# 衰减击退速度
	knockback_velocity.x = move_toward(knockback_velocity.x, 0, 500 * delta)

func die():
	current_state = State.DEAD
	print("纸人妖魅 %s 被消灭！" % name)
	
	# 停止移动
	velocity = Vector2.ZERO
	
	# 恢复颜色
	if sprite:
		sprite.modulate = Color(1, 1, 1, 1)
	
	# 禁用碰撞
	set_collision_layer_value(2, false)
	set_collision_mask_value(1, false)
	
	# 播放死亡动画
	if animation_player and animation_player.has_animation("death"):
		animation_player.play("death")
	else:
		# 简单的死亡效果：逐渐消失
		var tween = create_tween()
		tween.tween_property(sprite, "modulate:a", 0.0, 0.5)
	
	# 掉落经验值
	drop_experience()
	
	# 1秒后移除
	await get_tree().create_timer(1.0).timeout
	emit_signal("enemy_died")
	queue_free()

func drop_experience():
	# TODO: 实现经验值掉落系统
	print("%s 掉落 10 经验值" % name)

# ========== 辅助方法 ==========

func check_edge():
	# 使用射线检测前方是否有地面
	# 如果前方没有地面，换方向（防止掉落）
	var ray_position = Vector2(patrol_direction * 20, 10)
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(
		global_position + Vector2(patrol_direction * 20, 0),
		global_position + Vector2(patrol_direction * 20, 50)
	)
	query.collision_mask = 1  # 检测地面层
	
	var result = space_state.intersect_ray(query)
	if result.is_empty():
		# 前方没有地面，换方向
		patrol_direction *= -1
		patrol_timer = 0.0
