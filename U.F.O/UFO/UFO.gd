extends RigidBody2D

signal powered_up(icon) # signal emitted via Powerup.gd
signal damage_taken(hp)
signal killed(pos)

var dead = false
var hit_pass_time = 0.01
var out_of_bounds = false

onready var tween = $Tween

export (float) var radius = 70 setget set_radius
export (int) var max_health = 100
export (float) var health_points = 100 setget set_health_points
export (float, 0.1, 9999) var defense = 40
export (Vector2) onready var spawn_point = get_viewport_rect().size / 2

var prev_velocity : Vector2 = Vector2()

var default_glow = Color(0.6, 0.9, 0.9, 0.4)

func _ready():
	$SpriteGlow.modulate = default_glow
	global_position = spawn_point

func _physics_process(delta):
	hit_pass_time += delta
	prev_velocity = linear_velocity
	$OutOfBoundsField.modulate.a = min($OutOfBoundsField.modulate.a, 1)

func set_radius(rad):
	radius = rad
	if has_node("CollisionShape2D"): $CollisionShape.shape.radius = radius
	if has_node("IsVisible"): $IsVisible.rect = Rect2(-rad, -rad, rad*2, rad*2)
	if has_node("Sprite"): $Sprite.scale = Vector2(1,1) * rad/256.0
	if has_node("SpriteGlow"): $SpriteGlow.scale = Vector2(1,1) * rad/256.0
	if has_node("OutOfBoundsField"): $OutOfBoundsField.scale = Vector2(1,1) * rad/128.0 * 1.4

func push_UFO(pos, strength):
	var pulse = (global_position - pos).normalized()
	apply_impulse(Vector2(), pulse*strength)

func set_health_points(health):
	health_points = health
	emit_signal("damage_taken", health_points)

func take_damage(HP_loss):
	health_points -= HP_loss / defense
	emit_signal("damage_taken", health_points)
	
	if health_points <= 0 and not dead: kill()

func play_collision_sound(volume):
	$CollisionSound.set_volume_db(volume)
	$CollisionSound.play()

func kill():
	dead = true
	$CollisionShape2D.queue_free()
	tween.interpolate_property(self, "modulate", Color(1,1,1,1), Color(1,0,0,1), 0.5, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.interpolate_deferred_callback(self, 0.5, "queue_free")
	tween.start()
	
	emit_signal("killed", global_position)

func is_ufo():
	pass

func _on_collision(body : Node):
	if body.has_method("is_asteroid") and not dead:
		var HP_lost : float = linear_velocity.distance_to(prev_velocity)
		take_damage(HP_lost)
		
		play_collision_sound(linear2db(mass))
		hit_pass_time = 0

func _on_IsVisible_screen_exited():
	out_of_bounds = true
	take_damage(max_health / 10 * defense)
	
	if not dead:
		tween.interpolate_property(self, "global_position", global_position,
				spawn_point, 0.5, Tween.TRANS_BACK, Tween.EASE_OUT)
		tween.interpolate_property($OutOfBoundsField, "modulate", Color(1,1,1,8),
				Color(1,1,1,0), 0.5, Tween.TRANS_QUINT, Tween.EASE_OUT)
		tween.interpolate_property(self, "out_of_bounds", true, false, 0.5,
				Tween.TRANS_BACK, Tween.EASE_IN)
		tween.interpolate_deferred_callback($CollisionShape2D, 0.5, "set_disabled", false)
		$CollisionShape2D.disabled = true
		linear_velocity *= 0
		tween.start()
		$OutOfBoundsField/OOBSound.play()