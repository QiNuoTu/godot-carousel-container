@tool
extends CarouselContainer
class_name SpiralContainer
## 螺旋形轮播布局容器，提供平滑动画和丰富的视觉效果[[br][br]
## SpiralContainer是一种将控件根据螺旋轨迹排列和切换的容器

@export_group("Spiral")
## 螺旋起始半径
@export var spiral_start_radius: float = 1.5
## 螺旋每圈的半径增量
@export var spiral_radius_increment: float = 1.5
## 螺旋的角度增量（每项之间的角度差）
@export_range(-PI, PI, 0.001) var spiral_angle_increment: float = PI * 1.3
## 子项之间的间距
@export var spacing: float = 25.0

## 已实现螺旋形轮播
func _update_child_position(child: Control, delta: float) -> void:
	var child_index = child.get_index()
	var distance_from_selected = _get_wrapped_distance(child_index, selected_index, false)
	_update_child_z_index(child, distance_from_selected)
	
	var angle = child_index * spiral_angle_increment
	var radius = spiral_start_radius + child_index * spiral_radius_increment
	var x = cos(angle) * radius * spacing
	var y = sin(angle) * radius * spacing
	var target_pos = Vector2(x, y) - child.size * 0.5
	if !child.position.is_equal_approx(target_pos):
		child.position = lerp(child.position, target_pos, smoothing_speed * delta)
	
	_update_child_scale(child, distance_from_selected, delta)
	_update_child_opacity(child, distance_from_selected, delta)
	_update_child_rotation(child, distance_from_selected, delta)
