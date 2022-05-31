extends KinematicBody
enum State {
	SEARCHING,
	CHASING,
}
onready var anim_player = $principle/AnimationPlayer

func _ready():
	#for anim in anim_player.get_animation_list():
	#	anim_player.get_animation(anim).set_loop(true)
	anim_player.play("walk")
	

func _physics_process(delta):
	pass
	#move_and_slide(Vector3(0,0,-5))
