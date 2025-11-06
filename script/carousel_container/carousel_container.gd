@tool
extends Container
class_name CarouselContainer
## 轮播布局容器基[br][br]
## CarouselContainer提供平滑动画和丰富视觉效果功能，该类必须被继承，实现自己的轮播容器

@export_group("Visual Effects")
## 透明度变化强度（距离越远越透明）
@export_range(0.0, 1.0) var opacity_strength: float = 0.35
## 缩放变化强度（距离越远越小）
@export_range(0.0, 1.0) var scale_strength: float = 0.25
## 最小缩放比例
@export_range(0.01, 0.99, 0.01) var scale_min: float = 0.1
## 旋转强度（距离越远旋转角度越大）
@export_range(-TAU, TAU, 0.001, "radians_as_degrees", "or_greater", "or_less") var rotation_strength: float = 0.0

@export_group("Animation")
## 平滑动画速度
@export var smoothing_speed: float = 6.5
## 当前选中项的索引
@export var selected_index: int = 0: 
	set(v):
		var new_index = clamp(v, 0, get_child_count() - 1)
		if selected_index != new_index:
			selected_index = new_index
			if selected_index_changed.has_connections():
				selected_index_changed.emit(selected_index)
			var selected_child = get_selected_child()
			if selected_child and item_selected.has_connections():
				item_selected.emit(selected_child)

## 是否启用内置输入屏蔽
@export var block_input: bool = true
## 是否跟随按钮焦点自动选择
@export var follow_button_focus: bool = false

@export_group("Signals")

## 选中索引改变时触发
signal selected_index_changed(index: int)
## 项被选中时触发
signal item_selected(item: Control)

var _selected_index: int = 0

## 该函数必须被子类实现，更新单个子项的位置
@warning_ignore("unused_parameter")
func _update_child_position(child: Control, delta: float) -> void:
	pass

## 处理每帧更新
func _process(delta: float) -> void:
	var child_count = get_child_count()
	if child_count == 0 and selected_index == _selected_index:
		return
	selected_index = clamp(selected_index, 0, child_count - 1)
	_selected_index = selected_index
	for child in get_children():
		_update_child_position(child, delta)
		_handle_button_focus(child)
		_update_child_optional_state(child)
		
## 更新子项的可选状态（输入阻塞和焦点管理）
func _update_child_optional_state(child: Control) -> void:
	if !block_input:
		return
	
	var is_selected = (child.get_index() == selected_index)
	
	# 设置鼠标和键盘输入的可访问性
	child.mouse_filter = Control.MOUSE_FILTER_STOP if is_selected else Control.MOUSE_FILTER_IGNORE
	child.focus_mode = Control.FOCUS_ALL if is_selected else Control.FOCUS_NONE
	# 如果当前子项被选中且有焦点跟随，确保它获得焦点
	if is_selected and follow_button_focus and not child.has_focus():
		child.grab_focus()

## 更新子项的缩放效果
func _update_child_scale(child: Control, distance: float, delta: float) -> void:
	var target_scale = 1.0 - (scale_strength * abs(distance))
	target_scale = Vector2.ONE * clamp(target_scale, scale_min, 1.0)
	if !child.scale.is_equal_approx(target_scale):
		child.pivot_offset = child.size * 0.5
		child.scale = lerp(child.scale, target_scale, smoothing_speed * delta)

## 更新子项的透明度效果
func _update_child_opacity(child: Control, distance: float, delta: float) -> void:
	var target_alpha = 1.0 - (opacity_strength * abs(distance))
	target_alpha = clamp(target_alpha, 0.1, 1.0)
	if !is_equal_approx(child.modulate.a, target_alpha):
		child.modulate.a = lerp(child.modulate.a, target_alpha, smoothing_speed * delta)

## 更新子项的旋转效果
func _update_child_rotation(child: Control, distance: float, delta: float) -> void:
	if abs(rotation_strength) > 0:
		var target_rotation = distance * rotation_strength
		if !is_equal_approx(child.rotation, target_rotation):
			child.rotation = lerp(child.rotation, target_rotation, smoothing_speed * delta)
	else:
		if !is_equal_approx(child.rotation, 0.0):
			child.rotation = lerp(child.rotation, 0.0, smoothing_speed * delta)

## 更新子项的Z轴索引（层级）
func _update_child_z_index(child: Control, distance: float) -> void:
	child.z_index = get_child_count() + 1 if child.get_index() == selected_index else max(1, get_child_count() - abs(distance))

## 处理按钮焦点跟随
func _handle_button_focus(child: Control) -> void:
	if follow_button_focus and child.has_focus():
		selected_index = child.get_index()

## 获取环绕距离
func _get_wrapped_distance(from_index: int, to_index: int, full_surround: bool = true) -> float:
	var total_count = get_child_count()
	if total_count <= 1:
		return 0.0
	return _get_full_surround_distance(to_index - from_index, total_count) if full_surround else float(to_index - from_index)

## 获取完全环绕模式下的距离
func _get_full_surround_distance(direct_distance: int, total_count: int) -> float:
	var half_count = total_count * 0.5
	var wrapped_distance = direct_distance
	
	if abs(direct_distance) > half_count:
		if direct_distance > 0:
			wrapped_distance = direct_distance - total_count
		else:
			wrapped_distance = direct_distance + total_count
	
	return wrapped_distance

## 获取最短路径方向
func _get_shortest_path_direction(from_index: int, to_index: int, total_count: int) -> float:
	if total_count <= 1:
		return 1.0
	
	var direct_distance = to_index - from_index
	var half_count = total_count
	
	if abs(direct_distance) <= half_count:
		return 1.0 if direct_distance != 0 else sign(direct_distance)
	else:
		return -sign(direct_distance)

## 选择前一个项
func select_previous() -> void:
	var child_count = get_child_count()
	if child_count == 0:
		return
	selected_index = (selected_index - 1 + child_count) % child_count

## 选择下一个项
func select_next() -> void:
	var child_count = get_child_count()
	if child_count == 0:
		return
	selected_index = (selected_index + 1) % child_count

## 获取当前选中的子项
func get_selected_child() -> Control:
	if selected_index < 0 or selected_index >= get_child_count():
		return null
	return get_child(selected_index)

## 获取子项数量
func get_count() -> int:
	return get_child_count()

## 添加子项
func add_item(item: Control) -> void:
	add_child(item)

## 移除子项
func remove_item(item: Control) -> void:
	if item in get_children():
		remove_child(item)

## 清空所有子项
func clear_items() -> void:
	for child in get_children():
		remove_child(child)
