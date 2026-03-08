extends Control
class_name MainMenu
## 主菜单
## Week 6添加 - 游戏启动界面

@onready var start_button: Button = $CenterContainer/VBoxContainer/StartButton
@onready var settings_button: Button = $CenterContainer/VBoxContainer/SettingsButton
@onready var quit_button: Button = $CenterContainer/VBoxContainer/QuitButton
@onready var title_label: Label = $CenterContainer/VBoxContainer/TitleLabel

func _ready():
	# 连接按钮信号
	if start_button:
		start_button.pressed.connect(_on_start_pressed)
	if settings_button:
		settings_button.pressed.connect(_on_settings_pressed)
	if quit_button:
		quit_button.pressed.connect(_on_quit_pressed)
	
	# 设置标题
	if title_label:
		title_label.text = "镇魔司：缘起"
	
	print("[MainMenu] 主菜单已加载")

func _on_start_pressed():
	"""开始游戏按钮"""
	# AudioManager.play_sfx("ui_confirm")
	print("[MainMenu] 开始游戏")
	
	if GameManager:
		GameManager.start_game()
	else:
		get_tree().change_scene_to_file("res://scenes/levels/TestLevel.tscn")

func _on_settings_pressed():
	"""设置按钮"""
	# AudioManager.play_sfx("ui_button_click")
	print("[MainMenu] 打开设置菜单（待实现）")
	# TODO: 打开设置菜单

func _on_quit_pressed():
	"""退出按钮"""
	# AudioManager.play_sfx("ui_confirm")
	print("[MainMenu] 退出游戏")
	get_tree().quit()
