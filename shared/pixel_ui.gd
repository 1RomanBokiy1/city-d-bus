extends Node

# Shared button styling helper (pixel-like, Aurora palette).
class_name PixelUI

static func style_button(button: Button, primary: bool = false, compact: bool = false) -> void:
	if button == null:
		return

	var fg = Color(0.07, 0.14, 0.20, 1.0)
	var primary_bg = Color(0.17, 0.68, 0.67, 1.0)
	var secondary_bg = Color(0.84, 0.93, 0.95, 0.95)
	var border = Color(0.11, 0.43, 0.48, 1.0)

	var normal = StyleBoxFlat.new()
	normal.bg_color = primary_bg if primary else secondary_bg
	normal.border_color = border
	normal.border_width_left = 4
	normal.border_width_top = 4
	normal.border_width_right = 4
	normal.border_width_bottom = 4
	normal.corner_radius_top_left = 2
	normal.corner_radius_top_right = 2
	normal.corner_radius_bottom_left = 2
	normal.corner_radius_bottom_right = 2
	normal.shadow_color = Color(0, 0, 0, 0.25)
	normal.shadow_size = 3
	normal.shadow_offset = Vector2(2, 2)

	var hover = normal.duplicate()
	hover.bg_color = normal.bg_color.lightened(0.08)

	var pressed = normal.duplicate()
	pressed.bg_color = normal.bg_color.darkened(0.15)
	pressed.shadow_size = 0
	pressed.content_margin_left += 1
	pressed.content_margin_top += 1

	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)

	button.add_theme_color_override("font_color", fg)
	button.add_theme_color_override("font_hover_color", fg)
	button.add_theme_color_override("font_pressed_color", fg)

	if compact:
		button.add_theme_font_size_override("font_size", 30)
	else:
		button.add_theme_font_size_override("font_size", 58 if primary else 46)

