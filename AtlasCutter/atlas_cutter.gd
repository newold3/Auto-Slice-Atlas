@tool
extends EditorPlugin


func _enter_tree() -> void:
	
	var script = load("res://addons/AtlasCutter/cutter_sprite_2d.gd")
	var icon = load("res://addons/AtlasCutter/icon1.png")
	add_custom_type("CutterSprite2D", "Sprite2D", script, icon)
	script = load("res://addons/AtlasCutter/cutter_texture_button.gd")
	icon = load("res://addons/AtlasCutter/icon2.png")
	add_custom_type("CutterTextureButton", "TextureButton", script, icon)
	script = load("res://addons/AtlasCutter/cutter_texture_rect.gd")
	icon = load("res://addons/AtlasCutter/icon3.png")
	add_custom_type("CutterTextureRect", "TextureRect", script, icon)


func _exit_tree() -> void:
	remove_custom_type("CutterSprite2D")
	remove_custom_type("CutterTextureButton")
	remove_custom_type("CutterTextureRect")
