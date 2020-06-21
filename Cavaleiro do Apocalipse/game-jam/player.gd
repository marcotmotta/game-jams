extends KinematicBody2D

export (int) var speed = 450
export (int) var max_health = 100

var dagger = preload("res://Dagger.tscn")
var arrow = preload("res://ArrowPlayer.tscn")
var sword = preload("res://WarSword.tscn")
var coin = preload("res://FamineCoin.tscn")

onready var health = max_health

var velocity = Vector2()
var facing
var can_shoot = true
var fire_rate = 0.6
var projectile = dagger
var projectile_damage
var projectile_speed
#var projectile_size = 1
var available_weapons = 5
var weapon = 1
var dead = false

func _ready():
	$CanvasLayer/HealthBar.max_value = max_health
	$CanvasLayer/HealthBar.value = health

func get_input():
	velocity = Vector2()
	if Input.is_action_pressed('right'):
		velocity.x += 1
	if Input.is_action_pressed('left'):
		velocity.x -= 1
	if Input.is_action_pressed('down'):
		velocity.y += 1
	if Input.is_action_pressed('up'):
		velocity.y -= 1

	velocity = velocity.normalized() * speed
	
	if Input.is_action_just_pressed('w1'):
		weapon = 1
		$CanvasLayer/Weapons/Dagger/ColorRect.color = Color(0, 1, 1, 0.5)
		$CanvasLayer/Weapons/Arrow/ColorRect.color = Color(1, 1, 1, 0.5)
		$CanvasLayer/Weapons/Sword/ColorRect.color = Color(1, 1, 1, 0.5)
		$CanvasLayer/Weapons/Coin/ColorRect.color = Color(1, 1, 1, 0.5)
		#$CanvasLayer/Weapons/Dagger/ColorRect.color = Color(1, 1, 1, 0.5)
	elif Input.is_action_just_pressed('w2') and available_weapons >= 2:
		weapon = 2
		$CanvasLayer/Weapons/Dagger/ColorRect.color = Color(1, 1, 1, 0.5)
		$CanvasLayer/Weapons/Arrow/ColorRect.color = Color(0, 1, 1, 0.5)
		$CanvasLayer/Weapons/Sword/ColorRect.color = Color(1, 1, 1, 0.5)
		$CanvasLayer/Weapons/Coin/ColorRect.color = Color(1, 1, 1, 0.5)
		#$CanvasLayer/Weapons/Dagger/ColorRect.color = Color(1, 1, 1, 0.5)
	elif Input.is_action_just_pressed('w3') and available_weapons >= 3:
		weapon = 3
		$CanvasLayer/Weapons/Dagger/ColorRect.color = Color(1, 1, 1, 0.5)
		$CanvasLayer/Weapons/Arrow/ColorRect.color = Color(1, 1, 1, 0.5)
		$CanvasLayer/Weapons/Sword/ColorRect.color = Color(0, 1, 1, 0.5)
		$CanvasLayer/Weapons/Coin/ColorRect.color = Color(1, 1, 1, 0.5)
		#$CanvasLayer/Weapons/Dagger/ColorRect.color = Color(1, 1, 1, 0.5)
	elif Input.is_action_just_pressed('w4') and available_weapons >= 4:
		weapon = 4
		$CanvasLayer/Weapons/Dagger/ColorRect.color = Color(1, 1, 1, 0.5)
		$CanvasLayer/Weapons/Arrow/ColorRect.color = Color(1, 1, 1, 0.5)
		$CanvasLayer/Weapons/Sword/ColorRect.color = Color(1, 1, 1, 0.5)
		$CanvasLayer/Weapons/Coin/ColorRect.color = Color(0, 1, 1, 0.5)
		#$CanvasLayer/Weapons/Dagger/ColorRect.color = Color(1, 1, 1, 0.5)
	elif Input.is_action_just_pressed('w5') and available_weapons >= 5:
		weapon = 5
		$CanvasLayer/Weapons/Dagger/ColorRect.color = Color(1, 1, 1, 0.5)
		$CanvasLayer/Weapons/Arrow/ColorRect.color = Color(1, 1, 1, 0.5)
		$CanvasLayer/Weapons/Sword/ColorRect.color = Color(1, 1, 1, 0.5)
		$CanvasLayer/Weapons/Coin/ColorRect.color = Color(1, 1, 1, 0.5)
		#$CanvasLayer/Weapons/Dagger/ColorRect.color = Color(0, 1, 1, 0.5)

func _physics_process(delta):
	get_input()

	$AnimatedSprite.set_flip_h(get_global_mouse_position().x < position.x)

	if velocity:
		$AnimatedSprite.play('run')
	else:
		$AnimatedSprite.play('idle')

	velocity = move_and_slide(velocity)

func _process(delta):
	$CanvasLayer/HealthBar.value = health

	if available_weapons < 4:
		$CanvasLayer/Weapons/Coin.visible = false
		if available_weapons < 3:
			$CanvasLayer/Weapons/Sword.visible = false
			if available_weapons < 2:
				$CanvasLayer/Weapons/Arrow.visible = false

	$ShootPosition.position = (get_global_mouse_position() - \
		self.get_global_position()).normalized()

	if Input.is_action_pressed("shoot") and can_shoot:
		match weapon:
			1:
				projectile = dagger
				projectile_damage = 10
				projectile_speed = 350
				#projectile_size = 1
				fire_rate = 0.8
			2:
				projectile = arrow
				projectile_damage = 25
				projectile_speed = 400
				#projectile_size = 0.5
				fire_rate = 1.8
			3:
				projectile = sword
				projectile_damage = 20
				projectile_speed = 850
				#projectile_size = 0.5
				fire_rate = 1.8
			4:
				projectile = coin
				projectile_damage = 5
				projectile_speed = 350
				#projectile_size = 0.5
				fire_rate = 0.6
			_:
				projectile = dagger
				projectile_damage = 10
				projectile_speed = 350
				#projectile_size = 1
				fire_rate = 0.8
		var projectile_instance = projectile.instance()
		projectile_instance.damage = projectile_damage
		projectile_instance.speed = projectile_speed
		#projectile_instance.get_node('Sprite').scale *= projectile_size
		#projectile_instance.get_node('CollisionShape2D').scale *= projectile_size
		projectile_instance.target = 'enemies'
		projectile_instance.friends = 'player'
		projectile_instance.position = $ShootPosition.get_global_position()
		projectile_instance.direction = \
			(projectile_instance.position - \
			self.get_global_position()).normalized()
		get_parent().add_child(projectile_instance)
		
		can_shoot = false
		yield(get_tree().create_timer(fire_rate), "timeout")
		can_shoot = true

func take_damage(dmg):
	$HitAudio.play()
	health -= dmg
	$Hit.emitting = false
	$Hit.emitting = true
	if health <= 0:
		dead = true
		get_tree().paused = true
		$Retry/AnimationPlayer.play("retry")
		pass

func _on_TextureRect_gui_input(event):
	if event is InputEventMouseButton and event.is_pressed() and dead:
		get_tree().reload_current_scene()
		get_tree().paused = false
