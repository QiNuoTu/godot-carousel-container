@tool
extends CarouselContainer
class_name VLinearContainer
## 纵向轮播布局容器，提供平滑动画和丰富的视觉效果[br][br]
## VLinearContainer是一种将控件根据直线纵向排列和切换的容器。

@export_group("VLinear")
## 子项之间的间距
@export var spacing: float = 1.0

## 已实现纵向轮播
func _update_child_position(child: Control, delta: float) -> void:
	var child_index = child.get_index()
	var distance_from_selected = _get_wrapped_distance(child_index, selected_index, false)
	_update_child_z_index(child, distance_from_selected)
	var target_pos = Vector2(0, (child_index - selected_index) * (child.size.y + spacing)) - child.size * 0.5
	if !child.position.is_equal_approx(target_pos):
		child.position = lerp(child.position, target_pos, smoothing_speed * delta)
	_update_child_scale(child, distance_from_selected, delta)
	_update_child_opacity(child, distance_from_selected, delta)
	_update_child_rotation(child, distance_from_selected, delta)
