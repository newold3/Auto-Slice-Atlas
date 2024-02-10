@tool
extends TextureRect


@export var rects: Array[Rect2]


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
		if texture:
			set("main_texture", texture)
			update_rects()

## Change the frame displayed
@export var current_frame: int = 0:
	set(value):
		current_frame = max(0, min(value, rects.size() - 1))
		update()


func _ready() -> void:
	set_editor_description("Auto divides an image into frames using the transperency of the image to determine the frames.")


func update_rects() -> void:
	if !main_texture or !main_texture.get_image(): return
	
	rects.clear()
	
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
		
		rects.append(Rect2(Vector2(xi, yi), Vector2(xf-xi, yf-yi)))
	
	if !texture or !texture is AtlasTexture:
		texture = AtlasTexture.new()
		texture.set_local_to_scene(true)
		notify_property_list_changed()
		texture.atlas = main_texture

	main_texture = null

	current_frame = 0
	
	print("Texture %s created with %s frames" % [texture.get_path(), rects.size()])


func update() -> void:
	if texture and texture is AtlasTexture and rects and rects.size() > current_frame:
		var rect = rects[current_frame]
		texture.set_region(rect)
		texture = texture.duplicate()
		notify_property_list_changed()


func _validate_property(property):
	if property.name == "rects":
		property.usage &= ~PROPERTY_USAGE_EDITOR
