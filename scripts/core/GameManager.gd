extends Node
## 游戏全局管理器（AutoLoad单例）
## Week 6添加 - 管理游戏状态、统计数据、场景切换

# 游戏状态
enum GameState { MAIN_MENU, PLAYING, PAUSED, GAME_OVER }
var current_state = GameState.MAIN_MENU

# 游戏统计
var enemies_killed = 0
var total_exp_gained = 0
var play_time = 0.0

# 玩家数据
var player_level = 1
var player_max_health = 100
var current_health = 100

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	print("[GameManager] 游戏管理器已初始化")

func _process(delta):
	if current_state == GameState.PLAYING:
		play_time += delta

func reset_stats():
	"""重置统计数据"""
	enemies_killed = 0
	total_exp_gained = 0
	play_time = 0.0
	print("[GameManager] 统计数据已重置")

func on_enemy_killed(exp_value: int):
	"""敌人被击杀时调用"""
	enemies_killed += 1
	total_exp_gained += exp_value
	print("[GameManager] 击杀敌人 #%d，获得经验: %d" % [enemies_killed, exp_value])

func start_game():
	"""开始游戏"""
	reset_stats()
	current_state = GameState.PLAYING
	get_tree().change_scene_to_file("res://scenes/levels/TestLevel.tscn")
	print("[GameManager] 游戏开始")

func return_to_main_menu():
	"""返回主菜单"""
	current_state = GameState.MAIN_MENU
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")
	print("[GameManager] 返回主菜单")

func game_over():
	"""游戏结束"""
	current_state = GameState.GAME_OVER
	print("[GameManager] 游戏结束")
