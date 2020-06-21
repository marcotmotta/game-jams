extends KinematicBody2D

var arrow = preload("res://ConquestArrow.tscn")

export (int) var max_health = 1700

onready var health = max_health

var arrow_damage = 15
var arrow_speed = 800
var phase = 1
var rate1 = [1.5, 2, 2.5]
var rate2 = [1.5, 1.5, 1.5, 2]

func _ready():
	randomize()
	$CanvasLayer/HealthBar.max_value = max_health
	$CanvasLayer/HealthBar.value = health

func _process(delta):
	$CanvasLayer/HealthBar.value = health

	get_parent().get_node('Player').available_weapons = 1
	look_at(get_parent().get_node('Player').get_global_position())

func shoot_arrow():
	$Attack.play()
	var arrow_instance = arrow.instance()
	arrow_instance.damage = arrow_damage
	arrow_instance.speed = arrow_speed
	arrow_instance.target = 'player'
	arrow_instance.friends = 'conquest'
	arrow_instance.position = $ShootPosition.get_global_position()
	arrow_instance.direction = \
		(arrow_instance.position - \
		self.get_global_position()).normalized()
	get_parent().add_child(arrow_instance)
	if phase == 2:
		var arrow_instance2 = arrow.instance()
		arrow_instance2.damage = arrow_damage
		arrow_instance2.speed = arrow_speed
		arrow_instance2.target = 'player'
		arrow_instance2.friends = 'conquest'
		arrow_instance2.position = $ShootPosition.get_global_position()
		arrow_instance2.direction = \
			(arrow_instance2.position - \
			self.get_global_position()).normalized().rotated(0.5)
		get_parent().add_child(arrow_instance2)
		var arrow_instance3 = arrow.instance()
		arrow_instance3.damage = arrow_damage
		arrow_instance3.speed = arrow_speed
		arrow_instance3.target = 'player'
		arrow_instance3.friends = 'conquest'
		arrow_instance3.position = $ShootPosition.get_global_position()
		arrow_instance3.direction = \
			(arrow_instance3.position - \
			self.get_global_position()).normalized().rotated(-0.5)
		get_parent().add_child(arrow_instance3)

func _on_Timer_timeout():
	$AnimatedSprite.play('attack')
	match phase:
		2:
			$Timer.wait_time = choose(rate2)
		_:
			$Timer.wait_time = choose(rate1)

func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.animation == 'attack':
		shoot_arrow()
		$AnimatedSprite.play('idle')

func take_damage(dmg):
	health -= dmg
	if health <= 0:
		get_tree().change_scene("res://WarDialogue.tscn")
	elif health <= max_health/2:
		phase = 2
		arrow_speed = 1000
		$Particles2D.process_material.color = Color(0, 0, 0)

func choose(array):
	array.shuffle()
	return array.front()

