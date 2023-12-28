extends CharacterBody2D

@export var acceleration := 10.0
@export var max_speed := 300.0
@export var rotation_speed := 250.0

func _process(_delta):
	pass


func _physics_process(delta):
	var input_vector := Vector2(0, Input.get_axis("thrust_forward", "thrust_reverse"))
	
	velocity += input_vector.rotated(rotation) * acceleration
	velocity = velocity.limit_length(max_speed)
	
	if Input.is_action_pressed("rotate_right"):
		rotate(deg_to_rad(rotation_speed * delta))
	if Input.is_action_pressed("rotate_left"):
		rotate(deg_to_rad(-rotation_speed * delta))
	
	if input_vector.y == 0:
		velocity = velocity.move_toward(Vector2.ZERO, 3)
	
	move_and_slide()
	
	if global_position.y < -1500:
		global_position.y = 2750
	elif global_position.y > 2750:
		global_position.y = -1500
	if global_position.x < -1500:
		global_position.x = 2250
	elif global_position.x > 2250:
		global_position.x = -1500
 	
