extends RigidBody2D

var new_position
var direction
var speed
var damage
var target
var friends

func _process(delta):
	new_position = position + direction * speed * delta
	look_at(new_position)
	position = new_position

func _on_ConquestArrow_body_entered(body):
	if not body.is_in_group(friends) and not body.is_in_group('weapon'):
		if body.is_in_group(target):
			body.take_damage(damage)
		queue_free()
