@tool
extends Control
@export var carousel_container: CarouselContainer

var timer_delta: float = 0.0

func _process(delta: float) -> void:
	timer_delta += delta
	if carousel_container and timer_delta > 0.5:
		timer_delta = 0.0
		carousel_container.select_next()
