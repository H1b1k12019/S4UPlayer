@tool
extends Control

@export var CD本地化标签:String
@export var CD资源:CD
var CD名称

func _ready() -> void:
	if CD资源:
		CD名称 = CD资源.resource_path.get_basename().get_slice("/", 4)
		$"显示".texture = load("res://assets/texture/CD_side/"+CD名称+"side.png")

func 点击() -> void:
	print(CD名称)
	print(CD资源.歌单[0].歌曲名称)
	print(CD资源.歌单[0].歌曲文件)
	if get_parent().get_parent().插入的CD != CD资源:
		get_parent().get_parent().插入的CD = CD资源
		get_parent().get_parent().当前播放序号 = 1
		get_parent().get_parent().插入CD()

func 鼠标进入() -> void:
	$AnimationPlayer.play("选中")
	$"../../唱片名".show()
	#get_parent().get_parent().当前显示CD名 = CD名称
	#get_parent().get_parent().当前显示CD名 = CD资源.CD英文名称
	get_parent().get_parent().当前显示CD名 = CD本地化标签

func 鼠标离开() -> void:
	$AnimationPlayer.play("复原")
	$"../../唱片名".hide()

func _process(delta: float) -> void:
	if get_parent().get_parent().插入的CD == CD资源:
		self.hide()
	else:
		self.show()
