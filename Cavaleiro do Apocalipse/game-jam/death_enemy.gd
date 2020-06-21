extends KinematicBody2D

export (int) var max_health = 950
export (int) var max_armor = 70

onready var health = max_health
onready var armor = max_armor

var mine = preload("res://DeathMine.tscn")

var phase = 1
var damage = 15
var direction
var player_position
var max_speed = 200
var speed_slow = 50
var speed = 0
var stance = 0
var color = Color(1, 0.772549, 0)
var max_mines = 4
var mines = 0
var mine_damage = 10
var slow_time = 4
var repulse = 1

func _ready():
	randomize()
	$CanvasLayer/HealthBar.max_value = max_health
	$CanvasLayer/HealthBar.value = health
	$CanvasLayer/Armor.max_value = max_armor
	$CanvasLayer/Armor.value = armor

	yield(get_tree().create_timer(3), "timeout")
	speed = max_speed

func _process(delta):
	$CanvasLayer/HealthBar.value = health
	$CanvasLayer/Armor.value = armor

	get_parent().get_node('Player').available_weapons = 4
	player_position = get_parent().get_node('Player').get_global_position()
	look_at(player_position)

	if repulse < 1:
		repulse += 1

	direction = (player_position - \
		self.get_global_position()).normalized()

	position += direction * speed * delta * repulse

func take_damage(dmg):
	if stance == 0:
		armor -= dmg
		if armor <= 0:
			stance = 1
			speed = speed_slow
			$Particles2D.process_material.color = Color(1, 1, 1)
			yield(get_tree().create_timer(slow_time), "timeout")
			stance = 0
			armor = max_armor
			speed = max_speed
			$Particles2D.process_material.color = color
	elif stance == 1:
		health -= dmg
		if health <= 0:
			get_tree().change_scene("res://End.tscn")
			pass
		elif health <= max_health/2:
			phase = 2
			max_mines = 6
			max_armor = 100
			max_speed = 300
			speed_slow = 100
			color = Color(0, 0, 0)

func _on_HitBox_body_entered(body):
	if body.is_in_group('player'):
		body.take_damage(damage)
		repulse = -10

func _on_Mine_timeout():
	plant_mine()
	$Mine.wait_time = choose([3, 3.5, 4])

func plant_mine():
	if mines < max_mines:
		var mine_instance = mine.instance()
		mine_instance.damage = mine_damage
		mine_instance.target = 'player'
		mine_instance.friends = 'death'
		mine_instance.position = self.get_global_position()
		mine_instance.pos = self.get_global_position()
		get_parent().add_child(mine_instance)
		mines += 1

func choose(array):
	array.shuffle()
	return array.front()
