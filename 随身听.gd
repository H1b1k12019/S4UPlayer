extends Node2D

@export var 缩放倍率:float = 1
@export var 单曲循环模式 = false
@export var 当前显示CD名:String = "当前插入CD"
@export var 当前播放歌名:String = "当前播放歌曲"
@export var 插入的CD:CD
@export var 当前播放序号:int = 1
var 单曲循环模式设置用 = false
var 当前CD总曲目数

func 测试():
	print(OS.get_executable_path().get_base_dir()+"/") #导出后变为.exe自身文件夹
	var 目录路径 = "D:/S4U播放器/模拟外部文件"
	var MD碟片目录 = FileAccess.open(目录路径,FileAccess.READ)
	var 目录中的文件夹:Array
	print(DirAccess.open(目录路径).get_directories())
	
func _ready():
	if str(OS.get_locale()) == "zh_CN":
		TranslationServer.set_locale("zh")
	else:
		TranslationServer.set_locale("en")
	加载游戏()
	插入CD()
	get_viewport().transparent_bg = true
	if 单曲循环模式设置用 == true:
		$"单曲循环".button_pressed = true
func 插入CD():
	$"Panel/歌名显示".position.x = 0
	当前CD总曲目数 = 插入的CD.歌单.size()
	$"音频播放".stream = 插入的CD.歌单[0].歌曲文件
	当前播放歌名 = 插入的CD.歌单[0].歌曲名称
	当前显示CD名 = 插入的CD.resource_path.get_basename().get_slice("/", 4)
	$"唱片".texture = load("res://assets/texture/CD_front/"+当前显示CD名+".png")
	$AnimationPlayer3.play("插入碟片")
func 修改音频播放(歌单序号):
	$"Panel/歌名显示".position.x = 0
	$"音频播放".stream = 插入的CD.歌单[歌单序号-1].歌曲文件
	当前播放歌名 = 插入的CD.歌单[歌单序号-1].歌曲名称
	初始化音乐()
func CD已插入():
	修改音频播放(当前播放序号)
func 初始化音乐():
	$音频播放.playing = true
	储存游戏()
func 上一首():
	var 上一首序号
	上一首序号 = 当前播放序号 - 1
	if 上一首序号 <= 0:
		上一首序号 = 1
		print("当前为第一首歌")
	elif 上一首序号 >= 1:
		修改音频播放(上一首序号)
		当前播放序号-=1
		储存游戏()
func 下一首():
	var 下一首序号 = 当前播放序号 + 1
	if 下一首序号 > 当前CD总曲目数:
		当前播放序号 = 1
		修改音频播放(1)
		print("当前为最后一首")
	else:
		修改音频播放(下一首序号)
		当前播放序号+=1
		储存游戏()
func 重播():
	修改音频播放(当前播放序号)
var 歌名显示刷新 = true
func _process(delta: float) -> void:
	if 歌名显示刷新 == true:
		$"Panel/歌名显示".position.x -= 0.1
	$"唱片名".position = get_global_mouse_position()
	%"显示唱片名".text = 当前显示CD名
	%Label.text = 当前播放歌名
	#get_window().position += Vector2i(get_global_mouse_position())
	if !$音频播放.playing:
		$AnimationPlayer2.pause()
	else:
		$AnimationPlayer2.play()
var 正在拖拽 = false
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("鼠标右键"):
		正在拖拽 = true
	if event.is_action_released("鼠标右键"):
		正在拖拽 = false
	if event is InputEventMouseMotion and 正在拖拽:
		get_window().position += Vector2i(get_global_mouse_position())

func 播放() -> void:
	if $音频播放.playing == true:
		$音频播放.stream_paused = true
	else:
		$音频播放.stream_paused = false
	
func 文字离开(area: Area2D) -> void:
	歌名显示刷新 = false
	await get_tree().create_timer(1).timeout
	歌名显示刷新 = true
	$"Panel/歌名显示".position.x = 30

func 当前歌曲播放完成() -> void:
	if 单曲循环模式:
		重播()
	else:
		下一首()

func 切换单曲循环(toggled_on: bool) -> void:
	if !单曲循环模式:
		单曲循环模式 = true
		print("开启单曲循环")
	else:
		单曲循环模式 = false
		print("关闭单曲循环")
	单曲循环模式设置用 = 单曲循环模式
	储存游戏()

func 置顶窗口(toggled_on: bool) -> void:
	if get_window().always_on_top == true:
		get_window().always_on_top = false
	else:
		get_window().always_on_top = true

func 修改窗口大小(toggled_on: bool):
	if get_window().borderless == false:
		get_window().borderless = true
	else:
		get_window().borderless = false
	DisplayServer.window_set_size(Vector2(1100,380))

func 放大窗口() -> void:
	if 缩放倍率 < 1.5:
		缩放倍率+=0.25
		调整窗口大小()

func 缩小窗口() -> void:
	if 缩放倍率 > 0.5:
		缩放倍率-=0.25
		调整窗口大小()

func 调整窗口大小():
	DisplayServer.window_set_size(Vector2(1100*缩放倍率,380*缩放倍率))
	储存游戏()

func 储存游戏():
	var 配置文件 = ConfigFile.new()
	配置文件.set_value("设置","窗口缩放倍率",缩放倍率)
	配置文件.set_value("设置","选择的CD",插入的CD)
	配置文件.set_value("设置","播放序号",当前播放序号)
	配置文件.set_value("设置","单曲循环",单曲循环模式设置用)
	配置文件.save("user://设置.cfg")
	print("保存成功")
	
func 加载游戏():
	var 配置文件 = ConfigFile.new()
	var 读取结果 = 配置文件.load("user://设置.cfg")
	if 读取结果 == OK:
		缩放倍率 = 配置文件.get_value("设置","窗口缩放倍率")
		插入的CD = 配置文件.get_value("设置","选择的CD")
		当前播放序号 = 配置文件.get_value("设置","播放序号")
		单曲循环模式设置用 = 配置文件.get_value("设置","单曲循环")
		调整窗口大小()
