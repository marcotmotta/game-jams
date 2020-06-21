extends KinematicBody2D

var coin = preload("res://FamineCoin.tscn")

export (int) var max_health = 1800

onready var health = max_health

var coin_damage = 15
var coin_speed = 500

var stance = 1

var phase = 1
var rate1 = [1.5, 2, 2.5]
var rate2 = [1.2, 1.5, 2]

enum {
	LEFT,
	RIGHT,
	BOTH
}

func _ready():
	randomize()
	$CanvasLayer/HealthBar.max_value = max_health
	$CanvasLayer/HealthBar.value = health

	$AnimatedSprite.play('idle1')

func _process(delta):
	$CanvasLayer/HealthBar.value = health

	get_parent().get_node('Player').available_weapons = 3

func attack(attack_stance):
	$Attack.play()
	if phase == 2:
		var coin_instance = coin.instance()
		coin_instance.damage = coin_damage
		coin_instance.speed = coin_speed
		coin_instance.target = 'player'
		coin_instance.friends = 'famine'
		match attack_stance:
			1:
				coin_instance.position = $ShootLeft2.get_global_position()
			2:
				coin_instance.position = $ShootLeft1.get_global_position()
		coin_instance.direction = \
			(get_parent().get_node('Player').get_global_position() - \
			coin_instance.position).normalized()
		get_parent().add_child(coin_instance)
		var coin_instance2 = coin.instance()
		coin_instance2.damage = coin_damage
		coin_instance2.speed = coin_speed
		coin_instance2.target = 'player'
		coin_instance2.friends = 'famine'
		match attack_stance:
			1:
				coin_instance2.position = $ShootRight2.get_global_position()
			2:
				coin_instance2.position = $ShootRight1.get_global_position()
		coin_instance2.direction = \
			(get_parent().get_node('Player').get_global_position() - \
			coin_instance2.position).normalized()
		get_parent().add_child(coin_instance2)
	else:
		var coin_instance = coin.instance()
		coin_instance.damage = coin_damage
		coin_instance.speed = coin_speed
		coin_instance.target = 'player'
		coin_instance.friends = 'famine'
		var side = choose([LEFT, RIGHT])
		match attack_stance:
			1:
				match side:
					LEFT:
						coin_instance.position = $ShootLeft2.get_global_position()
					RIGHT:
						coin_instance.position = $ShootRight2.get_global_position()
			2:
				match side:
					LEFT:
						coin_instance.position = $ShootLeft1.get_global_position()
					RIGHT:
						coin_instance.position = $ShootRight1.get_global_position()
		coin_instance.direction = \
			(get_parent().get_node('Player').get_global_position() - \
			coin_instance.position).normalized()
		get_parent().add_child(coin_instance)

func _on_Timer_timeout():
	match stance:
		1:
			$AnimatedSprite.play('attack1')
			stance = 2
		2:
			$AnimatedSprite.play('attack2')
			stance = 1
	match phase:
		2:
			$Timer.wait_time = choose(rate2)
		_:
			$Timer.wait_time = choose(rate1)

func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.animation == 'attack1':
		attack(1)
		$AnimatedSprite.play('idle2')
		pass
	elif $AnimatedSprite.animation == 'attack2':
		attack(2)
		$AnimatedSprite.play('idle1')
		pass

func take_damage(dmg):
	health -= dmg
	if health <= 0:
		get_tree().change_scene("res://DeathDialogue.tscn")
		pass
	elif health <= max_health/2:
		phase = 2
		coin_speed = 750
		$Particles2D.process_material.color = Color(0, 0, 0)

func choose(array):
	array.shuffle()
	return array.front()
