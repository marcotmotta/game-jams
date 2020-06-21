extends KinematicBody2D

export (int) var max_health = 1650

onready var health = max_health

var is_aiming = false
var is_dashing = false
var dash_damage = 15
var dash_speed = 1500
var dash_target
var dash_delay = 0.5
var dash_direction
var time_out = false
var phase = 1
var rate1 = [2, 2.5, 3]
var rate2 = [1.5, 2]
var color = Color(1, 0.819608, 0)

func _ready():
	randomize()
	$CanvasLayer/HealthBar.max_value = max_health
	$CanvasLayer/HealthBar.value = health

func _process(delta):
	$CanvasLayer/HealthBar.value = health

	get_parent().get_node('Player').available_weapons = 2

	if not is_dashing and not is_aiming:
		look_at(get_parent().get_node('Player').get_global_position())

func _physics_process(delta):
	if is_dashing:
		dash_direction = (dash_target - self.get_global_position()).normalized()
		move_and_slide(dash_direction * dash_speed)
		if (dash_target.x < self.get_global_position().x + 100 \
			and dash_target.x > self.get_global_position().x - 100) \
			and (dash_target.y < self.get_global_position().y + 100 \
			and dash_target.y > self.get_global_position().y - 100):
			is_dashing = false
			$Particles2D.process_material.color = color
			$Particles2D.process_material.scale = 8

func take_damage(dmg):
	health -= dmg
	if health <= 0:
		get_tree().change_scene("res://FamineDialogue.tscn")
		pass
	elif health <= max_health/2:
		phase = 2
		color = Color(0, 0, 0)
		dash_delay = 0.15
		dash_speed = 1800

func _on_Timer_timeout():
	is_aiming = true
	$Particles2D.process_material.color = Color(0.617188, 0, 0)
	$Particles2D.process_material.scale = 16
	dash_target = get_parent().get_node('Player').get_global_position()
	yield(get_tree().create_timer(dash_delay), "timeout")
	$Attack.play()
	is_dashing = true
	is_aiming = false
	match phase:
		2:
			$Timer.wait_time = choose(rate2)
		_:
			$Timer.wait_time = choose(rate1)

func _on_HitBox_body_entered(body):
	if body.is_in_group('player') and time_out == false:
		body.take_damage(dash_damage)
		var rand_position = Vector2(randi() % 1280, randi() % 720)
		rand_position.x = 50 if rand_position.x < 50 \
			else 1230 if rand_position.x > 1230 else rand_position.x
		rand_position.y = 50 if rand_position.y < 50 \
			else 670 if rand_position.y > 670 else rand_position.y
		is_aiming = false
		is_dashing = false
		$Particles2D.process_material.color = Color(1, 1, 1)
		$Timer.wait_time = choose([3])
		time_out = true
		position = rand_position
		yield(get_tree().create_timer(1), "timeout")
		$Particles2D.process_material.color = color
		$Particles2D.process_material.scale = 8
		time_out = false
		$HitBox/CollisionShape2D.disabled = true
		$HitBox/CollisionShape2D.disabled = false

func choose(array):
	array.shuffle()
	return array.front()
