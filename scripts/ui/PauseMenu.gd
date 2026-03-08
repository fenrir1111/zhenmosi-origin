extends Control
class_name PauseMenu
## 暂停菜单
## Week 6添加 - 游戏暂停界面

@onready var resume_button: Button = $Panel/VBoxContainer/ButtonMargin/ButtonContainer/ResumeButton
@onready var restart_button: Button = $Panel/VBoxContainer/ButtonMargin/ButtonContainer/RestartButton
@onready var settings_button: Button = $Panel/VBoxContainer/ButtonMargin/ButtonContainer/SettingsButton
@onready var quit_button: Button = $Panel/VBoxContainer/ButtonMargin/ButtonContainer/QuitButton

var is_paused = false

func _ready():
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS  # 暂停时也能处理输入
	
	# 连接按钮信号
	if resume_button:
		resume_button.pressed.connect(_on_resume_pressed)
		print("[PauseMenu] 继续游戏按钮已连接")
	if restart_button:
		restart_button.pressed.connect(_on_restart_pressed)
		print("[PauseMenu] 重新开始按钮已连接")
	if settings_button:
		settings_button.pressed.connect(_on_settings_pressed)
		print("[PauseMenu] 设置按钮已连接")
	if quit_button:
		quit_button.pressed.connect(_on_quit_pressed)
		print("[PauseMenu] 退出按钮已连接")
	
	print("[PauseMenu] 暂停菜单初始化完成")

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
	is_paused = false
	# AudioManager.play_sfx("ui_menu_close")
	print("[PauseMenu] 游戏继续")

func _on_resume_pressed():
	"""继续游戏按钮"""
	print("[PauseMenu] 点击继续游戏")
	# AudioManager.play_sfx("ui_button_click")
	resume_game()

func _on_restart_pressed():
	"""重新开始按钮"""
	print("[PauseMenu] 点击重新开始")
	# AudioManager.play_sfx("ui_confirm")
	get_tree().paused = false
	is_paused = false
	get_tree().reload_current_scene()

func _on_settings_pressed():
	"""设置按钮"""
	print("[PauseMenu] 点击设置")
	# AudioManager.play_sfx("ui_button_click")
	# TODO: 打开设置菜单

func _on_quit_pressed():
	"""退出按钮"""
	print("[PauseMenu] 点击退出")
	# AudioManager.play_sfx("ui_confirm")
	get_tree().paused = false
	is_paused = false
	if GameManager:
		GameManager.return_to_main_menu()
	else:
		get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")
