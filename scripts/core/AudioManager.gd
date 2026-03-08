extends Node
## 音频管理器（AutoLoad单例）
## Week 2-5添加 - 管理所有音效和音乐

# 音效对象池
const MAX_SFX_PLAYERS = 20
var sfx_pool = []
var sfx_library = {}

# 音乐播放器
var music_player: AudioStreamPlayer = null

# 音量设置（0.0-1.0）
var master_volume = 1.0
var sfx_volume = 0.8
var music_volume = 0.7

func _ready():
	print("[AudioManager] 音频管理器已初始化")
	
	# 创建音效对象池
	for i in MAX_SFX_PLAYERS:
		var player = AudioStreamPlayer.new()
		player.name = "SFXPlayer%d" % i
		player.bus = "SFX"
		add_child(player)
		sfx_pool.append(player)
	
	# 创建音乐播放器
	music_player = AudioStreamPlayer.new()
	music_player.name = "MusicPlayer"
	music_player.bus = "Music"
	add_child(music_player)
	
	# 加载音效库
	load_sfx_library()

func load_sfx_library():
	"""加载音效库（占位符，实际音效文件需人工添加）"""
	# 战斗音效（Week 3-4）
	# sfx_library["player_attack"] = preload("res://assets/audio/sfx/player_attack.ogg")
	# sfx_library["player_hurt"] = preload("res://assets/audio/sfx/player_hurt.ogg")
	# sfx_library["enemy_hurt"] = preload("res://assets/audio/sfx/enemy_hurt.ogg")
	# sfx_library["death"] = preload("res://assets/audio/sfx/death.ogg")
	
	# UI音效（Week 5）
	# sfx_library["ui_menu_open"] = preload("res://assets/audio/sfx/ui/menu_open.ogg")
	# sfx_library["ui_button_click"] = preload("res://assets/audio/sfx/ui/button_click.ogg")
	# sfx_library["ui_level_up"] = preload("res://assets/audio/sfx/ui/level_up.ogg")
	
	print("[AudioManager] 音效库已加载（占位符）")

func play_sfx(sfx_name: String, volume_db: float = 0.0):
	"""播放音效"""
	if not sfx_library.has(sfx_name):
		print("[AudioManager] 警告：音效 '%s' 不存在" % sfx_name)
		return
	
	# 从对象池获取空闲播放器
	for player in sfx_pool:
		if not player.playing:
			player.stream = sfx_library[sfx_name]
			player.volume_db = volume_db + linear_to_db(sfx_volume)
			player.play()
			return
	
	print("[AudioManager] 警告：音效对象池已满")

func play_music(music_path: String, loop: bool = true):
	"""播放背景音乐"""
	if ResourceLoader.exists(music_path):
		var music = load(music_path)
		music_player.stream = music
		music_player.volume_db = linear_to_db(music_volume)
		if music_player.stream is AudioStreamOggVorbis:
			music_player.stream.loop = loop
		music_player.play()
		print("[AudioManager] 播放音乐: %s" % music_path)
	else:
		print("[AudioManager] 警告：音乐文件不存在: %s" % music_path)

func stop_music():
	"""停止背景音乐"""
	music_player.stop()

func set_master_volume(volume: float):
	"""设置主音量（0.0-1.0）"""
	master_volume = clamp(volume, 0.0, 1.0)
	AudioServer.set_bus_volume_db(0, linear_to_db(master_volume))

func set_sfx_volume(volume: float):
	"""设置音效音量（0.0-1.0）"""
	sfx_volume = clamp(volume, 0.0, 1.0)
	var sfx_bus = AudioServer.get_bus_index("SFX")
	if sfx_bus != -1:
		AudioServer.set_bus_volume_db(sfx_bus, linear_to_db(sfx_volume))

func set_music_volume(volume: float):
	"""设置音乐音量（0.0-1.0）"""
	music_volume = clamp(volume, 0.0, 1.0)
	var music_bus = AudioServer.get_bus_index("Music")
	if music_bus != -1:
		AudioServer.set_bus_volume_db(music_bus, linear_to_db(music_volume))
	if music_player:
		music_player.volume_db = linear_to_db(music_volume)
