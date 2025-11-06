@tool
extends CarouselContainer
class_name GridCarouselContainer
## 网格轮播布局容器，提供平滑动画和丰富的视觉效果[br][br]
## GridCarouselContainer是一种将控件根据网格排列和切换的容器

@export_group("Grid")
## 网格的列数
@export var grid_columns: int = 3
## 网格单元格宽度
@export var cell_width: float = 100.0
## 网格单元格高度
@export var cell_height: float = 100.0

## 已实现网格轮播
func _update_child_position(child: Control, delta: float) -> void:
	var child_index = child.get_index()
	var distance_from_selected = -_get_wrapped_distance(child_index, selected_index, false)
	_update_child_z_index(child, distance_from_selected)
	# 计算网格偏移，使选中项在中心
	var offset_x = ((child_index % grid_columns) - (selected_index % grid_columns)) * cell_width
	@warning_ignore("integer_division")
	var offset_y = ((child_index / grid_columns) - (selected_index / grid_columns)) * cell_height
	
	var target_pos = Vector2(offset_x, offset_y) - child.size * 0.5
	if !child.position.is_equal_approx(target_pos):
		child.position = lerp(child.position, target_pos, smoothing_speed * delta)
	
	_update_child_scale(child, distance_from_selected, delta)
	_update_child_opacity(child, distance_from_selected, delta)
	_update_child_rotation(child, distance_from_selected, delta)
