@tool
extends TextureButton


@export var rects: Dictionary = {
	"normal_rects" = [],
	"pressed_rects" = [],
	"hover_rects" = [],
	"disabled_rects" = [],
	"focused_rects" = []
}


@export_category("Cutter Data")
## Atlas texture (each image must be separated by transparency)
@export var main_texture: Texture2D:
	set(value):
		main_texture = value
		update_rects()

## epsilon is passed to RDP to control how accurately the polygons cover the bitmap: a lower epsilon corresponds to more points in the polygons.
@export var epsilon: float = 1.0:
	set(value):
		epsilon = value
		var tex = texture_normal.atlas	if target == 0 and texture_normal and texture_normal is AtlasTexture		\
		else texture_pressed.atlas		if target == 1 and texture_pressed and texture_pressed is AtlasTexture 		\
		else texture_hover.atlas		if target == 2 and texture_hover and texture_hover is AtlasTexture 			\
		else texture_disabled.atlas		if target == 3 and texture_disabled and texture_disabled is AtlasTexture 	\
		else texture_focused.atlas		if target == 4 and texture_focused and texture_focused is AtlasTexture 		\
		else null
		if tex:
			set("main_texture", tex)
			update_rects()

@export_enum("Normal Texture", "Pressed Texture", "Hover Texture", "Disabled Texture", "Focused Texture") var target = 0:
	set(value):
		target = value


@export_category("Texture Selected Frames")

@export var current_normal_frame: int = 0:
	set(value):
		current_normal_frame = max(0, min(value, rects.normal_rects.size() - 1))
		update(0)

@export var current_pressed_frame: int = 0:
	set(value):
		current_pressed_frame = max(0, min(value, rects.pressed_rects.size() - 1))
		update(1)

@export var current_hover_frame: int = 0:
	set(value):
		current_hover_frame = max(0, min(value, rects.hover_rects.size() - 1))
		update(2)

@export var current_disabled_frame: int = 0:
	set(value):
		current_disabled_frame = max(0, min(value, rects.disabled_rects.size() - 1))
		update(3)

@export var current_focused_frame: int = 0:
	set(value):
		current_focused_frame = max(0, min(value, rects.focused_rects.size() - 1))
		update(4)


var refresh_delay_timer: float = 0.0


func _ready() -> void:
	set_editor_description("Auto divides an image into frames using the transperency of the image to determine the frames.")


func update_rects() -> void:
	if !main_texture or !main_texture.get_image(): return

	var current_rects
	if target == 0:
		current_rects = rects.normal_rects
	elif target == 1:
		current_rects = rects.pressed_rects
	elif target == 2:
		current_rects = rects.hover_rects
	elif target == 3:
		current_rects = rects.disabled_rects
	elif target == 4:
		current_rects = rects.focused_rects
	
	current_rects.clear()
	
	var bitmap = BitMap.new()
	var image = main_texture.get_image()

	bitmap.create_from_image_alpha(image)
	var polygons = bitmap.opaque_to_polygons(Rect2(Vector2(), bitmap.get_size()), epsilon)

	for polygon in polygons:
		var xi = INF
		var yi = INF
		var xf = -INF
		var yf = -INF
		for vector in polygon:
			xi = min(xi, vector.x)
			yi = min(yi, vector.y)
			xf = max(xf, vector.x)
			yf = max(yf, vector.y)
		
		current_rects.append(Rect2(Vector2(xi, yi), Vector2(xf-xi, yf-yi)))
	
	if target == 0:
		if !texture_normal or !texture_normal is AtlasTexture:
			texture_normal = AtlasTexture.new()
			texture_normal.set_local_to_scene(true)
			notify_property_list_changed()
		texture_normal.atlas = main_texture
		current_normal_frame = 0
	elif target == 1:
		if !texture_pressed or !texture_pressed is AtlasTexture:
			texture_pressed = AtlasTexture.new()
			texture_pressed.set_local_to_scene(true)
			notify_property_list_changed()
		texture_pressed.atlas = main_texture
		current_pressed_frame = 0
	elif target == 2:
		if !texture_hover or !texture_hover is AtlasTexture:
			texture_hover = AtlasTexture.new()
			texture_hover.set_local_to_scene(true)
			notify_property_list_changed()
		texture_hover.atlas = main_texture
		current_hover_frame = 0
	elif target == 3:
		if !texture_disabled or !texture_disabled is AtlasTexture:
			texture_disabled = AtlasTexture.new()
			texture_disabled.set_local_to_scene(true)
			notify_property_list_changed()
		texture_disabled.atlas = main_texture
		current_disabled_frame = 0
	elif target == 4:
		if !texture_focused or !texture_focused is AtlasTexture:
			texture_focused = AtlasTexture.new()
			texture_focused.set_local_to_scene(true)
			notify_property_list_changed()
		texture_focused.atlas = main_texture
		current_focused_frame = 0
	
	print("Texture %s created with %s frames" % [main_texture.get_path(), rects.size()])
	
	main_texture = null


func update(_target: int) -> void:
	var current_rect
	var current_texture
	var temp_image = ImageTexture.new()
	var cache
	
	if _target == 0:
		current_rect = rects.normal_rects[current_normal_frame]
		current_texture = texture_normal
	elif _target == 1:
		current_rect = rects.pressed_rects[current_pressed_frame]
		current_texture = texture_pressed
	elif _target == 2:
		current_rect = rects.hover_rects[current_hover_frame]
		current_texture = texture_hover
	elif _target == 3:
		current_rect = rects.disabled_rects[current_disabled_frame]
		current_texture = texture_disabled
	elif _target == 4:
		current_rect = rects.focused_rects[current_focused_frame]
		current_texture = texture_focused
		
	if current_texture is AtlasTexture and current_rect:
		current_texture.set_region(current_rect)
		# Godot no refresh inspector texture in Atlas (bug??) this is the current solution v
		if _target == 0:
			texture_normal = current_texture.duplicate()
		elif _target == 1:
			texture_pressed = current_texture.duplicate()
		elif _target == 2:
			texture_hover = current_texture.duplicate()
		elif _target == 3:
			texture_disabled = current_texture.duplicate()
		elif _target == 4:
			texture_focused = current_texture.duplicate()
		notify_property_list_changed()


func _validate_property(property):
	if property.name == "rects":
		property.usage &= ~PROPERTY_USAGE_EDITOR

