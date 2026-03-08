extends Control
class_name PauseMenu
## 暂停菜单
## Week 6添加 - 游戏暂停界面

@onready var resume_button: Button = $Panel/VBoxContainer/ResumeButton
@onready var restart_button: Button = $Panel/VBoxContainer/RestartButton
@onready var settings_button: Button = $Panel/VBoxContainer/SettingsButton
@onready var quit_button: Button = $Panel/VBoxContainer/QuitButton

var is_paused = false

func _ready():
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS  # 暂停时也能处理输入
	
	# 连接按钮信号
	if resume_button:
		resume_button.pressed.connect(_on_resume_pressed)
	if restart_button:
		restart_button.pressed.connect(_on_restart_pressed)
	if settings_button:
		settings_button.pressed.connect(_on_settings_pressed)
	if quit_button:
		quit_button.pressed.connect(_on_quit_pressed)

func _input(event):
	if event.is_action_pressed("pause"):
		toggle_pause()

func toggle_pause():
	"""切换暂停状态"""
	is_paused = !is_paused
	
	if is_paused:
		pause_game()
	else:
		resume_game()

func pause_game():
	"""暂停游戏"""
	visible = true
	get_tree().paused = true
	# AudioManager.play_sfx("ui_menu_open")
	print("[PauseMenu] 游戏已暂停")

func resume_game():
	"""继续游戏"""
	visible = false
	get_tree().paused = false
	# AudioManager.play_sfx("ui_menu_close")
	print("[PauseMenu] 游戏继续")

func _on_resume_pressed():
	"""继续游戏按钮"""
	# AudioManager.play_sfx("ui_button_click")
	resume_game()

func _on_restart_pressed():
	"""重新开始按钮"""
	# AudioManager.play_sfx("ui_confirm")
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_settings_pressed():
	"""设置按钮"""
	# AudioManager.play_sfx("ui_button_click")
	print("[PauseMenu] 打开设置菜单（待实现）")
	# TODO: 打开设置菜单

func _on_quit_pressed():
	"""退出按钮"""
	# AudioManager.play_sfx("ui_confirm")
	get_tree().paused = false
	if GameManager:
		GameManager.return_to_main_menu()
	else:
		get_tree().quit()
