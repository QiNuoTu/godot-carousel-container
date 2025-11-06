@tool
extends CarouselContainer
class_name VCircularContainer
## 纵向圆形轮播布局容器，提供平滑动画和丰富的视觉效果[br][br]
## VCircularContainer是一种将控件根据圆形纵向排列和切换的容器

@export_group("Wraparound")
## 环绕的弧度范围
@export_range(-TAU, TAU, 0.001, "or_greater", "or_less") var wraparound_radian: float = TAU
## 环绕半径
@export var wraparound_radius: float = 300.0
## 环绕高度
@export var wraparound_height: float = 0.0
## 子项之间的间距
@export var spacing: float = 1.0
## 是否偏离中心环绕
@export var wraparound_off_centre:  bool = false
## 首尾相连
@export var end_to_end: bool = true

## 已实现圆形轮播
func _update_child_position(child: Control, delta: float) -> void:
	var child_count = get_child_count()
	var child_index = child.get_index()
	var distance_from_selected = _get_wrapped_distance(child_index, selected_index, end_to_end)
	_update_child_z_index(child, distance_from_selected)
	var angle_step = wraparound_radian / child_count
	var angle_offset = distance_from_selected * angle_step
	
	if child_count > 1:
		var shortest_path = _get_shortest_path_direction(child_index, selected_index, child_count)
		angle_offset *= shortest_path
	
	var spacing_adjustment = distance_from_selected * spacing if wraparound_off_centre else spacing
	var x = cos(angle_offset) * wraparound_height
	var y = sin(angle_offset) * (wraparound_radius + spacing_adjustment)
	
	var target_pos = Vector2(x - wraparound_height, y) - child.size * 0.5
	if !child.position.is_equal_approx(target_pos):
		child.position = lerp(child.position, target_pos, smoothing_speed * delta)
	
	_update_child_scale(child, distance_from_selected, delta)
	_update_child_opacity(child, distance_from_selected, delta)
	_update_child_rotation(child, distance_from_selected, delta)
