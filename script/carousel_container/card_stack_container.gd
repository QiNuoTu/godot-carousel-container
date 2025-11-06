@tool
extends CarouselContainer
class_name CardStackContainer
## 卡片堆叠轮播容器，模拟卡片堆叠效果

@export_group("Card Stack")
## 堆叠的偏移量
@export var stack_offset: Vector2 = Vector2(10, 5)
## 最大堆叠数量
@export var max_stack_count: int = 5

func _update_child_position(child: Control, delta: float) -> void:
	var child_index = child.get_index()
	var distance_from_selected = _get_wrapped_distance(child_index, selected_index, true)
	_update_child_z_index(child, distance_from_selected)
	
	if child_index == selected_index:
		# 选中项在顶层中央
		var target_pos = -child.size * 0.5
		if !child.position.is_equal_approx(target_pos):
			child.position = lerp(child.position, target_pos, smoothing_speed * delta)
	else:
		# 非选中项堆叠排列
		var stack_index = min(abs(distance_from_selected), max_stack_count)
		var target_pos = (stack_offset * stack_index) - child.size * 0.5
		if !child.position.is_equal_approx(target_pos):
			child.position = lerp(child.position, target_pos, smoothing_speed * delta)
	_update_child_scale(child, distance_from_selected, delta)
	_update_child_opacity(child, distance_from_selected, delta)
	_update_child_rotation(child, distance_from_selected, delta)
