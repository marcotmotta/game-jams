extends RigidBody2D

var pos
var damage
var target
var friends

func _process(delta):
	#position = pos
	pass

func _on_DeathMine_body_entered(body):
	if not body.is_in_group(friends) and not body.is_in_group('weapon'):
		print(body)
		if body.is_in_group(target):
			body.take_damage(damage)
		get_parent().get_node('DeathEnemy').mines -= 1
		$Sprite.visible = false
		$CollisionShape2D.queue_free()
		$Particles2D.emitting = true
		$Timer.queue_free()
		yield(get_tree().create_timer(1), "timeout")
		queue_free()

func _on_Timer_timeout():
	get_parent().get_node('DeathEnemy').mines -= 1
	$Sprite.visible = false
	$CollisionShape2D.queue_free()
	$Particles2D.emitting = true
	yield(get_tree().create_timer(1), "timeout")
	queue_free()
