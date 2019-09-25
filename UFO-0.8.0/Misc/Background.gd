tool
extends Node2D

const Star = preload("res://Effects/Lights/distant_star.png")
const StarMaterial = preload("Star.tres")
const StarColors = preload("StarColors.tres")
const Nebulae = preload("Nebulae.tres")

export(float) var density = 0.01 setget set_density
export(float) var brightness = 0.2 setget set_brightness

var BackgroundNebulae : Sprite
var BackgroundStar : Sprite
var BackgroundStars : Texture

var stars = []
var star_number = round(randf() * 14 + 1)
onready var window_size  = get_viewport_rect().size

var scroll_x = 0.0;

func _ready():
	generate_star_background(window_size.x, window_size.y, density, brightness)
	
	for i in range(star_number):
		var pos = Vector2(rand_range(0,window_size.x), rand_range(0,window_size.y))
		var star = Sprite.new()
		star.texture = Star
		star.material = StarMaterial.duplicate()
		star.material.set_shader_param("coreColor", Color(1,1,1))
		star.material.set_shader_param("haloFalloff", 0.28)
		var color = StarColors.interpolate(randf())
		star.material.set_shader_param("haloColor", color)
		star.material.set_shader_param("coreRadius", 0.05)
		star.position = pos
		var scale = rand_range(0.5, 2)
		star.scale = Vector2(scale, scale)
		stars.append(star)
		add_child(star)

func generate_star_background(width, height, density, brightness):
	var count = round(width * height * density)
	var data = PoolByteArray()
	data.resize(width * height * 3)
	for i in count:
		var r = floor(randf() * width * height)
		var c = round(255 * log(1 - randf()) * -brightness)
		data[r * 3 + 0] = c
		data[r * 3 + 1] = c
		data[r * 3 + 2] = c
	
	if not BackgroundStars:
		BackgroundStars = ImageTexture.new()
	
	var image = Image.new()
	image.create_from_data(width, height, false, Image.FORMAT_RGB8, data)
	BackgroundStars.create_from_image(image, Texture.FLAG_REPEAT | Texture.FLAG_FILTER)
	
	if not BackgroundStar:
		BackgroundStar = Sprite.new()
		BackgroundStar.material = CanvasItemMaterial.new()
		BackgroundStar.material.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
		BackgroundStar.centered = false
		BackgroundStar.region_enabled = true
		add_child(BackgroundStar)
	BackgroundStar.region_rect = Rect2(Vector2(), Vector2(window_size.x * 2, window_size.y))
	BackgroundStar.texture = BackgroundStars
	
	if not BackgroundNebulae:
		BackgroundNebulae = Sprite.new()
		var material = Nebulae.duplicate()
		material.get_shader_param("color_map").noise.seed = randi()
		material.get_shader_param("density_map").noise.seed = randi()
		BackgroundNebulae.material = material
		BackgroundNebulae.centered = false
		BackgroundNebulae.region_enabled = true
		var texture = BackgroundNebulae.material.get_shader_param("density_map")
		BackgroundNebulae.texture = texture
		add_child(BackgroundNebulae)
	BackgroundNebulae.region_rect = Rect2(Vector2(), window_size)

func set_density(dens):
	density = dens
	if window_size:
		generate_star_background(window_size.x, window_size.y, density, brightness)

func set_brightness(bright):
	brightness = bright
	if window_size:
		generate_star_background(window_size.x, window_size.y, density, brightness)

func _process(delta):
	var window_size = get_viewport_rect().size
	scroll_x += delta * 50
	scroll_x = wrapf(scroll_x, 0, window_size.x)
	
	for star in stars:
		star.position.x += star.scale.x * 5
		if(star.position.x - star.scale.x*16 >= window_size.x):
			var color = preload("res://Misc/StarColors.tres").interpolate(randf())
			star.material.set_shader_param("haloColor", color)
			var scale = rand_range(0.5, 2)
			star.scale = Vector2(scale, scale)
			star.position.x = -scale*16
			star.position.y = rand_range(0, window_size.y)
	
	BackgroundStar.offset.x = scroll_x - window_size.x
	BackgroundNebulae.material.set_shader_param("offset", -scroll_x / window_size.x);
	update()
