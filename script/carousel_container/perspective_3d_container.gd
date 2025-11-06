@tool
extends CarouselContainer
class_name Perspective3DContainer
## 3D透视效果轮播容器，模拟3D空间中的排列

@export_group("3D Perspective")
## 水平偏移系数
@export var horizontal_offset: float = 500.0
## 垂直偏移系数
@export var vertical_offset: float = 100.0

func _update_child_position(child: Control, delta: float) -> void:
	var child_count = get_child_count()
	var child_index = child.get_index()
	var distance_from_selected = _get_wrapped_distance(child_index, selected_index, false)
	_update_child_z_index(child, distance_from_selected)
	var normalized_distance = float(distance_from_selected) / max(1, child_count)

	var x = normalized_distance * horizontal_offset
	var y = abs(normalized_distance) * vertical_offset

	var target_pos = Vector2(x, y) - child.size * 0.5
	if !child.position.is_equal_approx(target_pos):
		child.position = lerp(child.position, target_pos, smoothing_speed * delta)
	_update_child_scale(child, distance_from_selected, delta)
	_update_child_opacity(child, distance_from_selected, delta)
	_update_child_rotation(child, distance_from_selected, delta)
