tool
extends Node2D

export (Texture) var DistantStar = preload("res://Effects/Lights/distant_star.png")
export (Texture) var CloseupStar = preload("res://Effects/Lights/closup_star.png")

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

onready var window_size = get_viewport_rect().size

func _ready():
	generate_star_background(window_size.x, window_size.y, density, brightness)
	
	var star = Sprite.new()
	star.texture = Star
	star.material = StarMaterial.duplicate()
	star.material.set_shader_param("coreColor", Color(1,1,1))
	star.material.set_shader_param("haloFalloff", 0.28)
	star.material.set_shader_param("haloColor", Color(1,1,1))
	star.material.set_shader_param("coreRadius", 0.6)
	star.position = window_size / 2
	star.scale = Vector2(40, 40) * (window_size.y / 1280)
	stars.append(star)
	add_child(star)
	
	var star_number = rand_range(3, 10)
	for i in range(star_number):
		var pos = Vector2(rand_range(0, window_size.x),
				rand_range(0, window_size.y))
		var back_star = Sprite.new()
		back_star.texture = Star
		back_star.material = StarMaterial.duplicate()
		back_star.material.set_shader_param("coreColor", Color(1,1,1))
		back_star.material.set_shader_param("haloFalloff", 0.28)
		var color = StarColors.interpolate(randf())
		back_star.material.set_shader_param("haloColor", color)
		back_star.material.set_shader_param("coreRadius", 0.05)
		back_star.position = pos
		var scale = rand_range(0.5, 2)
		back_star.scale = Vector2(scale, scale)
		stars.append(back_star)
		add_child(back_star)

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
	window_size = get_viewport_rect().size
	
	var noise = OpenSimplexNoise.new()
	noise.seed = 1400
	var newFalloff = noise.get_noise_2d(OS.get_ticks_msec() * 0.1, 1.0)
	newFalloff = range_lerp(newFalloff, 0, 1, 0.2, 0.3)
	stars[0].material.set_shader_param("haloFalloff", newFalloff)