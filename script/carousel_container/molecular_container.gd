@tool
extends CarouselContainer
class_name MolecularContainer
## 分子运动轮播容器，模拟分子在容器中的随机运动

@export_group("Molecular Motion")
## 运动半径
@export var motion_radius: float = 150.0
## 运动速度
@export var motion_speed: float = 2.0
## 是否启用随机运动
@export var random_motion: bool = true
## 子项之间的间距
@export var spacing: float = 1.0

var _motion_offsets: Array[Vector2] = []
var _motion_angles: Array[float] = []

func _update_child_position(child: Control, delta: float) -> void:
	var child_count = get_child_count()
	var child_index = child.get_index()
	var distance_from_selected = _get_wrapped_distance(child_index, selected_index, true)
	_update_child_z_index(child, distance_from_selected)
	
	if _motion_offsets.size() != child_count:
		_motion_offsets.clear()
		_motion_angles.clear()
		for i in child_count:
			_motion_offsets.append(Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized() * motion_radius)
			_motion_angles.append(randf_range(-TAU, TAU))
	
	var base_pos = Vector2.ZERO
	if random_motion:
		# 更新运动角度
		_motion_angles[child_index] += motion_speed * delta
		var motion_offset = _motion_offsets[child_index] * sin(_motion_angles[child_index])
		base_pos += motion_offset
	
	# 根据距离添加额外偏移
	var distance_offset = Vector2(distance_from_selected * spacing, 0)
	var target_pos = base_pos + distance_offset - child.size * 0.5
	if !child.position.is_equal_approx(target_pos):
		child.position = lerp(child.position, target_pos, smoothing_speed * delta)
	
	_update_child_scale(child, distance_from_selected, delta)
	_update_child_opacity(child, distance_from_selected, delta)
	_update_child_rotation(child, distance_from_selected, delta)
