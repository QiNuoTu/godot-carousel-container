@tool
extends CarouselContainer
class_name VWaveContainer
## 纵向波浪形轮播布局容器，提供平滑动画和丰富的视觉效果[br][br]
## VWaveContainer是一种将控件根据波浪轨迹排列和切换的容器

@export_group("Wave")

## 波浪的振幅
@export var wave_amplitude: float = 100.0
## 波浪的频率
@export var wave_frequency: float = 2.0
## 波浪的水平间距
@export var wave_spacing: float = 80.0
## 首尾相连
@export var end_to_end: bool = false

## 已实现波浪形轮播
func _update_child_position(child: Control, delta: float) -> void:
	var child_count = get_child_count()
	var child_index = child.get_index()
	var distance_from_selected = _get_wrapped_distance(child_index, selected_index, end_to_end)
	_update_child_z_index(child, distance_from_selected)
	
	var y = distance_from_selected * wave_spacing
	var phase = float(child_index) / max(1, child_count - 1) * TAU * wave_frequency
	var x = sin(phase) * wave_amplitude
	
	var target_pos = Vector2(x, y) - child.size * 0.5
	if !child.position.is_equal_approx(target_pos):
		child.position = lerp(child.position, target_pos, smoothing_speed * delta)
	
	_update_child_scale(child, distance_from_selected, delta)
	_update_child_opacity(child, distance_from_selected, delta)
	_update_child_rotation(child, distance_from_selected, delta)
